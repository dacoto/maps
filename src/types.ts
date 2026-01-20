export type MapProvider = 'google' | 'apple';

export interface Coordinate {
  latitude: number;
  longitude: number;
}

export interface Point {
  x: number;
  y: number;
}

export interface EdgeInsets {
  top: number;
  left: number;
  bottom: number;
  right: number;
}
