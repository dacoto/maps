package com.luggmaps

import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.viewmanagers.MapWrapperViewManagerDelegate
import com.facebook.react.viewmanagers.MapWrapperViewManagerInterface

@ReactModule(name = MapWrapperViewManager.NAME)
class MapWrapperViewManager :
  ViewGroupManager<MapWrapperView>(),
  MapWrapperViewManagerInterface<MapWrapperView> {
  private val delegate: ViewManagerDelegate<MapWrapperView> = MapWrapperViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<MapWrapperView> = delegate

  override fun getName(): String = NAME

  override fun createViewInstance(context: ThemedReactContext): MapWrapperView = MapWrapperView(context)

  companion object {
    const val NAME = "MapWrapperView"
  }
}
