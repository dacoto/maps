package com.luggmaps

import android.util.Log
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.MarkerViewManagerDelegate
import com.facebook.react.viewmanagers.MarkerViewManagerInterface

@ReactModule(name = MarkerViewManager.NAME)
class MarkerViewManager :
  ViewGroupManager<MarkerView>(),
  MarkerViewManagerInterface<MarkerView> {
  private val delegate: ViewManagerDelegate<MarkerView> = MarkerViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<MarkerView> = delegate
  override fun getName(): String = NAME
  override fun createViewInstance(context: ThemedReactContext): MarkerView = MarkerView(context)

  override fun onDropViewInstance(view: MarkerView) {
    super.onDropViewInstance(view)
    view.onDropViewInstance()
  }

  override fun onAfterUpdateTransaction(view: MarkerView) {
    super.onAfterUpdateTransaction(view)
    view.onAfterUpdateTransaction()
  }

  @ReactProp(name = "coordinate")
  override fun setCoordinate(view: MarkerView, value: ReadableMap?) {
    value?.let {
      val latitude = if (it.hasKey("latitude")) it.getDouble("latitude") else 0.0
      val longitude = if (it.hasKey("longitude")) it.getDouble("longitude") else 0.0
      view.setCoordinate(latitude, longitude)
    }
  }

  @ReactProp(name = "name")
  override fun setName(view: MarkerView, value: String?) {
    view.setName(value)
  }

  @ReactProp(name = "title")
  override fun setTitle(view: MarkerView, value: String?) {
    view.setTitle(value)
  }

  @ReactProp(name = "description")
  override fun setDescription(view: MarkerView, value: String?) {
    view.setDescription(value)
  }

  @ReactProp(name = "anchor")
  override fun setAnchor(view: MarkerView, value: ReadableMap?) {
    value?.let {
      val x = if (it.hasKey("x")) it.getDouble("x") else 0.5
      val y = if (it.hasKey("y")) it.getDouble("y") else 1.0
      view.setAnchor(x, y)
    }
  }

  companion object {
    const val NAME = "MarkerView"
  }
}
