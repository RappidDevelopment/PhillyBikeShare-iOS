//
//  PBSLocationManager.m
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import "PBSGetAllDataCommand.h"
#import "PBSLocationManager.h"
#import "PBSStation.h"

@interface PBSLocationManager () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *updateDataTimer;

- (void)fetchAllLocationsWithCompletion:(void (^)(NSError *error))completionBlock;
- (NSArray *)parseData:(id)responseObject;
- (void)sortLocationsClosestToUser;

@end

@implementation PBSLocationManager

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    _locationManager.delegate = self;

    return _locationManager;
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.updateDataTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                                target:self
                                                              selector:@selector(requestUsersCurrentLocation)
                                                              userInfo:nil
                                                               repeats:YES];
    }

    return self;
}

- (void)dealloc
{
    [self.updateDataTimer invalidate];
    self.updateDataTimer = nil;
}

- (void)requestUsersCurrentLocation
{
    [self.locationManager requestWhenInUseAuthorization];

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self.delegate didUpdateUsersAuthorizationStatus:status];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.usersCurrentLocation = [locations lastObject];
    [self.locationManager stopUpdatingLocation];

    @weakify(self)
        [self fetchAllLocationsWithCompletion:^(NSError *error) {
          @strongify(self) if (error)
          {
              [self.delegate didReceiveError:error];
          }
          else
          {
              [self sortLocationsClosestToUser];
              [self.delegate didUpdateLocationData];
          }
        }];
}

- (void)fetchAllLocationsWithCompletion:(void (^)(NSError *error))completionBlock
{
    @weakify(self);
    PBSGetAllDataCommand *getAllDataCommand = [[PBSGetAllDataCommand alloc] initWithSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
      @strongify(self);
      self.stations = [self parseData:responseObject];

      if (completionBlock) {
          completionBlock(nil);
      }
    }
        andFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
          DLog(@"Failure");
          DLog(@"%@", error.localizedDescription);

          if (completionBlock) {
              completionBlock(error);
          }
        }];
    [getAllDataCommand execute];
}

- (NSArray *)parseData:(id)responseObject
{
    NSArray *stationsArray = [responseObject objectForKey:@"features"];
    NSMutableArray *mutableStations = [NSMutableArray array];

    for (id stationObject in stationsArray) {
        id geometry = stationObject[@"geometry"];
        NSArray *coordinates = geometry[@"coordinates"];
        id properties = stationObject[@"properties"];
        float longitude = [[coordinates objectAtIndex:0] floatValue];
        float latitude = [[coordinates objectAtIndex:1] floatValue];
        PBSStation *phillyBikeShareLocation = [[PBSStation alloc] initWithKioskId:[properties[@"kioskId"] intValue]
                                                                          andName:properties[@"name"]
                                                                      andLatitude:latitude
                                                                     andLongtiude:longitude
                                                                 andAddressStreet:properties[@"addressStreet"]
                                                                   andAddressCity:properties[@"addressCity"]
                                                                  andAddressState:properties[@"addressState"]
                                                                 andAddresZipCode:properties[@"addressZipCode"]
                                                                andBikesAvailable:[properties[@"bikesAvailable"] intValue]
                                                                andDocksAvailable:[properties[@"docksAvailable"] intValue]
                                                                    andTotalDocks:[properties[@"totalDocks"] intValue]];
        [mutableStations addObject:phillyBikeShareLocation];
    }

    return mutableStations;
}

- (void)sortLocationsClosestToUser
{
    NSMutableArray *stationsMutable = [NSMutableArray arrayWithArray:self.stations];

    for (PBSStation *station in stationsMutable) {
        CLLocation *stationLocation = [[CLLocation alloc] initWithLatitude:station.latitude longitude:station.longitude];
        CLLocationDistance distanceBetweenUserandStation = [self.usersCurrentLocation distanceFromLocation:stationLocation];
        double distanceInMiles = distanceBetweenUserandStation / 1609.344;
        station.distanceFromUser = distanceInMiles;
    }
    [stationsMutable sortUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"distanceFromUser" ascending:YES], nil]];
    self.stations = stationsMutable;
}

@end