//
//  PhillyBikeShareLocationManager.h
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import <Foundation/Foundation.h>

// Move to private instance.
@import CoreLocation;

/*!
 * @brief A block that is run after a successful operation.
 * @param locations An array of PhillyBikeShareLocations
 */
typedef void (^PhillyBikeShareSuccessBlock) (NSArray *locations);
/*!
 * @brief A block that is run after an unsuccessful operation.
 * @param error The error object that caused the failure.
 */
typedef void (^PhillyBikeShareFailureBlock) (NSError *error);

@interface PhillyBikeShareLocationManager : NSObject

/*!
 * @discussion A method to return the sharedInsance of this class.
 * @return A singleton instance of this class.
 */
+ (instancetype)sharedInstance;

/*!
 * @discussion A method to fetch the latest information on all PhillyBikeShare locations.
 * @param successBlock A block that is run after successfully fetching the locations.
 * @param failureBlock A block that is run if an error occurs while fetching the data.
 */
- (void)fetchAllLocationsWithSuccessBlock:(PhillyBikeShareSuccessBlock)successBlock
                     andFailureBlock:(PhillyBikeShareFailureBlock)failureBlock;

/*!
 * @discussion A method to sort the locations based on distance from the user.
 * @param nextBlock A block that is run after successfully sorting the location data.
 */
// Move to private instance.
- (void)sortLocationsBasedOnUsersLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees)longitude withNextBlock:(PhillyBikeShareSuccessBlock)nextBlock;

@end
