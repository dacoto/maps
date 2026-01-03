#import "GoogleMapView.h"
#import "MapMarkerView.h"

#import <react/renderer/components/RNMapsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNMapsSpec/EventEmitters.h>
#import <react/renderer/components/RNMapsSpec/Props.h>
#import <react/renderer/components/RNMapsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@implementation GoogleMapViewContent
@end

@interface GoogleMapView () <RCTGoogleMapViewViewProtocol>
@end

@implementation GoogleMapView {
    GoogleMapViewContent *_mapView;
    NSMutableDictionary<NSNumber *, GMSMarker *> *_markers;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
    return concreteComponentDescriptorProvider<GoogleMapViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        static const auto defaultProps = std::make_shared<const GoogleMapViewProps>();
        _props = defaultProps;

        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.7749
                                                                longitude:-122.4194
                                                                     zoom:10];

        GMSMapViewOptions *options = [[GMSMapViewOptions alloc] init];
        options.frame = self.bounds;
        options.camera = camera;

        _mapView = [[GoogleMapViewContent alloc] initWithOptions:options];
        _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _markers = [NSMutableDictionary new];

        self.contentView = _mapView;
    }

    return self;
}

- (GMSMapView *)mapView
{
    return _mapView;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    const auto &oldViewProps = *std::static_pointer_cast<GoogleMapViewProps const>(_props);
    const auto &newViewProps = *std::static_pointer_cast<GoogleMapViewProps const>(props);

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

- (void)mountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
    if ([childComponentView isKindOfClass:[MapMarkerView class]]) {
        MapMarkerView *markerView = (MapMarkerView *)childComponentView;
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = markerView.coordinate;
        marker.title = markerView.title;
        marker.snippet = markerView.markerDescription;
        marker.map = _mapView;

        NSNumber *key = @((NSUInteger)childComponentView);
        _markers[key] = marker;
    }
}

- (void)unmountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
    if ([childComponentView isKindOfClass:[MapMarkerView class]]) {
        NSNumber *key = @((NSUInteger)childComponentView);
        GMSMarker *marker = _markers[key];
        if (marker) {
            marker.map = nil;
            [_markers removeObjectForKey:key];
        }
    }
}

Class<RCTComponentViewProtocol> GoogleMapViewCls(void)
{
    return GoogleMapView.class;
}

@end
