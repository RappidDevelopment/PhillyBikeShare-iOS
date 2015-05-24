//
//  PhillyBikeShareLocation.h
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhillyBikeShareLocation : NSObject

@property (nonatomic) NSInteger kioskId;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (strong, nonatomic) NSString *addressStreet;
@property (strong, nonatomic) NSString *addressCity;
@property (strong , nonatomic) NSString *addressState;
@property (strong, nonatomic) NSString *addressZipCode;
@property (nonatomic) NSInteger bikesAvailable;
@property (nonatomic) NSInteger docksAvailable;
@property (nonatomic) NSInteger totalDocs;

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