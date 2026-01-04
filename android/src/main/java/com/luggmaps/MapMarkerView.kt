package com.luggmaps

import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.View
import com.facebook.react.views.view.ReactViewGroup

interface MapMarkerViewDelegate {
  fun markerViewDidUpdateProps(markerView: MapMarkerView)
  fun markerViewDidUpdateLayout(markerView: MapMarkerView)
}

class MapMarkerView(context: Context) : ReactViewGroup(context) {
  var delegate: MapMarkerViewDelegate? = null

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
  val hasCustomView: Boolean
    get() = childCount > 0

  init {
    setBackgroundColor(Color.TRANSPARENT)
  }

  fun setCoordinate(latitude: Double, longitude: Double) {
    this.latitude = latitude
    this.longitude = longitude
    delegate?.markerViewDidUpdateProps(this)
  }

  fun setTitle(title: String?) {
    this.markerTitle = title
    delegate?.markerViewDidUpdateProps(this)
  }

  fun setDescription(description: String?) {
    this.markerDescription = description
    delegate?.markerViewDidUpdateProps(this)
  }

  fun setAnchor(x: Double, y: Double) {
    anchorX = x.toFloat()
    anchorY = y.toFloat()
    delegate?.markerViewDidUpdateProps(this)
  }

  // override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
  //   super.onLayout(changed, left, top, right, bottom)
  //   Log.d(TAG, "onLayout - changed: $changed, childCount: $childCount, size: ${width}x${height}")

  //   if (!hasCustomView) {
  //     return
  //   }

  //   var maxWidth = 0
  //   var maxHeight = 0

  //   for (i in 0 until childCount) {
  //     val child = getChildAt(i)
  //     val fw = child.left + child.width
  //     val fh = child.top + child.height
  //     Log.d(TAG, "child[$i] - left: ${child.left}, top: ${child.top}, size: ${child.width}x${child.height}")
  //     maxWidth = maxOf(maxWidth, fw)
  //     maxHeight = maxOf(maxHeight, fh)
  //   }

  //   Log.d(TAG, "calculated size: ${maxWidth}x${maxHeight}, current: ${width}x${height}")

  //   if (maxWidth > 0 && maxHeight > 0 && (maxWidth != width || maxHeight != height)) {
  //     Log.d(TAG, "resizing to ${maxWidth}x${maxHeight}")
  //     layout(0, 0, maxWidth, maxHeight)
  //   }

  //   delegate?.markerViewDidUpdateLayout(this)
  // }

  companion object {
    const val TAG = "MapMarkerView"
  }

  override fun addView(child: View?, index: Int) {
    super.addView(child, index)
    Log.d(TAG, "addView - childCount: $childCount, markerView: ${width}x${height}, child: ${child?.width}x${child?.height}")
  }

  private fun updateSize() {
    if (!hasCustomView) {
      return
    }

    var maxWidth = 0
    var maxHeight = 0

    for (i in 0 until childCount) {
      val child = getChildAt(i)
      child.measure(
        MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
        MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
      )
      val fw = child.left + child.measuredWidth
      val fh = child.top + child.measuredHeight
      Log.d(TAG, "updateSize child[$i] - size: ${child.measuredWidth}x${child.measuredHeight}")
      maxWidth = maxOf(maxWidth, fw)
      maxHeight = maxOf(maxHeight, fh)
    }

    if (maxWidth > 0 && maxHeight > 0) {
      Log.d(TAG, "updateSize calculated ${maxWidth}x${maxHeight}, markerView: ${width}x${height}")
    }
  }

  override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
    super.onSizeChanged(w, h, oldw, oldh)
    Log.d(TAG, "onSizeChanged: ${w}x${h}, old: ${oldw}x${oldh}")
    
    if (!hasCustomView || childCount == 0) {
      return
    }

    var maxWidth = 0
    var maxHeight = 0

    for (i in 0 until childCount) {
      val child = getChildAt(i)
      val cw = child.width
      val ch = child.height
      if (cw == 0 || ch == 0) {
        child.measure(
          MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED),
          MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
        )
        maxWidth = maxOf(maxWidth, child.measuredWidth)
        maxHeight = maxOf(maxHeight, child.measuredHeight)
      } else {
        maxWidth = maxOf(maxWidth, cw)
        maxHeight = maxOf(maxHeight, ch)
      }
    }

    Log.d(TAG, "onSizeChanged calculated: ${maxWidth}x${maxHeight}, current: ${w}x${h}")
    
    if (maxWidth > 0 && maxHeight > 0 && (maxWidth != w || maxHeight != h)) {
      Log.d(TAG, "resizing markerView to ${maxWidth}x${maxHeight}")
      layoutParams?.let {
        it.width = maxWidth
        it.height = maxHeight
      }
    }
    
    if (maxWidth > 0 && maxHeight > 0) {
      delegate?.markerViewDidUpdateLayout(this)
    }
  }

}
