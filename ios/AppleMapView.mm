#import "AppleMapView.h"

#import <react/renderer/components/RNMapsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNMapsSpec/EventEmitters.h>
#import <react/renderer/components/RNMapsSpec/Props.h>
#import <react/renderer/components/RNMapsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@implementation AppleMapViewContent
@end

@interface AppleMapView () <RCTAppleMapViewViewProtocol>
@end

@implementation AppleMapView {
    AppleMapViewContent *_mapView;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<AppleMapViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const AppleMapViewProps>();
        _props = defaultProps;

        _mapView = [[AppleMapViewContent alloc] init];
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        MKCoordinateRegion region = MKCoordinateRegionMake(
            CLLocationCoordinate2DMake(37.7749, -122.4194),
            MKCoordinateSpanMake(0.0922, 0.0421)
        );
        [_mapView setRegion:region animated:NO];

        self.contentView = _mapView;
    }

    return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<AppleMapViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<AppleMapViewProps const>(props);

    if (newViewProps.initialRegion.latitude != oldViewProps.initialRegion.latitude ||
        newViewProps.initialRegion.longitude != oldViewProps.initialRegion.longitude ||
        newViewProps.initialRegion.latitudeDelta != oldViewProps.initialRegion.latitudeDelta ||
        newViewProps.initialRegion.longitudeDelta != oldViewProps.initialRegion.longitudeDelta) {

        MKCoordinateRegion region = MKCoordinateRegionMake(
            CLLocationCoordinate2DMake(newViewProps.initialRegion.latitude, newViewProps.initialRegion.longitude),
            MKCoordinateSpanMake(newViewProps.initialRegion.latitudeDelta, newViewProps.initialRegion.longitudeDelta)
        );
        [_mapView setRegion:region animated:NO];
    }

    if (newViewProps.zoomEnabled != oldViewProps.zoomEnabled) {
        _mapView.zoomEnabled = newViewProps.zoomEnabled;
    }

    if (newViewProps.scrollEnabled != oldViewProps.scrollEnabled) {
        _mapView.scrollEnabled = newViewProps.scrollEnabled;
    }

    if (newViewProps.rotateEnabled != oldViewProps.rotateEnabled) {
        _mapView.rotateEnabled = newViewProps.rotateEnabled;
    }

    if (newViewProps.pitchEnabled != oldViewProps.pitchEnabled) {
        _mapView.pitchEnabled = newViewProps.pitchEnabled;
    }

    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> AppleMapViewCls(void)
{
    return AppleMapView.class;
}

@end
