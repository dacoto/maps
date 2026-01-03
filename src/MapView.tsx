import React from 'react';
import { Platform } from 'react-native';
import NativeGoogleMapView from './fabric/GoogleMapViewNativeComponent';
import NativeAppleMapView from './fabric/AppleMapViewNativeComponent';
import type { MapViewProps } from './MapView.types';

export class MapView extends React.Component<MapViewProps> {
  static defaultProps: Partial<MapViewProps> = {
    provider: Platform.OS === 'ios' ? 'apple' : 'google',
    zoomEnabled: true,
    scrollEnabled: true,
    rotateEnabled: true,
    pitchEnabled: true,
  };

  render() {
    const {
      style,
      provider,
      initialRegion,
      zoomEnabled,
      scrollEnabled,
      rotateEnabled,
      pitchEnabled,
    } = this.props;

    const NativeMapView =
      Platform.OS === 'ios' && provider === 'apple'
        ? NativeAppleMapView
        : NativeGoogleMapView;

    return (
      <NativeMapView
        style={style}
        initialRegion={initialRegion}
        zoomEnabled={zoomEnabled}
        scrollEnabled={scrollEnabled}
        rotateEnabled={rotateEnabled}
        pitchEnabled={pitchEnabled}
      />
    );
  }
}
