package com.luggmaps

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.MapMarkerViewManagerDelegate
import com.facebook.react.viewmanagers.MapMarkerViewManagerInterface

@ReactModule(name = MapMarkerManager.NAME)
class MapMarkerManager :
  SimpleViewManager<MapMarkerView>(),
  MapMarkerViewManagerInterface<MapMarkerView> {
  private val delegate: ViewManagerDelegate<MapMarkerView> = MapMarkerViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<MapMarkerView> = delegate

  override fun getName(): String = NAME

  override fun createViewInstance(context: ThemedReactContext): MapMarkerView = MapMarkerView(context)

  @ReactProp(name = "coordinate")
  override fun setCoordinate(view: MapMarkerView, value: ReadableMap?) {
    value?.let {
      val latitude = if (it.hasKey("latitude")) it.getDouble("latitude") else 0.0
      val longitude = if (it.hasKey("longitude")) it.getDouble("longitude") else 0.0
      view.setCoordinate(latitude, longitude)
    }
  }

  @ReactProp(name = "title")
  override fun setTitle(view: MapMarkerView, value: String?) {
    view.setTitle(value)
  }

  @ReactProp(name = "description")
  override fun setDescription(view: MapMarkerView, value: String?) {
    view.setDescription(value)
  }

  @ReactProp(name = "anchor")
  override fun setAnchor(view: MapMarkerView, value: ReadableMap?) {
    value?.let {
      val x = if (it.hasKey("x")) it.getDouble("x") else 0.5
      val y = if (it.hasKey("y")) it.getDouble("y") else 1.0
      view.setAnchor(x, y)
    }
  }

  companion object {
    const val NAME = "MapMarkerView"
  }
}
