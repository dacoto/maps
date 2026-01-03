package com.luggmaps

import android.content.Context
import android.view.View

class MapMarkerView(context: Context) : View(context) {
    var latitude: Double = 0.0
        private set
    var longitude: Double = 0.0
        private set
    var markerTitle: String? = null
        private set
    var markerDescription: String? = null
        private set

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
}
