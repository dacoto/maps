import type { ColorValue } from 'react-native';
import type { Coordinate } from './types';

/**
 * Polyline component props
 */
export interface PolylineProps {
  /**
   * Array of coordinates forming the polyline
   */
  coordinates: Coordinate[];
  /**
   * Gradient colors along the polyline
   */
  strokeColors?: ColorValue[];
  /**
   * Line width in points
   */
  strokeWidth?: number;
}
