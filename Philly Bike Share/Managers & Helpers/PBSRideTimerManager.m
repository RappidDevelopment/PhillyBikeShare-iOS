//
//  PBSRideTimerManager.m
//  Philly Bike Share
//
//  Created by Matt Morgis on 12/7/15.
//  Copyright © 2015 Rappid Development. All rights reserved.
//

#import "PBSRideTimerManager.h"

@interface PBSRideTimerManager()

@property (nonatomic, strong) NSTimer *rideTimer;
@property (nonatomic) NSInteger secondsLeft;
@property (nonatomic) NSInteger hours;
@property (nonatomic) NSInteger minutes;
@property (nonatomic) NSInteger seconds;

@end

@implementation PBSRideTimerManager

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc {
    if ([self.rideTimer isValid]) {
        [self.rideTimer invalidate];
        self.rideTimer = nil;
    }
}

- (BOOL)timerIsRunning {
    return self.rideTimer.isValid;
}

- (void)startRideTimer {
    if ([self.rideTimer isValid]) {
        [self.rideTimer invalidate];
    }
    // Start the ride timer.
    self.rideTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                      target:self
                                                    selector:@selector(rideTimerUpdated)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)resetRideTimer {
    [self.rideTimer invalidate];
    self.rideTimer = nil;
    self.secondsLeft = self.hours = self.minutes = self.seconds = 1800;
}

- (void)pauseRideTimer {
    /*
     * Applications are allowed to run in the background for 10 minutes.
     * To keep the 30 minute timer running, I store how many seconds are left,
     * and the time stamp at when the user exited the app.
     */
    if ([self.rideTimer isValid]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:self.secondsLeft forKey:@"secondsLeft"];
        [defaults setObject:[NSDate date] forKey:@"timeStopped"];
        [defaults synchronize];
    }
}

- (void)resumeRideTimer {
    /*
     * If the ride timer is active,
     * calulcate how long it's been since they exited the app.
     * Update the timer accordingly.
     */
    if ([self.rideTimer isValid]) {
        [self.rideTimer invalidate];
        NSDate *timeOpen = [NSDate date];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDate *timeStopped = [defaults objectForKey:@"timeStopped"];
        NSTimeInterval secondsPassed = [timeOpen timeIntervalSinceDate:timeStopped];

        if ((self.secondsLeft - secondsPassed) > 0) {
            self.secondsLeft = self.hours = self.minutes = self.seconds = self.secondsLeft - secondsPassed;
            [self startRideTimer];
        }
    }
}

- (void)rideTimerUpdated {
    // Some magic math to count backwards from 30:00
    if (self.secondsLeft > 0) {
        self.secondsLeft--;
        self.hours = self.secondsLeft / 3600;
        self.minutes = (self.secondsLeft % 3600) / 60;
        self.seconds = (self.secondsLeft % 3600) % 60;
        [self.delegate rideTimerDidUpdateToTime:[NSString stringWithFormat:@"%02ld:%02ld", (long)self.minutes, (long)self.seconds]];
    }
    else {
        // If there is no time left invalidate the timer.
        [self.rideTimer invalidate];
    }
}

@end