import type { ReactNode } from 'react';
import type { ViewProps } from 'react-native';
import type { MapProvider, Coordinate } from './types';

export interface MapViewProps extends ViewProps {
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
