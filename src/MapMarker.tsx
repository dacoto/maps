import React from 'react';
import NativeMapMarker from './fabric/MapMarkerNativeComponent';
import type { MapMarkerProps } from './MapMarker.types';
import { StyleSheet } from 'react-native';

export class MapMarker extends React.Component<MapMarkerProps> {
  render() {
    const { name, coordinate, title, description, anchor, children } =
      this.props;

    return (
      <NativeMapMarker
        style={styles.marker}
        name={name}
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

const styles = StyleSheet.create({
  marker: {
    position: 'absolute',
  },
});
