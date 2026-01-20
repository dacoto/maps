#import <MapKit/MapKit.h>
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LuggMapsAppleMapViewContent : MKMapView
@end

@interface LuggMapsAppleMapView : RCTViewComponentView

- (MKMapView *)mapView;

@end

NS_ASSUME_NONNULL_END
