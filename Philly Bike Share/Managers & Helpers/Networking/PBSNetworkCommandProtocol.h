//
//  PBSNetworkCommandProtocol.h
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperation.h>
#import <Foundation/Foundation.h>

/*!
 * @discussion A block that is run after a succesful network call.
 * @param operation A operation object contains the status codes and content types.
 * @param responseObject The data returned from the server.
 */
typedef void (^AFHTTPRequestOperationSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);

/*!
 * @discussion A block that is run after an unsuccesful network call.
 * @param operation A operation object contains the status codes and content types.
 * @param error The error returned from the server.
 */
typedef void (^AFHTTPRequestOperationFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);

@protocol PBSNetworkCommandProtocol <NSObject>

/*!
 * @discussion The execute method must be implemented by every network command.
 */
- (void)execute;

@end