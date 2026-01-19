#import "PolylineRenderer.h"

@implementation PolylineRenderer {
  MKPolyline *_polyline;
}

- (id)initWithPolyline:(MKPolyline *)polyline {
  self = [super initWithOverlay:polyline];
  if (self) {
    _polyline = polyline;
    [self createPath];
  }
  return self;
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

- (UIColor *)colorForIndex:(NSUInteger)index {
  if (!_strokeColors || _strokeColors.count == 0) {
    return self.strokeColor;
  }
  return _strokeColors[MIN(index, _strokeColors.count - 1)];
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

  if (!_strokeColors || _strokeColors.count <= 1) {
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    CGContextAddPath(context, self.path);
    CGContextStrokePath(context);
    return;
  }

  for (NSUInteger i = 0; i < _polyline.pointCount - 1; i++) {
    CGPoint startPoint = [self pointForMapPoint:_polyline.points[i]];
    CGPoint endPoint = [self pointForMapPoint:_polyline.points[i + 1]];

    UIColor *color = [self colorForIndex:i];

    CGContextSetStrokeColorWithColor(context, color.CGColor);

    CGContextBeginPath(context);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
  }
}

@end
