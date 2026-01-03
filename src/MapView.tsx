import React from 'react';
import NativeMapView from './fabric/MapViewNativeComponent';
import type { MapViewProps } from './MapView.types';

export class MapView extends React.Component<MapViewProps> {
  static defaultProps: Partial<MapViewProps> = {
    zoomEnabled: true,
    scrollEnabled: true,
    rotateEnabled: true,
    pitchEnabled: true,
  };

  render() {
    const {
      style,
      initialRegion,
      zoomEnabled,
      scrollEnabled,
      rotateEnabled,
      pitchEnabled,
    } = this.props;

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
