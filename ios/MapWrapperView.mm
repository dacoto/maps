#import "MapWrapperView.h"

#import <react/renderer/components/RNMapsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNMapsSpec/EventEmitters.h>
#import <react/renderer/components/RNMapsSpec/Props.h>
#import <react/renderer/components/RNMapsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface MapWrapperView () <RCTMapWrapperViewViewProtocol>
@end

@implementation MapWrapperView

+ (ComponentDescriptorProvider)componentDescriptorProvider {
  return concreteComponentDescriptorProvider<
      MapWrapperViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps =
        std::make_shared<const MapWrapperViewProps>();
    _props = defaultProps;
  }

  return self;
}

Class<RCTComponentViewProtocol> MapWrapperViewCls(void) {
  return MapWrapperView.class;
}

@end
