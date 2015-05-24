//
//  PhillyBikeShareMainViewController.m
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import "PhillyBikeShareMainViewController.h"
@import CoreLocation;

@interface PhillyBikeShareMainViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)checkForLocationServices;

@end

@implementation PhillyBikeShareMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotficationHeard:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self checkForLocationServices];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

# pragma mark - Location Manager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    DLog(@"%@", [locations lastObject]);
    [self.locationManager stopUpdatingLocation];
}

# pragma mark - Location helper methods

- (void)checkForLocationServices {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location services are turned off"
                                                        message:@"To give the best possible user experiences, you must enable location services for this application in Settings."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Settings", @"Cancel", nil];
    
    if (status == kCLAuthorizationStatusDenied) {
        [alertView show];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)applicationDidBecomeActiveNotficationHeard:(NSNotification *)notification {
    [self checkForLocationServices];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    } else {
        [alertView dismissWithClickedButtonIndex:1 animated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end