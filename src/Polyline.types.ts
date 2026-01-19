import type { ColorValue } from 'react-native';
import type { Coordinate } from './types';

export interface PolylineProps {
  coordinates: Coordinate[];
  strokeColors?: ColorValue[];
  strokeWidth?: number;
}
