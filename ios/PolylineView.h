#import <CoreLocation/CoreLocation.h>
#import <React/RCTViewComponentView.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PolylineView;

@protocol PolylineViewDelegate <NSObject>
@optional
- (void)polylineViewDidUpdate:(PolylineView *)polylineView;
@end

@interface PolylineView : RCTViewComponentView

@property(nonatomic, readonly) NSArray<CLLocation *> *coordinates;
@property(nonatomic, readonly) NSArray<UIColor *> *strokeColors;
@property(nonatomic, readonly) CGFloat strokeWidth;
@property(nonatomic, weak, nullable) id<PolylineViewDelegate> delegate;
@property(nonatomic, strong, nullable) NSObject *polyline;

@end

NS_ASSUME_NONNULL_END
