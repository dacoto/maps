package com.luggmaps

import android.content.Context
import android.widget.FrameLayout
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.MapView as GoogleMapView
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng

class MapView(context: Context) : FrameLayout(context), OnMapReadyCallback {
    private val mapView: GoogleMapView = GoogleMapView(context)
    private var googleMap: GoogleMap? = null

    private var initialLatitude: Double = 37.7749
    private var initialLongitude: Double = -122.4194
    private var initialLatitudeDelta: Double = 0.0922
    private var zoomEnabled: Boolean = true
    private var scrollEnabled: Boolean = true
    private var rotateEnabled: Boolean = true
    private var pitchEnabled: Boolean = true

    init {
        addView(mapView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        mapView.onCreate(null)
        mapView.getMapAsync(this)
    }

    override fun onMapReady(map: GoogleMap) {
        googleMap = map
        updateMapSettings()
        updateCamera()
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
            val zoom = if (initialLatitudeDelta > 0) {
                (Math.log(360.0 / initialLatitudeDelta) / Math.log(2.0)).toFloat()
            } else {
                10f
            }

            val cameraPosition = CameraPosition.Builder()
                .target(LatLng(initialLatitude, initialLongitude))
                .zoom(zoom)
                .build()

            map.moveCamera(CameraUpdateFactory.newCameraPosition(cameraPosition))
        }
    }

    fun onResume() {
        mapView.onResume()
    }

    fun onPause() {
        mapView.onPause()
    }

    fun onDestroy() {
        mapView.onDestroy()
    }

    fun onLowMemory() {
        mapView.onLowMemory()
    }
}
