#import "MKMapView+Zoom.h"

@implementation MKMapView (Zoom)

- (MKCoordinateSpan)coordinateSpanForZoomLevel:(double)zoomLevel centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
{
    // Google Maps: zoom level defines how many 256px tiles fit the world
    // At zoom 0, 1 tile = 360 degrees
    // Each zoom level doubles the number of tiles (halves the degrees per tile)
    // Offset of ~0.5 adjusts for difference between Google Maps and MKMapView rendering
    double adjustedZoom = zoomLevel - 0.5;
    double latitudeDelta = 360.0 / pow(2, adjustedZoom);
    
    // Adjust longitude delta for latitude (Mercator projection)
    double longitudeDelta = latitudeDelta / cos(centerCoordinate.latitude * M_PI / 180.0);
    
    return MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
}

#pragma mark - Public Methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(double)zoomLevel
                   animated:(BOOL)animated
{
    MKCoordinateRegion region = [self regionForCenterCoordinate:centerCoordinate zoomLevel:zoomLevel];
    [self setRegion:region animated:animated];
}

- (MKCoordinateRegion)regionForCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                      zoomLevel:(double)zoomLevel
{
    zoomLevel = MIN(zoomLevel, 28);
    MKCoordinateSpan span = [self coordinateSpanForZoomLevel:zoomLevel centerCoordinate:centerCoordinate];
    return MKCoordinateRegionMake(centerCoordinate, span);
}

- (double)zoomLevel
{
    MKCoordinateRegion region = self.region;
    double zoomLevel = log2(360.0 / region.span.latitudeDelta) + 0.5;
    return zoomLevel;
}

@end
