//
//  PBSMainViewController.m
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import "PBSLocationManager.h"
#import "PBSMainViewController.h"
#import "PBSRideTimerManager.h"
#import "PBSStation.h"

@import MapKit;

@interface PBSMainViewController () <PBSLocationManagerDelegate, PBSRideTimerManagerDelegate, MKMapViewDelegate>

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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *milesAwayCenterYConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *milesAwayTopSpaceConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fullMapCenterYConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fullMapBottomSpaceConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *aboutButtonYConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *aboutButtonBottomSpaceConstraint;
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
@property (strong, nonatomic) PBSLocationManager *locationManager;
@property (strong, nonatomic) PBSRideTimerManager *rideTimerManager;
@property (strong, nonatomic) PBSStation *selectedStation;
@property (strong, nonatomic) UIAlertView *needLocationAlertView;
@property (strong, nonatomic) UIAlertView *outOfAreaAlertView;
@property (nonatomic) NSInteger currentPlace;
@property (nonatomic) CGPoint lastTranslation;
@property (nonatomic) NSInteger bikeViewInitialHeight;
@property (nonatomic) NSInteger headerLabelBottomSpaceInitalValue;
@property (nonatomic) BOOL displayedOutOfAreaWarning;

- (void)revealFullMapView;
- (void)hideFullMapView;
- (void)moveFooterAndHeaderViewByxOffset:(CGFloat)xOffset;
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

@implementation PBSMainViewController

- (PBSLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[PBSLocationManager alloc] init];
        _locationManager.delegate = self;
    }

    return _locationManager;
}

- (PBSRideTimerManager *)rideTimerManager
{
    if (!_rideTimerManager) {
        _rideTimerManager = [[PBSRideTimerManager alloc] init];
        _rideTimerManager.delegate = self;
    }

    return _rideTimerManager;
}

- (UIAlertView *)needLocationAlertView
{
    if (!_needLocationAlertView) {
        _needLocationAlertView = [[UIAlertView alloc] initWithTitle:@"Location services are turned off"
                                                            message:@"To give the best possible user experiences, you must enable location services for this application in Settings."
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Settings", nil];
    }

    return _needLocationAlertView;
}

- (UIAlertView *)outOfAreaAlertView
{
    if (!_outOfAreaAlertView) {
        _outOfAreaAlertView = [[UIAlertView alloc] initWithTitle:@"Philly Bike Share"
                                                         message:@"Philly Bike Share works best when in the Philadelphia area. You will still be able to view the closest Indego docking station to you, but it might be a very long ride to get there!"
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    }

    return _outOfAreaAlertView;
}

- (void)setSelectedStation:(PBSStation *)selectedStation
{
    _selectedStation = selectedStation;
    [self setupViewBasedOnUsersCurrentLocation];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self calculateHeaderAndFooterHeightConstraints];
    self.mapView.mapType = MKMapTypeStandard;
    [self.mapView setShowsUserLocation:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    [self showLoadingView];
    [self applyGestures];
    [self registerForNotifications];

    // We have not displayed the out of area warning yet.
    self.displayedOutOfAreaWarning = NO;

    // Clip these so they animate with the parent view.
    self.bikeView.clipsToBounds = YES;
    self.docksView.clipsToBounds = YES;
    self.aboutBlurView.alpha = 0;
}

- (void)dealloc
{
    [self removeNotifications];
}

#pragma mark - View Helpers

- (void)showLoadingView
{
    // Initally hide these elements until
    // All of the data is loaded.
    self.loadingView.hidden = NO;
    self.headerLocationLabel.hidden = YES;
    self.bikeView.hidden = YES;
    self.docksView.hidden = YES;
    self.milesAwayLabel.hidden = YES;
    self.fullMapButton.hidden = YES;
    self.timerLabel.hidden = YES;
    self.startRideButton.hidden = YES;
    self.aboutButton.hidden = YES;
}

- (void)hideLoadingView
{
    self.loadingView.hidden = YES;
    self.headerLocationLabel.hidden = NO;
    self.bikeView.hidden = NO;
    self.docksView.hidden = NO;
    self.milesAwayLabel.hidden = NO;
    self.fullMapButton.hidden = NO;
    self.startRideButton.hidden = NO;
    self.aboutButton.hidden = NO;
}

- (void)calculateHeaderAndFooterHeightConstraints
{
    self.headerViewHeight.constant = floor(ScreenHeight / 3);
    self.bikeViewWidth.constant = floor(ScreenWidth / 2);

    // Remove the Y constraint on the elements in the footer.
    // These will be added again when the full map view is displayed.
    if ([self.footerView.constraints containsObject:self.milesAwayCenterYConstraint]) {
        [self.footerView removeConstraint:self.milesAwayCenterYConstraint];
    }

    if ([self.footerView.constraints containsObject:self.fullMapCenterYConstraint]) {
        [self.footerView removeConstraint:self.fullMapCenterYConstraint];
    }

    if ([self.footerView.constraints containsObject:self.aboutButtonYConstraint]) {
        [self.footerView removeConstraint:self.aboutButtonYConstraint];
    }

    //Handle this iPhone 4 edge case - couldn't handle the full 20 pixels.
    if (IS_IPHONE_5) {
        self.milesAwayTopSpaceConstraint.constant = 8;
    }
    else if (IS_IPHONE_4_OR_LESS) {
        // We just won't appeal to iPhone 4 users;
        self.milesAwayTopSpaceConstraint.constant = 8;
        if (IS_IPHONE_4_OR_LESS) {
            self.rappidButton.hidden = YES;
        }
    }

    // Save these so we can animate back to it later.
    self.bikeViewInitialHeight = self.bikeViewHeight.constant;
    self.headerLabelBottomSpaceInitalValue = self.headerLabelBottomSpaceConstraint.constant;
}

- (void)setupViewBasedOnUsersCurrentLocation
{
    double distance = [self.locationManager.usersCurrentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:self.selectedStation.latitude longitude:self.selectedStation.longitude]];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.locationManager.usersCurrentLocation.coordinate, 2 * distance, 2 * distance);

    for (MKPointAnnotation *annotaiton in self.mapView.annotations) {
        if (annotaiton.coordinate.latitude == self.selectedStation.latitude) {
            [self.mapView selectAnnotation:annotaiton animated:NO];
        }
    }

    [UIView animateWithDuration:0.5 animations:^{
      [self hideLoadingView];
      self.headerLocationLabel.text = self.selectedStation.name;
      self.numberOfBikesLabel.text = [NSString stringWithFormat:@"%ld", (long)self.selectedStation.bikesAvailable];
      self.numberOfDocksLabel.text = [NSString stringWithFormat:@"%ld", (long)self.selectedStation.docksAvailable];
      self.milesAwayLabel.text = [NSString stringWithFormat:@"%.2f miles away", self.selectedStation.distanceFromUser];
    }];

    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];

    if (self.selectedStation.distanceFromUser > 25 && self.displayedOutOfAreaWarning != YES) {
        [self.outOfAreaAlertView show];
        self.displayedOutOfAreaWarning = YES;
    }
}

- (void)registerForNotifications
{
    // Listen for when the application becomes active or enters the background.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActiveNotficationHeard:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackgroundNotficationHeard:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)removeNotifications
{
    // Remove the observer on the application lifecycle notifications.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

#pragma mark - Notfication Center Handlers

- (void)applicationDidBecomeActiveNotficationHeard:(NSNotification *)notification
{
    [self.locationManager requestUsersCurrentLocation];

    if ([self.rideTimerManager timerIsRunning]) {
        [self.rideTimerManager resumeRideTimer];
    }
}

- (void)applicationDidEnterBackgroundNotficationHeard:(NSNotification *)notification
{
    if ([self.rideTimerManager timerIsRunning]) {
        [self.rideTimerManager pauseRideTimer];
    }
}

#pragma mark - PBSLocationManager Delegate

- (void)didUpdateUsersAuthorizationStatus:(CLAuthorizationStatus)authorizationStatus
{
    // If we do not have permission to get the user's location
    // Throw an alert and take the user to the Settings app.
    if (authorizationStatus == kCLAuthorizationStatusDenied) {
        [self.needLocationAlertView show];
    }
}

- (void)didReceiveError:(NSError *)error
{
    // TODO: Handle error properly.
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Fetching Bike Share Data"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)didUpdateLocationData
{
    [self pinStationsToMapView];
    self.selectedStation = [self.locationManager.stations firstObject];
}

- (void)pinStationsToMapView
{
    // Loop through each station and create a pin, add that pin to the map.
    for (PBSStation *station in self.locationManager.stations) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(station.latitude, station.longitude);
        [annotation setCoordinate:locationCoordinate];
        [annotation setTitle:station.name];
        [annotation setSubtitle:station.addressStreet];

        if (![self.mapView.annotations containsObject:annotation]) {
            [self.mapView addAnnotation:annotation];
        }
    }
}

#pragma mark - PBSRideTimerManager Delegate

- (void)rideTimerDidUpdateToTime:(NSString *)time
{
    self.timerLabel.text = time;
}

#pragma mark - Map View Delegate Methods

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MKPointAnnotation *annotation = [view annotation];

    // When the user selects a pin, find which station is associated with it.
    // I'm using latitude as a common property.
    for (int i = 0; i < self.locationManager.stations.count; i++) {
        PBSStation *station = [self.locationManager.stations objectAtIndex:i];

        if (station.latitude == annotation.coordinate.latitude) {
            // Once the latitude match, set the active location to it.
            if (![self.selectedStation isEqual:station]) {
                self.selectedStation = station;
                self.currentPlace = i;
            }
        }
    }
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:self.needLocationAlertView]) {
        if (buttonIndex == 0) {
            // Send the user to the Settings for this app to work.
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
}

#pragma mark - Button Click Events

- (IBAction)startRideButtonPressed:(id)sender
{
    if ([self.rideTimerManager timerIsRunning]) {
        self.headerLabelBottomSpaceConstraint.constant = self.headerLabelBottomSpaceInitalValue;
        [self.rideTimerManager resetRideTimer];
        [UIView animateWithDuration:0.5 animations:^{
          [self.startRideButton setTitle:@"Start Ride" forState:UIControlStateNormal];
          self.timerLabel.hidden = YES;
          [self.view layoutIfNeeded];
        }];
    }
    else {
        [self.rideTimerManager resetRideTimer];
        [self.rideTimerManager startRideTimer];
        self.headerLabelBottomSpaceConstraint.constant = 36;
        self.timerLabel.text = @"30:00";
        [self.startRideButton setTitle:@"Stop Ride" forState:UIControlStateNormal];
        [UIView animateWithDuration:0.25 animations:^{
          self.timerLabel.hidden = NO;
          //[self startRideCountdownTimer];
          [self.view layoutIfNeeded];
        }];
    }
}

- (IBAction)fullMapButtonPressed:(id)sender
{
    if (self.fullMapButton.selected == NO) {
        self.fullMapButton.selected = YES;
        self.fullMapButton.backgroundColor = RDBlueishGrey;
        [self revealFullMapView];
    }
    else {
        self.fullMapButton.selected = NO;
        self.fullMapButton.backgroundColor = [UIColor clearColor];
        [self hideFullMapView];
    }
}

- (IBAction)aboutButtonPressed:(id)sender
{
    //Toggle between hidden and not.
    [UIView animateWithDuration:0.3 animations:^{
      self.aboutBlurView.alpha = (self.aboutBlurView.alpha == 0) ? 1 : 0;
    }
                     completion:nil];
}

- (IBAction)githubRepoButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/RappidDevelopment/PhillyBikeShare-iOS"]];
}

- (IBAction)bikeShareButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.rideindego.com"]];
}

- (IBAction)rappidButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://rappiddevelopment.com"]];
}

#pragma mark - Gesture Recognizers

- (void)applyGestures
{
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(swipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(swipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    UIPanGestureRecognizer *revealFullMapViewPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                                            action:@selector(handleRevealFullMapViewPan:)];
    [self.footerView addGestureRecognizer:swipeRight];
    [self.footerView addGestureRecognizer:swipeLeft];
    [self.footerView addGestureRecognizer:revealFullMapViewPanGestureRecognizer];

    // This sets the pan gesture as the priority. Without they were getting all messed up.
    [revealFullMapViewPanGestureRecognizer requireGestureRecognizerToFail:swipeLeft];
    [revealFullMapViewPanGestureRecognizer requireGestureRecognizerToFail:swipeRight];

    // Add a tap gesture to the about blur view.
    UITapGestureRecognizer *aboutTapGestureRecognzier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aboutBlurViewTapped:)];
    [self.aboutBlurView addGestureRecognizer:aboutTapGestureRecognzier];
}

- (void)swipe:(UISwipeGestureRecognizer *)swipeRecogniser
{
    if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionRight) {
        if (self.currentPlace == self.locationManager.stations.count - 1) {
            self.currentPlace = 0;
        }
        else {
            self.currentPlace++;
        }
        self.selectedStation = [self.locationManager.stations objectAtIndex:self.currentPlace];
    }
    else if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionLeft) {
        if (self.currentPlace == 0) {
            self.currentPlace = self.locationManager.stations.count - 1;
        }
        else {
            self.currentPlace--;
        }
        self.selectedStation = [self.locationManager.stations objectAtIndex:self.currentPlace];
    }
}

- (IBAction)swipeLeftArrow:(id)sender
{
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] init];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self swipe:swipeLeft];
}

- (IBAction)swipeRightArrow:(id)sender
{
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] init];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self swipe:swipeRight];
}

- (void)handleRevealFullMapViewPan:(UIPanGestureRecognizer *)panRecognizer
{
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
            }
            else {
                [self revealFullMapView];
            }
            break;

        default:
            break;
    }
}

- (void)moveFooterAndHeaderViewByxOffset:(CGFloat)xOffset
{
    CGFloat currentHeight = self.headerViewHeight.constant;
    currentHeight += xOffset;
    self.bikeViewHeight.constant = (currentHeight < (ScreenHeight / 3) / 1.5) ? 0 : self.bikeViewInitialHeight;
    self.headerViewHeight.constant = (currentHeight > (ScreenHeight / 3)) ? ScreenHeight / 3 : currentHeight;
    self.startRideButton.hidden = (currentHeight > ScreenHeight / 3 / 1.5) ? NO : YES;
    [self.view layoutIfNeeded];
}

- (void)revealFullMapView
{
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

    if ([self.footerView.constraints containsObject:self.aboutButtonBottomSpaceConstraint]) {
        [self.footerView removeConstraint:self.aboutButtonBottomSpaceConstraint];
    }

    if (![self.footerView.constraints containsObject:self.aboutButtonYConstraint]) {
        [self.footerView addConstraint:self.aboutButtonYConstraint];
    }

    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.selectedStation.latitude longitude:self.selectedStation.longitude];

    double distance = [self.locationManager.usersCurrentLocation distanceFromLocation:location];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.locationManager.usersCurrentLocation.coordinate, 2 * distance, 2 * distance);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];

    [UIView animateWithDuration:0.5f
        animations:^{
          self.headerLocationLabel.transform = CGAffineTransformScale(self.headerLocationLabel.transform, .5, .5);
          [self.view layoutIfNeeded];
        }
        completion:^(BOOL finished) {
          self.headerLocationLabel.font = MontserratBold(24);
          self.headerLocationLabel.transform = CGAffineTransformScale(self.headerLocationLabel.transform, 1.0, 1.0);
        }];
}

- (void)hideFullMapView
{
    self.fullMapButton.backgroundColor = [UIColor clearColor];
    self.timerLabel.hidden = ([self.rideTimerManager timerIsRunning]) ? NO : YES;
    self.startRideButton.hidden = NO;
    self.headerLabelBottomSpaceConstraint.constant = ([self.rideTimerManager timerIsRunning]) ? 36 : self.headerLabelBottomSpaceInitalValue;
    self.headerViewHeight.constant = floor(ScreenHeight / 3);
    self.headerLocationLabel.font = MontserratBold(48);
    self.headerLocationLabel.transform = CGAffineTransformScale(self.headerLocationLabel.transform, 0.5, 0.5);
    self.bikeViewHeight.constant = self.bikeViewInitialHeight;

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

    if ([self.footerView.constraints containsObject:self.aboutButtonYConstraint]) {
        [self.footerView removeConstraint:self.aboutButtonYConstraint];
    }

    if (![self.footerView.constraints containsObject:self.aboutButtonBottomSpaceConstraint]) {
        [self.footerView addConstraint:self.self.aboutButtonBottomSpaceConstraint];
    }
    [UIView animateWithDuration:0.5f
        animations:^{
          self.headerLocationLabel.transform = CGAffineTransformScale(self.headerLocationLabel.transform, 2, 2);
          [self.view layoutIfNeeded];
        }
        completion:^(BOOL finished) {
          self.headerLocationLabel.font = MontserratBold(48);
          self.headerLocationLabel.transform = CGAffineTransformScale(self.headerLocationLabel.transform, 1.0, 1.0);
          //[self setupViewBasedOnUsersCurrentLocation];
        }];
}

- (void)aboutBlurViewTapped:(UITapGestureRecognizer *)tapRecognizer
{
    [UIView animateWithDuration:0.3 animations:^{
      self.aboutBlurView.alpha = (self.aboutBlurView.alpha == 0) ? 1 : 0;
    }
                     completion:nil];
}

@end