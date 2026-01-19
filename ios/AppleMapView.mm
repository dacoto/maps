#import "AppleMapView.h"
#import "MapWrapperView.h"
#import "MarkerView.h"
#import "PolylineView.h"
#import "core/PolylineRenderer.h"
#import "extensions/MKMapView+Zoom.h"

#import <react/renderer/components/RNMapsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNMapsSpec/EventEmitters.h>
#import <react/renderer/components/RNMapsSpec/Props.h>
#import <react/renderer/components/RNMapsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

@interface AppleMarkerAnnotation : NSObject <MKAnnotation>
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, copy, nullable) NSString *subtitle;
@property(nonatomic, strong) MarkerView *markerView;
@property(nonatomic, weak) MKAnnotationView *annotationView;
@end

@implementation AppleMarkerAnnotation
@end

@implementation AppleMapViewContent
@end

@interface AppleMapView () <RCTAppleMapViewViewProtocol, MKMapViewDelegate,
                            MarkerViewDelegate, PolylineViewDelegate>
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
  } else if ([childComponentView isKindOfClass:[MarkerView class]]) {
    MarkerView *markerView = (MarkerView *)childComponentView;
    markerView.delegate = self;

    AppleMarkerAnnotation *annotation = [[AppleMarkerAnnotation alloc] init];
    annotation.markerView = markerView;
    markerView.marker = annotation;

    if (_mapView) {
      [_mapView addAnnotation:annotation];
    }

    [self markerViewDidUpdate:markerView];
  } else if ([childComponentView isKindOfClass:[PolylineView class]]) {
    PolylineView *polylineView = (PolylineView *)childComponentView;
    polylineView.delegate = self;
    [self addPolylineViewToMap:polylineView];
  }
}

- (void)unmountChildComponentView:
            (UIView<RCTComponentViewProtocol> *)childComponentView
                            index:(NSInteger)index {
  if ([childComponentView isKindOfClass:[MarkerView class]]) {
    MarkerView *markerView = (MarkerView *)childComponentView;
    markerView.delegate = nil;

    AppleMarkerAnnotation *annotation =
        (AppleMarkerAnnotation *)markerView.marker;

    if (annotation) {
      annotation.markerView = nil;
      annotation.annotationView = nil;
      [_mapView removeAnnotation:annotation];
      markerView.marker = nil;
    }
  } else if ([childComponentView isKindOfClass:[PolylineView class]]) {
    PolylineView *polylineView = (PolylineView *)childComponentView;
    polylineView.delegate = nil;
    MKPolyline *polyline = (MKPolyline *)polylineView.polyline;
    if (polyline) {
      [_mapView removeOverlay:polyline];
      polylineView.polyline = nil;
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
    if ([subview isKindOfClass:[MarkerView class]]) {
      MarkerView *markerView = (MarkerView *)subview;
      AppleMarkerAnnotation *annotation =
          (AppleMarkerAnnotation *)markerView.marker;
      if (annotation) {
        [_mapView addAnnotation:annotation];
      }
    } else if ([subview isKindOfClass:[PolylineView class]]) {
      PolylineView *polylineView = (PolylineView *)subview;
      [self addPolylineViewToMap:polylineView];
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

- (void)updateAnnotationViewFrame:(AppleMarkerAnnotation *)annotation {
  MKAnnotationView *annotationView = annotation.annotationView;
  MarkerView *markerView = annotation.markerView;

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

#pragma mark - PolylineViewDelegate

- (void)polylineViewDidUpdate:(PolylineView *)polylineView {
  [self syncPolylineView:polylineView];
}

#pragma mark - Polyline Management

- (void)addPolylineViewToMap:(PolylineView *)polylineView {
  if (!_mapView) {
    return;
  }

  NSArray<CLLocation *> *coordinates = polylineView.coordinates;
  if (coordinates.count == 0) {
    return;
  }

  CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(
      sizeof(CLLocationCoordinate2D) * coordinates.count);
  for (NSUInteger i = 0; i < coordinates.count; i++) {
    coords[i] = coordinates[i].coordinate;
  }

  MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords
                                                       count:coordinates.count];
  free(coords);

  polylineView.polyline = polyline;
  [_mapView addOverlay:polyline];
}

- (void)syncPolylineView:(PolylineView *)polylineView {
  if (!_mapView) {
    return;
  }

  MKPolyline *oldPolyline = (MKPolyline *)polylineView.polyline;
  if (oldPolyline) {
    [_mapView removeOverlay:oldPolyline];
    polylineView.polyline = nil;
  }

  [self addPolylineViewToMap:polylineView];
}

- (PolylineView *)findPolylineViewForOverlay:(id<MKOverlay>)overlay {
  for (UIView *subview in self.subviews) {
    if ([subview isKindOfClass:[PolylineView class]]) {
      PolylineView *polylineView = (PolylineView *)subview;
      if (polylineView.polyline == overlay) {
        return polylineView;
      }
    }
  }
  return nil;
}

#pragma mark - MarkerViewDelegate

- (void)markerViewDidLayout:(MarkerView *)markerView {
  AppleMarkerAnnotation *annotation =
      (AppleMarkerAnnotation *)markerView.marker;
  if (annotation) {
    [self updateAnnotationViewFrame:annotation];
  }
}

- (void)markerViewDidUpdate:(MarkerView *)markerView {
  AppleMarkerAnnotation *annotation =
      (AppleMarkerAnnotation *)markerView.marker;

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
  if (![annotation isKindOfClass:[AppleMarkerAnnotation class]]) {
    return nil;
  }

  AppleMarkerAnnotation *markerAnnotation = (AppleMarkerAnnotation *)annotation;
  MarkerView *markerView = markerAnnotation.markerView;

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

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay {
  if ([overlay isKindOfClass:[MKPolyline class]]) {
    PolylineView *polylineView = [self findPolylineViewForOverlay:overlay];
    MKPolyline *polyline = (MKPolyline *)overlay;

    if (polylineView) {
      NSArray<UIColor *> *colors = polylineView.strokeColors;

      PolylineRenderer *renderer =
          [[PolylineRenderer alloc] initWithPolyline:polyline];
      renderer.lineWidth = polylineView.strokeWidth;
      renderer.strokeColor = colors.firstObject;
      if (colors.count > 1) {
        renderer.strokeColors = colors;
      }
      return renderer;
    }

    MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithPolyline:polyline];
    return renderer;
  }
  return nil;
}

#pragma mark - Commands

- (void)fitCoordinates:(NSArray *)coordinates
               padding:(double)padding
              duration:(double)duration {
  if (!_mapView || coordinates.count == 0) {
    return;
  }

  CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(
      sizeof(CLLocationCoordinate2D) * coordinates.count);
  for (NSUInteger i = 0; i < coordinates.count; i++) {
    NSDictionary *coord = coordinates[i];
    coords[i] = CLLocationCoordinate2DMake([coord[@"latitude"] doubleValue],
                                           [coord[@"longitude"] doubleValue]);
  }

  MKMapRect mapRect = MKMapRectNull;
  for (NSUInteger i = 0; i < coordinates.count; i++) {
    MKMapPoint point = MKMapPointForCoordinate(coords[i]);
    MKMapRect pointRect = MKMapRectMake(point.x, point.y, 0, 0);
    mapRect = MKMapRectUnion(mapRect, pointRect);
  }
  free(coords);

  UIEdgeInsets edgePadding =
      UIEdgeInsetsMake(padding, padding, padding, padding);

  if (duration < 0) {
    [_mapView setVisibleMapRect:mapRect edgePadding:edgePadding animated:YES];
  } else if (duration > 0) {
    [UIView animateWithDuration:duration / 1000.0
                     animations:^{
                       [self->_mapView setVisibleMapRect:mapRect
                                             edgePadding:edgePadding
                                                animated:NO];
                     }];
  } else {
    [_mapView setVisibleMapRect:mapRect edgePadding:edgePadding animated:NO];
  }
}

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args {
  if ([commandName isEqualToString:@"moveCamera"]) {
    double latitude = [args[0] doubleValue];
    double longitude = [args[1] doubleValue];
    double zoom = [args[2] doubleValue];
    double duration = [args[3] doubleValue];

    if (duration < 0) {
      [self setCameraWithLatitude:latitude
                        longitude:longitude
                             zoom:zoom
                         animated:YES];
    } else if (duration > 0) {
      CLLocationCoordinate2D center =
          CLLocationCoordinate2DMake(latitude, longitude);
      MKCoordinateRegion region = [_mapView regionForCenterCoordinate:center
                                                            zoomLevel:zoom];
      [UIView animateWithDuration:duration / 1000.0
                       animations:^{
                         [self->_mapView setRegion:region animated:NO];
                       }];
    } else {
      [self setCameraWithLatitude:latitude
                        longitude:longitude
                             zoom:zoom
                         animated:NO];
    }
  } else if ([commandName isEqualToString:@"fitCoordinates"]) {
    NSArray *coordinates = args[0];
    double padding = [args[1] doubleValue];
    double duration = [args[2] doubleValue];
    [self fitCoordinates:coordinates padding:padding duration:duration];
  }
}

Class<RCTComponentViewProtocol> AppleMapViewCls(void) {
  return AppleMapView.class;
}

@end
