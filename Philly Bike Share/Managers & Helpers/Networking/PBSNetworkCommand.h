//
//  PBSNetworkCommand.h
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import "PBSNetworkCommandProtocol.h"
#import <Foundation/Foundation.h>

/*!
 * @discussion This class handles the heavy lifting and configuration
 * of making networking calls to the PhillyBikeShare API.
 *
 */
@interface PBSNetworkCommand : NSObject <PBSNetworkCommandProtocol>

- (instancetype)initWithUrl:(NSString *)url
              andParameters:(NSDictionary *)parameters
            andSuccessBlock:(AFHTTPRequestOperationSuccessBlock)success
            andFailureBlock:(AFHTTPRequestOperationFailureBlock)failure;

- (instancetype)initWithUrl:(NSString *)url
                  andMethod:(NSString *)method
             andJsonRequest:(BOOL)jsonRequest
              andParameters:(NSDictionary *)parameters
            andSuccessBlock:(AFHTTPRequestOperationSuccessBlock)success
            andFailureBlock:(AFHTTPRequestOperationFailureBlock)failure;

@end
