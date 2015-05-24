//
//  PhillyBikeShareNetworkCommandProtocol.h
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperation.h>

/**
 * Block definitions
 */
typedef void (^AFHTTPRequestOperationSuccessBlock) (AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFHTTPRequestOperationFailureBlock) (AFHTTPRequestOperation *operation, NSError *error);

@protocol PhillyBikeShareNetworkCommandProtocol <NSObject>

- (void)execute;

@end