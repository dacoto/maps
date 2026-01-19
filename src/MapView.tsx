import React from 'react';
import { Platform, StyleSheet } from 'react-native';
import NativeGoogleMapView, {
  Commands as GoogleMapCommands,
} from './fabric/GoogleMapViewNativeComponent';
import NativeAppleMapView, {
  Commands as AppleMapCommands,
} from './fabric/AppleMapViewNativeComponent';
import NativeMapWrapperView from './fabric/MapWrapperViewNativeComponent';
import type {
  MapViewProps,
  MapViewRef,
  MoveCameraOptions,
} from './MapView.types';

export class MapView
  extends React.Component<MapViewProps>
  implements MapViewRef
{
  static defaultProps: Partial<MapViewProps> = {
    provider: Platform.OS === 'ios' ? 'apple' : 'google',
    initialZoom: 10,
    zoomEnabled: true,
    scrollEnabled: true,
    rotateEnabled: true,
    pitchEnabled: true,
  };

  private nativeRef = React.createRef<any>();

  moveCamera(options: MoveCameraOptions) {
    const { coordinate, zoom, duration = -1 } = options;
    const ref = this.nativeRef.current;
    if (!ref) return;

    const provider = this.props.provider ?? MapView.defaultProps.provider;
    const isApple = Platform.OS === 'ios' && provider === 'apple';
    const Commands = isApple ? AppleMapCommands : GoogleMapCommands;

    Commands.moveCamera(
      ref,
      coordinate.latitude,
      coordinate.longitude,
      zoom,
      duration
    );
  }

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
        ref={this.nativeRef}
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
