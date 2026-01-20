package com.luggmaps.core

import android.animation.ValueAnimator
import android.graphics.Color
import android.view.animation.LinearInterpolator
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Polyline
import com.google.android.gms.maps.model.StrokeStyle
import com.google.android.gms.maps.model.StyleSpan
import kotlin.math.floor
import kotlin.math.max
import kotlin.math.min

class PolylineAnimator {
  var polyline: Polyline? = null
  var coordinates: List<LatLng> = emptyList()
  var strokeColors: List<Int> = listOf(Color.BLACK)
  var strokeWidth: Float = 1f

  var animated: Boolean = false
    set(value) {
      if (field == value) return
      field = value
      if (value) {
        startAnimation()
      } else {
        stopAnimation()
        update()
      }
    }

  private var animator: ValueAnimator? = null
  private var animationProgress: Float = 0f

  fun update() {
    if (animated) return

    val poly = polyline ?: return
    if (coordinates.size < 2) return

    poly.points = coordinates

    if (strokeColors.size > 1) {
      poly.setSpans(createGradientSpans())
    } else {
      poly.color = strokeColors.firstOrNull() ?: Color.BLACK
    }
  }

  private fun startAnimation() {
    if (animator != null) return

    animator = ValueAnimator.ofFloat(0f, 2.15f).apply {
      duration = 3650 // ~1.75s per phase * 2 + pause
      repeatCount = ValueAnimator.INFINITE
      interpolator = LinearInterpolator()
      addUpdateListener { animation ->
        animationProgress = animation.animatedValue as Float
        updateAnimatedPolyline()
      }
      start()
    }
  }

  private fun stopAnimation() {
    animator?.cancel()
    animator = null
  }

  private fun updateAnimatedPolyline() {
    val poly = polyline ?: return
    if (coordinates.size < 2) {
      poly.points = coordinates
      return
    }

    val segmentCount = coordinates.size - 1
    val progress = min(animationProgress, 2f)

    val headPos: Float
    val tailPos: Float

    if (progress <= 1f) {
      tailPos = 0f
      headPos = progress * segmentCount
    } else {
      val shrinkProgress = progress - 1f
      tailPos = shrinkProgress * segmentCount
      headPos = segmentCount.toFloat()
    }

    if (headPos <= tailPos || coordinates.isEmpty()) {
      poly.setSpans(emptyList())
      poly.points = listOf(coordinates.firstOrNull() ?: LatLng(0.0, 0.0))
      return
    }

    val startIndex = floor(tailPos).toInt()
    val endIndex = kotlin.math.ceil(headPos.toDouble()).toInt()
    val visibleLength = headPos - tailPos

    val points = mutableListOf<LatLng>()
    val spans = mutableListOf<StyleSpan>()

    for (i in startIndex..minOf(endIndex, coordinates.size - 1)) {
      var coord = coordinates[i]

      // Interpolate tail
      if (i == startIndex && tailPos > startIndex.toFloat() && i + 1 < coordinates.size) {
        val t = tailPos - startIndex
        val next = coordinates[i + 1]
        coord = LatLng(
          coord.latitude + (next.latitude - coord.latitude) * t,
          coord.longitude + (next.longitude - coord.longitude) * t
        )
      }

      // Interpolate head
      if (i == endIndex && headPos < endIndex.toFloat() && i > 0) {
        val t = headPos - (endIndex - 1)
        val prev = coordinates[i - 1]
        coord = LatLng(
          prev.latitude + (coordinates[i].latitude - prev.latitude) * t,
          prev.longitude + (coordinates[i].longitude - prev.longitude) * t
        )
      }

      points.add(coord)

      if (i < endIndex && i < segmentCount) {
        val segStartPos = max(i.toFloat(), tailPos)
        val segEndPos = min((i + 1).toFloat(), headPos)
        val gradientMid = ((segStartPos + segEndPos) / 2f - tailPos) / visibleLength
        val color = colorAtGradientPosition(gradientMid)
        spans.add(StyleSpan(StrokeStyle.colorBuilder(color).build()))
      }
    }

    poly.points = points
    if (spans.isNotEmpty()) {
      poly.setSpans(spans)
    }
  }

  private fun createGradientSpans(): List<StyleSpan> {
    val segmentCount = coordinates.size - 1
    return (0 until segmentCount).map { i ->
      val position = i.toFloat() / segmentCount
      val color = colorAtGradientPosition(position)
      StyleSpan(StrokeStyle.colorBuilder(color).build())
    }
  }

  private fun colorAtGradientPosition(position: Float): Int {
    if (strokeColors.isEmpty()) return Color.BLACK
    if (strokeColors.size == 1) return strokeColors[0]

    val pos = position.coerceIn(0f, 1f)
    val scaledPos = pos * (strokeColors.size - 1)
    val index = floor(scaledPos).toInt()
    val t = scaledPos - index

    if (index >= strokeColors.size - 1) return strokeColors.last()

    val c1 = strokeColors[index]
    val c2 = strokeColors[index + 1]

    val r = ((Color.red(c1) + (Color.red(c2) - Color.red(c1)) * t).toInt())
    val g = ((Color.green(c1) + (Color.green(c2) - Color.green(c1)) * t).toInt())
    val b = ((Color.blue(c1) + (Color.blue(c2) - Color.blue(c1)) * t).toInt())
    val a = ((Color.alpha(c1) + (Color.alpha(c2) - Color.alpha(c1)) * t).toInt())

    return Color.argb(a, r, g, b)
  }

  fun destroy() {
    stopAnimation()
    polyline = null
  }
}
