import type { ReactNode } from 'react';
import type { StyleProp, ViewStyle } from 'react-native';

export type MapProvider = 'google' | 'apple';

export interface Region {
  latitude: number;
  longitude: number;
  latitudeDelta: number;
  longitudeDelta: number;
}

export interface MapViewProps {
  style?: StyleProp<ViewStyle>;
  provider?: MapProvider;
  initialRegion?: Region;
  zoomEnabled?: boolean;
  scrollEnabled?: boolean;
  rotateEnabled?: boolean;
  pitchEnabled?: boolean;
  children?: ReactNode;
}
