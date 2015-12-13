//
//  PBSGetAllDataCommand.h
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import "PBSNetworkCommandProtocol.h"
#import <Foundation/Foundation.h>

/*!
 * @discussion The network command to fetch all PhillyBikeShareLocation data.
 *
 *
 */
@interface PBSGetAllDataCommand : NSObject <PBSNetworkCommandProtocol>

- (instancetype)initWithSuccessBlock:(AFHTTPRequestOperationSuccessBlock)success
                     andFailureBlock:(AFHTTPRequestOperationFailureBlock)failure;

@end
