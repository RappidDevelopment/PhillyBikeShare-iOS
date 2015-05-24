//
//  PhillyBikeShareLocationManager.m
//  Philly Bike Share
//
//  Created by Morgis, Matthew on 5/24/15.
//  Copyright (c) 2015 Rappid Development. All rights reserved.
//

#import "PhillyBikeShareLocationManager.h"
#import "PhillyBikeShareLocation.h"
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
        
        NSArray *locations = [responseObject objectForKey:@"features"];
        NSMutableArray *mutablePhillyBikeShareLocations = [NSMutableArray array];
        
        for (id location in locations) {
            id geometry = [location objectForKey:@"geometry"];
            NSArray *coordinates = [geometry objectForKey:@"coordinates"];
            id properties = [location objectForKey:@"properties"];
            
            NSInteger kioskId = [[properties objectForKey:@"kioskId"]intValue];
            NSString *name = [properties objectForKey:@"name"];
            float latitude = [[coordinates objectAtIndex:0]floatValue];
            float longitude = [[coordinates objectAtIndex:1]floatValue];
            NSString *addressStreet = [properties objectForKey:@"addressStreet"];
            NSString *addressState = [properties objectForKey:@"addressState"];
            NSString *addressCity = [properties objectForKey:@"addressCity"];
            NSString *addressZipCode = [properties objectForKey:@"addressZipCode"];
            NSInteger bikesAvailable = [[properties objectForKey:@"bikesAvailable"]intValue];
            NSInteger docksAvailable = [[properties objectForKey:@"docksAvailable"]intValue];
            NSInteger totalDocks = [[properties objectForKey:@"totalDocks"]intValue];
            
            PhillyBikeShareLocation *phillyBikeShareLocation = [[PhillyBikeShareLocation alloc]initWithKioskId:kioskId
                                                                                                       andName:name
                                                                                                   andLatitude:latitude
                                                                                                  andLongtiude:longitude andAddressStreet:addressStreet andAddressCity:addressCity
                                                                                               andAddressState:addressState
                                                                                            andAddresZipCode:addressZipCode
                                                                                             andBikesAvailable:bikesAvailable
                                                                                             andDocksAvailable:docksAvailable
                                                                                                 andTotalDocks:totalDocks];
            
            [mutablePhillyBikeShareLocations addObject:phillyBikeShareLocation];
        }
        self.phillyBikeShareLocations = mutablePhillyBikeShareLocations;
        successBlock(self.phillyBikeShareLocations);
    } andFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Failure");
        DLog(@"%@", error.localizedDescription);
        failureBlock(error);
    }];
    [getAllDataCommand execute];
}

@end