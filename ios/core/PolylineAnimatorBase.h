#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol PolylineAnimator <NSObject>

@property(nonatomic, strong) NSArray<CLLocation *> *coordinates;
@property(nonatomic, strong) NSArray<UIColor *> *strokeColors;
@property(nonatomic, assign) BOOL animated;

- (void)update;

@end

@interface PolylineAnimatorBase : NSObject

@property(nonatomic, strong) NSArray<CLLocation *> *coordinates;
@property(nonatomic, strong) NSArray<UIColor *> *strokeColors;

- (UIColor *)colorAtGradientPosition:(CGFloat)position;

@end
