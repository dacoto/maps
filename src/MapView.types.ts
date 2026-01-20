import type { ReactNode } from 'react';
import type { NativeSyntheticEvent, ViewProps } from 'react-native';
import type { MapProvider, Coordinate, EdgeInsets } from './types';

export interface MoveCameraOptions {
  zoom: number;
  duration?: number;
}

export interface FitCoordinatesOptions {
  padding?: number;
  duration?: number;
}

export interface MapViewRef {
  moveCamera(coordinate: Coordinate, options: MoveCameraOptions): void;
  fitCoordinates(
    coordinates: Coordinate[],
    options?: FitCoordinatesOptions
  ): void;
}

export interface CameraMoveEvent {
  coordinate: Coordinate;
  zoom: number;
}

export interface CameraIdleEvent {
  coordinate: Coordinate;
  zoom: number;
}

export interface MapViewProps extends ViewProps {
  provider?: MapProvider;
  mapId?: string;
  initialCoordinate?: Coordinate;
  initialZoom?: number;
  zoomEnabled?: boolean;
  scrollEnabled?: boolean;
  rotateEnabled?: boolean;
  pitchEnabled?: boolean;
  padding?: EdgeInsets;
  onCameraMove?: (event: NativeSyntheticEvent<CameraMoveEvent>) => void;
  onCameraIdle?: (event: NativeSyntheticEvent<CameraIdleEvent>) => void;
  children?: ReactNode;
}
