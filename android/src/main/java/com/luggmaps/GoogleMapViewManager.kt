package com.luggmaps

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.GoogleMapViewManagerDelegate
import com.facebook.react.viewmanagers.GoogleMapViewManagerInterface
import com.google.android.gms.maps.GoogleMapOptions

@ReactModule(name = GoogleMapViewManager.NAME)
class GoogleMapViewManager :
  ViewGroupManager<GoogleMapView>(),
  GoogleMapViewManagerInterface<GoogleMapView> {
  private val delegate: ViewManagerDelegate<GoogleMapView> = GoogleMapViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<GoogleMapView> = delegate

  override fun getName(): String = NAME

  override fun createViewInstance(context: ThemedReactContext): GoogleMapView {
    val options = GoogleMapOptions().mapId(DEMO_MAP_ID)
    return GoogleMapView(context, options)
  }

  @ReactProp(name = "mapId")
  override fun setMapId(view: GoogleMapView, value: String?) {
    view.setMapId(value)
  }

  @ReactProp(name = "initialCoordinate")
  override fun setInitialCoordinate(view: GoogleMapView, value: ReadableMap?) {
    value?.let {
      val latitude = if (it.hasKey("latitude")) it.getDouble("latitude") else 0.0
      val longitude = if (it.hasKey("longitude")) it.getDouble("longitude") else 0.0
      view.setInitialCoordinate(latitude, longitude)
    }
  }

  @ReactProp(name = "initialZoom", defaultDouble = 10.0)
  override fun setInitialZoom(view: GoogleMapView, value: Double) {
    view.setInitialZoom(value)
  }

  @ReactProp(name = "zoomEnabled", defaultBoolean = true)
  override fun setZoomEnabled(view: GoogleMapView, value: Boolean) {
    view.setZoomEnabled(value)
  }

  @ReactProp(name = "scrollEnabled", defaultBoolean = true)
  override fun setScrollEnabled(view: GoogleMapView, value: Boolean) {
    view.setScrollEnabled(value)
  }

  @ReactProp(name = "rotateEnabled", defaultBoolean = true)
  override fun setRotateEnabled(view: GoogleMapView, value: Boolean) {
    view.setRotateEnabled(value)
  }

  @ReactProp(name = "pitchEnabled", defaultBoolean = true)
  override fun setPitchEnabled(view: GoogleMapView, value: Boolean) {
    view.setPitchEnabled(value)
  }

  companion object {
    const val NAME = "GoogleMapView"
    const val DEMO_MAP_ID = "DEMO_MAP_ID"
  }
}
