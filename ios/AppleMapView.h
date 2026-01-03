#import <React/RCTViewComponentView.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppleMapViewContent : MKMapView
@end

@interface AppleMapView : RCTViewComponentView

- (MKMapView *)mapView;

@end

NS_ASSUME_NONNULL_END
