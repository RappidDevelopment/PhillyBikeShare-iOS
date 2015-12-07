//
//  PhillyBikeShareTimerManager.m
//  Philly Bike Share
//
//  Created by Matt Morgis on 12/7/15.
//  Copyright © 2015 Rappid Development. All rights reserved.
//

#import "PhillyBikeShareTimerManager.h"

@implementation PhillyBikeShareTimerManager

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
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[PhillyBikeShareTimerManager sharedInstance]" userInfo:nil];
    return nil;
}

//Return privately initialized instance
- (instancetype)initPrivate
{
    self = [super init];
    
    if(self) {
        // init code goes here;
    }
    return self;
}

@end
