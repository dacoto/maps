import { useCallback, useMemo, useState } from 'react';
import { Polyline, type PolylineProps, type Coordinate } from '@lugg/maps';
import Animated, {
  cancelAnimation,
  Easing,
  interpolate,
  runOnJS,
  useAnimatedProps,
  useAnimatedReaction,
  useSharedValue,
  withDelay,
  withRepeat,
  withSequence,
  withTiming,
} from 'react-native-reanimated';

import { generateGradientColors, smoothCoordinates } from '../utils';

const ReanimatedPolyline = Animated.createAnimatedComponent(Polyline);

interface AnimatedPolylineProps extends Omit<PolylineProps, 'strokeColors'> {
  duration?: number;
  strokeColors?: [string, string];
  maxInterpolatedPoints?: number;
}

const getSliceIndices = (progress: number, len: number): [number, number] => {
  'worklet';
  if (progress <= 1) {
    return [0, Math.max(1, Math.floor(interpolate(progress, [0, 1], [1, len])))];
  }
  return [Math.max(0, Math.floor(interpolate(progress, [1, 2], [0, len - 1]))), len];
};

export function AnimatedPolyline({
  coordinates,
  strokeWidth,
  duration = 1750,
  strokeColors = ['#B321E0', '#3744FF'],
  maxInterpolatedPoints = 50,
}: AnimatedPolylineProps) {
  const progress = useSharedValue(0);

  const processedCoordinates = useMemo(() => {
    const smoothed = smoothCoordinates(coordinates);

    if (smoothed.length > maxInterpolatedPoints) {
      const sampled: Coordinate[] = [];
      const step = Math.max(
        1,
        Math.floor(smoothed.length / maxInterpolatedPoints)
      );
      for (let i = 0; i < smoothed.length; i += step) {
        sampled.push(smoothed[i]!);
      }
      if (sampled[sampled.length - 1] !== smoothed[smoothed.length - 1]) {
        sampled.push(smoothed[smoothed.length - 1]!);
      }
      return sampled;
    }

    return smoothed;
  }, [coordinates, maxInterpolatedPoints]);

  const gradientColors = useMemo(
    () =>
      generateGradientColors(
        strokeColors[0],
        strokeColors[1],
        processedCoordinates.length
      ),
    [processedCoordinates.length, strokeColors]
  );

  const [currentStrokeColors, setCurrentStrokeColors] = useState(gradientColors);

  const animatedProps = useAnimatedProps(() => {
    const [start, end] = getSliceIndices(progress.value, processedCoordinates.length);
    return { coordinates: processedCoordinates.slice(start, end) };
  });

  useAnimatedReaction(
    () => progress.value,
    (value) => {
      const [start, end] = getSliceIndices(value, gradientColors.length);
      runOnJS(setCurrentStrokeColors)(gradientColors.slice(start, end));
    },
    [gradientColors]
  );

  const animate = useCallback(() => {
    if (coordinates.length > 1) {
      cancelAnimation(progress);
      progress.value = 0;

      progress.value = withRepeat(
        withSequence(
          withTiming(1, { duration, easing: Easing.linear }),
          withTiming(2, { duration, easing: Easing.linear }),
          withDelay(300, withTiming(0, { duration: 0 }))
        ),
        -1,
        false
      );
    }

    return () => cancelAnimation(progress);
  }, [coordinates, duration, progress]);

  return (
    // @ts-expect-error coordinates passed via animatedProps
    <ReanimatedPolyline
      ref={animate}
      animatedProps={animatedProps}
      strokeWidth={strokeWidth}
      strokeColors={currentStrokeColors}
    />
  );
}
