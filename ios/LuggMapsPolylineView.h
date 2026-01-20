#import <CoreLocation/CoreLocation.h>
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LuggMapsPolylineView;

@protocol LuggMapsPolylineViewDelegate <NSObject>
@optional
- (void)polylineViewDidUpdate:(LuggMapsPolylineView *)polylineView;
@end

@interface LuggMapsPolylineView : RCTViewComponentView

@property(nonatomic, readonly) NSArray<CLLocation *> *coordinates;
@property(nonatomic, readonly) NSArray<UIColor *> *strokeColors;
@property(nonatomic, readonly) CGFloat strokeWidth;
@property(nonatomic, weak, nullable) id<LuggMapsPolylineViewDelegate> delegate;
@property(nonatomic, strong, nullable) NSObject *polyline;
@property(nonatomic, weak, nullable) NSObject *renderer;
@property(nonatomic, strong, nullable) NSArray *cachedSpans;

@end

NS_ASSUME_NONNULL_END
