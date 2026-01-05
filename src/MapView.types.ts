import type { ReactNode } from 'react';
import type { StyleProp, ViewStyle } from 'react-native';
import type { MapProvider, Coordinate } from './types';

export interface MapViewProps {
  style?: StyleProp<ViewStyle>;
  provider?: MapProvider;
  mapId?: string;
  initialCoordinate?: Coordinate;
  initialZoom?: number;
  zoomEnabled?: boolean;
  scrollEnabled?: boolean;
  rotateEnabled?: boolean;
  pitchEnabled?: boolean;
  children?: ReactNode;
}
