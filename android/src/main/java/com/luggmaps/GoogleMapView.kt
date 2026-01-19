package com.luggmaps

import android.annotation.SuppressLint
import android.util.Log
import android.view.View
import android.view.ViewGroup
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.util.RNLog
import com.facebook.react.views.view.ReactViewGroup
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.GoogleMapOptions
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.model.AdvancedMarker
import com.google.android.gms.maps.model.AdvancedMarkerOptions
import com.google.android.gms.maps.model.AdvancedMarkerOptions.CollisionBehavior
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.PolylineOptions

@SuppressLint("ViewConstructor")
class GoogleMapView(private val reactContext: ThemedReactContext) :
  ReactViewGroup(reactContext),
  OnMapReadyCallback,
  MarkerViewDelegate,
  PolylineViewDelegate {

  private var mapView: MapView? = null
  private var mapWrapperView: MapWrapperView? = null
  private var googleMap: GoogleMap? = null
  private var isMapReady = false
  private var mapId: String = DEMO_MAP_ID
  private val pendingMarkerViews = mutableListOf<MarkerView>()
  private val pendingPolylineViews = mutableListOf<PolylineView>()

  // Initial camera settings
  private var initialLatitude: Double = 37.78
  private var initialLongitude: Double = -122.43
  private var initialZoom: Float = 14f

  // UI settings
  private var zoomEnabled: Boolean = true
  private var scrollEnabled: Boolean = true
  private var rotateEnabled: Boolean = true
  private var pitchEnabled: Boolean = true

  // region View Lifecycle

  override fun addView(child: View?, index: Int) {
    super.addView(child, index)
    when (child) {
      is MapWrapperView -> mapWrapperView = child
      is MarkerView -> {
        child.delegate = this
        syncMarkerView(child)
      }
      is PolylineView -> {
        child.delegate = this
        syncPolylineView(child)
      }
    }
  }

  override fun removeViewAt(index: Int) {
    val view = getChildAt(index)
    if (view is MarkerView) {
      Log.d(TAG, "removing markerView: ${view.name}")
      view.marker?.remove()
      view.marker = null
    } else if (view is PolylineView) {
      view.polyline?.remove()
      view.polyline = null
    }
    super.removeViewAt(index)
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    if (mapView == null && mapWrapperView != null) {
      initializeMap()
    }
  }

  fun onDropViewInstance() {
    Log.d(TAG, "dropping mapView instance")
    pendingMarkerViews.clear()
    pendingPolylineViews.clear()
    googleMap?.clear()
    googleMap = null
    isMapReady = false
    mapView?.onPause()
    mapView?.onDestroy()
    mapView = null
    mapWrapperView = null
  }

  // endregion

  // region Map Initialization

  private fun initializeMap() {
    if (mapView != null || mapWrapperView == null) return

    val options = GoogleMapOptions().mapId(mapId)
    mapView = MapView(context, options).also { view ->
      view.onCreate(null)
      view.onResume()
      view.getMapAsync(this)
      mapWrapperView?.addView(
        view,
        LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
      )
    }
  }

  override fun onMapReady(map: GoogleMap) {
    googleMap = map
    isMapReady = true

    val position = LatLng(initialLatitude, initialLongitude)
    map.moveCamera(CameraUpdateFactory.newLatLngZoom(position, initialZoom))

    applyUiSettings()
    processPendingMarkers()
    processPendingPolylines()
  }

  private fun applyUiSettings() {
    googleMap?.uiSettings?.apply {
      isZoomGesturesEnabled = zoomEnabled
      isScrollGesturesEnabled = scrollEnabled
      isRotateGesturesEnabled = rotateEnabled
      isTiltGesturesEnabled = pitchEnabled
    }
  }

  // endregion

  // region PolylineViewDelegate

  override fun polylineViewDidUpdate(polylineView: PolylineView) {
    syncPolylineView(polylineView)
  }

  // endregion

  // region MarkerViewDelegate

  override fun markerViewDidLayout(markerView: MarkerView) {
    if (googleMap == null) {
      if (!pendingMarkerViews.contains(markerView)) {
        pendingMarkerViews.add(markerView)
      }
      return
    }

    // Recreate marker with custom view
    markerView.marker?.remove()
    addMarkerViewToMap(markerView)
  }

  override fun markerViewDidUpdate(markerView: MarkerView) {
    syncMarkerView(markerView)
  }

  // endregion

  // region Marker Management

  private fun syncMarkerView(markerView: MarkerView) {
    // Custom views are handled in markerViewDidLayout
    if (markerView.hasCustomView) return

    if (googleMap == null) {
      if (!pendingMarkerViews.contains(markerView)) {
        pendingMarkerViews.add(markerView)
      }
      return
    }

    if (markerView.marker == null) {
      addMarkerViewToMap(markerView)
      return
    }

    markerView.marker?.apply {
      position = LatLng(markerView.latitude, markerView.longitude)
      title = markerView.title
      snippet = markerView.description
      setAnchor(markerView.anchorX, markerView.anchorY)
    }
  }

  private fun processPendingMarkers() {
    if (googleMap == null) return

    Log.d(TAG, "processing pending markers ${pendingMarkerViews.size}")
    pendingMarkerViews.forEach { addMarkerViewToMap(it) }
    pendingMarkerViews.clear()
  }

  private fun addMarkerViewToMap(markerView: MarkerView) {
    val map = googleMap ?: run {
      RNLog.w(reactContext, "LuggMaps: addMarkerViewToMap called without a map")
      return
    }

    val position = LatLng(markerView.latitude, markerView.longitude)
    val iconView = markerView.iconView

    (iconView.parent as? ViewGroup)?.removeView(iconView)

    val options = AdvancedMarkerOptions()
      .position(position)
      .title(markerView.title)
      .snippet(markerView.description)
      .collisionBehavior(CollisionBehavior.REQUIRED)

    Log.d(TAG, "adding marker: ${markerView.name} customview: ${markerView.hasCustomView}")
    if (markerView.hasCustomView) {
      options.iconView(iconView)
    }

    val marker = map.addMarker(options) as AdvancedMarker
    marker.setAnchor(markerView.anchorX, markerView.anchorY)

    markerView.marker = marker
  }

  // endregion

  // region Polyline Management

  private fun syncPolylineView(polylineView: PolylineView) {
    if (googleMap == null) {
      if (!pendingPolylineViews.contains(polylineView)) {
        pendingPolylineViews.add(polylineView)
      }
      return
    }

    if (polylineView.polyline == null) {
      addPolylineViewToMap(polylineView)
      return
    }

    val density = resources.displayMetrics.density
    polylineView.polyline?.apply {
      points = polylineView.coordinates
      color = polylineView.strokeColor
      width = polylineView.strokeWidth * density
    }
  }

  private fun processPendingPolylines() {
    if (googleMap == null) return

    pendingPolylineViews.forEach { addPolylineViewToMap(it) }
    pendingPolylineViews.clear()
  }

  private fun addPolylineViewToMap(polylineView: PolylineView) {
    val map = googleMap ?: return

    val density = resources.displayMetrics.density
    val options = PolylineOptions()
      .addAll(polylineView.coordinates)
      .color(polylineView.strokeColor)
      .width(polylineView.strokeWidth * density)

    polylineView.polyline = map.addPolyline(options)
  }

  // endregion

  // region Property Setters

  fun setMapId(value: String?) {
    if (value.isNullOrEmpty()) return

    if (mapView != null) {
      RNLog.w(reactContext, "LuggMaps: mapId cannot be changed after map is initialized")
      return
    }

    mapId = value
  }

  fun setInitialCoordinate(latitude: Double, longitude: Double) {
    initialLatitude = latitude
    initialLongitude = longitude
  }

  fun setInitialZoom(zoom: Double) {
    initialZoom = zoom.toFloat()
  }

  fun setZoomEnabled(enabled: Boolean) {
    zoomEnabled = enabled
    googleMap?.uiSettings?.isZoomGesturesEnabled = enabled
  }

  fun setScrollEnabled(enabled: Boolean) {
    scrollEnabled = enabled
    googleMap?.uiSettings?.isScrollGesturesEnabled = enabled
  }

  fun setRotateEnabled(enabled: Boolean) {
    rotateEnabled = enabled
    googleMap?.uiSettings?.isRotateGesturesEnabled = enabled
  }

  fun setPitchEnabled(enabled: Boolean) {
    pitchEnabled = enabled
    googleMap?.uiSettings?.isTiltGesturesEnabled = enabled
  }

  // endregion

  // region Commands

  fun moveCamera(latitude: Double, longitude: Double, zoom: Double, duration: Int) {
    val map = googleMap ?: return
    val position = LatLng(latitude, longitude)
    val cameraUpdate = CameraUpdateFactory.newLatLngZoom(position, zoom.toFloat())
    when {
      duration < 0 -> map.animateCamera(cameraUpdate)
      duration > 0 -> map.animateCamera(cameraUpdate, duration, null)
      else -> map.moveCamera(cameraUpdate)
    }
  }

  // endregion

  companion object {
    private const val TAG = "LuggMaps"
    const val DEMO_MAP_ID = "DEMO_MAP_ID"
  }
}
