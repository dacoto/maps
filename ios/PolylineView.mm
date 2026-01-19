#import "PolylineView.h"

#import <react/renderer/components/RNMapsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNMapsSpec/EventEmitters.h>
#import <react/renderer/components/RNMapsSpec/Props.h>
#import <react/renderer/components/RNMapsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"
#import <React/RCTConversions.h>

using namespace facebook::react;

@interface PolylineView () <RCTPolylineViewViewProtocol>
@end

@implementation PolylineView {
  NSArray<CLLocation *> *_coordinates;
  UIColor *_strokeColor;
  CGFloat _strokeWidth;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider {
  return concreteComponentDescriptorProvider<PolylineViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps =
        std::make_shared<const PolylineViewProps>();
    _props = defaultProps;

    _coordinates = @[];
    _strokeColor = [UIColor blackColor];
    _strokeWidth = 1.0;

    self.hidden = YES;
  }

  return self;
}

- (void)updateProps:(Props::Shared const &)props
           oldProps:(Props::Shared const &)oldProps {
  [super updateProps:props oldProps:oldProps];
  const auto &newViewProps =
      *std::static_pointer_cast<PolylineViewProps const>(props);

  NSMutableArray<CLLocation *> *coords = [NSMutableArray array];
  for (const auto &coord : newViewProps.coordinates) {
    CLLocation *location =
        [[CLLocation alloc] initWithLatitude:coord.latitude
                                   longitude:coord.longitude];
    [coords addObject:location];
  }
  _coordinates = [coords copy];

  _strokeColor = RCTUIColorFromSharedColor(newViewProps.strokeColor) ?: [UIColor blackColor];

  _strokeWidth = newViewProps.strokeWidth > 0 ? newViewProps.strokeWidth : 1.0;
}

- (void)finalizeUpdates:(RNComponentViewUpdateMask)updateMask {
  [super finalizeUpdates:updateMask];

  if (updateMask & RNComponentViewUpdateMaskProps) {
    if ([self.delegate respondsToSelector:@selector(polylineViewDidUpdate:)]) {
      [self.delegate polylineViewDidUpdate:self];
    }
  }
}

- (NSArray<CLLocation *> *)coordinates {
  return _coordinates;
}

- (UIColor *)strokeColor {
  return _strokeColor;
}

- (CGFloat)strokeWidth {
  return _strokeWidth;
}

- (void)prepareForRecycle {
  [super prepareForRecycle];
  self.polyline = nil;
  self.delegate = nil;
}

Class<RCTComponentViewProtocol> PolylineViewCls(void) {
  return PolylineView.class;
}

@end
