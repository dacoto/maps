#import <CoreLocation/CoreLocation.h>
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LuggMapsMarkerView;

@protocol LuggMapsMarkerViewDelegate <NSObject>
@optional
- (void)markerViewDidLayout:(LuggMapsMarkerView *)markerView;
- (void)markerViewDidUpdate:(LuggMapsMarkerView *)markerView;
@end

@interface LuggMapsMarkerView : RCTViewComponentView

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly, nullable) NSString *title;
@property(nonatomic, readonly, nullable) NSString *markerDescription;
@property(nonatomic, readonly) CGPoint anchor;
@property(nonatomic, readonly) BOOL hasCustomView;
@property(nonatomic, readonly) BOOL didLayout;
@property(nonatomic, readonly) UIView *iconView;
@property(nonatomic, weak, nullable) id<LuggMapsMarkerViewDelegate> delegate;
@property(nonatomic, strong, nullable) NSObject *marker;

@end

NS_ASSUME_NONNULL_END
