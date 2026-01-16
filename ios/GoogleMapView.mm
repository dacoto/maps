#import "GoogleMapView.h"
#import "MapMarkerView.h"

#import <react/renderer/components/RNMapsSpec/ComponentDescriptors.h>
#import <react/renderer/components/RNMapsSpec/EventEmitters.h>
#import <react/renderer/components/RNMapsSpec/Props.h>
#import <react/renderer/components/RNMapsSpec/RCTComponentViewHelpers.h>

#import "RCTFabricComponentsPlugins.h"

using namespace facebook::react;

#import "MapWrapperView.h"

static NSString *const kDemoMapId = @"DEMO_MAP_ID";

@interface GoogleMapView () <RCTGoogleMapViewViewProtocol, GMSMapViewDelegate,
                             MapMarkerViewDelegate>
@end

@implementation GoogleMapView {
  GMSMapView *_mapView;
  MapWrapperView *_mapWrapperView;
  BOOL _isMapReady;
  NSString *_mapId;
  NSMutableArray<MapMarkerView *> *_pendingMarkerViews;
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
    [self syncMarkerView:markerView caller:@"mountChildComponentView"];
  }
}

- (void)unmountChildComponentView:
            (UIView<RCTComponentViewProtocol> *)childComponentView
                            index:(NSInteger)index {
  if ([childComponentView isKindOfClass:[MapMarkerView class]]) {
    MapMarkerView *markerView = (MapMarkerView *)childComponentView;
    GMSAdvancedMarker *marker = (GMSAdvancedMarker *)markerView.marker;
    if (marker) {
      marker.iconView = nil;
      marker.map = nil;
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

  [_pendingMarkerViews removeAllObjects];
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
}

- (GMSMapView *)mapView {
  return _mapView;
}

#pragma mark - GMSMapViewDelegate

- (void)mapViewDidFinishTileRendering:(GMSMapView *)mapView {
  // Map tiles finished rendering
}

#pragma mark - MapMarkerViewDelegate

- (void)markerViewDidLayout:(MapMarkerView *)markerView {
  [self syncMarkerView:markerView caller:@"markerViewDidLayout"];
}

- (void)markerViewDidUpdate:(MapMarkerView *)markerView {
  [self syncMarkerView:markerView caller:@"markerViewDidUpdate"];
}

#pragma mark - Marker Management

- (void)syncMarkerView:(MapMarkerView *)markerView caller:(NSString *)caller {
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

  for (MapMarkerView *markerView in _pendingMarkerViews) {
    [self addMarkerViewToMap:markerView];
  }
  [_pendingMarkerViews removeAllObjects];
}

- (void)addMarkerViewToMap:(MapMarkerView *)markerView {
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

Class<RCTComponentViewProtocol> GoogleMapViewCls(void) {
  return GoogleMapView.class;
}

@end
