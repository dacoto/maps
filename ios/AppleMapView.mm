#import "AppleMapView.h"
#import "MapMarkerView.h"
#import "extensions/MKMapView+Zoom.h"

#import <react/renderer/components/RNMapsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNMapsSpec/EventEmitters.h>
#import <react/renderer/components/RNMapsSpec/Props.h>
#import <react/renderer/components/RNMapsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface AppleMapMarkerAnnotation : NSObject <MKAnnotation>
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, copy, nullable) NSString *subtitle;
@property(nonatomic, strong) MapMarkerView *markerView;
@property(nonatomic, weak) MKAnnotationView *annotationView;
@end

@implementation AppleMapMarkerAnnotation
@end

@implementation AppleMapViewContent
@end

@interface AppleMapView () <RCTAppleMapViewViewProtocol, MKMapViewDelegate,
                            MapMarkerViewDelegate>
@end

@implementation AppleMapView {
  AppleMapViewContent *_mapView;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider {
  return concreteComponentDescriptorProvider<AppleMapViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps =
        std::make_shared<const AppleMapViewProps>();
    _props = defaultProps;

    _mapView = [[AppleMapViewContent alloc] init];
    _mapView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.delegate = self;

    // Set default camera
    [self setCameraWithLatitude:37.7749
                      longitude:-122.4194
                           zoom:10
                       animated:NO];

    self.contentView = _mapView;
  }

  return self;
}

- (void)setCameraWithLatitude:(double)latitude
                    longitude:(double)longitude
                         zoom:(double)zoom
                     animated:(BOOL)animated {
  CLLocationCoordinate2D center =
      CLLocationCoordinate2DMake(latitude, longitude);
  [_mapView setCenterCoordinate:center zoomLevel:zoom animated:animated];
}

- (MKMapView *)mapView {
  return _mapView;
}

// TODO: no need for individual comparison
- (void)updateProps:(Props::Shared const &)props
           oldProps:(Props::Shared const &)oldProps {
  const auto &oldViewProps =
      *std::static_pointer_cast<AppleMapViewProps const>(_props);
  const auto &newViewProps =
      *std::static_pointer_cast<AppleMapViewProps const>(props);

  if (newViewProps.initialCoordinate.latitude !=
          oldViewProps.initialCoordinate.latitude ||
      newViewProps.initialCoordinate.longitude !=
          oldViewProps.initialCoordinate.longitude ||
      newViewProps.initialZoom != oldViewProps.initialZoom) {

    [self setCameraWithLatitude:newViewProps.initialCoordinate.latitude
                      longitude:newViewProps.initialCoordinate.longitude
                           zoom:newViewProps.initialZoom
                       animated:NO];
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

- (void)mountChildComponentView:
            (UIView<RCTComponentViewProtocol> *)childComponentView
                          index:(NSInteger)index {
  if ([childComponentView isKindOfClass:[MapMarkerView class]]) {
    MapMarkerView *markerView = (MapMarkerView *)childComponentView;
    markerView.delegate = self;

    AppleMapMarkerAnnotation *annotation =
        [[AppleMapMarkerAnnotation alloc] init];
    annotation.markerView = markerView;
    markerView.annotation = annotation;

    [_mapView addAnnotation:annotation];
    [self markerViewDidUpdateProps:markerView];
  }
}

- (void)unmountChildComponentView:
            (UIView<RCTComponentViewProtocol> *)childComponentView
                            index:(NSInteger)index {
  if ([childComponentView isKindOfClass:[MapMarkerView class]]) {
    MapMarkerView *markerView = (MapMarkerView *)childComponentView;
    markerView.delegate = nil;

    [markerView removeFromSuperview];

    AppleMapMarkerAnnotation *annotation =
        (AppleMapMarkerAnnotation *)markerView.annotation;

    if (annotation) {
      annotation.markerView = nil;
      annotation.annotationView = nil;
      [_mapView removeAnnotation:annotation];
      markerView.annotation = nil;
    }
  }
}

- (void)updateAnnotationViewFrame:(AppleMapMarkerAnnotation *)annotation {
  MKAnnotationView *annotationView = annotation.annotationView;
  MapMarkerView *markerView = annotation.markerView;

  if (!annotationView || !markerView) {
    return;
  }

  CGRect frame = markerView.frame;
  if (frame.size.width > 0 && frame.size.height > 0) {
    annotationView.frame = frame;

    CGPoint anchor = markerView.anchor;
    annotationView.centerOffset =
        CGPointMake(frame.size.width * (anchor.x - 0.5),
                    -frame.size.height * (anchor.y - 0.5));
  }
}

#pragma mark - MapMarkerViewDelegate

- (void)markerViewDidUpdateLayout:(MapMarkerView *)markerView {
  AppleMapMarkerAnnotation *annotation =
      (AppleMapMarkerAnnotation *)markerView.annotation;
  if (annotation) {
    [self updateAnnotationViewFrame:annotation];
  }
}

- (void)markerViewDidUpdateProps:(MapMarkerView *)markerView {
  AppleMapMarkerAnnotation *annotation =
      (AppleMapMarkerAnnotation *)markerView.annotation;

  if (!annotation) {
    RCTLogWarn(@"markerViewDidUpdateProps called without annotation");
    return;
  }

  annotation.coordinate = markerView.coordinate;
  annotation.title = markerView.title;
  annotation.subtitle = markerView.markerDescription;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
  if (![annotation isKindOfClass:[AppleMapMarkerAnnotation class]]) {
    return nil;
  }

  AppleMapMarkerAnnotation *markerAnnotation =
      (AppleMapMarkerAnnotation *)annotation;
  MapMarkerView *markerView = markerAnnotation.markerView;

  if (!markerView || !markerView.hasCustomView) {
    return nil;
  }

  MKAnnotationView *annotationView =
      [[MKAnnotationView alloc] initWithAnnotation:annotation
                                   reuseIdentifier:nil];
  annotationView.canShowCallout = YES;
  annotationView.displayPriority = MKFeatureDisplayPriorityRequired;
  annotationView.collisionMode = MKAnnotationViewCollisionModeNone;

  // Add marker view as a subview
  [annotationView addSubview:markerView];

  // Store reference for frame updates
  markerAnnotation.annotationView = annotationView;

  return annotationView;
}

Class<RCTComponentViewProtocol> AppleMapViewCls(void) {
  return AppleMapView.class;
}

@end
