//
//  PhillyBikeShareLocation.h
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhillyBikeShareLocation : NSObject

/*!
 * @brief The id of the location.
 */
@property (nonatomic) NSInteger kioskId;

/*!
 * @brief The name of the location.
 */
@property (strong, nonatomic) NSString *name;

/*!
 * @brief The latitude of the location.
 */
@property (nonatomic) float latitude;

/*!
 * @brief The longtidue of the location.
 */
@property (nonatomic) float longitude;

/*!
 * @brief The address of the location.
 */
@property (strong, nonatomic) NSString *addressStreet;

/*!
 * @brief The city of the location.
 */
@property (strong, nonatomic) NSString *addressCity;

/*!
 * @brief The state of the location.
 */
@property (strong , nonatomic) NSString *addressState;

/*!
 * @brief The zipcode of the location.
 */
@property (strong, nonatomic) NSString *addressZipCode;

/*!
 * @brief The number of bikes available at the location.
 */
@property (nonatomic) NSInteger bikesAvailable;

/*!
 * @brief The number of open docks avilable at the location.
 */
@property (nonatomic) NSInteger docksAvailable;

/*!
 * @brief The total number of docks at the location.
 */
@property (nonatomic) NSInteger totalDocs;

/*!
 * @brief The distance in miles the location is away from the user 
 */
@property (nonatomic) float distanceFromUser;

/*!
 * @discussion Public constructor of the PhillyBikeShareLocation object.
 * @param kioskId The id of the station
 * @param name The name of the station
 * @param latitude The latitude of the station
 * @param longitude The longtidue of the station
 * @param addressStress The street address of the station
 * @param addressCity The city of the station
 * @param addressState The state of the station
 * @param addressZipCode The zipcode of the station
 * @param bikesAvailable The number of bikes available at the station
 * @param docksAvailable The number of open docks available at the station
 * @param docksAvailable The total number of docks available at the station
 * @return A PhillyBikeShareLocation object
 */
- (instancetype) initWithKioskId:(NSInteger)kioskId
                         andName:(NSString *)name
                     andLatitude:(float)latitude
                    andLongtiude:(float)longitude
                andAddressStreet:(NSString *)addressStreet
                  andAddressCity:(NSString *)addressCity
                 andAddressState:(NSString *)addressState
                andAddresZipCode:(NSString *)addressZipCode
               andBikesAvailable:(NSInteger)bikesAvailable
               andDocksAvailable:(NSInteger)docksAvailable
                   andTotalDocks:(NSInteger)totalDocs;

@end