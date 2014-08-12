//
//  Frame.m
//  TrackerMouse
//
//  Created by Clare Matthews on 11/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "Frame.h"

@implementation Frame

-(void) showFrame {
    VideoCapture capture(0);
    Mat frame;
    capture.read(frame);
    NSLog(@"rows: %d", frame.rows);
    NSLog(@"cols: %d", frame.cols);
    resize(frame, frame, cv::Size(1440, 900));
    
    // Move cursor
    uint32_t count = 0;
    CGDirectDisplayID displayForPoint;
    
    // New mouse position
    CGPoint newPoint = CGPointMake(frame.cols/2, frame.rows/2);
    
    // Display for new position
    if (CGGetDisplaysWithPoint(newPoint, 1, &displayForPoint, &count) != kCGErrorSuccess)
    {
        NSLog(@"Error getting display");
    }
    imshow("camera", frame);
    CGDisplayMoveCursorToPoint(displayForPoint, newPoint);

    waitKey(0);
    
    // New mouse position
    newPoint = CGPointMake(frame.cols, frame.rows/2);
    
    // Display for new position
    if (CGGetDisplaysWithPoint(newPoint, 1, &displayForPoint, &count) != kCGErrorSuccess)
    {
        NSLog(@"Error getting display");
    }
    imshow("camera", frame);
    CGDisplayMoveCursorToPoint(displayForPoint, newPoint);
    
    waitKey(0);
    
    // New mouse position
    newPoint = CGPointMake(frame.cols/2, frame.rows);
    
    // Display for new position
    if (CGGetDisplaysWithPoint(newPoint, 1, &displayForPoint, &count) != kCGErrorSuccess)
    {
        NSLog(@"Error getting display");
    }
    imshow("camera", frame);
    CGDisplayMoveCursorToPoint(displayForPoint, newPoint);
    
    waitKey(0);
    
    // New mouse position
    newPoint = CGPointMake(1440, 900);
    
    // Display for new position
    if (CGGetDisplaysWithPoint(newPoint, 1, &displayForPoint, &count) != kCGErrorSuccess)
    {
        NSLog(@"Error getting display");
    }
    imshow("camera", frame);
    CGDisplayMoveCursorToPoint(displayForPoint, newPoint);
    
    waitKey(0);
    
    // New mouse position
    newPoint = CGPointMake(720, 0);
    
    // Display for new position
    if (CGGetDisplaysWithPoint(newPoint, 1, &displayForPoint, &count) != kCGErrorSuccess)
    {
        NSLog(@"Error getting display");
    }
    imshow("camera", frame);
    CGDisplayMoveCursorToPoint(displayForPoint, newPoint);
    
    waitKey(0);
    
    // New mouse position
    newPoint = CGPointMake(720, 22);
    
    // Display for new position
    if (CGGetDisplaysWithPoint(newPoint, 1, &displayForPoint, &count) != kCGErrorSuccess)
    {
        NSLog(@"Error getting display");
    }
    imshow("camera", frame);
    CGDisplayMoveCursorToPoint(displayForPoint, newPoint);
    
    waitKey(0);
    
//    Mat frame = imread("frame_00001.jpg");
//    
//    namedWindow("OpenCV Window", CV_WINDOW_NORMAL);
//    moveWindow("OpenCV Window", 0, 0);
//    imshow("OpenCV Window", frame);
//    
//    waitKey(0);
    
}

@end
