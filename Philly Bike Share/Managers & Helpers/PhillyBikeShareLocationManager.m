//
//  PhillyBikeShareLocationManager.m
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import "PhillyBikeShareLocationManager.h"
#import "PhillyBikeShareGetAllDataCommand.h"

@interface PhillyBikeShareLocationManager()

@property (strong, nonatomic) NSArray *phillyBikeShareLocations;
@property (atomic) BOOL isRefreshing;

@end

@implementation PhillyBikeShareLocationManager

//Return singleton instance
+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initPrivate];
    });
    return sharedInstance;
}


//If a programmer calls this method, scold him with an exception (use sharedInstance initializer only)
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[PhillyBikeShareLocationManager sharedInstance]" userInfo:nil];
    return nil;
}

//Return privately initialized instance
- (instancetype)initPrivate
{
    self = [super init];
    if(self) {
        self.phillyBikeShareLocations = [[NSArray alloc]init];
    }
    return self;
}

- (void)fetchAllLocationsWithSuccessBlock:(PhillyBikeShareSuccessBlock)successBlock
                     andFailureBlock:(PhillyBikeShareFailureBlock)failureBlock {
    
    PhillyBikeShareGetAllDataCommand *getAllDataCommand = [[PhillyBikeShareGetAllDataCommand alloc]initWithSuccessBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"Successssss");
        DLog(@"%@", responseObject);
        //TODO: Handle JSON parsing here;
        successBlock(responseObject);
    } andFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Failure");
        DLog(@"%@", error.localizedDescription);
        failureBlock(error);
    }];
    [getAllDataCommand execute];
}

@end