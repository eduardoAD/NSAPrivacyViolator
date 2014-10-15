//
//  ViewController.m
//  NSAPrivacyViolator
//
//  Created by Eduardo Alvarado Díaz on 10/15/14.
//  Copyright (c) 2014 Globant. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController () <CLLocationManagerDelegate>
@property CLLocationManager *myLocationManager;
@property (strong, nonatomic) IBOutlet UITextView *myTextView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myLocationManager = [[CLLocationManager alloc] init];
    [self.myLocationManager requestWhenInUseAuthorization];
    self.myLocationManager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)startViolatingPrivacy:(id)sender {
    NSLog(@"Violating privacy");
    [self.myLocationManager startUpdatingLocation];
    self.myTextView.text = @"Locating you...";
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"I failed: %@",error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    for (CLLocation *location in locations) {
        if(location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000){
            self.myTextView.text = @"Location found. Reverse Geocoding...";
            [self reverseGeocode:location];
            NSLog(@"location: %@",location);
            [self.myLocationManager stopUpdatingLocation];
            break;
        }
    }
}

- (void)reverseGeocode:(CLLocation *)location{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        NSString *address = [NSString stringWithFormat:@"%@ %@ \n%@",placemark.subThoroughfare,placemark.thoroughfare,placemark.locality];
        self.myTextView.text = [NSString stringWithFormat:@"Found you: %@",address];
        [self findJailNear:placemark.location];
    }];
}

- (void)findJailNear:(CLLocation *)location{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = @"prison";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1));
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;
        MKMapItem *mapItem = mapItems.firstObject;
        self.myTextView.text = [NSString stringWithFormat:@"You should go to: %@",mapItem.name];
    }];
}

@end
