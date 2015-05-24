//
//  PhillyBikeShareNetworkCommand.h
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhillyBikeShareNetworkCommandProtocol.h"

@interface PhillyBikeShareNetworkCommand : NSObject <PhillyBikeShareNetworkCommandProtocol>

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
