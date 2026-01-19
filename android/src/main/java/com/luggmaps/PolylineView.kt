package com.luggmaps

import android.content.Context
import android.graphics.Color
import com.facebook.react.views.view.ReactViewGroup
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.Polyline

interface PolylineViewDelegate {
  fun polylineViewDidUpdate(polylineView: PolylineView)
}

class PolylineView(context: Context) : ReactViewGroup(context) {
  var coordinates: List<LatLng> = emptyList()
    private set

  var strokeColors: List<Int> = listOf(Color.BLACK)
    private set

  var strokeWidth: Float = 1f
    private set

  var delegate: PolylineViewDelegate? = null
  var polyline: Polyline? = null

  init {
    visibility = GONE
  }

  fun setCoordinates(coords: List<LatLng>) {
    coordinates = coords
  }

  fun setStrokeColors(colors: List<Int>) {
    strokeColors = colors.ifEmpty { listOf(Color.BLACK) }
  }

  fun setStrokeWidth(width: Float) {
    strokeWidth = width
  }

  fun onAfterUpdateTransaction() {
    delegate?.polylineViewDidUpdate(this)
  }

  fun onDropViewInstance() {
    delegate = null
    polyline?.remove()
    polyline = null
  }
}
