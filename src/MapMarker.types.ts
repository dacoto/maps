import type { StyleProp, ViewStyle } from 'react-native';

export interface Coordinate {
  latitude: number;
  longitude: number;
}

export interface MapMarkerProps {
  style?: StyleProp<ViewStyle>;
  coordinate: Coordinate;
  title?: string;
  description?: string;
}
