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
typedef void (^PhillyBikeShareFailureBlock) (NSError *error);

@interface PhillyBikeShareLocationManager : NSObject

+ (instancetype)sharedInstance;

- (void)fetchAllLocationsWithSuccessBlock:(PhillyBikeShareSuccessBlock)successBlock
                     andFailureBlock:(PhillyBikeShareFailureBlock)failureBlock;

- (PhillyBikeShareLocation *)getPhillyBikeShareLocationById:(NSInteger)phillyBikeShareLocationId;

- (void)sortLocationsBasedOnUsersLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude withNextBlock:(PhillyBikeShareSuccessBlock)nextBlock;

@end
