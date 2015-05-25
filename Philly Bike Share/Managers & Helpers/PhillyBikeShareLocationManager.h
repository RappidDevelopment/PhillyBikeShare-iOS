//
//  PhillyBikeShareLocationManager.h
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhillyBikeShareLocation.h"
@import CoreLocation;

typedef void (^PhillyBikeShareSuccessBlock) (NSArray *locations);
typedef void (^PhillyBikeShareClosestStationAndDistanceBlock) (PhillyBikeShareLocation *location, CLLocationDistance distance);
typedef void (^PhillyBikeShareFailureBlock) (NSError *error);

@interface PhillyBikeShareLocationManager : NSObject

+ (instancetype)sharedInstance;

- (void)fetchAllLocationsWithSuccessBlock:(PhillyBikeShareSuccessBlock)successBlock
                     andFailureBlock:(PhillyBikeShareFailureBlock)failureBlock;

- (PhillyBikeShareLocation *)getPhillyBikeShareLocationById:(NSInteger)phillyBikeShareLocationId;

- (void)fetchClosestBikeShareStationToLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude withNextBlock:(PhillyBikeShareClosestStationAndDistanceBlock)nextBlock;

@end
