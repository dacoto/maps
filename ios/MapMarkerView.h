#import <CoreLocation/CoreLocation.h>
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MapMarkerView;

@protocol MapMarkerViewDelegate <NSObject>
@optional
- (void)markerViewDidUpdateLayout:(MapMarkerView *)markerView;
- (void)markerViewDidUpdateProps:(MapMarkerView *)markerView;
@end

@interface MapMarkerView : RCTViewComponentView

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly, nullable) NSString *title;
@property(nonatomic, readonly, nullable) NSString *markerDescription;
@property(nonatomic, readonly) CGPoint anchor;
@property(nonatomic, readonly) BOOL hasCustomView;
@property(nonatomic, weak, nullable) id<MapMarkerViewDelegate> delegate;
@property(nonatomic, strong, nullable) NSObject *annotation;

@end

NS_ASSUME_NONNULL_END
