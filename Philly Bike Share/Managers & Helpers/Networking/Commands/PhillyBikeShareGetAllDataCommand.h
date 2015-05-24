//
//  PhillyBikeShareGetAllDataCommand.h
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhillyBikeShareNetworkCommandProtocol.h"

@interface PhillyBikeShareGetAllDataCommand : NSObject <PhillyBikeShareNetworkCommandProtocol>

- (instancetype)initWithSuccessBlock:(AFHTTPRequestOperationSuccessBlock)success
                     andFailureBlock:(AFHTTPRequestOperationFailureBlock)failure;

@end