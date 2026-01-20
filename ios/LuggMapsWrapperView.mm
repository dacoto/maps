#import "LuggMapsWrapperView.h"

#import <react/renderer/components/RNMapsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNMapsSpec/EventEmitters.h>
#import <react/renderer/components/RNMapsSpec/Props.h>
#import <react/renderer/components/RNMapsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface LuggMapsWrapperView () <RCTLuggMapsWrapperViewViewProtocol>
@end

@implementation LuggMapsWrapperView

+ (ComponentDescriptorProvider)componentDescriptorProvider {
  return concreteComponentDescriptorProvider<
      LuggMapsWrapperViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps =
        std::make_shared<const LuggMapsWrapperViewProps>();
    _props = defaultProps;
  }

  return self;
}

Class<RCTComponentViewProtocol> LuggMapsWrapperViewCls(void) {
  return LuggMapsWrapperView.class;
}

@end
