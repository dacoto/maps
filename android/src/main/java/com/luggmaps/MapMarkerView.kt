package com.luggmaps

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout

class MapMarkerView(context: Context) : FrameLayout(context) {
  var latitude: Double = 0.0
    private set
  var longitude: Double = 0.0
    private set
  var markerTitle: String? = null
    private set
  var markerDescription: String? = null
    private set
  var anchorX: Float = 0.5f
    private set
  var anchorY: Float = 1.0f
    private set
  var hasCustomView: Boolean = false
    private set

  private var _iconView: FrameLayout = FrameLayout(context)

  init {
    setBackgroundColor(Color.TRANSPARENT)
    _iconView.setBackgroundColor(Color.TRANSPARENT)
  }

  val iconView: FrameLayout
    get() = _iconView

  fun setCoordinate(latitude: Double, longitude: Double) {
    this.latitude = latitude
    this.longitude = longitude
  }

  fun setTitle(title: String?) {
    this.markerTitle = title
  }

  fun setDescription(description: String?) {
    this.markerDescription = description
  }

  fun setAnchor(x: Double, y: Double) {
    anchorX = x.toFloat()
    anchorY = y.toFloat()
  }

  override fun addView(child: View?, index: Int) {
    if (child != null) {
      _iconView.addView(child, index)
      hasCustomView = _iconView.childCount > 0
    }
  }

  override fun removeView(child: View?) {
    _iconView.removeView(child)
    hasCustomView = _iconView.childCount > 0
  }

  override fun removeViewAt(index: Int) {
    _iconView.removeViewAt(index)
    hasCustomView = _iconView.childCount > 0
  }
}
