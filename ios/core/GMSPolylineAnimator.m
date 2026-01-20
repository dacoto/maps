#import "GMSPolylineAnimator.h"
#import <QuartzCore/QuartzCore.h>

@implementation GMSPolylineAnimator {
  CADisplayLink *_displayLink;
  CGFloat _animationProgress;
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
    [self update];
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
  CGFloat speed = displayLink.duration / 1.75;
  _animationProgress += speed;

  if (_animationProgress >= 2.15) {
    _animationProgress = 0;
  }

  [self updateAnimatedPolyline];
}

- (void)update {
  if (_animated) {
    return;
  }

  if (!_polyline || self.coordinates.count < 2) {
    return;
  }

  GMSMutablePath *path = [GMSMutablePath path];
  for (CLLocation *location in self.coordinates) {
    [path addCoordinate:location.coordinate];
  }
  _polyline.path = path;

  if (self.strokeColors.count > 1) {
    _polyline.spans = [self createGradientSpans];
  } else {
    _polyline.strokeColor = self.strokeColors.firstObject ?: [UIColor blackColor];
  }
}

- (void)updateAnimatedPolyline {
  if (!_polyline || self.coordinates.count < 2) {
    return;
  }

  NSUInteger segmentCount = self.coordinates.count - 1;
  CGFloat progress = MIN(_animationProgress, 2.0);
  CGFloat headPos, tailPos;

  if (progress <= 1.0) {
    tailPos = 0;
    headPos = progress * segmentCount;
  } else {
    CGFloat shrinkProgress = progress - 1.0;
    tailPos = shrinkProgress * segmentCount;
    headPos = segmentCount;
  }

  if (headPos <= tailPos) {
    _polyline.path = [GMSMutablePath path];
    return;
  }

  NSUInteger startIndex = (NSUInteger)floor(tailPos);
  NSUInteger endIndex = (NSUInteger)ceil(headPos);
  CGFloat visibleLength = headPos - tailPos;

  GMSMutablePath *path = [GMSMutablePath path];
  NSMutableArray<GMSStyleSpan *> *spans = [NSMutableArray array];

  for (NSUInteger i = startIndex; i <= endIndex && i < self.coordinates.count; i++) {
    CLLocationCoordinate2D coord = self.coordinates[i].coordinate;

    if (i == startIndex && tailPos > (CGFloat)startIndex) {
      CGFloat t = tailPos - (CGFloat)startIndex;
      CLLocationCoordinate2D nextCoord = self.coordinates[i + 1].coordinate;
      coord.latitude = coord.latitude + (nextCoord.latitude - coord.latitude) * t;
      coord.longitude = coord.longitude + (nextCoord.longitude - coord.longitude) * t;
    }

    if (i == endIndex && headPos < (CGFloat)endIndex && i > 0) {
      CGFloat t = headPos - (CGFloat)(endIndex - 1);
      CLLocationCoordinate2D prevCoord = self.coordinates[i - 1].coordinate;
      coord.latitude = prevCoord.latitude + (coord.latitude - prevCoord.latitude) * t;
      coord.longitude = prevCoord.longitude + (coord.longitude - prevCoord.longitude) * t;
    }

    [path addCoordinate:coord];

    if (i < endIndex && i < segmentCount) {
      CGFloat segStartPos = MAX((CGFloat)i, tailPos);
      CGFloat segEndPos = MIN((CGFloat)(i + 1), headPos);
      CGFloat gradientMid = ((segStartPos + segEndPos) / 2.0 - tailPos) / visibleLength;
      UIColor *color = [self colorAtGradientPosition:gradientMid];
      GMSStrokeStyle *style = [GMSStrokeStyle solidColor:color];
      [spans addObject:[GMSStyleSpan spanWithStyle:style]];
    }
  }

  _polyline.path = path;
  _polyline.spans = spans;
}

- (NSArray<GMSStyleSpan *> *)createGradientSpans {
  NSMutableArray<GMSStyleSpan *> *spans = [NSMutableArray array];
  NSUInteger segmentCount = self.coordinates.count - 1;

  for (NSUInteger i = 0; i < segmentCount; i++) {
    CGFloat position = (CGFloat)i / (CGFloat)segmentCount;
    UIColor *color = [self colorAtGradientPosition:position];
    GMSStrokeStyle *style = [GMSStrokeStyle solidColor:color];
    [spans addObject:[GMSStyleSpan spanWithStyle:style]];
  }

  return spans;
}

@end
