import React from 'react';
import MarkerViewNativeComponent from './fabric/MarkerViewNativeComponent';
import type { MarkerProps } from './Marker.types';
import { StyleSheet } from 'react-native';

export class Marker extends React.Component<MarkerProps> {
  render() {
    const { name, coordinate, title, description, anchor, children } =
      this.props;

    return (
      <MarkerViewNativeComponent
        style={styles.marker}
        name={name}
        coordinate={coordinate}
        title={title}
        description={description}
        anchor={anchor}
      >
        {children}
      </MarkerViewNativeComponent>
    );
  }
}

const styles = StyleSheet.create({
  marker: {
    position: 'absolute',
    pointerEvents: 'box-none',
  },
});
