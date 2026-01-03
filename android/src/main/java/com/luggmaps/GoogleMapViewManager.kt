package com.luggmaps

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.GoogleMapViewManagerDelegate
import com.facebook.react.viewmanagers.GoogleMapViewManagerInterface

@ReactModule(name = GoogleMapViewManager.NAME)
class GoogleMapViewManager :
  SimpleViewManager<GoogleMapView>(),
  GoogleMapViewManagerInterface<GoogleMapView> {
  private val delegate: ViewManagerDelegate<GoogleMapView> = GoogleMapViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<GoogleMapView> = delegate

  override fun getName(): String = NAME

  override fun createViewInstance(context: ThemedReactContext): GoogleMapView = GoogleMapView(context)

  @ReactProp(name = "mapId")
  override fun setMapId(view: GoogleMapView, value: String?) {
    view.setMapId(value)
  }

  @ReactProp(name = "initialRegion")
  override fun setInitialRegion(view: GoogleMapView, value: ReadableMap?) {
    value?.let {
      val latitude = if (it.hasKey("latitude")) it.getDouble("latitude") else 0.0
      val longitude = if (it.hasKey("longitude")) it.getDouble("longitude") else 0.0
      val latitudeDelta = if (it.hasKey("latitudeDelta")) it.getDouble("latitudeDelta") else 0.0
      val longitudeDelta = if (it.hasKey("longitudeDelta")) it.getDouble("longitudeDelta") else 0.0
      view.setInitialRegion(latitude, longitude, latitudeDelta, longitudeDelta)
    }
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
  }
}
