package com.luggmaps

import android.content.Context
import android.util.Log
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.GoogleMapOptions
import com.google.android.gms.maps.MapView
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.model.AdvancedMarkerOptions
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker

class GoogleMapView(context: Context, options: GoogleMapOptions) :
  MapView(context, options),
  OnMapReadyCallback,
  MapMarkerViewDelegate {
  private var googleMap: GoogleMap? = null
  private var isMapReady = false
  private val markerMap: MutableMap<MapMarkerView, Marker> = mutableMapOf()
  private val pendingMarkers: MutableList<MapMarkerView> = mutableListOf()

  private var initialLatitude: Double = 37.7749
  private var initialLongitude: Double = -122.4194
  private var initialZoom: Double = 10.0

  constructor(context: Context) : this(context, GoogleMapOptions())

  init {
    onCreate(null)
    getMapAsync(this)
  }

  override fun requestLayout() {
    super.requestLayout()
    if (isMapReady && width > 0 && height > 0) {
      measure(
        MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY),
        MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY)
      )
      layout(left, top, right, bottom)
    }
  }

  override fun onMapReady(map: GoogleMap) {
    googleMap = map
    isMapReady = true
    map.moveCamera(CameraUpdateFactory.newLatLngZoom(LatLng(initialLatitude, initialLongitude), initialZoom.toFloat()))

    pendingMarkers.forEach { addMarkerToMap(it) }
    pendingMarkers.clear()
  }

  fun setMapId(mapId: String?) {
    // mapId must be set via GoogleMapOptions in constructor
  }

  fun setInitialCoordinate(latitude: Double, longitude: Double) {
    initialLatitude = latitude
    initialLongitude = longitude
  }

  fun setInitialZoom(zoom: Double) {
    initialZoom = zoom
  }

  fun setZoomEnabled(enabled: Boolean) {
    googleMap?.uiSettings?.isZoomGesturesEnabled = enabled
  }

  fun setScrollEnabled(enabled: Boolean) {
    googleMap?.uiSettings?.isScrollGesturesEnabled = enabled
  }

  fun setRotateEnabled(enabled: Boolean) {
    googleMap?.uiSettings?.isRotateGesturesEnabled = enabled
  }

  fun setPitchEnabled(enabled: Boolean) {
    googleMap?.uiSettings?.isTiltGesturesEnabled = enabled
  }

  override fun addView(child: android.view.View?, index: Int) {
    if (child is MapMarkerView) {
      child.delegate = this
      if (!child.hasCustomView) {
        // Regular markers can be added immediately
        if (googleMap != null) {
          addMarkerToMap(child)
        } else {
          pendingMarkers.add(child)
        }
      }
      // Custom view markers will be added in markerViewDidUpdateLayout after layout
    } else {
      super.addView(child, index)
    }
  }

  override fun removeView(child: android.view.View?) {
    if (child is MapMarkerView) {
      child.delegate = null
      markerMap[child]?.remove()
      markerMap.remove(child)
      pendingMarkers.remove(child)
    } else {
      super.removeView(child)
    }
  }

  override fun markerViewDidUpdateProps(markerView: MapMarkerView) {
    markerMap[markerView]?.position = LatLng(markerView.latitude, markerView.longitude)
  }

  override fun markerViewDidUpdateLayout(markerView: MapMarkerView) {
    Log.d(TAG, "markerViewDidUpdateLayout - googleMap: ${googleMap != null}, hasCustomView: ${markerView.hasCustomView}, inMap: ${markerMap.containsKey(markerView)}")
    if (googleMap == null) {
      if (!pendingMarkers.contains(markerView)) {
        Log.d(TAG, "adding to pendingMarkers")
        pendingMarkers.add(markerView)
      }
      return
    }

    if (!markerMap.containsKey(markerView)) {
      Log.d(TAG, "adding marker to map")
      addMarkerToMap(markerView)
    }
    // Marker already on map - iconView updates automatically
  }

  companion object {
    const val TAG = "GoogleMapView"
  }

  private fun addMarkerToMap(markerView: MapMarkerView) {
    googleMap?.let { map ->
      val options = AdvancedMarkerOptions()
        .position(LatLng(markerView.latitude, markerView.longitude))

      if (markerView.hasCustomView) {
        options.iconView(markerView)
      }

      map.addMarker(options)?.let { marker ->
        markerMap[markerView] = marker
      }
    }
  }
}
