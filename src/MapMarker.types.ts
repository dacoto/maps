import type { ReactNode } from 'react';
import type { Coordinate, Point } from './types';

export interface MapMarkerProps {
  /** Name used for debugging purposes */
  name?: string;
  coordinate: Coordinate;
  title?: string;
  description?: string;
  anchor?: Point;
  children?: ReactNode;
}
