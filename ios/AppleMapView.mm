#import "AppleMapView.h"
#import "MapMarkerView.h"

#import <react/renderer/components/RNMapsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNMapsSpec/EventEmitters.h>
#import <react/renderer/components/RNMapsSpec/Props.h>
#import <react/renderer/components/RNMapsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface AppleMapMarkerAnnotation : NSObject <MKAnnotation>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *subtitle;
@property (nonatomic, weak) MapMarkerView *markerView;
@end

@implementation AppleMapMarkerAnnotation
@end

@implementation AppleMapViewContent
@end

@interface AppleMapView () <RCTAppleMapViewViewProtocol>
@end

@implementation AppleMapView {
    AppleMapViewContent *_mapView;
    NSMutableDictionary<NSNumber *, AppleMapMarkerAnnotation *> *_markerAnnotations;
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
        _markerAnnotations = [NSMutableDictionary new];

        MKCoordinateRegion region = MKCoordinateRegionMake(
            CLLocationCoordinate2DMake(37.7749, -122.4194),
            MKCoordinateSpanMake(0.0922, 0.0421)
        );
        [_mapView setRegion:region animated:NO];

        self.contentView = _mapView;
    }

    return self;
}

- (MKMapView *)mapView
{
    return _mapView;
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

- (void)mountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
    if ([childComponentView isKindOfClass:[MapMarkerView class]]) {
        MapMarkerView *marker = (MapMarkerView *)childComponentView;
        AppleMapMarkerAnnotation *annotation = [[AppleMapMarkerAnnotation alloc] init];
        annotation.coordinate = marker.coordinate;
        annotation.title = marker.title;
        annotation.subtitle = marker.markerDescription;
        annotation.markerView = marker;

        NSNumber *key = @((NSUInteger)childComponentView);
        _markerAnnotations[key] = annotation;
        [_mapView addAnnotation:annotation];
    }
}

- (void)unmountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index
{
    if ([childComponentView isKindOfClass:[MapMarkerView class]]) {
        NSNumber *key = @((NSUInteger)childComponentView);
        AppleMapMarkerAnnotation *annotation = _markerAnnotations[key];
        if (annotation) {
            [_mapView removeAnnotation:annotation];
            [_markerAnnotations removeObjectForKey:key];
        }
    }
}

Class<RCTComponentViewProtocol> AppleMapViewCls(void)
{
    return AppleMapView.class;
}

@end
