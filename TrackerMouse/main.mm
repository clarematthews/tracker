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
#import <QuartzCore/CABase.h>
#import <ApplicationServices/ApplicationServices.h>
#import "Frame.h"
#import "Ball.h"

using namespace std;
using namespace cv;

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        int offsetx = 0;
        int offsety = 0;
        int bins = 20;
        int radius = 50;
        Ball *trackBall = [[Ball alloc] init];
        Ball *clickBall = [[Ball alloc] init];
        
        double trackThresh = 0;
        double clickThresh = 0;
        double clickWaitTime = 3; // secs to wait before next click
        int clickSensitivity = 5; // number of frames ball must be present for
        int clickFac = 1; // multiplicative factor for threshold;
        double lastclick = -clickWaitTime;
        int clickCount = 0;
        int training = 5;
        int pixRange = 100; // size for subframes
        int pixRangeFac = 1; // multiplicative factor to increase range
        
        VideoCapture capture(0);
        Mat frame;
        capture.read(frame);
        
        Circle *circ = [[Circle alloc] initWithCentre:cv::Point(frame.cols/2, frame.rows/2) withRadius:radius withColour:Scalar(255, 200, 50)];
        bool isTrackInitialised = false;
        bool isClickInitialised = false;
        int upC = circ.centre.x - pixRange;
        int upR = circ.centre.y - pixRange;
        int downC = circ.centre.x + pixRange;
        int downR = circ.centre.y + pixRange;
        
        while (!isClickInitialised) {
            capture.read(frame);
            flip(frame, frame, 1);
            
            // Add circle
            circle(frame, circ.centre, circ.radius, circ.colour, circ.width);
            
            imshow("Tracker", frame);
            
            if (waitKey(10) == 32) {
                [clickBall setHistogram:&frame withBins:bins fromCircle:circ];
                [clickBall isPresent:&frame inRegion:cv::Rect(cv::Point(upC, upR), cv::Point(downC, downR)) withBins:bins inTraining:true withThreshold:clickThresh];
                clickThresh = clickThresh*clickFac;
                isClickInitialised = true;
            }
            
        }
        
        circ.colour = Scalar(150, 150, 255);
        
        while (!isTrackInitialised) {
            capture.read(frame);
            flip(frame, frame, 1);
            
            // Add circle
            circle(frame, circ.centre, circ.radius, circ.colour, circ.width);
            
            imshow("Tracker", frame);
            
            if (waitKey(10) == 32) {
                [trackBall setHistogram:&frame withBins:bins fromCircle:circ];
                isTrackInitialised = true;
                destroyWindow("Tracker");
            }
            
        }

        Mat state(4, 1, CV_32F);
        
        state.at<float>(0) = circ.centre.x;
        state.at<float>(1) = circ.centre.y;
        state.at<float>(2) = 0;
        state.at<float>(3) = 0;
        
        int frameCount = 0;
        
        uint32_t count = 0;
        CGDirectDisplayID displayForPoint;
        
        NSLog(@"thresh: %f", clickThresh);
        
        while (capture.isOpened()) {

            capture.read(frame);
            flip(frame, frame, 1);
            resize(frame, frame, cv::Size(1440, 900));
//            namedWindow("OpenCV Window", CV_WINDOW_NORMAL);
//            moveWindow("OpenCV Window", 0, 0);
//            imshow("OpenCV Window", frame);
            
            int curX = state.at<float>(0); // col
            int curY = state.at<float>(1); // row
            int curDx = state.at<float>(2); // col velocity
            int curDy = state.at<float>(3); // row velocity
            int upR = 0;
            int upC = 0;
            int downR = frame.rows;
            int downC = frame.cols;
            
            if (curY >= 0 && curX >= 0 && curY < frame.rows && curX < frame.cols) {
                if (curX - pixRange*pixRangeFac + curDx > 0 && curX - pixRange*pixRangeFac + curDx < frame.cols) {
                    upC = curX - pixRange*pixRangeFac + curDx;
                }
                if (curY - pixRange*pixRangeFac + curDy > 0 && curY - pixRange*pixRangeFac + curDy < frame.rows) {
                    upR = curY - pixRange*pixRangeFac + curDy;
                }
                if (curX + pixRange*pixRangeFac  + curDx < frame.cols && curX + pixRange*pixRangeFac  + curDx > 0) {
                    downC = curX + pixRange*pixRangeFac + curDx;
                }
                if (curY + pixRange*pixRangeFac + curDy < frame.rows && curY + pixRange*pixRangeFac + curDy > 0) {
                    downR = curY + pixRange*pixRangeFac + curDy;
                }
            }
            
            bool isFound = [trackBall findCentre:&frame inRegion:cv::Rect(cv::Point(upC, upR), cv::Point(downC, downR)) withBins:bins withRadius:radius inTraining:frameCount < training withThreshold:trackThresh];
            
            bool isClick = [clickBall isPresent:&frame inRegion:cv::Rect(cv::Point(upC, upR), cv::Point(downC, downR)) withBins:bins inTraining:false withThreshold:clickThresh];
            
            cv::Point centreEst = trackBall.centre;
            
            if (isFound) {
                state.at<float>(2) = (centreEst.x + upC - curX)/2; // col velocity
                state.at<float>(3) = (centreEst.y + upR - curY)/2; // row velocity
                state.at<float>(0) = centreEst.x + upC; // col
                state.at<float>(1) = centreEst.y + upR; // row
                pixRangeFac = 1;
            }
            else {
                state.at<float>(2) = (centreEst.x - curX)/2; // col velocity
                state.at<float>(3) = (centreEst.y - curY)/2; // row velocity
                state.at<float>(0) = centreEst.x; // col
                state.at<float>(1) = centreEst.y; // row
                pixRangeFac = 2;
            }
            
            // New mouse position
            CGPoint newPoint = CGPointMake(state.at<float>(0) + offsetx, state.at<float>(1) + offsety);
            
            // Display for new position
            if (CGGetDisplaysWithPoint(newPoint, 1, &displayForPoint, &count) != kCGErrorSuccess)
            {
                NSLog(@"Error getting display");
                return 0;
            }
            
            // Move cursor
            CGDisplayMoveCursorToPoint(displayForPoint, newPoint);
            
            // Check for click
            if (isClick) {
                clickCount++;
                if (clickCount >= clickSensitivity) {
                    double currentTime = CACurrentMediaTime();
                    if (currentTime > lastclick + clickWaitTime) {
                        NSLog(@"click! ");
                        CGEventRef clickDown = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, newPoint, kCGMouseButtonLeft);
                        CGEventRef clickUp = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, newPoint, kCGMouseButtonLeft);
                        CGEventPost(kCGHIDEventTap, clickDown);
                        CGEventPost(kCGHIDEventTap, clickUp);
                        lastclick = currentTime;
                        clickCount = 0;
                    }
                }
                
            }
            else {
                clickCount = 0;
            }
            
            ++frameCount;
            if (frameCount == training) {
                trackThresh = trackThresh/training/2;
            }
            
            if (waitKey(10) == 27) {
                break;
            }
        }
        
    }
    return 0;
}

