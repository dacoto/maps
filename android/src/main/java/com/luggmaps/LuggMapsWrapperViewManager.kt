package com.luggmaps

import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.viewmanagers.LuggMapsWrapperViewManagerDelegate
import com.facebook.react.viewmanagers.LuggMapsWrapperViewManagerInterface

@ReactModule(name = LuggMapsWrapperViewManager.NAME)
class LuggMapsWrapperViewManager :
  ViewGroupManager<LuggMapsWrapperView>(),
  LuggMapsWrapperViewManagerInterface<LuggMapsWrapperView> {
  private val delegate: ViewManagerDelegate<LuggMapsWrapperView> = LuggMapsWrapperViewManagerDelegate(this)

  override fun getDelegate(): ViewManagerDelegate<LuggMapsWrapperView> = delegate

  override fun getName(): String = NAME

  override fun createViewInstance(context: ThemedReactContext): LuggMapsWrapperView = LuggMapsWrapperView(context)

  companion object {
    const val NAME = "LuggMapsWrapperView"
  }
}
