#import "MKPolylineAnimator.h"
#import <QuartzCore/QuartzCore.h>

@implementation MKPolylineAnimator {
  MKPolyline *_polyline;
  CADisplayLink *_displayLink;
  CGFloat _animationProgress; // 0→1 grow, 1→2 shrink
}

- (id)initWithPolyline:(MKPolyline *)polyline {
  self = [super initWithOverlay:polyline];
  if (self) {
    _polyline = polyline;
    _animationProgress = 0;
    [self createPath];
  }
  return self;
}

- (void)dealloc {
  [self stopAnimation];
}

- (void)setAnimated:(BOOL)animated {
  if (_animated == animated) {
    return;
  }
  _animated = animated;

  if (_animated) {
    [self startAnimation];
  } else {
    [self stopAnimation];
  }
}

- (void)startAnimation {
  if (_displayLink) {
    return;
  }
  _animationProgress = 0;
  _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationTick:)];
  [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation {
  [_displayLink invalidate];
  _displayLink = nil;
}

- (void)animationTick:(CADisplayLink *)displayLink {
  // ~1.75s per phase (grow or shrink), matching JS duration
  CGFloat speed = displayLink.duration / 1.75;
  _animationProgress += speed;

  // 0→1 grow, 1→2 shrink, then reset with small pause
  if (_animationProgress >= 2.15) { // 2.0 + 0.15 pause (~300ms at this speed)
    _animationProgress = 0;
  }

  MKMapRect bounds = _polyline.boundingMapRect;
  bounds = MKMapRectInset(bounds, -bounds.size.width * 0.1, -bounds.size.height * 0.1);
  [self setNeedsDisplayInMapRect:bounds];
}

- (void)updatePolyline:(MKPolyline *)polyline {
  _polyline = polyline;
  [self invalidatePath];
  [self createPath];
  [self setNeedsDisplay];
}

- (void)createPath {
  CGMutablePathRef path = CGPathCreateMutable();
  BOOL first = YES;
  for (NSUInteger i = 0; i < _polyline.pointCount; i++) {
    CGPoint point = [self pointForMapPoint:_polyline.points[i]];
    if (first) {
      CGPathMoveToPoint(path, nil, point.x, point.y);
      first = NO;
    } else {
      CGPathAddLineToPoint(path, nil, point.x, point.y);
    }
  }
  self.path = path;
}

- (UIColor *)colorAtGradientPosition:(CGFloat)position {
  if (!_strokeColors || _strokeColors.count == 0) {
    return self.strokeColor;
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

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context {
  CGRect pointsRect = CGPathGetBoundingBox(self.path);
  CGRect mapRectCG = [self rectForMapRect:mapRect];
  if (!CGRectIntersectsRect(pointsRect, mapRectCG)) {
    return;
  }

  CGFloat lineWidth = self.lineWidth / zoomScale;
  CGContextSetLineWidth(context, lineWidth);
  CGContextSetLineCap(context, self.lineCap);
  CGContextSetLineJoin(context, self.lineJoin);

  NSUInteger segmentCount = _polyline.pointCount - 1;
  if (segmentCount == 0) {
    return;
  }

  // Snake animation: grow from start, then shrink from start
  if (_animated && _polyline.pointCount > 1) {
    CGFloat progress = MIN(_animationProgress, 2.0);
    CGFloat headPos, tailPos;

    if (progress <= 1.0) {
      // Phase 1: grow from start to end
      tailPos = 0;
      headPos = progress * segmentCount;
    } else {
      // Phase 2: shrink from start
      CGFloat shrinkProgress = progress - 1.0;
      tailPos = shrinkProgress * segmentCount;
      headPos = segmentCount;
    }

    if (headPos <= tailPos) {
      return;
    }

    NSUInteger startIndex = (NSUInteger)floor(tailPos);
    NSUInteger endIndex = (NSUInteger)ceil(headPos);
    CGFloat visibleLength = headPos - tailPos;

    for (NSUInteger i = startIndex; i < endIndex && i < segmentCount; i++) {
      CGPoint segStart = [self pointForMapPoint:_polyline.points[i]];
      CGPoint segEnd = [self pointForMapPoint:_polyline.points[i + 1]];

      CGPoint drawStart = segStart;
      CGPoint drawEnd = segEnd;
      CGFloat segStartPos = (CGFloat)i;
      CGFloat segEndPos = (CGFloat)(i + 1);

      // Interpolate tail (partial segment at start)
      if (segStartPos < tailPos) {
        CGFloat t = tailPos - segStartPos;
        drawStart.x = segStart.x + (segEnd.x - segStart.x) * t;
        drawStart.y = segStart.y + (segEnd.y - segStart.y) * t;
        segStartPos = tailPos;
      }

      // Interpolate head (partial segment at end)
      if (segEndPos > headPos) {
        CGFloat t = headPos - (CGFloat)i;
        drawEnd.x = segStart.x + (segEnd.x - segStart.x) * t;
        drawEnd.y = segStart.y + (segEnd.y - segStart.y) * t;
        segEndPos = headPos;
      }

      // Calculate gradient position (0-1) within visible portion
      CGFloat gradientStart = (segStartPos - tailPos) / visibleLength;
      CGFloat gradientEnd = (segEndPos - tailPos) / visibleLength;

      UIColor *startColor = [self colorAtGradientPosition:gradientStart];
      UIColor *endColor = [self colorAtGradientPosition:gradientEnd];

      // Draw gradient line segment
      CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
      NSArray *colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
      CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, NULL);

      CGContextSaveGState(context);
      CGContextBeginPath(context);
      CGContextMoveToPoint(context, drawStart.x, drawStart.y);
      CGContextAddLineToPoint(context, drawEnd.x, drawEnd.y);
      CGContextReplacePathWithStrokedPath(context);
      CGContextClip(context);

      CGContextDrawLinearGradient(context, gradient, drawStart, drawEnd, 0);

      CGContextRestoreGState(context);
      CGGradientRelease(gradient);
      CGColorSpaceRelease(colorSpace);
    }
    return;
  }

  // Static gradient rendering
  if (_strokeColors && _strokeColors.count > 1) {
    for (NSUInteger i = 0; i < segmentCount; i++) {
      CGPoint startPoint = [self pointForMapPoint:_polyline.points[i]];
      CGPoint endPoint = [self pointForMapPoint:_polyline.points[i + 1]];

      CGFloat gradientStart = (CGFloat)i / segmentCount;
      CGFloat gradientEnd = (CGFloat)(i + 1) / segmentCount;

      UIColor *startColor = [self colorAtGradientPosition:gradientStart];
      UIColor *endColor = [self colorAtGradientPosition:gradientEnd];

      CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
      NSArray *colors = @[(__bridge id)startColor.CGColor, (__bridge id)endColor.CGColor];
      CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, NULL);

      CGContextSaveGState(context);
      CGContextBeginPath(context);
      CGContextMoveToPoint(context, startPoint.x, startPoint.y);
      CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
      CGContextReplacePathWithStrokedPath(context);
      CGContextClip(context);

      CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);

      CGContextRestoreGState(context);
      CGGradientRelease(gradient);
      CGColorSpaceRelease(colorSpace);
    }
    return;
  }

  // Single color
  CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
  CGContextAddPath(context, self.path);
  CGContextStrokePath(context);
}

@end
