#import "GoogleMapView.h"
#import "MarkerView.h"
#import "PolylineView.h"

#import <react/renderer/components/RNMapsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNMapsSpec/EventEmitters.h>
#import <react/renderer/components/RNMapsSpec/Props.h>
#import <react/renderer/components/RNMapsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

#import "MapWrapperView.h"

static NSString *const kDemoMapId = @"DEMO_MAP_ID";

@interface GoogleMapView () <RCTGoogleMapViewViewProtocol, GMSMapViewDelegate,
                             MarkerViewDelegate, PolylineViewDelegate>
@end

@implementation GoogleMapView {
  GMSMapView *_mapView;
  MapWrapperView *_mapWrapperView;
  BOOL _isMapReady;
  NSString *_mapId;
  NSMutableArray<MarkerView *> *_pendingMarkerViews;
  NSMutableArray<PolylineView *> *_pendingPolylineViews;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider {
  return concreteComponentDescriptorProvider<
      GoogleMapViewComponentDescriptor>();
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    static const auto defaultProps =
        std::make_shared<const GoogleMapViewProps>();
    _props = defaultProps;

    _isMapReady = NO;
    _mapId = kDemoMapId;
    _pendingMarkerViews = [NSMutableArray array];
    _pendingPolylineViews = [NSMutableArray array];
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
    [self syncMarkerView:markerView caller:@"mountChildComponentView"];
  } else if ([childComponentView isKindOfClass:[PolylineView class]]) {
    PolylineView *polylineView = (PolylineView *)childComponentView;
    polylineView.delegate = self;
    [self syncPolylineView:polylineView];
  }
}

- (void)unmountChildComponentView:
            (UIView<RCTComponentViewProtocol> *)childComponentView
                            index:(NSInteger)index {
  if ([childComponentView isKindOfClass:[MarkerView class]]) {
    MarkerView *markerView = (MarkerView *)childComponentView;
    GMSAdvancedMarker *marker = (GMSAdvancedMarker *)markerView.marker;
    if (marker) {
      marker.iconView = nil;
      marker.map = nil;
      markerView.marker = nil;
    }
  } else if ([childComponentView isKindOfClass:[PolylineView class]]) {
    PolylineView *polylineView = (PolylineView *)childComponentView;
    GMSPolyline *polyline = (GMSPolyline *)polylineView.polyline;
    if (polyline) {
      polyline.map = nil;
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

  [_pendingMarkerViews removeAllObjects];
  [_pendingPolylineViews removeAllObjects];
  [_mapView clear];
  [_mapView removeFromSuperview];
  _mapView = nil;
  _mapWrapperView = nil;
  _isMapReady = NO;
}

#pragma mark - Map Initialization

- (void)initializeMap {
  if (_mapView || !_mapWrapperView) {
    return;
  }

  GMSMapID *gmsMapId;
  if ([_mapId isEqualToString:kDemoMapId] || _mapId.length == 0) {
    gmsMapId = [GMSMapID demoMapID];
  } else {
    gmsMapId = [GMSMapID mapIDWithIdentifier:_mapId];
  }

  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.78
                                                          longitude:-122.43
                                                               zoom:14];

  GMSMapViewOptions *options = [[GMSMapViewOptions alloc] init];
  options.frame = _mapWrapperView.bounds;
  options.camera = camera;
  options.mapID = gmsMapId;

  _mapView = [[GMSMapView alloc] initWithOptions:options];
  _mapView.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _mapView.delegate = self;

  [_mapWrapperView addSubview:_mapView];

  _isMapReady = YES;
  [self processPendingMarkers];
  [self processPendingPolylines];
}

- (GMSMapView *)mapView {
  return _mapView;
}

#pragma mark - GMSMapViewDelegate

- (void)mapViewDidFinishTileRendering:(GMSMapView *)mapView {
  // Map tiles finished rendering
}

#pragma mark - PolylineViewDelegate

- (void)polylineViewDidUpdate:(PolylineView *)polylineView {
  [self syncPolylineView:polylineView];
}

#pragma mark - MarkerViewDelegate

- (void)markerViewDidLayout:(MarkerView *)markerView {
  [self syncMarkerView:markerView caller:@"markerViewDidLayout"];
}

- (void)markerViewDidUpdate:(MarkerView *)markerView {
  [self syncMarkerView:markerView caller:@"markerViewDidUpdate"];
}

#pragma mark - Marker Management

- (void)syncMarkerView:(MarkerView *)markerView caller:(NSString *)caller {
  if (!_mapView) {
    if (![_pendingMarkerViews containsObject:markerView]) {
      [_pendingMarkerViews addObject:markerView];
    }
    return;
  }

  if (!markerView.marker) {
    [self addMarkerViewToMap:markerView];
    return;
  }

  GMSAdvancedMarker *marker = (GMSAdvancedMarker *)markerView.marker;
  marker.position = markerView.coordinate;
  marker.title = markerView.title;
  marker.snippet = markerView.markerDescription;
  marker.groundAnchor = markerView.anchor;

  if (markerView.hasCustomView) {
    UIView *iconView = markerView.iconView;
    [iconView removeFromSuperview];
    marker.iconView = iconView;
  } else {
    marker.iconView = nil;
  }
}

- (void)processPendingMarkers {
  if (!_mapView) {
    return;
  }

  for (MarkerView *markerView in _pendingMarkerViews) {
    [self addMarkerViewToMap:markerView];
  }
  [_pendingMarkerViews removeAllObjects];
}

- (void)addMarkerViewToMap:(MarkerView *)markerView {
  if (!_mapView) {
    RCTLogWarn(@"LuggMaps: addMarkerViewToMap called without a map");
    return;
  }

  UIView *iconView = markerView.iconView;
  [iconView removeFromSuperview];

  GMSAdvancedMarker *marker = [[GMSAdvancedMarker alloc] init];
  marker.position = markerView.coordinate;
  marker.title = markerView.title;
  marker.snippet = markerView.markerDescription;
  marker.collisionBehavior = GMSCollisionBehaviorRequired;

  if (markerView.hasCustomView) {
    marker.iconView = iconView;
  }

  marker.groundAnchor = markerView.anchor;
  marker.map = _mapView;

  markerView.marker = marker;
}

#pragma mark - Polyline Management

- (void)syncPolylineView:(PolylineView *)polylineView {
  if (!_mapView) {
    if (![_pendingPolylineViews containsObject:polylineView]) {
      [_pendingPolylineViews addObject:polylineView];
    }
    return;
  }

  if (!polylineView.polyline) {
    [self addPolylineViewToMap:polylineView];
    return;
  }

  GMSPolyline *polyline = (GMSPolyline *)polylineView.polyline;
  GMSMutablePath *path = [GMSMutablePath path];
  for (CLLocation *location in polylineView.coordinates) {
    [path addCoordinate:location.coordinate];
  }
  polyline.path = path;
  polyline.strokeWidth = polylineView.strokeWidth;

  NSArray<UIColor *> *colors = polylineView.strokeColors;
  if (colors.count > 1) {
    polyline.spans = [self getOrCreateSpansForPolylineView:polylineView];
  } else {
    polyline.strokeColor = colors.firstObject;
  }
}

- (void)processPendingPolylines {
  if (!_mapView) {
    return;
  }

  for (PolylineView *polylineView in _pendingPolylineViews) {
    [self addPolylineViewToMap:polylineView];
  }
  [_pendingPolylineViews removeAllObjects];
}

- (void)addPolylineViewToMap:(PolylineView *)polylineView {
  if (!_mapView) {
    return;
  }

  GMSMutablePath *path = [GMSMutablePath path];
  for (CLLocation *location in polylineView.coordinates) {
    [path addCoordinate:location.coordinate];
  }

  GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
  polyline.strokeWidth = polylineView.strokeWidth;

  NSArray<UIColor *> *colors = polylineView.strokeColors;
  if (colors.count > 1) {
    polyline.spans = [self getOrCreateSpansForPolylineView:polylineView];
  } else {
    polyline.strokeColor = colors.firstObject;
  }

  polyline.map = _mapView;

  polylineView.polyline = polyline;
}

- (NSArray<GMSStyleSpan *> *)getOrCreateSpansForPolylineView:(PolylineView *)polylineView {
  if (polylineView.cachedSpans) {
    return (NSArray<GMSStyleSpan *> *)polylineView.cachedSpans;
  }

  NSArray<UIColor *> *colors = polylineView.strokeColors;
  NSMutableArray<GMSStyleSpan *> *spans = [NSMutableArray array];
  NSUInteger segmentCount = polylineView.coordinates.count - 1;
  for (NSUInteger i = 0; i < segmentCount; i++) {
    UIColor *color = colors[i % colors.count];
    GMSStrokeStyle *style = [GMSStrokeStyle solidColor:color];
    [spans addObject:[GMSStyleSpan spanWithStyle:style]];
  }

  polylineView.cachedSpans = spans;
  return spans;
}

#pragma mark - Property Setters

- (void)updateProps:(Props::Shared const &)props
           oldProps:(Props::Shared const &)oldProps {
  const auto &oldViewProps =
      *std::static_pointer_cast<GoogleMapViewProps const>(_props);
  const auto &newViewProps =
      *std::static_pointer_cast<GoogleMapViewProps const>(props);

  if (_mapView == nil) {
    NSString *newMapId =
        [NSString stringWithUTF8String:newViewProps.mapId.c_str()];
    if (newMapId.length > 0) {
      _mapId = newMapId;
    }
  }

  if (_mapView) {
    if (newViewProps.initialCoordinate.latitude !=
            oldViewProps.initialCoordinate.latitude ||
        newViewProps.initialCoordinate.longitude !=
            oldViewProps.initialCoordinate.longitude ||
        newViewProps.initialZoom != oldViewProps.initialZoom) {

      GMSCameraPosition *camera = [GMSCameraPosition
          cameraWithLatitude:newViewProps.initialCoordinate.latitude
                   longitude:newViewProps.initialCoordinate.longitude
                        zoom:newViewProps.initialZoom];
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
  }

  [super updateProps:props oldProps:oldProps];
}

#pragma mark - Commands

- (void)moveCamera:(double)latitude
         longitude:(double)longitude
              zoom:(double)zoom
          duration:(double)duration {
  if (!_mapView) {
    return;
  }

  GMSCameraPosition *camera =
      [GMSCameraPosition cameraWithLatitude:latitude
                                  longitude:longitude
                                       zoom:(float)zoom];
  if (duration < 0) {
    [_mapView animateToCameraPosition:camera];
  } else if (duration > 0) {
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration / 1000.0];
    [_mapView animateToCameraPosition:camera];
    [CATransaction commit];
  } else {
    [_mapView setCamera:camera];
  }
}

- (void)fitCoordinates:(NSArray *)coordinates
               padding:(double)padding
              duration:(double)duration {
  if (!_mapView || coordinates.count == 0) {
    return;
  }

  GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
  for (NSDictionary *coord in coordinates) {
    double lat = [coord[@"latitude"] doubleValue];
    double lng = [coord[@"longitude"] doubleValue];
    bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(lat, lng)];
  }

  GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds:bounds
                                                 withPadding:padding];

  if (duration < 0) {
    [_mapView animateWithCameraUpdate:cameraUpdate];
  } else if (duration > 0) {
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration / 1000.0];
    [_mapView animateWithCameraUpdate:cameraUpdate];
    [CATransaction commit];
  } else {
    [_mapView moveCamera:cameraUpdate];
  }
}

- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args {
  if ([commandName isEqualToString:@"moveCamera"]) {
    double latitude = [args[0] doubleValue];
    double longitude = [args[1] doubleValue];
    double zoom = [args[2] doubleValue];
    double duration = [args[3] doubleValue];
    [self moveCamera:latitude longitude:longitude zoom:zoom duration:duration];
  } else if ([commandName isEqualToString:@"fitCoordinates"]) {
    NSArray *coordinates = args[0];
    double padding = [args[1] doubleValue];
    double duration = [args[2] doubleValue];
    [self fitCoordinates:coordinates padding:padding duration:duration];
  }
}

Class<RCTComponentViewProtocol> GoogleMapViewCls(void) {
  return GoogleMapView.class;
}

@end
