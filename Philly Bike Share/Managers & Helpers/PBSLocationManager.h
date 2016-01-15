//
//  PBSLocationManager.h
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@class PBSLocationManager;
@protocol PBSLocationManagerDelegate <NSObject>

- (void)didUpdateLocationData;
- (void)didUpdateUsersAuthorizationStatus:(CLAuthorizationStatus)authorizationStatus;
- (void)didReceiveError:(NSError *)error;

@end

@interface PBSLocationManager : NSObject

@property (nonatomic, weak) id<PBSLocationManagerDelegate> delegate;
@property (nonatomic, strong) NSArray *stations;
@property (nonatomic, strong) CLLocation *usersCurrentLocation;

- (void)requestUsersCurrentLocation;

@end
