import React from 'react';
import PolylineViewNativeComponent from './fabric/PolylineViewNativeComponent';
import type { PolylineProps } from './Polyline.types';
import { StyleSheet } from 'react-native';

export class Polyline extends React.Component<PolylineProps> {
  render() {
    const { coordinates, strokeColors, strokeWidth } = this.props;

    return (
      <PolylineViewNativeComponent
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
