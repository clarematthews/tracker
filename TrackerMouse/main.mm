//
//  main.m
//  TrackerMouse
//
//  Created by Clare Matthews on 11/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "opencv2/opencv.hpp"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Frame.h"
#import "Ball.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        Ball *ball = [[Ball alloc] init];
        
        Frame *oneframe = [[Frame alloc] init];
        [oneframe showFrame];
        
        uint32_t count = 0;
        CGDirectDisplayID displayForPoint;
        
        // New mouse position
        CGPoint newPoint = CGPointMake(100, 800);
        
        // Display for new position
        if (CGGetDisplaysWithPoint(newPoint, 1, &displayForPoint, &count) != kCGErrorSuccess)
        {
            NSLog(@"Error getting display");
            return 0;
        }
        
        // Move cursor
        CGDisplayMoveCursorToPoint(displayForPoint, newPoint);
        
    }
    return 0;
}

