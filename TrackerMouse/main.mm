//
//  main.mm
//  TrackerClick
//
//  TrackerClick provides control of the cursor by tracking a hand-held
//  circular, coloured controller.
//  Placing a second, different coloured controller next to the track-
//  controller signals a click.
//  The application is developed for use on a MacBook, running
//  OS X Mavericks, and uses the iSight camera for tracking.
//  The OpenCV library is used for image manipulation.
//
//  Created by Clare Matthews on 11/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "opencv2/opencv.hpp"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <QuartzCore/CABase.h>
#import <ApplicationServices/ApplicationServices.h>
#import "Ball.h"
#import "Source.h"

using namespace std;
using namespace cv;

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        /*
         *  Adjustable parameters to control the tracking and
         *  cursor control
         */
        
        // Horizontal offset of camera frame relative to screen
        int offsetx = 0;
        // Vertical offset of camera frame relative to screen
        int offsety = 0;
        // Number of initial frames to use to calculate threshold for detection
        int trainingFrames = 5;
        // Size of subframes used for initial detection
        int subframePix = 100;
        // Proportion of distance to new point to move
        double moveFac = 0.5;
        // Number of bins for histogram model
        int bins = 20;
        // Radius of circle in kernel and set-up stage
        int radius = 50;
        // Time to wait before the next click detection registers (s)
        double clickWaitTime = 3;
        // Number of consecutive frames ball must be present to register click
        int clickSensitivity = 2;
        // Multiplicative factor for threshold
        double clickFac = 0.8;
        
        // Initialise image source
        
        Source *source = [[Source alloc] initWithCamera];
        Mat frame = source.captureFrame;
        
        // Initialise colour model for click-controller
        
        bool isClickInitialised = false;
        double clickThresh = 0;
        Circle *circ = [[Circle alloc] initWithCentre:cv::Point(frame.cols/2, frame.rows/2) withRadius:radius withColour:Scalar(130, 220, 40)];
        Ball *clickBall = [[Ball alloc] init];
        
        int upC = circ.centre.x - subframePix;
        int upR = circ.centre.y - subframePix;
        int downC = circ.centre.x + subframePix;
        int downR = circ.centre.y + subframePix;
        
        while (!isClickInitialised) {
            frame = source.captureFrame;
            flip(frame, frame, 1);
            
            // Add circle to frame
            
            circle(frame, circ.centre, circ.radius, circ.colour, circ.width);
            
            imshow("Tracker", frame);
            
            // Press space to capture pixels for initialisation
            
            if (waitKey(10) == 32) {
                [clickBall setHistogram:&frame withBins:bins fromCircle:circ];
                frame = source.captureFrame;
                
                // Detect controller to set threshold value
                
                [clickBall isPresent:&frame inRegion:cv::Rect(cv::Point(upC, upR), cv::Point(downC, downR)) withBins:bins inTraining:true withThreshold:clickThresh];
                clickThresh = clickThresh*clickFac;
                isClickInitialised = true;
            }
            
        }
        
        // Initialise colour model for click-controller
        
        bool isTrackInitialised = false;
        double trackThresh = 0;
        circ.colour = Scalar(40, 180, 230);
        Ball *trackBall = [[Ball alloc] init];
        
        while (!isTrackInitialised) {
            frame = source.captureFrame;
            flip(frame, frame, 1);
            
            // Add circle to frame
            
            circle(frame, circ.centre, circ.radius, circ.colour, circ.width);
            
            imshow("Tracker", frame);
            
            // Press space to capture pixels for initialisation
            
            if (waitKey(10) == 32) {
                [trackBall setHistogram:&frame withBins:bins fromCircle:circ];
                isTrackInitialised = true;
                destroyWindow("Tracker");
            }
            
        }

        // Initialise state matrix
        
        Mat state(4, 1, CV_32F);
        
        state.at<float>(0) = circ.centre.x;
        state.at<float>(1) = circ.centre.y;
        state.at<float>(2) = 0;
        state.at<float>(3) = 0;
        
        // Initialise cursor objects and parameters
        
        uint32_t count = 0;
        CGDirectDisplayID displayForPoint;
        
        int frameCount = 0;
        int clickCount = 0;
        double lastclick = -clickWaitTime;
        int pixRangeFac = 1; // Multiplicative factor to increase range
        
        // Detect ball frame-by-frame
        
        while (source.isOpen) {

            ++frameCount;
            
            frame = source.captureFrame;
            flip(frame, frame, 1);
            
            // Resize frame to screen size
            
            resize(frame, frame, cv::Size(1440, 900));

            
            int curX = state.at<float>(0); // Column location
            int curY = state.at<float>(1); // Row location
            int curDx = state.at<float>(2); // Column velocity
            int curDy = state.at<float>(3); // Row velocity
            int upR = 0;
            int upC = 0;
            int downR = frame.rows;
            int downC = frame.cols;
            int upRclick = 0;
            int upCclick = 0;
            int downRclick = frame.rows;
            int downCclick = frame.cols;
            
            // Generate subregion to search
            
            if (curY >= 0 && curX >= 0 && curY < frame.rows && curX < frame.cols) {
                if (curX - subframePix*pixRangeFac + curDx > 0 && curX - subframePix*pixRangeFac + curDx < frame.cols) {
                    upC = curX - subframePix*pixRangeFac + curDx;
                }
                if (curY - subframePix*pixRangeFac + curDy > 0 && curY - subframePix*pixRangeFac + curDy < frame.rows) {
                    upR = curY - subframePix*pixRangeFac + curDy;
                }
                if (curX + subframePix*pixRangeFac  + curDx < frame.cols && curX + subframePix*pixRangeFac  + curDx > 0) {
                    downC = curX + subframePix*pixRangeFac + curDx;
                }
                if (curY + subframePix*pixRangeFac + curDy < frame.rows && curY + subframePix*pixRangeFac + curDy > 0) {
                    downR = curY + subframePix*pixRangeFac + curDy;
                }
                if (curX - 2*subframePix*pixRangeFac > 0 && curX - 2*subframePix*pixRangeFac < frame.cols) {
                    upCclick = curX - 2*subframePix*pixRangeFac;
                }
                if (curY - 2*subframePix*pixRangeFac > 0 && curY - 2*subframePix*pixRangeFac < frame.rows) {
                    upRclick = curY - 2*subframePix*pixRangeFac;
                }
                if (curX + 2*subframePix*pixRangeFac < frame.cols && curX + 2*subframePix*pixRangeFac > 0) {
                    downCclick = curX + 2*subframePix*pixRangeFac;
                }
                if (curY + 2*subframePix*pixRangeFac < frame.rows && curY + 2*subframePix*pixRangeFac > 0) {
                    downRclick = curY + 2*subframePix*pixRangeFac;
                }
            }
            
            // Estimate and update ball centre
            
            bool isFound = [trackBall findCentre:&frame inRegion:cv::Rect(cv::Point(upC, upR), cv::Point(downC, downR)) withBins:bins withRadius:radius inTraining:frameCount < trainingFrames withThreshold:trackThresh];
            
            cv::Point centreEst = trackBall.centre;
            
            if (isFound) {
                state.at<float>(2) = moveFac*(centreEst.x + upC - curX)/2; // Column velocity
                state.at<float>(3) = moveFac*(centreEst.y + upR - curY)/2; // Row velocity
                state.at<float>(0) = moveFac*(centreEst.x + upC - state.at<float>(0)) + state.at<float>(0); // Column location
                state.at<float>(1) = moveFac*(centreEst.y + upR - state.at<float>(1)) + state.at<float>(1); // Row location
                pixRangeFac = 1;
            }
            else {
                state.at<float>(2) = (centreEst.x - curX)/2; // Column velocity
                state.at<float>(3) = (centreEst.y - curY)/2; // Row velocity
                state.at<float>(0) = moveFac*(centreEst.x - state.at<float>(0)) + state.at<float>(0); // Column location
                state.at<float>(1) = moveFac*(centreEst.y - state.at<float>(1)) + state.at<float>(1); // Row location
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
            
            bool isClick = [clickBall isPresent:&frame inRegion:cv::Rect(cv::Point(upCclick, upRclick), cv::Point(downCclick, downRclick)) withBins:bins inTraining:false withThreshold:clickThresh];
            
            if (isClick) {
                clickCount++;
                if (clickCount >= clickSensitivity) {
                    double currentTime = CACurrentMediaTime();
                    
                    // If detection should register as an event, click
                    
                    if (currentTime > lastclick + clickWaitTime) {
                        NSLog(@"click! ");
                        CGEventRef clickDown = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, newPoint, kCGMouseButtonLeft);                         CGEventRef clickUp = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, newPoint, kCGMouseButtonLeft);
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
            
            // Press esc to exit
            
            if (waitKey(10) == 27) {
                break;
            }
            
            if (frameCount == trainingFrames) {
                trackThresh = trackThresh/trainingFrames/2;
            }
            
        }
        
    }
    return 0;
}

