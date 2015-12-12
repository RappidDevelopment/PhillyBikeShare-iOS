//
//  PBSStation.m
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import "PBSStation.h"

@implementation PBSStation

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
                   andTotalDocks:(NSInteger)totalDocs {
    
    self = [super init];
    
    if (self) {
        self.kioskId = kioskId;
        self.name = name;
        self.latitude = latitude;
        self.longitude = longitude;
        self.addressStreet = addressStreet;
        self.addressCity = addressCity;
        self.addressState = addressState;
        self.addressZipCode = addressZipCode;
        self.bikesAvailable = bikesAvailable;
        self.docksAvailable = docksAvailable;
        self.totalDocs = totalDocs;
    }
    
    return self;
}

@end