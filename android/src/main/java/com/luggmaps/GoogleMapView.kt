package com.luggmaps

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.GoogleMapOptions
import com.google.android.gms.maps.MapView as GmsMapView
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.model.AdvancedMarkerOptions
import com.google.android.gms.maps.model.AdvancedMarkerOptions.CollisionBehavior
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Marker

class GoogleMapView(context: Context) :
  FrameLayout(context),
  OnMapReadyCallback {
  private var mapView: GmsMapView? = null
  private var googleMap: GoogleMap? = null
  private val markerMap: MutableMap<MapMarkerView, Marker> = mutableMapOf()
  private val pendingMarkers: MutableList<MapMarkerView> = mutableListOf()

  private var currentMapId: String? = null
  private var initialLatitude: Double = 37.7749
  private var initialLongitude: Double = -122.4194
  private var initialLatitudeDelta: Double = 0.0922
  private var zoomEnabled: Boolean = true
  private var scrollEnabled: Boolean = true
  private var rotateEnabled: Boolean = true
  private var pitchEnabled: Boolean = true

  companion object {
    const val DEMO_MAP_ID = "DEMO_MAP_ID"
  }

  fun setMapId(mapId: String?) {
    val newMapId = mapId ?: DEMO_MAP_ID
    if (newMapId == currentMapId) return

    currentMapId = newMapId
    setupMapView(newMapId)
  }

  private fun setupMapView(mapId: String) {
    mapView?.let {
      it.onDestroy()
      removeView(it)
    }

    googleMap = null
    markerMap.clear()

    val options = GoogleMapOptions().mapId(mapId)
    mapView =
      GmsMapView(context, options).also {
        addView(it, 0, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        it.onCreate(null)
        it.getMapAsync(this)
      }
  }

  override fun onMapReady(map: GoogleMap) {
    googleMap = map
    updateMapSettings()
    updateCamera()

    pendingMarkers.forEach { addMarkerToMap(it) }
    pendingMarkers.clear()
  }

  fun setInitialRegion(latitude: Double, longitude: Double, latitudeDelta: Double, longitudeDelta: Double) {
    initialLatitude = latitude
    initialLongitude = longitude
    initialLatitudeDelta = latitudeDelta
    updateCamera()
  }

  fun setZoomEnabled(enabled: Boolean) {
    zoomEnabled = enabled
    updateMapSettings()
  }

  fun setScrollEnabled(enabled: Boolean) {
    scrollEnabled = enabled
    updateMapSettings()
  }

  fun setRotateEnabled(enabled: Boolean) {
    rotateEnabled = enabled
    updateMapSettings()
  }

  fun setPitchEnabled(enabled: Boolean) {
    pitchEnabled = enabled
    updateMapSettings()
  }

  private fun updateMapSettings() {
    googleMap?.uiSettings?.apply {
      isZoomGesturesEnabled = zoomEnabled
      isScrollGesturesEnabled = scrollEnabled
      isRotateGesturesEnabled = rotateEnabled
      isTiltGesturesEnabled = pitchEnabled
    }
  }

  private fun updateCamera() {
    googleMap?.let { map ->
      val zoom =
        if (initialLatitudeDelta > 0) {
          (Math.log(360.0 / initialLatitudeDelta) / Math.log(2.0)).toFloat()
        } else {
          10f
        }

      val cameraPosition =
        CameraPosition
          .Builder()
          .target(LatLng(initialLatitude, initialLongitude))
          .zoom(zoom)
          .build()

      map.moveCamera(CameraUpdateFactory.newCameraPosition(cameraPosition))
    }
  }

  fun onResume() {
    mapView?.onResume()
  }

  fun onPause() {
    mapView?.onPause()
  }

  fun onDestroy() {
    mapView?.onDestroy()
  }

  fun onLowMemory() {
    mapView?.onLowMemory()
  }

  override fun addView(child: View?, index: Int) {
    if (child is MapMarkerView) {
      val map = googleMap
      if (map != null) {
        addMarkerToMap(child)
      } else {
        pendingMarkers.add(child)
      }
    } else {
      super.addView(child, index)
    }
  }

  override fun removeView(child: View?) {
    if (child is MapMarkerView) {
      markerMap[child]?.remove()
      markerMap.remove(child)
      pendingMarkers.remove(child)
    } else {
      super.removeView(child)
    }
  }

  private fun addMarkerToMap(mapMarkerView: MapMarkerView) {
    googleMap?.let { map ->
      val markerOptions =
        AdvancedMarkerOptions()
          .position(LatLng(mapMarkerView.latitude, mapMarkerView.longitude))
          .title(mapMarkerView.markerTitle)
          .snippet(mapMarkerView.markerDescription)
          .collisionBehavior(CollisionBehavior.REQUIRED)

      if (mapMarkerView.hasCustomView) {
        markerOptions.iconView(mapMarkerView.iconView)
      }

      val marker = map.addMarker(markerOptions)
      if (marker != null) {
        markerMap[mapMarkerView] = marker
      }
    }
  }
}
