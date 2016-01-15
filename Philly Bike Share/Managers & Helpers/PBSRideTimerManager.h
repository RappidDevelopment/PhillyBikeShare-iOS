//
//  PBSRideTimerManager.h
//  Philly Bike Share
//
//  Created by Matt Morgis on 12/7/15.
//  Copyright © 2015 Rappid Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PBSRideTimerManagerDelegate <NSObject>

- (void)rideTimerDidUpdateToTime:(NSString *)time;

@end

@interface PBSRideTimerManager : NSObject

@property (nonatomic, weak) id<PBSRideTimerManagerDelegate> delegate;

- (BOOL)timerIsRunning;
- (void)startRideTimer;
- (void)resetRideTimer;
- (void)pauseRideTimer;
- (void)resumeRideTimer;

@end
