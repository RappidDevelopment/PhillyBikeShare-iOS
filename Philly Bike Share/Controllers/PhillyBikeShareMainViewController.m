//
//  PhillyBikeShareMainViewController.m
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import <libextobjc/EXTScope.h>
#import "PhillyBikeShareMainViewController.h"
#import "PhillyBikeShareLocationManager.h"

@interface PhillyBikeShareMainViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *usersCurrentLocation;
@property (strong, nonatomic) PhillyBikeShareLocation *cloestBikeShareLocation;
@property (nonatomic) CLLocationDistance distanceAwayFromClosestStation;
@property (strong, nonatomic) NSArray *phillyBikeShareLocations;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLocationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeight;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *bikeView;
@property (weak, nonatomic) IBOutlet UIView *docksView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bikeViewWidth;
@property (weak, nonatomic) IBOutlet UILabel *milesAwayLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfBikesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfDocksLabel;
@property (weak, nonatomic) IBOutlet UILabel *bikesLabel;
@property (weak, nonatomic) IBOutlet UILabel *docksLabel;

- (void)checkForLocationServices;
- (void)calculateConstraints;
- (void)pinLocaitonsToMapView;
- (void)setupViewBasedOnUsersCurrentLocation;

@end

@implementation PhillyBikeShareMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    self.headerLocationLabel.font = MontserratBold(44);
    self.loadingLabel.font = MontserratBold(16);
    [self calculateConstraints];
    
    self.headerLocationLabel.hidden = YES;
    self.bikeView.hidden = YES;
    self.docksView.hidden = YES;
    self.milesAwayLabel.hidden = YES;
    
    [self.view layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotficationHeard:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

# pragma mark - Location Manager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.locationManager stopUpdatingLocation];
    self.usersCurrentLocation = [locations lastObject];
    
    @weakify(self);
    [[PhillyBikeShareLocationManager sharedInstance]fetchAllLocationsWithSuccessBlock:^(NSArray *locations) {
        @strongify(self);
        self.phillyBikeShareLocations = locations;
        [self pinLocaitonsToMapView];
        @weakify(self);
        [[PhillyBikeShareLocationManager sharedInstance]fetchClosestBikeShareStationToLatitude:self.usersCurrentLocation.coordinate.latitude andLongitude:self.usersCurrentLocation.coordinate.longitude withNextBlock:^(PhillyBikeShareLocation *location, CLLocationDistance distance) {
            @strongify(self);
            self.cloestBikeShareLocation = location;
            self.distanceAwayFromClosestStation = distance;
            [self setupViewBasedOnUsersCurrentLocation];
        }];
    } andFailureBlock:^(NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error Fetching Bike Share Data" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }];
}

# pragma mark - Location helper methods

- (void)checkForLocationServices {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location services are turned off" message:@"To give the best possible user experiences, you must enable location services for this application in Settings."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Settings", nil];
    
    if (status == kCLAuthorizationStatusDenied) {
        [alertView show];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // Send the user to the Settings for this app to work.
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

#pragma mark - Notfication Center Handlers

- (void)applicationDidBecomeActiveNotficationHeard:(NSNotification *)notification {
    [self checkForLocationServices];
}

#pragma mark - helper methods.

- (void)calculateConstraints {
    self.headerViewHeight.constant = floor(ScreenHeight / 3);
    self.bikeViewWidth.constant = floor(ScreenWidth/2);
}

- (void)setupViewBasedOnUsersCurrentLocation {
    
    if (self.distanceAwayFromClosestStation > 25.0f) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Philly Bike Share" message:@"Philly Bike Share works best when in the Philadelphia area. You will still be able to view the closest Indego docking station to you, but it might be a very long ride to get there!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.headerLocationLabel.text = self.cloestBikeShareLocation.name;
        self.numberOfBikesLabel.text = [NSString stringWithFormat:@"%ld", (long)self.cloestBikeShareLocation.bikesAvailable];
        self.numberOfDocksLabel.text = [NSString stringWithFormat:@"%ld", (long)self.cloestBikeShareLocation.docksAvailable];
        
        self.milesAwayLabel.text = [NSString stringWithFormat:@"%.2f miles away", self.distanceAwayFromClosestStation];
        
        self.headerLocationLabel.hidden = NO;
        self.loadingView.hidden = YES;
        self.bikeView.hidden = NO;
        self.docksView.hidden = NO;
        self.milesAwayLabel.hidden = NO;
    }];
}

- (void)pinLocaitonsToMapView {
    //TODO:
    
    return;
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