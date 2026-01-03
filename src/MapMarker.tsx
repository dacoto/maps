import React from 'react';
import NativeMapMarker from './fabric/MapMarkerNativeComponent';
import type { MapMarkerProps } from './MapMarker.types';

export class MapMarker extends React.Component<MapMarkerProps> {
  private static keyCounter = 0;

  render() {
    const { style, coordinate, title, description, anchor, children } =
      this.props;

    return (
      <NativeMapMarker
        style={style}
        key={`marker-${MapMarker.keyCounter++}`}
        coordinate={coordinate}
        title={title}
        description={description}
        anchor={anchor}
      >
        {children}
      </NativeMapMarker>
    );
  }
}
