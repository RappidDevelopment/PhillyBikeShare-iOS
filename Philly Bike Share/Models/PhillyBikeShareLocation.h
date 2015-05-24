//
//  PhillyBikeShareLocation.h
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhillyBikeShareLocation : NSObject

@property (strong, nonatomic) NSNumber *kioskId;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (strong, nonatomic) NSString *addressStreet;
@property (strong, nonatomic) NSString *addressCity;
@property (strong, nonatomic) NSString *addressZipCode;
@property (strong, nonatomic) NSNumber *bikesAvailable;
@property (strong, nonatomic) NSNumber *docksAvailable;
@property (strong, nonatomic) NSNumber *totalDocs;

@end