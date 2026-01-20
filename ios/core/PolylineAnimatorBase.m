#import "PolylineAnimatorBase.h"

@implementation PolylineAnimatorBase

- (UIColor *)colorAtGradientPosition:(CGFloat)position {
  if (!_strokeColors || _strokeColors.count == 0) {
    return [UIColor blackColor];
  }
  if (_strokeColors.count == 1) {
    return _strokeColors[0];
  }

  position = MAX(0, MIN(1, position));
  CGFloat scaledPos = position * (_strokeColors.count - 1);
  NSUInteger index = (NSUInteger)floor(scaledPos);
  CGFloat t = scaledPos - index;

  if (index >= _strokeColors.count - 1) {
    return _strokeColors.lastObject;
  }

  UIColor *c1 = _strokeColors[index];
  UIColor *c2 = _strokeColors[index + 1];

  CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
  [c1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
  [c2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];

  return [UIColor colorWithRed:r1 + (r2 - r1) * t
                         green:g1 + (g2 - g1) * t
                          blue:b1 + (b2 - b1) * t
                         alpha:a1 + (a2 - a1) * t];
}

@end
