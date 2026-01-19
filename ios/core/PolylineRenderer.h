#import <MapKit/MapKit.h>

@interface PolylineRenderer : MKOverlayPathRenderer

- (id)initWithPolyline:(MKPolyline *)polyline;

@property(nonatomic, strong) NSArray<UIColor *> *strokeColors;

- (void)updatePolyline:(MKPolyline *)polyline;

@end
