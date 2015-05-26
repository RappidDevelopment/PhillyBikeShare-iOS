//
//  PhillyBikeShareGetAllDataCommand.m
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import "PhillyBikeShareGetAllDataCommand.h"
#import "PhillyBikeShareNetworkCommand.h"

@interface PhillyBikeShareGetAllDataCommand()

@property (nonatomic, copy) AFHTTPRequestOperationSuccessBlock successHandler;
@property (nonatomic, copy) AFHTTPRequestOperationFailureBlock failureHandler;

@end

@implementation PhillyBikeShareGetAllDataCommand

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
    
    PhillyBikeShareNetworkCommand *command = [[PhillyBikeShareNetworkCommand alloc] initWithUrl:url andMethod:method andJsonRequest:YES andParameters:nil andSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
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
