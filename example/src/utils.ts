export const randomFrom = <T>(arr: T[]): T =>
  arr[Math.floor(Math.random() * arr.length)]!;

export const randomInt = (min: number, max: number) =>
  Math.floor(Math.random() * (max - min + 1)) + min;

export const randomLetter = () =>
  String.fromCharCode(65 + Math.floor(Math.random() * 26));

const hexToRgb = (hex: string) => {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result
    ? {
        r: parseInt(result[1]!, 16),
        g: parseInt(result[2]!, 16),
        b: parseInt(result[3]!, 16),
      }
    : { r: 0, g: 0, b: 0 };
};

const rgbToHex = (r: number, g: number, b: number) =>
  `#${[r, g, b].map((x) => Math.round(x).toString(16).padStart(2, '0')).join('')}`;

export const generateGradientColors = (
  startColor: string,
  endColor: string,
  steps: number
): string[] => {
  if (steps <= 1) return [startColor];
  const start = hexToRgb(startColor);
  const end = hexToRgb(endColor);
  return Array.from({ length: steps }, (_, i) => {
    const t = i / (steps - 1);
    return rgbToHex(
      start.r + (end.r - start.r) * t,
      start.g + (end.g - start.g) * t,
      start.b + (end.b - start.b) * t
    );
  });
};

type Point = { latitude: number; longitude: number };

const catmullRom = (p0: number, p1: number, p2: number, p3: number, t: number) => {
  const t2 = t * t;
  const t3 = t2 * t;
  return (
    0.5 *
    (2 * p1 +
      (-p0 + p2) * t +
      (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 +
      (-p0 + 3 * p1 - 3 * p2 + p3) * t3)
  );
};

export const smoothCoordinates = (
  points: Point[],
  segments: number = 10
): Point[] => {
  if (points.length < 2) return points;
  if (points.length === 2) return points;

  const result: Point[] = [];

  for (let i = 0; i < points.length - 1; i++) {
    const p0 = points[Math.max(0, i - 1)]!;
    const p1 = points[i]!;
    const p2 = points[i + 1]!;
    const p3 = points[Math.min(points.length - 1, i + 2)]!;

    for (let j = 0; j < segments; j++) {
      const t = j / segments;
      result.push({
        latitude: catmullRom(p0.latitude, p1.latitude, p2.latitude, p3.latitude, t),
        longitude: catmullRom(p0.longitude, p1.longitude, p2.longitude, p3.longitude, t),
      });
    }
  }

  result.push(points[points.length - 1]!);
  return result;
};
