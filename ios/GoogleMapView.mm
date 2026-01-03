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

@interface GoogleMapView () <RCTGoogleMapViewViewProtocol,
                             MapMarkerViewDelegate>
@end

@implementation GoogleMapView {
  GoogleMapViewContent *_mapView;
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

    [self setupMapView:defaultProps];
  }

  return self;
}

- (void)setupMapView:(std::shared_ptr<const GoogleMapViewProps>)props {
  NSString *mapId = [NSString stringWithUTF8String:props->mapId.c_str()];
  GMSMapID *gmsMapId;

  if ([mapId isEqualToString:@"DEMO_MAP_ID"] || mapId.length == 0) {
    gmsMapId = [GMSMapID demoMapID];
  } else {
    gmsMapId = [GMSMapID mapIDWithIdentifier:mapId];
  }

  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.7749
                                                          longitude:-122.4194
                                                               zoom:10];

  GMSMapViewOptions *options = [[GMSMapViewOptions alloc] init];
  options.frame = self.bounds;
  options.camera = camera;
  options.mapID = gmsMapId;

  _mapView = [[GoogleMapViewContent alloc] initWithOptions:options];
  _mapView.autoresizingMask =
      UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

  self.contentView = _mapView;
}

- (GMSMapView *)mapView {
  return _mapView;
}

// TODO: no need to manually compare individual props
- (void)updateProps:(Props::Shared const &)props
           oldProps:(Props::Shared const &)oldProps {
  const auto &oldViewProps =
      *std::static_pointer_cast<GoogleMapViewProps const>(_props);
  const auto &newViewProps =
      *std::static_pointer_cast<GoogleMapViewProps const>(props);

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

  [super updateProps:props oldProps:oldProps];
}

- (void)mountChildComponentView:
            (UIView<RCTComponentViewProtocol> *)childComponentView
                          index:(NSInteger)index {
  if ([childComponentView isKindOfClass:[MapMarkerView class]]) {
    MapMarkerView *markerView = (MapMarkerView *)childComponentView;
    markerView.delegate = self;

    GMSAdvancedMarker *marker = [[GMSAdvancedMarker alloc] init];
    marker.collisionBehavior = GMSCollisionBehaviorRequired;
    marker.map = _mapView;
    markerView.annotation = marker;

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

    GMSAdvancedMarker *marker = (GMSAdvancedMarker *)markerView.annotation;
    if (marker) {
      marker.iconView = nil;
      marker.map = nil;
      markerView.annotation = nil;
    }
  }
}

#pragma mark - MapMarkerViewDelegate

- (void)markerViewDidUpdateLayout:(MapMarkerView *)markerView {
  CGRect frame = markerView.frame;
  if (frame.size.width <= 0 || frame.size.height <= 0) {
    return;
  }

  GMSAdvancedMarker *marker = (GMSAdvancedMarker *)markerView.annotation;
  if (marker && markerView.hasCustomView) {
    marker.iconView = nil;
    marker.iconView = markerView;
  }
}

- (void)markerViewDidUpdateProps:(MapMarkerView *)markerView {
  GMSAdvancedMarker *marker = (GMSAdvancedMarker *)markerView.annotation;

  if (!marker) {
    RCTLogWarn(@"markerViewDidUpdateProps called without marker");
    return;
  }

  marker.position = markerView.coordinate;
  marker.title = markerView.title;
  marker.snippet = markerView.markerDescription;

  if (markerView.hasCustomView) {
    marker.groundAnchor = CGPointMake(markerView.anchor.x, markerView.anchor.y);
    marker.iconView = markerView;
  } else {
    marker.iconView = nil;
  }
}

Class<RCTComponentViewProtocol> GoogleMapViewCls(void) {
  return GoogleMapView.class;
}

@end
