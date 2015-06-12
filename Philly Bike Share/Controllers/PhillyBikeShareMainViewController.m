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

#define iPhone4Height 480.0

@interface PhillyBikeShareMainViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *usersCurrentLocation;
@property (strong, nonatomic) PhillyBikeShareLocation *activeBikeShareLocation;
@property (strong, nonatomic) NSArray *phillyBikeShareLocations;
@property (strong, nonatomic) UIAlertView *needLocationAlertView;
@property (strong, nonatomic) NSTimer *updateLocationAndData;
@property (strong, nonatomic) NSTimer *rideTimer;
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
@property (weak, nonatomic) IBOutlet UIButton *swipeRightArrow;
@property (weak, nonatomic) IBOutlet UIButton *swipeLeftArrow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *arrowWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerLabelBottomSpaceConstraint;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *startRideButton;

- (void)checkForLocationServices;
- (void)calculateConstraints;
- (void)pinLocaitonsToMapView;
- (void)setupViewBasedOnUsersCurrentLocation;
- (void)revealFullMapView;
- (void)hideFullMapView;
- (void)moveFooterAndHeaderViewByxOffset:(CGFloat)xOffset;
- (void)updateCounter:(NSTimer *)rideTiemr;
- (void)countdownTimer;

@end

@implementation PhillyBikeShareMainViewController {
    int _bikeViewInitialHeight;
    int _headerLabelBottomSpaceInitalValue;
    BOOL _displayedOutOfAreaWarning;
    int _secondsLeft, _hours, _minutes, _seconds;
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
    self.timerLabel.hidden = YES;
    self.startRideButton.hidden = YES;
    
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
    
    //Handle iPhone 4 case.
    if (ScreenHeight == iPhone4Height) {
        self.milesAwayTopSpaceConstraint.constant = 8;
    }
    _bikeViewInitialHeight = self.bikeViewHeight.constant;
    self.bikeView.clipsToBounds = YES;
    self.docksView.clipsToBounds = YES;
    
    self.mapView.mapType = MKMapTypeStandard;
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    _displayedOutOfAreaWarning = NO;
    _headerLabelBottomSpaceInitalValue = self.headerLabelBottomSpaceConstraint.constant;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackgroundNotficationHeard:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
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
    self.needLocationAlertView = [[UIAlertView alloc] initWithTitle:@"Location services are turned off" message:@"To give the best possible user experiences, you must enable location services for this application in Settings."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Settings", nil];
    
    if (status == kCLAuthorizationStatusDenied) {
        [self.needLocationAlertView show];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView isEqual:self.needLocationAlertView]) {
        if (buttonIndex == 0) {
            // Send the user to the Settings for this app to work.
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
}

#pragma mark - Map View Delegate Methods

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    MKPointAnnotation *annotation = [view annotation];
    
    for (int i = 0; i < self.phillyBikeShareLocations.count; i++) {
        PhillyBikeShareLocation *location = [self.phillyBikeShareLocations objectAtIndex:i];
        
        if (location.latitude == annotation.coordinate.latitude) {
            if (![self.activeBikeShareLocation isEqual:location]) {
                self.activeBikeShareLocation = location;
                self.currentPlace = i;
            }
        }
    }
}

#pragma mark - Notfication Center Handlers

- (void)applicationDidBecomeActiveNotficationHeard:(NSNotification *)notification {
    [self checkForLocationServices];
    if ([self.rideTimer isValid]) {
        [self.rideTimer invalidate];
        NSDate *timeOpen = [NSDate date];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDate *timeStopped = [defaults objectForKey:@"timeStopped"];
        NSTimeInterval secondsPassed = [timeOpen timeIntervalSinceDate:timeStopped];
        
        if ((_secondsLeft - secondsPassed) > 0) {
            _secondsLeft = _hours = _minutes = _seconds = _secondsLeft - secondsPassed;
            [self countdownTimer];
        }
    }
}

- (void)applicationDidEnterBackgroundNotficationHeard:(NSNotification *)notification {
    if ([self.rideTimer isValid]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:_secondsLeft forKey:@"secondsLeft"];
        [defaults setObject:[NSDate date] forKey:@"timeStopped"];
        [defaults synchronize];
    }
}

#pragma mark - helper methods.

- (void)calculateConstraints {
    self.headerViewHeight.constant = floor(ScreenHeight / 3);
    self.bikeViewWidth.constant = floor(ScreenWidth/2);
}

- (void)handleUpdateTimer:(id)sender {
    [self checkForLocationServices];
}

- (void)countdownTimer {
    if ([self.rideTimer isValid]) {
        [self.rideTimer invalidate];
    }
    self.rideTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
}

- (void)updateCounter:(NSTimer *)theTimer {
    if(_secondsLeft > 0){
        _secondsLeft -- ;
        _hours = _secondsLeft / 3600;
        _minutes = (_secondsLeft % 3600) / 60;
        _seconds = (_secondsLeft %3600) % 60;
        self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", _minutes, _seconds];
    }
    else {
        [self.rideTimer invalidate];
    }
}

- (void)swipe:(UISwipeGestureRecognizer *)swipeRecogniser {
    
    if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionRight) {
        
        if (self.currentPlace == self.phillyBikeShareLocations.count - 1) {
            self.currentPlace = 0;
        } else {
            self.currentPlace++;
        }
        self.activeBikeShareLocation = [self.phillyBikeShareLocations objectAtIndex:self.currentPlace];
    } else if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionLeft) {
        
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
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:self.activeBikeShareLocation.latitude longitude:self.activeBikeShareLocation.longitude];
    double distance = [self.usersCurrentLocation distanceFromLocation:location];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.usersCurrentLocation.coordinate, 2 * distance, 2 * distance);
    
    for (MKPointAnnotation *annotaiton in self.mapView.annotations) {
        if (annotaiton.coordinate.latitude == self.activeBikeShareLocation.latitude) {
            [self.mapView selectAnnotation:annotaiton animated:NO];
        }
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.headerLocationLabel.text = _activeBikeShareLocation.name;
        self.numberOfBikesLabel.text = [NSString stringWithFormat:@"%ld", (long)_activeBikeShareLocation.bikesAvailable];
        self.numberOfDocksLabel.text = [NSString stringWithFormat:@"%ld", (long)_activeBikeShareLocation.docksAvailable];
        
        self.milesAwayLabel.text = [NSString stringWithFormat:@"%.2f miles away", _activeBikeShareLocation.distanceFromUser];
    }];
    
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
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
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
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
        self.startRideButton.hidden = NO;
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

- (IBAction)startRideButtonPressed:(id)sender {
    
    if ([self.rideTimer isValid]) {
        self.headerLabelBottomSpaceConstraint.constant = _headerLabelBottomSpaceInitalValue;
        [self.rideTimer invalidate];
        [UIView animateWithDuration:0.5 animations:^{
            [self.startRideButton setTitle:@"Start Ride" forState:UIControlStateNormal];
            self.timerLabel.hidden = YES;
            [self.view layoutIfNeeded];
        }];
    } else {
        self.headerLabelBottomSpaceConstraint.constant = 36;
        _secondsLeft = _hours = _minutes = _seconds = 1800;
        self.timerLabel.text = @"30:00";
        [self.startRideButton setTitle:@"Stop Ride" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.25 animations:^{
            self.timerLabel.hidden = NO;
            [self countdownTimer];
            [self.view layoutIfNeeded];
        }];
    }
}

- (IBAction)swipeLeftArrow:(id)sender {
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc]init];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self swipe:swipeLeft];
}

- (IBAction)swipeRightArrow:(id)sender {
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc]init];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self swipe:swipeRight];
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
    self.fullMapButton.backgroundColor = RDBlueishGrey;
    self.startRideButton.hidden = YES;
    self.timerLabel.hidden = YES;
    self.headerLabelBottomSpaceConstraint.constant = 8;
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
    self.fullMapButton.backgroundColor = [UIColor clearColor];
    self.timerLabel.hidden = ([self.rideTimer isValid]) ? NO : YES;
    self.startRideButton.hidden = NO;
    self.headerLabelBottomSpaceConstraint.constant = ([self.rideTimer isValid]) ? 36 : _headerLabelBottomSpaceInitalValue;
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
    self.startRideButton.hidden = (currentHeight > ScreenHeight / 3 / 1.5) ? NO : YES;
    [self.view layoutIfNeeded];
}

@end