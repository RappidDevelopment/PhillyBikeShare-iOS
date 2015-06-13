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

// Private Instance Variables.
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *usersCurrentLocation;
@property (strong, nonatomic) PhillyBikeShareLocation *activeBikeShareLocation;
@property (strong, nonatomic) NSArray *phillyBikeShareLocations;
@property (strong, nonatomic) UIAlertView *needLocationAlertView;
@property (strong, nonatomic) NSTimer *updateLocationAndBikeShareDataTimer;
@property (strong, nonatomic) NSTimer *rideTimer;
@property (nonatomic) NSInteger currentPlace;
@property (nonatomic) CGPoint lastTranslation;
// View Outlets
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
// These are strong because I remove and add them during animations.
// This controller needs a strong reference because
// when they were weak and I added them back to the view they were
// not remembered.
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
@property (weak, nonatomic) IBOutlet UIVisualEffectView *aboutBlurView;
@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutGitHubRepoButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutBikeShareButton;
@property (weak, nonatomic) IBOutlet UIButton *rappidButton;

- (void)checkForLocationServices;
- (void)calculateConstraints;
- (void)pinLocaitonsToMapView;
- (void)setupViewBasedOnUsersCurrentLocation;
- (void)revealFullMapView;
- (void)hideFullMapView;
- (void)moveFooterAndHeaderViewByxOffset:(CGFloat)xOffset;
- (void)updateRideTimer:(NSTimer *)rideTiemr;
- (void)startRideCountdownTimer;
- (void)swipe:(UISwipeGestureRecognizer *)swipeRecogniser;
- (void)handleRevealFullMapViewPan:(UIPanGestureRecognizer *)panRecognizer;
- (IBAction)swipeLeftArrow:(id)sender;
- (IBAction)swipeRightArrow:(id)sender;
- (IBAction)startRideButtonPressed:(id)sender;
- (IBAction)fullMapButtonPressed:(id)sender;
- (IBAction)aboutButtonPressed:(id)sender;
- (IBAction)githubRepoButtonPressed:(id)sender;
- (IBAction)bikeShareButtonPressed:(id)sender;
- (IBAction)rappidButtonPressed:(id)sender;

@end

@implementation PhillyBikeShareMainViewController {
    //Helper variables
    int _bikeViewInitialHeight;
    int _headerLabelBottomSpaceInitalValue;
    BOOL _displayedOutOfAreaWarning;
    int _secondsLeft, _hours, _minutes, _seconds;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the user's current location.
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    
    // Setup the view's styles.
    self.headerLocationLabel.font = MontserratBold(48);
    self.loadingLabel.font = MontserratBold(16);
    self.milesAwayLabel.font = MontserratBold(24);
    
    // Setup the view to be displayed in thirds.
    [self calculateConstraints];
    
    // Initally hide these elements until
    // All of the data is loaded.
    self.headerLocationLabel.hidden = YES;
    self.bikeView.hidden = YES;
    self.docksView.hidden = YES;
    self.milesAwayLabel.hidden = YES;
    self.fullMapButton.hidden = YES;
    self.timerLabel.hidden = YES;
    self.startRideButton.hidden = YES;
    self.aboutButton.hidden = YES;
    
    //Using alpha so I can animate the blur.
    self.aboutBlurView.alpha = 0;
    
    // Add swipe and pan gestures to the footer view.
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    UIPanGestureRecognizer *revealFullMapViewPanGestureRecognizer =
    [[UIPanGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleRevealFullMapViewPan:)];
    [self.footerView addGestureRecognizer:swipeRight];
    [self.footerView addGestureRecognizer:swipeLeft];
    [self.footerView addGestureRecognizer:revealFullMapViewPanGestureRecognizer];
    
    // Add a tap gesture to the about blur view.
    UITapGestureRecognizer *aboutTapGestureRecognzier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aboutBlurViewTapped:)];
    [self.aboutBlurView addGestureRecognizer:aboutTapGestureRecognzier];
    
    // This sets the pan gesture as the priority. Without they were getting all messed up.
    [revealFullMapViewPanGestureRecognizer requireGestureRecognizerToFail:swipeLeft];
    [revealFullMapViewPanGestureRecognizer requireGestureRecognizerToFail:swipeRight];
    
    // Set the current place in the array to 0, the closest docking station to the user.
    self.currentPlace = 0;
    
    // Remove the Y constraint on the elements in the footer.
    // These will be added again when the full map view is displayed.
    if ([self.footerView.constraints containsObject:self.milesAwayCenterYConstraint]) {
        [self.footerView removeConstraint:self.milesAwayCenterYConstraint];
    }
    
    if ([self.footerView.constraints containsObject:self.fullMapCenterYConstraint]) {
        [self.footerView removeConstraint:self.fullMapCenterYConstraint];
    }
    
    //Handle this iPhone 4 edge case - couldn't handle the full 20 pixels.
    if (ScreenHeight == iPhone4Height) {
        self.milesAwayTopSpaceConstraint.constant = 8;
        // We just won't appeal to iPhone 4 users;
        self.rappidButton.hidden = YES;
    }
    
    // Save these so we can animate back to it later.
    _bikeViewInitialHeight = self.bikeViewHeight.constant;
    _headerLabelBottomSpaceInitalValue = self.headerLabelBottomSpaceConstraint.constant;
    
    //Clip these so they animate with the parent view.
    self.bikeView.clipsToBounds = YES;
    self.docksView.clipsToBounds = YES;
    
    //Setup the map view.
    self.mapView.mapType = MKMapTypeStandard;
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    
    //We have not displayed the out of area warning yet.
    _displayedOutOfAreaWarning = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /* 
     * This is a timer that is set to check the user's location 
     * and update the bike share data every 60 seconds.
     */
    self.updateLocationAndBikeShareDataTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                                                target:self
                                                                              selector:@selector(handleUpdateLocationAndBikeShareDataTimer:)
                                                                              userInfo:nil
                                                                               repeats:YES];
    
    // Listen for when the application becomes active or enters the background.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotficationHeard:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackgroundNotficationHeard:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Invalidate the update timer.
    if (self.updateLocationAndBikeShareDataTimer) {
        [self.updateLocationAndBikeShareDataTimer invalidate];
        self.updateLocationAndBikeShareDataTimer = nil;
    }
    
    // Remove the observer on the application lifecycle notifications.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

# pragma mark - Location Manager Delegate Method

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    // Save and stop updating the user's current location.
    self.usersCurrentLocation = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
    
    // Fetch all of the PhillyBikeShareLocations.
    @weakify(self);
    [[PhillyBikeShareLocationManager sharedInstance]fetchAllLocationsWithSuccessBlock:^(NSArray *locations) {
        @strongify(self);
        self.phillyBikeShareLocations = locations;
        // Pin the locations to the map now that we have them.
        [self pinLocaitonsToMapView];
        // Sort them based on the user's location.
        @weakify(self);
        [[PhillyBikeShareLocationManager sharedInstance]sortLocationsBasedOnUsersLatitude:self.usersCurrentLocation.coordinate.latitude andLongitude:self.usersCurrentLocation.coordinate.longitude withNextBlock:^(NSArray *sortedLocations) {
            @strongify(self);
            // Set the active station to the closest one to the user.
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

# pragma mark - Location Helper Methods

- (void)checkForLocationServices {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    self.needLocationAlertView = [[UIAlertView alloc] initWithTitle:@"Location services are turned off" message:@"To give the best possible user experiences, you must enable location services for this application in Settings."
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Settings", nil];
    // If we do not have permission to get the user's location
    // Throw an alert and take the user to the Settings app.
    if (status == kCLAuthorizationStatusDenied) {
        [self.needLocationAlertView show];
    } else {
        // If we do have permission, get their location.
        [self.locationManager startUpdatingLocation];
    }
}

- (void)setupViewBasedOnUsersCurrentLocation {
    
    // If the user is more than 25 miles away, tell them the app won't be much use.
    if (self.activeBikeShareLocation.distanceFromUser > 25.0f) {
        if (!_displayedOutOfAreaWarning) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Philly Bike Share" message:@"Philly Bike Share works best when in the Philadelphia area. You will still be able to view the closest Indego docking station to you, but it might be a very long ride to get there!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            // Also note that we showed them this message.
            _displayedOutOfAreaWarning = YES;
        }
    }
    
    // Setup the visible regsion of the map and update the UI.
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
        self.aboutButton.hidden = NO;
    }];
}

- (void)pinLocaitonsToMapView {
    
    // Loop through each station and create a pin, add that pin to the map.
    for (PhillyBikeShareLocation *location in self.phillyBikeShareLocations) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        [annotation setCoordinate:locationCoordinate];
        [annotation setTitle:location.name];
        [annotation setSubtitle:location.addressStreet];
        [self.mapView addAnnotation:annotation];
    }
    
}

#pragma mark - Map View Delegate Methods

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    MKPointAnnotation *annotation = [view annotation];
    
    // When the user selects a pin, find which station is associated with it.
    // I'm using latitude as a common property.
    for (int i = 0; i < self.phillyBikeShareLocations.count; i++) {
        PhillyBikeShareLocation *location = [self.phillyBikeShareLocations objectAtIndex:i];
        
        if (location.latitude == annotation.coordinate.latitude) {
            
            // Once the latitude match, set the active location to it.
            if (![self.activeBikeShareLocation isEqual:location]) {
                self.activeBikeShareLocation = location;
                self.currentPlace = i;
            }
        }
    }
}

#pragma mark - Notfication Center Handlers

- (void)applicationDidBecomeActiveNotficationHeard:(NSNotification *)notification {
    // Get the user's current location.
    [self checkForLocationServices];
    
    /*
     * If the ride timer is active,
     * calulcate how long it's been since they exited the app.
     * Update the timer accordingly.
     */
    if ([self.rideTimer isValid]) {
        [self.rideTimer invalidate];
        NSDate *timeOpen = [NSDate date];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDate *timeStopped = [defaults objectForKey:@"timeStopped"];
        NSTimeInterval secondsPassed = [timeOpen timeIntervalSinceDate:timeStopped];
        
        if ((_secondsLeft - secondsPassed) > 0) {
            _secondsLeft = _hours = _minutes = _seconds = _secondsLeft - secondsPassed;
            [self startRideCountdownTimer];
        }
    }
}

- (void)applicationDidEnterBackgroundNotficationHeard:(NSNotification *)notification {
    
    /*
     * Applications are allowed to run in the background for 10 minutes. 
     * To keep the 30 minute timer running, I store how many seconds are left,
     * and the time stamp at when the user exited the app.
     */
    if ([self.rideTimer isValid]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:_secondsLeft forKey:@"secondsLeft"];
        [defaults setObject:[NSDate date] forKey:@"timeStopped"];
        [defaults synchronize];
    }
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView isEqual:self.needLocationAlertView]) {
        if (buttonIndex == 0) {
            // Send the user to the Settings for this app to work.
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
}

#pragma mark - NSTimer Handlers

- (void)handleUpdateLocationAndBikeShareDataTimer:(id)sender {
    [self checkForLocationServices];
}

- (void)startRideCountdownTimer {
    if ([self.rideTimer isValid]) {
        [self.rideTimer invalidate];
    }
    // Start the ride timer.
    self.rideTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateRideTimer:) userInfo:nil repeats:YES];
}

- (void)updateRideTimer:(NSTimer *)theTimer {
    
    // Some magic math to count backwards from 30:00
    if(_secondsLeft > 0){
        _secondsLeft -- ;
        _hours = _secondsLeft / 3600;
        _minutes = (_secondsLeft % 3600) / 60;
        _seconds = (_secondsLeft %3600) % 60;
        self.timerLabel.text = [NSString stringWithFormat:@"%02d:%02d", _minutes, _seconds];
    }
    else {
        // If there is no time left invalidate the timer.
        [self.rideTimer invalidate];
    }
}

#pragma mark - Gesture Recognizers

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

- (void)aboutBlurViewTapped:(UITapGestureRecognizer *)tapRecognizer {
    
    [UIView animateWithDuration:0.3 animations: ^ {
        self.aboutBlurView.alpha = (self.aboutBlurView.alpha == 0) ? 1 : 0;
    } completion:nil];
}

#pragma mark - Override Methods

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
        if (self.fullMapButton.selected) {
            self.startRideButton.hidden = YES;
        }
    }];
    
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

#pragma mark - Button Click Events

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
            [self startRideCountdownTimer];
            [self.view layoutIfNeeded];
        }];
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

- (IBAction)aboutButtonPressed:(id)sender {
    
    //Toggle between hidden and not.
    [UIView animateWithDuration:0.3 animations: ^ {
        self.aboutBlurView.alpha = (self.aboutBlurView.alpha == 0) ? 1 : 0;
    } completion:nil];
}

- (IBAction)githubRepoButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://github.com/RappidDevelopment/PhillyBikeShare-iOS"]];
}

- (IBAction)bikeShareButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.rideindego.com"]];
}

- (IBAction)rappidButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://rappiddevelopment.com"]];
}

#pragma mark - View Animations

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

/*
 * Helper method to setup the header and footer
 * view of the applcation.
 */
- (void)calculateConstraints {
    self.headerViewHeight.constant = floor(ScreenHeight / 3);
    self.bikeViewWidth.constant = floor(ScreenWidth / 2);
}

@end