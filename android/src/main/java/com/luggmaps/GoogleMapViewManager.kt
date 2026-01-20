package com.luggmaps

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.uimanager.PixelUtil.dpToPx
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.viewmanagers.GoogleMapViewManagerDelegate
import com.facebook.react.viewmanagers.GoogleMapViewManagerInterface
import com.google.android.gms.maps.model.LatLng
import com.luggmaps.events.CameraMoveEvent

@ReactModule(name = GoogleMapViewManager.NAME)
class GoogleMapViewManager :
  ViewGroupManager<GoogleMapView>(),
  GoogleMapViewManagerInterface<GoogleMapView>,
  GoogleMapViewEventDelegate {
  private val delegate: ViewManagerDelegate<GoogleMapView> = GoogleMapViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<GoogleMapView> = delegate

  override fun getName(): String = NAME

  override fun createViewInstance(context: ThemedReactContext): GoogleMapView {
    val view = GoogleMapView(context)
    view.eventDelegate = this
    return view
  }

  override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any> {
    return mapOf(
      "topCameraMove" to mapOf("registrationName" to "onCameraMove")
    )
  }

  override fun onCameraMove(view: GoogleMapView, latitude: Double, longitude: Double, zoom: Float) {
    val eventDispatcher = UIManagerHelper.getEventDispatcherForReactTag(
      view.context as ThemedReactContext,
      view.id
    )
    eventDispatcher?.dispatchEvent(CameraMoveEvent(UIManagerHelper.getSurfaceId(view), view.id, latitude, longitude, zoom))
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

  @ReactProp(name = "padding")
  override fun setPadding(view: GoogleMapView, value: ReadableMap?) {
    value?.let {
      val top = if (it.hasKey("top")) it.getDouble("top").toFloat().dpToPx().toInt() else 0
      val left = if (it.hasKey("left")) it.getDouble("left").toFloat().dpToPx().toInt() else 0
      val bottom = if (it.hasKey("bottom")) it.getDouble("bottom").toFloat().dpToPx().toInt() else 0
      val right = if (it.hasKey("right")) it.getDouble("right").toFloat().dpToPx().toInt() else 0
      view.setMapPadding(top, left, bottom, right)
    }
  }

  override fun onDropViewInstance(view: GoogleMapView) {
    super.onDropViewInstance(view)
    view.onDropViewInstance()
  }

  override fun moveCamera(
    view: GoogleMapView,
    latitude: Double,
    longitude: Double,
    zoom: Double,
    duration: Double
  ) {
    view.moveCamera(latitude, longitude, zoom, duration.toInt())
  }

  override fun fitCoordinates(view: GoogleMapView, coordinates: ReadableArray?, padding: Double, duration: Double) {
    val coords = mutableListOf<LatLng>()
    coordinates?.let {
      for (i in 0 until it.size()) {
        val coord = it.getMap(i)
        val lat = coord?.getDouble("latitude") ?: 0.0
        val lng = coord?.getDouble("longitude") ?: 0.0
        coords.add(LatLng(lat, lng))
      }
    }
    view.fitCoordinates(coords, padding.toInt(), duration.toInt())
  }

  companion object {
    const val NAME = "GoogleMapView"
  }
}
