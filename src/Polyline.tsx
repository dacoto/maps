import React from 'react';
import LuggMapsPolylineViewNativeComponent from './fabric/LuggMapsPolylineViewNativeComponent';
import type { PolylineProps } from './Polyline.types';
import { StyleSheet } from 'react-native';

export class Polyline extends React.Component<PolylineProps> {
  render() {
    const {
      coordinates,
      strokeColors,
      strokeWidth,
      animated = false,
    } = this.props;

    return (
      <LuggMapsPolylineViewNativeComponent
        style={styles.polyline}
        coordinates={coordinates}
        strokeColors={strokeColors}
        strokeWidth={strokeWidth}
        animated={animated}
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
