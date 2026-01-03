#import <React/RCTViewComponentView.h>
#import <GoogleMaps/GoogleMaps.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoogleMapViewContent : GMSMapView
@end

@interface GoogleMapView : RCTViewComponentView

- (GMSMapView *)mapView;

@end

NS_ASSUME_NONNULL_END
