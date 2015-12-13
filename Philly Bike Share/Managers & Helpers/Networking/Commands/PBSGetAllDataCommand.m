//
//  PBSGetAllDataCommand.m
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import "PBSGetAllDataCommand.h"
#import "PBSNetworkCommand.h"

@interface PBSGetAllDataCommand()

@property (nonatomic, copy) AFHTTPRequestOperationSuccessBlock successHandler;
@property (nonatomic, copy) AFHTTPRequestOperationFailureBlock failureHandler;

@end

@implementation PBSGetAllDataCommand

- (instancetype)initWithSuccessBlock:(AFHTTPRequestOperationSuccessBlock)success andFailureBlock:(AFHTTPRequestOperationFailureBlock)failure {
    
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.successHandler = [success copy];
    self.failureHandler = [failure copy];
    
    return self;
}

- (void)execute {
    
    NSString *url = @"https://api.phila.gov/bike-share-stations/v1";
    NSString *method = @"GET";
    
    PBSNetworkCommand *command = [[PBSNetworkCommand alloc] initWithUrl:url andMethod:method andJsonRequest:NO andParameters:nil andSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        HideNetworkActivityIndicator();
        self.successHandler(operation, responseObject);
    } andFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        HideNetworkActivityIndicator();
        self.failureHandler(operation, error);
    }];
    
    ShowNetworkActivityIndicator();
    [command execute];
}

@end
