package com.luggmaps

import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.MapViewManagerInterface
import com.facebook.react.viewmanagers.MapViewManagerDelegate

@ReactModule(name = MapViewManager.NAME)
class MapViewManager : SimpleViewManager<MapView>(), MapViewManagerInterface<MapView> {
    private val delegate: ViewManagerDelegate<MapView> = MapViewManagerDelegate(this)

    override fun getDelegate(): ViewManagerDelegate<MapView> = delegate

    override fun getName(): String = NAME

    override fun createViewInstance(context: ThemedReactContext): MapView {
        return MapView(context)
    }

    @ReactProp(name = "initialRegion")
    override fun setInitialRegion(view: MapView, value: ReadableMap?) {
        value?.let {
            val latitude = if (it.hasKey("latitude")) it.getDouble("latitude") else 0.0
            val longitude = if (it.hasKey("longitude")) it.getDouble("longitude") else 0.0
            val latitudeDelta = if (it.hasKey("latitudeDelta")) it.getDouble("latitudeDelta") else 0.0
            val longitudeDelta = if (it.hasKey("longitudeDelta")) it.getDouble("longitudeDelta") else 0.0
            view.setInitialRegion(latitude, longitude, latitudeDelta, longitudeDelta)
        }
    }

    @ReactProp(name = "zoomEnabled", defaultBoolean = true)
    override fun setZoomEnabled(view: MapView, value: Boolean) {
        view.setZoomEnabled(value)
    }

    @ReactProp(name = "scrollEnabled", defaultBoolean = true)
    override fun setScrollEnabled(view: MapView, value: Boolean) {
        view.setScrollEnabled(value)
    }

    @ReactProp(name = "rotateEnabled", defaultBoolean = true)
    override fun setRotateEnabled(view: MapView, value: Boolean) {
        view.setRotateEnabled(value)
    }

    @ReactProp(name = "pitchEnabled", defaultBoolean = true)
    override fun setPitchEnabled(view: MapView, value: Boolean) {
        view.setPitchEnabled(value)
    }

    companion object {
        const val NAME = "MapView"
    }
}
