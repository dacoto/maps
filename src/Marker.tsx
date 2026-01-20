import React from 'react';
import LuggMapsMarkerViewNativeComponent from './fabric/LuggMapsMarkerViewNativeComponent';
import type { MarkerProps } from './Marker.types';
import { StyleSheet } from 'react-native';

export class Marker extends React.Component<MarkerProps> {
  render() {
    const { name, coordinate, title, description, anchor, children } =
      this.props;

    return (
      <LuggMapsMarkerViewNativeComponent
        style={styles.marker}
        name={name}
        coordinate={coordinate}
        title={title}
        description={description}
        anchor={anchor}
      >
        {children}
      </LuggMapsMarkerViewNativeComponent>
    );
  }
}

const styles = StyleSheet.create({
  marker: {
    position: 'absolute',
    pointerEvents: 'box-none',
  },
});
