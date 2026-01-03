package com.luggmaps

import android.graphics.Color
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.LuggMapsViewManagerInterface
import com.facebook.react.viewmanagers.LuggMapsViewManagerDelegate

@ReactModule(name = LuggMapsViewManager.NAME)
class LuggMapsViewManager : SimpleViewManager<LuggMapsView>(),
  LuggMapsViewManagerInterface<LuggMapsView> {
  private val mDelegate: ViewManagerDelegate<LuggMapsView>

  init {
    mDelegate = LuggMapsViewManagerDelegate(this)
  }

  override fun getDelegate(): ViewManagerDelegate<LuggMapsView>? {
    return mDelegate
  }

  override fun getName(): String {
    return NAME
  }

  public override fun createViewInstance(context: ThemedReactContext): LuggMapsView {
    return LuggMapsView(context)
  }

  @ReactProp(name = "color")
  override fun setColor(view: LuggMapsView?, color: String?) {
    view?.setBackgroundColor(Color.parseColor(color))
  }

  companion object {
    const val NAME = "LuggMapsView"
  }
}
