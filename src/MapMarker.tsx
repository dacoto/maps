import React from 'react';
import NativeMapMarker from './fabric/MapMarkerNativeComponent';
import type { MapMarkerProps } from './MapMarker.types';

export class MapMarker extends React.Component<MapMarkerProps> {
  render() {
    const { style, coordinate, title, description } = this.props;

    return (
      <NativeMapMarker
        style={style}
        coordinate={coordinate}
        title={title}
        description={description}
      />
    );
  }
}
