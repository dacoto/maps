import React from 'react';
import { Platform, StyleSheet } from 'react-native';
import NativeGoogleMapView from './fabric/GoogleMapViewNativeComponent';
import NativeAppleMapView from './fabric/AppleMapViewNativeComponent';
import NativeMapWrapperView from './fabric/MapWrapperViewNativeComponent';
import type { MapViewProps } from './MapView.types';

export class MapView extends React.Component<MapViewProps> {
  static defaultProps: Partial<MapViewProps> = {
    provider: Platform.OS === 'ios' ? 'apple' : 'google',
    initialZoom: 10,
    zoomEnabled: true,
    scrollEnabled: true,
    rotateEnabled: true,
    pitchEnabled: true,
  };

  render() {
    const {
      provider,
      mapId,
      initialCoordinate,
      initialZoom,
      zoomEnabled,
      scrollEnabled,
      rotateEnabled,
      pitchEnabled,
      children,
      ...rest
    } = this.props;

    const NativeMapView =
      Platform.OS === 'ios' && provider === 'apple'
        ? NativeAppleMapView
        : NativeGoogleMapView;

    return (
      <NativeMapView
        {...rest}
        mapId={mapId}
        initialCoordinate={initialCoordinate}
        initialZoom={initialZoom}
        zoomEnabled={zoomEnabled}
        scrollEnabled={scrollEnabled}
        rotateEnabled={rotateEnabled}
        pitchEnabled={pitchEnabled}
      >
        <NativeMapWrapperView style={StyleSheet.absoluteFill} />
        {children}
      </NativeMapView>
    );
  }
}
