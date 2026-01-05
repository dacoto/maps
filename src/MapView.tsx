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
      style,
      provider,
      mapId,
      initialCoordinate,
      initialZoom,
      zoomEnabled,
      scrollEnabled,
      rotateEnabled,
      pitchEnabled,
      children,
    } = this.props;

    const NativeMapView =
      Platform.OS === 'ios' && provider === 'apple'
        ? NativeAppleMapView
        : NativeGoogleMapView;

    const isAndroid = Platform.OS === 'android';

    return (
      <NativeMapView
        style={style}
        mapId={mapId}
        initialCoordinate={initialCoordinate}
        initialZoom={initialZoom}
        zoomEnabled={zoomEnabled}
        scrollEnabled={scrollEnabled}
        rotateEnabled={rotateEnabled}
        pitchEnabled={pitchEnabled}
      >
        <NativeMapWrapperView style={styles.wrapper} />
        {children}
      </NativeMapView>
    );
  }
}

const styles = StyleSheet.create({
  wrapper: {
    ...StyleSheet.absoluteFillObject,
  },
});
