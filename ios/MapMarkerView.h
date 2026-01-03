#import <React/RCTViewComponentView.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapMarkerView : RCTViewComponentView

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, nullable) NSString *title;
@property (nonatomic, readonly, nullable) NSString *markerDescription;

@end

NS_ASSUME_NONNULL_END
