import type { ReactNode } from 'react';
import type { StyleProp, ViewStyle } from 'react-native';
import type { Coordinate, Point } from './types';

export interface MapMarkerProps {
  style?: StyleProp<ViewStyle>;
  coordinate: Coordinate;
  title?: string;
  description?: string;
  anchor?: Point;
  children?: ReactNode;
}
