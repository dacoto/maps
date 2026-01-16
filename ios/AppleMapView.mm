#import "AppleMapView.h"
#import "MapMarkerView.h"
#import "MapWrapperView.h"
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
  MapWrapperView *_mapWrapperView;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider {
  return concreteComponentDescriptorProvider<AppleMapViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps =
        std::make_shared<const AppleMapViewProps>();
    _props = defaultProps;
  }

  return self;
}

#pragma mark - View Lifecycle

- (void)mountChildComponentView:
            (UIView<RCTComponentViewProtocol> *)childComponentView
                          index:(NSInteger)index {
  [super mountChildComponentView:childComponentView index:index];

  if ([childComponentView isKindOfClass:[MapWrapperView class]]) {
    _mapWrapperView = (MapWrapperView *)childComponentView;
  } else if ([childComponentView isKindOfClass:[MapMarkerView class]]) {
    MapMarkerView *markerView = (MapMarkerView *)childComponentView;
    markerView.delegate = self;

    AppleMapMarkerAnnotation *annotation =
        [[AppleMapMarkerAnnotation alloc] init];
    annotation.markerView = markerView;
    markerView.marker = annotation;

    if (_mapView) {
      [_mapView addAnnotation:annotation];
    }

    [self markerViewDidUpdate:markerView];
  }
}

- (void)unmountChildComponentView:
            (UIView<RCTComponentViewProtocol> *)childComponentView
                            index:(NSInteger)index {
  if ([childComponentView isKindOfClass:[MapMarkerView class]]) {
    MapMarkerView *markerView = (MapMarkerView *)childComponentView;
    markerView.delegate = nil;

    AppleMapMarkerAnnotation *annotation =
        (AppleMapMarkerAnnotation *)markerView.marker;

    if (annotation) {
      annotation.markerView = nil;
      annotation.annotationView = nil;
      [_mapView removeAnnotation:annotation];
      markerView.marker = nil;
    }
  }

  [super unmountChildComponentView:childComponentView index:index];
}

- (void)didMoveToWindow {
  [super didMoveToWindow];
  if (self.window && !_mapView && _mapWrapperView) {
    [self initializeMap];
  }
}

- (void)prepareForRecycle {
  [super prepareForRecycle];

  [_mapView removeFromSuperview];
  _mapView = nil;
  _mapWrapperView = nil;
}

#pragma mark - Map Initialization

- (void)initializeMap {
  if (_mapView || !_mapWrapperView) {
    return;
  }

  const auto &viewProps =
      *std::static_pointer_cast<AppleMapViewProps const>(_props);

  _mapView = [[AppleMapViewContent alloc] initWithFrame:_mapWrapperView.bounds];
  _mapView.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _mapView.delegate = self;
  _mapView.zoomEnabled = viewProps.zoomEnabled;
  _mapView.scrollEnabled = viewProps.scrollEnabled;
  _mapView.rotateEnabled = viewProps.rotateEnabled;
  _mapView.pitchEnabled = viewProps.pitchEnabled;

  [_mapWrapperView addSubview:_mapView];

  [self setCameraWithLatitude:viewProps.initialCoordinate.latitude
                    longitude:viewProps.initialCoordinate.longitude
                         zoom:viewProps.initialZoom
                     animated:NO];

  // Add annotations for any markers that were mounted before map was ready
  for (UIView *subview in self.subviews) {
    if ([subview isKindOfClass:[MapMarkerView class]]) {
      MapMarkerView *markerView = (MapMarkerView *)subview;
      AppleMapMarkerAnnotation *annotation =
          (AppleMapMarkerAnnotation *)markerView.marker;
      if (annotation) {
        [_mapView addAnnotation:annotation];
      }
    }
  }
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

#pragma mark - Property Setters

- (void)updateProps:(Props::Shared const &)props
           oldProps:(Props::Shared const &)oldProps {
  const auto &oldViewProps =
      *std::static_pointer_cast<AppleMapViewProps const>(_props);
  const auto &newViewProps =
      *std::static_pointer_cast<AppleMapViewProps const>(props);

  if (_mapView) {
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
  }

  [super updateProps:props oldProps:oldProps];
}

#pragma mark - Annotation Helpers

- (void)updateAnnotationViewFrame:(AppleMapMarkerAnnotation *)annotation {
  MKAnnotationView *annotationView = annotation.annotationView;
  MapMarkerView *markerView = annotation.markerView;

  if (!annotationView || !markerView) {
    return;
  }

  UIView *iconView = markerView.iconView;
  CGRect frame = iconView.frame;
  if (frame.size.width > 0 && frame.size.height > 0) {
    annotationView.frame = frame;

    CGPoint anchor = markerView.anchor;
    annotationView.centerOffset =
        CGPointMake(frame.size.width * (anchor.x - 0.5),
                    -frame.size.height * (anchor.y - 0.5));
  }
}

#pragma mark - MapMarkerViewDelegate

- (void)markerViewDidLayout:(MapMarkerView *)markerView {
  AppleMapMarkerAnnotation *annotation =
      (AppleMapMarkerAnnotation *)markerView.marker;
  if (annotation) {
    [self updateAnnotationViewFrame:annotation];
  }
}

- (void)markerViewDidUpdate:(MapMarkerView *)markerView {
  AppleMapMarkerAnnotation *annotation =
      (AppleMapMarkerAnnotation *)markerView.marker;

  if (!annotation) {
    RCTLogWarn(@"markerViewDidUpdate called without annotation");
    return;
  }

  annotation.coordinate = markerView.coordinate;
  annotation.title = markerView.title;
  annotation.subtitle = markerView.markerDescription;

  [self updateAnnotationViewFrame:annotation];
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

  UIView *iconView = markerView.iconView;
  [iconView removeFromSuperview];
  [annotationView addSubview:iconView];

  markerAnnotation.annotationView = annotationView;

  return annotationView;
}

Class<RCTComponentViewProtocol> AppleMapViewCls(void) {
  return AppleMapView.class;
}

@end
