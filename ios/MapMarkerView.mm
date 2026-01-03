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
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<MapMarkerViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const MapMarkerViewProps>();
        _props = defaultProps;

        _coordinate = CLLocationCoordinate2DMake(0, 0);
    }

    return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<MapMarkerViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<MapMarkerViewProps const>(props);

    if (newViewProps.coordinate.latitude != oldViewProps.coordinate.latitude ||
        newViewProps.coordinate.longitude != oldViewProps.coordinate.longitude) {
        _coordinate = CLLocationCoordinate2DMake(
            newViewProps.coordinate.latitude,
            newViewProps.coordinate.longitude
        );
    }

    if (newViewProps.title != oldViewProps.title) {
        _title = [NSString stringWithUTF8String:newViewProps.title.c_str()];
    }

    if (newViewProps.description != oldViewProps.description) {
        _markerDescription = [NSString stringWithUTF8String:newViewProps.description.c_str()];
    }

    [super updateProps:props oldProps:oldProps];
}

- (CLLocationCoordinate2D)coordinate
{
    return _coordinate;
}

- (NSString *)title
{
    return _title;
}

- (NSString *)markerDescription
{
    return _markerDescription;
}

Class<RCTComponentViewProtocol> MapMarkerViewCls(void)
{
    return MapMarkerView.class;
}

@end
