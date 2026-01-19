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

@SuppressLint("ViewConstructor")
class GoogleMapView(private val reactContext: ThemedReactContext) :
  ReactViewGroup(reactContext),
  OnMapReadyCallback,
  MapMarkerDelegate {

  private var mapView: MapView? = null
  private var mapWrapperView: MapWrapperView? = null
  private var googleMap: GoogleMap? = null
  private var isMapReady = false
  private var mapId: String = DEMO_MAP_ID
  private val pendingMarkerViews = mutableListOf<MapMarkerView>()

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
      is MapMarkerView -> child.delegate = this
    }
  }

  override fun removeViewAt(index: Int) {
    val view = getChildAt(index)
    if (view is MapMarkerView) {
      Log.d(TAG, "removing markerView: ${view.name}")
      view.marker?.remove()
      view.marker = null
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

  // region MapMarkerDelegate

  override fun markerViewDidLayout(markerView: MapMarkerView) {
    syncMarkerView(markerView, "markerViewDidLayout")
  }

  override fun markerViewDidUpdate(markerView: MapMarkerView) {
    syncMarkerView(markerView, "markerViewDidUpdate")
  }

  // endregion

  // region Marker Management

  private fun syncMarkerView(markerView: MapMarkerView, caller: String) {
    if (googleMap == null) {
      if (!pendingMarkerViews.contains(markerView)) {
        Log.d(TAG, "$caller: ${markerView.name} - added to pending markers")
        pendingMarkerViews.add(markerView)
      }
      return
    }

    if (markerView.marker == null) {
      Log.d(TAG, "$caller: ${markerView.name} - adding to map")
      addMarkerViewToMap(markerView)
      return
    }

    Log.d(TAG, "$caller: ${markerView.name} hasCustomView: ${markerView.hasCustomView}")

    // Recreate the marker when it has a custom view
    if (markerView.hasCustomView) {
      markerView.marker?.remove()
      addMarkerViewToMap(markerView)
      return
    }

    markerView.marker?.apply {
      position = LatLng(markerView.latitude, markerView.longitude)
      title = markerView.title
      snippet = markerView.description
      setAnchor(markerView.anchorX, markerView.anchorY)
      iconView = null
    }
  }

  private fun processPendingMarkers() {
    if (googleMap == null) return

    Log.d(TAG, "processing pending markers ${pendingMarkerViews.size}")
    pendingMarkerViews.forEach { addMarkerViewToMap(it) }
    pendingMarkerViews.clear()
  }

  private fun addMarkerViewToMap(markerView: MapMarkerView) {
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

  companion object {
    private const val TAG = "LuggMaps"
    const val DEMO_MAP_ID = "DEMO_MAP_ID"
  }
}
