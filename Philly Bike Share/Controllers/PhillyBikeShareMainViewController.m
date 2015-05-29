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
@import MapKit;

@interface PhillyBikeShareMainViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *usersCurrentLocation;
@property (strong, nonatomic) PhillyBikeShareLocation *activeBikeShareLocation;
@property (strong, nonatomic) NSArray *phillyBikeShareLocations;
@property (strong, nonatomic) NSTimer *updateLocationAndData;
@property (nonatomic) NSInteger currentPlace;
@property (nonatomic) CGPoint lastTranslation;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLocationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewHeight;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *bikeView;
@property (weak, nonatomic) IBOutlet UIView *docksView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bikeViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bikeViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *milesAwayLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfBikesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfDocksLabel;
@property (weak, nonatomic) IBOutlet UILabel *bikesLabel;
@property (weak, nonatomic) IBOutlet UILabel *docksLabel;
@property (weak, nonatomic) IBOutlet UIButton *fullMapButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *milesAwayCenterYConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *milesAwayTopSpaceConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fullMapCenterYConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fullMapBottomSpaceConstraint;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (void)checkForLocationServices;
- (void)calculateConstraints;
- (void)pinLocaitonsToMapView;
- (void)setupViewBasedOnUsersCurrentLocation;
- (void)revealFullMapView;
- (void)hideFullMapView;
- (void)moveFooterAndHeaderViewByxOffset:(CGFloat)xOffset;


@end

@implementation PhillyBikeShareMainViewController {
    int _bikeViewInitialHeight;
    BOOL _displayedOutOfAreaWarning;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    self.headerLocationLabel.font = MontserratBold(48);
    self.loadingLabel.font = MontserratBold(16);
    self.milesAwayLabel.font = MontserratBold(24);
    [self calculateConstraints];
    
    self.headerLocationLabel.hidden = YES;
    self.bikeView.hidden = YES;
    self.docksView.hidden = YES;
    self.milesAwayLabel.hidden = YES;
    self.fullMapButton.hidden = YES;
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    [self.view addGestureRecognizer:swipeLeft];
    
    UIPanGestureRecognizer *revealFullMapViewPanGestureRecognizer =
    [[UIPanGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleRevealFullMapViewPan:)];
    [self.footerView addGestureRecognizer:revealFullMapViewPanGestureRecognizer];
    
    [revealFullMapViewPanGestureRecognizer requireGestureRecognizerToFail:swipeLeft];
    [revealFullMapViewPanGestureRecognizer requireGestureRecognizerToFail:swipeRight];
    
    self.currentPlace = 0;
    
    if ([self.footerView.constraints containsObject:self.milesAwayCenterYConstraint]) {
        [self.footerView removeConstraint:self.milesAwayCenterYConstraint];
    }
    
    if ([self.footerView.constraints containsObject:self.fullMapCenterYConstraint]) {
        [self.footerView removeConstraint:self.fullMapCenterYConstraint];
    }
    
    _bikeViewInitialHeight = self.bikeViewHeight.constant;
    self.bikeView.clipsToBounds = YES;
    self.docksView.clipsToBounds = YES;
    
    self.mapView.mapType = MKMapTypeStandard;
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    _displayedOutOfAreaWarning = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.updateLocationAndData = [NSTimer scheduledTimerWithTimeInterval:60
                                                                  target:self
                                                                selector:@selector(handleUpdateTimer:)
                                                                userInfo:nil
                                                                 repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotficationHeard:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.updateLocationAndData) {
        [self.updateLocationAndData invalidate];
        self.updateLocationAndData = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

# pragma mark - Location Manager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.usersCurrentLocation = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
    
    @weakify(self);
    [[PhillyBikeShareLocationManager sharedInstance]fetchAllLocationsWithSuccessBlock:^(NSArray *locations) {
        @strongify(self);
        self.phillyBikeShareLocations = locations;
        [self pinLocaitonsToMapView];
        @weakify(self);
        [[PhillyBikeShareLocationManager sharedInstance]sortLocationsBasedOnUsersLatitude:self.usersCurrentLocation.coordinate.latitude andLongitude:self.usersCurrentLocation.coordinate.longitude withNextBlock:^(NSArray *sortedLocations) {
            @strongify(self);
            PhillyBikeShareLocation *closestLocation = [sortedLocations firstObject];
            self.activeBikeShareLocation = closestLocation;
            self.phillyBikeShareLocations = sortedLocations;
            if (!self.fullMapButton.selected) {
                [self setupViewBasedOnUsersCurrentLocation];
            }
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

-(void)handleUpdateTimer:(id)sender {
    [self checkForLocationServices];
}

- (void)swipe:(UISwipeGestureRecognizer *)swipeRecogniser {
    
    if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionLeft){
        
        if (self.currentPlace == self.phillyBikeShareLocations.count - 1) {
            self.currentPlace = 0;
        } else {
            self.currentPlace++;
        }
        self.activeBikeShareLocation = [self.phillyBikeShareLocations objectAtIndex:self.currentPlace];
    } else if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionRight) {
        
        if (self.currentPlace == 0) {
            self.currentPlace = self.phillyBikeShareLocations.count - 1;
        } else {
            self.currentPlace--;
        }
        self.activeBikeShareLocation = [self.phillyBikeShareLocations objectAtIndex:self.currentPlace];
    }
}

- (void)handleRevealFullMapViewPan:(UIPanGestureRecognizer *)panRecognizer {
    CGPoint translation = [panRecognizer translationInView:self.view];
    
    CGPoint delta;
    
    switch (panRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.lastTranslation = delta = [panRecognizer translationInView:self.view];
            [self moveFooterAndHeaderViewByxOffset:-delta.x];
            break;
            
        case UIGestureRecognizerStateChanged:
            // On state changed: calculate the difference between the translation and our
            // previous translation.
            delta = CGPointApplyAffineTransform([panRecognizer translationInView:self.view], CGAffineTransformMakeTranslation(-self.lastTranslation.x, -self.lastTranslation.y));
            self.lastTranslation = [panRecognizer translationInView:self.view];
            [self moveFooterAndHeaderViewByxOffset:-delta.y];
            break;
            
        case UIGestureRecognizerStateEnded:
            if (translation.y < 0) {
                [self hideFullMapView];
            } else {
                [self revealFullMapView];
            }
            break;
            
        default:
            break;

    }
}

- (void)setActiveBikeShareLocation:(PhillyBikeShareLocation *)activeBikeShareLocation {
    _activeBikeShareLocation = activeBikeShareLocation;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.headerLocationLabel.text = self.activeBikeShareLocation.name;
        self.numberOfBikesLabel.text = [NSString stringWithFormat:@"%ld", (long)self.activeBikeShareLocation.bikesAvailable];
        self.numberOfDocksLabel.text = [NSString stringWithFormat:@"%ld", (long)self.activeBikeShareLocation.docksAvailable];
        
        self.milesAwayLabel.text = [NSString stringWithFormat:@"%.2f miles away", self.activeBikeShareLocation.distanceFromUser];
    }];
}

- (void)setupViewBasedOnUsersCurrentLocation {
    
    if (self.activeBikeShareLocation.distanceFromUser > 25.0f) {
        if (!_displayedOutOfAreaWarning) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Philly Bike Share" message:@"Philly Bike Share works best when in the Philadelphia area. You will still be able to view the closest Indego docking station to you, but it might be a very long ride to get there!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            _displayedOutOfAreaWarning = YES;
        }
    }
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:self.activeBikeShareLocation.latitude longitude:self.activeBikeShareLocation.longitude];
    
    double distance = [self.usersCurrentLocation distanceFromLocation:location];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.usersCurrentLocation.coordinate, 2 * distance, 2 * distance);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.headerLocationLabel.text = self.activeBikeShareLocation.name;
        self.numberOfBikesLabel.text = [NSString stringWithFormat:@"%ld", (long)self.activeBikeShareLocation.bikesAvailable];
        self.numberOfDocksLabel.text = [NSString stringWithFormat:@"%ld", (long)self.activeBikeShareLocation.docksAvailable];
        
        self.milesAwayLabel.text = [NSString stringWithFormat:@"%.2f miles away", self.activeBikeShareLocation.distanceFromUser];
        
        self.headerLocationLabel.hidden = NO;
        self.loadingView.hidden = YES;
        self.bikeView.hidden = NO;
        self.docksView.hidden = NO;
        self.milesAwayLabel.hidden = NO;
        self.fullMapButton.hidden = NO;
    }];
}

- (void)pinLocaitonsToMapView {
    
    for (PhillyBikeShareLocation *location in self.phillyBikeShareLocations) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        [annotation setCoordinate:locationCoordinate];
        [annotation setTitle:location.name];
        [annotation setSubtitle:location.addressStreet];
        [self.mapView addAnnotation:annotation];
    }
    
}

- (IBAction)fullMapButtonPressed:(id)sender {
    
    if (self.fullMapButton.selected == NO) {
        self.fullMapButton.selected = YES;
        self.fullMapButton.backgroundColor = RDBlueishGrey;
        [self revealFullMapView];
        
    } else {
        self.fullMapButton.selected = NO;
        self.fullMapButton.backgroundColor = [UIColor clearColor];
        [self hideFullMapView];
    }
}

- (void)revealFullMapView {
    self.fullMapButton.selected = YES;
    self.bikeViewHeight.constant = 0;
    self.headerViewHeight.constant = 64;
    self.headerLocationLabel.font = MontserratBold(24);
    self.headerLocationLabel.transform = CGAffineTransformScale(self.headerLocationLabel.transform, 2, 2);
    
    if ([self.footerView.constraints containsObject:self.milesAwayTopSpaceConstraint]) {
        [self.footerView removeConstraint:self.milesAwayTopSpaceConstraint];
    }
    
    if (![self.footerView.constraints containsObject:self.milesAwayCenterYConstraint]) {
        [self.footerView addConstraint:self.milesAwayCenterYConstraint];
    }
    
    if ([self.footerView.constraints containsObject:self.fullMapBottomSpaceConstraint]) {
        [self.footerView removeConstraint:self.fullMapBottomSpaceConstraint];
    }
    
    if (![self.footerView.constraints containsObject:self.fullMapCenterYConstraint]) {
        [self.footerView addConstraint:self.fullMapCenterYConstraint];
    }
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:self.activeBikeShareLocation.latitude longitude:self.activeBikeShareLocation.longitude];
    
    double distance = [self.usersCurrentLocation distanceFromLocation:location];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.usersCurrentLocation.coordinate, 2 * distance, 2 * distance);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.headerLocationLabel.transform = CGAffineTransformScale(self.headerLocationLabel.transform, .5, .5);
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.headerLocationLabel.font = MontserratBold(24);
                         self.headerLocationLabel.transform = CGAffineTransformScale(self.headerLocationLabel.transform, 1.0, 1.0);
                     }
    ];
    
    
}

- (void)hideFullMapView {
    
    self.fullMapButton.selected = NO;
    self.headerViewHeight.constant = floor(ScreenHeight / 3);
    self.headerLocationLabel.font = MontserratBold(48);
    self.headerLocationLabel.transform = CGAffineTransformScale(self.headerLocationLabel.transform, 0.5, 0.5);
    
    self.bikeViewHeight.constant = _bikeViewInitialHeight;
    
    if ([self.footerView.constraints containsObject:self.milesAwayCenterYConstraint]) {
        [self.footerView removeConstraint:self.milesAwayCenterYConstraint];
    }
    
    if (![self.footerView.constraints containsObject:self.milesAwayTopSpaceConstraint]) {
        [self.footerView addConstraint:self.self.milesAwayTopSpaceConstraint];
    }
    
    if ([self.footerView.constraints containsObject:self.fullMapCenterYConstraint]) {
        [self.footerView removeConstraint:self.fullMapCenterYConstraint];
    }
    
    if (![self.footerView.constraints containsObject:self.fullMapBottomSpaceConstraint]) {
        [self.footerView addConstraint:self.self.fullMapBottomSpaceConstraint];
    }
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.headerLocationLabel.transform = CGAffineTransformScale(self.headerLocationLabel.transform, 2, 2);
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.headerLocationLabel.font = MontserratBold(48);
                         self.headerLocationLabel.transform = CGAffineTransformScale(self.headerLocationLabel.transform, 1.0, 1.0);
                         [self setupViewBasedOnUsersCurrentLocation];
                     }
     ];

}

- (void)moveFooterAndHeaderViewByxOffset:(CGFloat)xOffset {
    CGFloat currentHeight = self.headerViewHeight.constant;
    currentHeight += xOffset;
    self.bikeViewHeight.constant = (currentHeight < (ScreenHeight / 3)/1.5) ? 0 : _bikeViewInitialHeight;
    self.headerViewHeight.constant = (currentHeight > (ScreenHeight / 3)) ? ScreenHeight / 3 : currentHeight;
    [self.view layoutIfNeeded];
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