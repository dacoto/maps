package com.luggmaps

import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.PolylineViewManagerDelegate
import com.facebook.react.viewmanagers.PolylineViewManagerInterface
import com.google.android.gms.maps.model.LatLng

@ReactModule(name = PolylineViewManager.NAME)
class PolylineViewManager :
  ViewGroupManager<PolylineView>(),
  PolylineViewManagerInterface<PolylineView> {
  private val delegate: ViewManagerDelegate<PolylineView> = PolylineViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<PolylineView> = delegate
  override fun getName(): String = NAME
  override fun createViewInstance(context: ThemedReactContext): PolylineView = PolylineView(context)

  override fun onDropViewInstance(view: PolylineView) {
    super.onDropViewInstance(view)
    view.onDropViewInstance()
  }

  override fun onAfterUpdateTransaction(view: PolylineView) {
    super.onAfterUpdateTransaction(view)
    view.onAfterUpdateTransaction()
  }

  @ReactProp(name = "coordinates")
  override fun setCoordinates(view: PolylineView, value: ReadableArray?) {
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
  override fun setStrokeColors(view: PolylineView, value: ReadableArray?) {
    val colors = mutableListOf<Int>()
    value?.let { array ->
      for (i in 0 until array.size()) {
        colors.add(array.getInt(i))
      }
    }
    view.setStrokeColors(colors)
  }

  @ReactProp(name = "strokeWidth", defaultDouble = 1.0)
  override fun setStrokeWidth(view: PolylineView, value: Double) {
    view.setStrokeWidth(value.toFloat())
  }

  companion object {
    const val NAME = "PolylineView"
  }
}
