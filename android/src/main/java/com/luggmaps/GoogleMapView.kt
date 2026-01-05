package com.luggmaps

import android.annotation.SuppressLint
import android.util.Log
import android.view.View
import android.view.ViewGroup
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.views.view.ReactViewGroup
import com.facebook.react.util.RNLog
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

  override fun addView(child: View?, index: Int) {
    super.addView(child, index)
    if (child is MapWrapperView) {
      mapWrapperView = child
    }

    if (child is MapMarkerView) {
      child.delegate = this
    }
  }

  override fun removeViewAt(index: Int) {
    val view = getChildAt(index)
    if (view is MapMarkerView) {
      Log.d(TAG, "removing markerView: ${view.name}")
      view.marker?.iconView = null
      view.marker?.remove()
      view.marker = null
    }
    super.removeViewAt(index)
  }

  override fun markerViewDidLayout(markerView: MapMarkerView) {
    if (googleMap == null) {
      // Queue pending markers until map becomes available
      if (!pendingMarkerViews.contains(markerView)) {
        Log.d(TAG, "markerViewDidLayout: ${markerView.name} - added to pending markers ${markerView.marker}")
        pendingMarkerViews.add(markerView)
      }
      return
    }

    // Add directly to the map if no marker is attached to the view
    if (markerView.marker == null) {
      Log.d(TAG, "markerViewDidLayout ${markerView.name} - adding to map")
      addMarkerViewToMap(markerView)
      return
    }

    Log.d(TAG, "markerViewDidLayout ${markerView.name} ${markerView}")

    markerView.marker?.position = LatLng(markerView.latitude, markerView.longitude)
    markerView.marker?.title = markerView.title
    markerView.marker?.snippet = markerView.description
    markerView.marker?.setAnchor(markerView.anchorX, markerView.anchorY)

    markerView.marker?.iconView = null
    if (markerView.hasCustomView) {
      (markerView.iconView.parent as? ViewGroup)?.removeView(markerView.iconView)
      markerView.marker?.iconView = markerView.iconView
    }
  }

  override fun markerViewDidUpdate(markerView: MapMarkerView) {
    if (googleMap == null) {
      // Queue pending markers until map becomes available
      if (!pendingMarkerViews.contains(markerView)) {
        Log.d(TAG, "markerViewDidUpdate: ${markerView.name} - added to pending markers ${markerView.marker}")
        pendingMarkerViews.add(markerView)
      }
      return
    }

    // Add directly to the map if no marker is attached to the view
    if (markerView.marker == null) {
      Log.d(TAG, "markerViewDidUpdate ${markerView.name} - adding to map")
      addMarkerViewToMap(markerView)
      return
    }

    Log.d(TAG, "markerViewDidUpdate ${markerView.name} ${markerView}")

    markerView.marker?.position = LatLng(markerView.latitude, markerView.longitude)
    markerView.marker?.title = markerView.title
    markerView.marker?.snippet = markerView.description
    markerView.marker?.setAnchor(markerView.anchorX, markerView.anchorY)

    markerView.marker?.iconView = null
    if (markerView.hasCustomView) {
      (markerView.iconView.parent as? ViewGroup)?.removeView(markerView.iconView)
      markerView.marker?.iconView = markerView.iconView
    }
  }

  override fun onAttachedToWindow() {
    super.onAttachedToWindow()
    if (mapView == null && mapWrapperView != null) {
      initializeMap()
    }
  }

  fun onDropViewInstance() {
    pendingMarkerViews.clear()
    mapView?.onPause()
    mapView?.onDestroy()
    mapView = null
    mapWrapperView = null
    googleMap = null
    isMapReady = false
  }

  private fun initializeMap() {
    if (mapView != null || mapWrapperView == null) return

    val options = GoogleMapOptions().mapId(mapId)

    mapView = MapView(context, options).also {
      it.onCreate(null)
      it.onResume()
      it.getMapAsync(this)

      mapWrapperView?.addView(it, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
    }
  }

  override fun onMapReady(map: GoogleMap) {
    googleMap = map
    isMapReady = true

    val position = LatLng(37.78, -122.43)
    map.moveCamera(CameraUpdateFactory.newLatLngZoom(position, 12f))
    processPendingMarkers()
  }

  fun processPendingMarkers() {
    if (googleMap == null) return

    Log.d(TAG, "processing pending markers ${pendingMarkerViews.size}")

    for (markerView in pendingMarkerViews) {
      addMarkerViewToMap(markerView)
    }

    pendingMarkerViews.clear()
  }

  fun addMarkerViewToMap(markerView: MapMarkerView) {
    if (googleMap == null) {
      RNLog.w(reactContext, "LuggMaps: addMarkerViewToMap called without a map")
      return
    }

    val position = LatLng(markerView.latitude, markerView.longitude)
    val options = AdvancedMarkerOptions()
      .position(position)
      .title(markerView.title)
      .snippet(markerView.description)
      .anchor(markerView.anchorX, markerView.anchorY)
      .collisionBehavior(CollisionBehavior.REQUIRED)

    Log.d(TAG, "adding marker: ${markerView.name} customview: ${markerView.hasCustomView} ${markerView}")
    if (markerView.hasCustomView) {
      (markerView.iconView.parent as? ViewGroup)?.removeView(markerView.iconView)
      options.iconView(markerView.iconView)
    }

    markerView.marker = googleMap?.addMarker(options) as? AdvancedMarker
  }

  fun setMapId(value: String?) {
    if (value.isNullOrEmpty()) return

    if (mapView != null) {
      RNLog.w(reactContext, "LuggMaps: mapId cannot be changed after map is initialized")
      return
    }

    mapId = value
  }

  companion object {
    private const val TAG = "LuggMaps"
    const val DEMO_MAP_ID = "DEMO_MAP_ID"
  }

  fun setInitialCoordinate(latitude: Double, longitude: Double) {
  }

  fun setInitialZoom(zoom: Double) {
  }

  fun setZoomEnabled(enabled: Boolean) {
  }

  fun setScrollEnabled(enabled: Boolean) {
  }

  fun setRotateEnabled(enabled: Boolean) {
  }

  fun setPitchEnabled(enabled: Boolean) {
  }
}
