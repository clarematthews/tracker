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
        
        int bins = 20;
        int ballSum = 0;
        Ball *ball = [[Ball alloc] init];
        Circle *circ = [[Circle alloc] initWithCentre:cv::Point(253, 237) withRadius:30];
        Mat frame = imread("frame_00001.jpg");
        [ball setHistogram:&frame withBins:bins fromCircle:circ withPixels:&ballSum];
        
        
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

