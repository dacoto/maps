import React from 'react';
import LuggMapsPolylineViewNativeComponent from './fabric/LuggMapsPolylineViewNativeComponent';
import type { PolylineProps } from './Polyline.types';
import { StyleSheet } from 'react-native';

export class Polyline extends React.Component<PolylineProps> {
  render() {
    const { coordinates, strokeColors, strokeWidth } = this.props;

    return (
      <LuggMapsPolylineViewNativeComponent
        style={styles.polyline}
        coordinates={coordinates}
        strokeColors={strokeColors}
        strokeWidth={strokeWidth}
      />
    );
  }
}

const styles = StyleSheet.create({
  polyline: {
    position: 'absolute',
    pointerEvents: 'none',
  },
});
