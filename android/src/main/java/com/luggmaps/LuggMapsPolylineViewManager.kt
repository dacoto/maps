package com.luggmaps

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.LuggMapsPolylineViewManagerDelegate
import com.facebook.react.viewmanagers.LuggMapsPolylineViewManagerInterface
import com.google.android.gms.maps.model.LatLng

@ReactModule(name = LuggMapsPolylineViewManager.NAME)
class LuggMapsPolylineViewManager :
  ViewGroupManager<LuggMapsPolylineView>(),
  LuggMapsPolylineViewManagerInterface<LuggMapsPolylineView> {
  private val delegate: ViewManagerDelegate<LuggMapsPolylineView> = LuggMapsPolylineViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<LuggMapsPolylineView> = delegate
  override fun getName(): String = NAME
  override fun createViewInstance(context: ThemedReactContext): LuggMapsPolylineView = LuggMapsPolylineView(context)

  override fun onDropViewInstance(view: LuggMapsPolylineView) {
    super.onDropViewInstance(view)
    view.onDropViewInstance()
  }

  override fun onAfterUpdateTransaction(view: LuggMapsPolylineView) {
    super.onAfterUpdateTransaction(view)
    view.onAfterUpdateTransaction()
  }

  @ReactProp(name = "coordinates")
  override fun setCoordinates(view: LuggMapsPolylineView, value: ReadableArray?) {
    value?.let { array ->
      val coords = mutableListOf<LatLng>()
      for (i in 0 until array.size()) {
        val coord = array.getMap(i)
        val lat = coord?.getDouble("latitude") ?: 0.0
        val lng = coord?.getDouble("longitude") ?: 0.0
        coords.add(LatLng(lat, lng))
      }
      view.setCoordinates(coords)
    }
  }

  @ReactProp(name = "strokeColors")
  override fun setStrokeColors(view: LuggMapsPolylineView, value: ReadableArray?) {
    val colors = mutableListOf<Int>()
    value?.let { array ->
      for (i in 0 until array.size()) {
        colors.add(array.getInt(i))
      }
    }
    view.setStrokeColors(colors)
  }

  @ReactProp(name = "strokeWidth", defaultDouble = 1.0)
  override fun setStrokeWidth(view: LuggMapsPolylineView, value: Double) {
    view.setStrokeWidth(value.toFloat())
  }

  @ReactProp(name = "animated", defaultBoolean = false)
  override fun setAnimated(view: LuggMapsPolylineView, value: Boolean) {
    view.setAnimated(value)
  }

  companion object {
    const val NAME = "LuggMapsPolylineView"
  }
}
