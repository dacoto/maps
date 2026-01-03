#import "MapView.h"

#import <react/renderer/components/MapViewSpec/ComponentDescriptors.h>
#import <react/renderer/components/MapViewSpec/EventEmitters.h>
#import <react/renderer/components/MapViewSpec/Props.h>
#import <react/renderer/components/MapViewSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@implementation MapViewContent
@end

@interface MapView () <RCTMapViewViewProtocol>
@end

@implementation MapView {
    MapViewContent *_mapView;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<MapViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const MapViewProps>();
        _props = defaultProps;

        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.7749
                                                                longitude:-122.4194
                                                                     zoom:10];

        GMSMapViewOptions *options = [[GMSMapViewOptions alloc] init];
        options.frame = self.bounds;
        options.camera = camera;

        _mapView = [[MapViewContent alloc] initWithOptions:options];
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.contentView = _mapView;
    }

    return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<MapViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<MapViewProps const>(props);

    if (newViewProps.initialRegion.latitude != oldViewProps.initialRegion.latitude ||
        newViewProps.initialRegion.longitude != oldViewProps.initialRegion.longitude ||
        newViewProps.initialRegion.latitudeDelta != oldViewProps.initialRegion.latitudeDelta ||
        newViewProps.initialRegion.longitudeDelta != oldViewProps.initialRegion.longitudeDelta) {

        double latitude = newViewProps.initialRegion.latitude;
        double longitude = newViewProps.initialRegion.longitude;
        double latitudeDelta = newViewProps.initialRegion.latitudeDelta;

        float zoom = 10;
        if (latitudeDelta > 0) {
            zoom = log2(360.0 / latitudeDelta);
        }

        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                                longitude:longitude
                                                                     zoom:zoom];
        [_mapView setCamera:camera];
    }

    if (newViewProps.zoomEnabled != oldViewProps.zoomEnabled) {
        _mapView.settings.zoomGestures = newViewProps.zoomEnabled;
    }

    if (newViewProps.scrollEnabled != oldViewProps.scrollEnabled) {
        _mapView.settings.scrollGestures = newViewProps.scrollEnabled;
    }

    if (newViewProps.rotateEnabled != oldViewProps.rotateEnabled) {
        _mapView.settings.rotateGestures = newViewProps.rotateEnabled;
    }

    if (newViewProps.pitchEnabled != oldViewProps.pitchEnabled) {
        _mapView.settings.tiltGestures = newViewProps.pitchEnabled;
    }

    [super updateProps:props oldProps:oldProps];
}

Class<RCTComponentViewProtocol> MapViewCls(void)
{
    return MapView.class;
}

@end
