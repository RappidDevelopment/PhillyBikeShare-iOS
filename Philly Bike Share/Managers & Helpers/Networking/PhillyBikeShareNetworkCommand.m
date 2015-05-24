//
//  PhillyBikeShareNetworkCommand.m
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import "PhillyBikeShareNetworkCommand.h"
#import <AFNetworking.h>
#import <AFNetworking/AFHTTPRequestOperation.h>

@interface PhillyBikeShareNetworkCommand()

@property (nonatomic, copy) AFHTTPRequestOperationSuccessBlock successHandler;
@property (nonatomic, copy) AFHTTPRequestOperationFailureBlock failureHandler;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, assign) BOOL jsonRequest;

@end

@implementation PhillyBikeShareNetworkCommand

- (instancetype)initWithUrl:(NSString *)url
              andParameters:(NSDictionary *)parameters
            andSuccessBlock:(AFHTTPRequestOperationSuccessBlock)success
            andFailureBlock:(AFHTTPRequestOperationFailureBlock)failure {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.successHandler = [success copy];
    self.failureHandler = [failure copy];
    self.parameters = parameters;
    self.url = url;
    
    if (!self.method) {
        self.method = @"POST";
    }
    
    return self;
}

- (instancetype)initWithUrl:(NSString *)url
                  andMethod:(NSString *)method
             andJsonRequest:(BOOL)jsonRequest
              andParameters:(NSDictionary *)parameters
            andSuccessBlock:(AFHTTPRequestOperationSuccessBlock)success
            andFailureBlock:(AFHTTPRequestOperationFailureBlock)failure {
    
    self.method = method;
    self.jsonRequest = jsonRequest;
    
    return [self initWithUrl:url andParameters:parameters andSuccessBlock:success andFailureBlock:failure];
}

- (void)execute {
    
    // setup the manager
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if (self.jsonRequest) {
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager setRequestSerializer:requestSerializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        //Needed because the API doesn't technically return JSON data.
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    } else {
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        [requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [manager setRequestSerializer:requestSerializer];
    }
    
    SEL methodSelector = NSSelectorFromString([[NSString alloc]
                                               initWithFormat:@"%@:%@", self.method,@"parameters:success:failure:"]);
    
    NSMethodSignature *signature = [manager methodSignatureForSelector:methodSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature ];
    [invocation setSelector:methodSelector];
    [invocation setArgument:&_url atIndex:2];
    [invocation setArgument:&_parameters atIndex:3];
    
    // define the success and failure blocks to pass to the manager
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        self.successHandler(operation, responseObject);
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        self.failureHandler(operation, error);
    };
    successBlock = [successBlock copy];
    failureBlock = [failureBlock copy];
    [invocation setArgument:&successBlock atIndex:4];
    [invocation setArgument:&failureBlock atIndex:5];
    
    // Invoke the method
    [invocation invokeWithTarget:manager];
}

@end
