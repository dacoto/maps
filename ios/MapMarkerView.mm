#import "MapMarkerView.h"

#import <react/renderer/components/RNMapsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNMapsSpec/EventEmitters.h>
#import <react/renderer/components/RNMapsSpec/Props.h>
#import <react/renderer/components/RNMapsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface MapMarkerView () <RCTMapMarkerViewViewProtocol>
@end

@implementation MapMarkerView {
  CLLocationCoordinate2D _coordinate;
  NSString *_title;
  NSString *_markerDescription;
  CGPoint _anchor;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider {
  return concreteComponentDescriptorProvider<
      MapMarkerViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps =
        std::make_shared<const MapMarkerViewProps>();
    _props = defaultProps;

    _coordinate = CLLocationCoordinate2DMake(0, 0);
    _anchor = CGPointMake(0.5, 1.0);

    self.backgroundColor = [UIColor clearColor];
  }

  return self;
}

- (void)updateProps:(Props::Shared const &)props
           oldProps:(Props::Shared const &)oldProps {
  [super updateProps:props oldProps:oldProps];
  const auto &newViewProps =
      *std::static_pointer_cast<MapMarkerViewProps const>(props);

  _coordinate = CLLocationCoordinate2DMake(newViewProps.coordinate.latitude,
                                           newViewProps.coordinate.longitude);
  _title = [NSString stringWithUTF8String:newViewProps.title.c_str()];
  _markerDescription =
      [NSString stringWithUTF8String:newViewProps.description.c_str()];
  _anchor = CGPointMake(newViewProps.anchor.x, newViewProps.anchor.y);
}

- (void)finalizeUpdates:(RNComponentViewUpdateMask)updateMask {
  [super finalizeUpdates:updateMask];

  if (updateMask & RNComponentViewUpdateMaskProps) {
    if ([self.delegate
            respondsToSelector:@selector(markerViewDidUpdateProps:)]) {
      [self.delegate markerViewDidUpdateProps:self];
    }
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];

  if (!self.hasCustomView) {
    return;
  }

  CGFloat width = 0;
  CGFloat height = 0;

  for (UIView *subview in self.subviews) {
    CGFloat fw = subview.frame.origin.x + subview.frame.size.width;
    CGFloat fh = subview.frame.origin.y + subview.frame.size.height;
    width = MAX(fw, width);
    height = MAX(fh, height);
  }

  if (width > 0 && height > 0) {
    self.frame = CGRectMake(0, 0, width, height);
  }

  if ([self.delegate
          respondsToSelector:@selector(markerViewDidUpdateLayout:)]) {
    [self.delegate markerViewDidUpdateLayout:self];
  }
}

- (CLLocationCoordinate2D)coordinate {
  return _coordinate;
}

- (NSString *)title {
  return _title;
}

- (NSString *)markerDescription {
  return _markerDescription;
}

- (CGPoint)anchor {
  return _anchor;
}

- (BOOL)hasCustomView {
  return self.subviews.count > 0;
}

- (void)prepareForRecycle {
  [super prepareForRecycle];
  self.annotation = nil;
  self.delegate = nil;
}

Class<RCTComponentViewProtocol> MapMarkerViewCls(void) {
  return MapMarkerView.class;
}

@end
