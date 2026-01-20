import type { ReactNode } from 'react';
import type { Coordinate, Point } from './types';

/**
 * Marker component props
 */
export interface MarkerProps {
  /**
   * Name used for debugging purposes
   */
  name?: string;
  /**
   * Marker position
   */
  coordinate: Coordinate;
  /**
   * Callout title
   */
  title?: string;
  /**
   * Callout description
   */
  description?: string;
  /**
   * Anchor point for custom marker views
   */
  anchor?: Point;
  /**
   * Custom marker view
   */
  children?: ReactNode;
}
