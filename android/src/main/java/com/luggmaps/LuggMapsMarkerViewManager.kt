package com.luggmaps

import android.util.Log
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.LuggMapsMarkerViewManagerDelegate
import com.facebook.react.viewmanagers.LuggMapsMarkerViewManagerInterface

@ReactModule(name = LuggMapsMarkerViewManager.NAME)
class LuggMapsMarkerViewManager :
  ViewGroupManager<LuggMapsMarkerView>(),
  LuggMapsMarkerViewManagerInterface<LuggMapsMarkerView> {
  private val delegate: ViewManagerDelegate<LuggMapsMarkerView> = LuggMapsMarkerViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<LuggMapsMarkerView> = delegate
  override fun getName(): String = NAME
  override fun createViewInstance(context: ThemedReactContext): LuggMapsMarkerView = LuggMapsMarkerView(context)

  override fun onDropViewInstance(view: LuggMapsMarkerView) {
    super.onDropViewInstance(view)
    view.onDropViewInstance()
  }

  override fun onAfterUpdateTransaction(view: LuggMapsMarkerView) {
    super.onAfterUpdateTransaction(view)
    view.onAfterUpdateTransaction()
  }

  @ReactProp(name = "coordinate")
  override fun setCoordinate(view: LuggMapsMarkerView, value: ReadableMap?) {
    value?.let {
      val latitude = if (it.hasKey("latitude")) it.getDouble("latitude") else 0.0
      val longitude = if (it.hasKey("longitude")) it.getDouble("longitude") else 0.0
      view.setCoordinate(latitude, longitude)
    }
  }

  @ReactProp(name = "name")
  override fun setName(view: LuggMapsMarkerView, value: String?) {
    view.setName(value)
  }

  @ReactProp(name = "title")
  override fun setTitle(view: LuggMapsMarkerView, value: String?) {
    view.setTitle(value)
  }

  @ReactProp(name = "description")
  override fun setDescription(view: LuggMapsMarkerView, value: String?) {
    view.setDescription(value)
  }

  @ReactProp(name = "anchor")
  override fun setAnchor(view: LuggMapsMarkerView, value: ReadableMap?) {
    value?.let {
      val x = if (it.hasKey("x")) it.getDouble("x") else 0.5
      val y = if (it.hasKey("y")) it.getDouble("y") else 1.0
      view.setAnchor(x, y)
    }
  }

  companion object {
    const val NAME = "LuggMapsMarkerView"
  }
}
