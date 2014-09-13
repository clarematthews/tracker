//
//  main.m
// TrackerMouse
//
//  TrackerMouse provides control of the cursor by tracking a hand-held
//  circular, coloured controller.
//  The application is developed for use on a MacBook, running OS X Mavericks,
//  and uses the iSight camera for tracking.
//  The OpenCV library is used for image manipulation.
//
//  Created by Clare Matthews on 11/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "opencv2/opencv.hpp"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "Source.h"
#import "Ball.h"

using namespace std;
using namespace cv;

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // Adjustable parameters to control the tracking and cursor control
        
        int offsetx = 0; // Horizontal offset of camera frame relative to screen
        int offsety = 0; // Vertical offset of camera frame relative to screen
        int trainingFrames = 5; // Number of initial frames to use to calculate threshold for detection
        int subframePix = 100; // Size of subframes used for initial detection
        double moveFac = 0.5; // Proportion of distance to new point to move
        int bins = 20; // Number of bins for histogram model
        int radius = 50; // Radius of circle in kernel and set-up stage
        
        // Initialse image source
        
        Source *source = [[Source alloc] initWithCamera];
        Mat frame = source.captureFrame;
        
        // Initialise colour model for controller
        
        bool isInitialised = false;
        Circle *circ = [[Circle alloc] initWithCentre:cv::Point(frame.cols/2, frame.rows/2) withRadius:radius];
        Ball *ball = [[Ball alloc] init];
        while (!isInitialised) {
            frame = source.captureFrame;
            flip(frame, frame, 1);
            
            // Add circle to frame
            
            circle(frame, circ.centre, circ.radius, circ.colour, circ.width);
            
            imshow("Tracker", frame);
            
            // Press space to capture pixels for initialisation
            
            if (waitKey(10) == 32) {
                [ball setHistogram:&frame withBins:bins fromCircle:circ];
                isInitialised = true;
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
        double thresh = 0;
        int pixRangeFac = 1; // Multiplicative factor used to control subregion size
        
        // Detect ball frame-by-frame
        
        while (source.isOpen) {

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
            }
            
            // Estimate and update ball centre
            
            bool isFound = [ball findCentre:&frame inRegion:cv::Rect(cv::Point(upC, upR), cv::Point(downC, downR)) withBins:bins withRadius:radius inTraining:frameCount < trainingFrames withThreshold:thresh];
            
            cv::Point centreEst = ball.centre;
            
            if (isFound) {
                state.at<float>(2) = moveFac*(centreEst.x + upC - curX)/2; // Column velocity
                state.at<float>(3) = moveFac*(centreEst.y + upR - curY)/2; // Row velocity
                state.at<float>(0) = state.at<float>(0) + moveFac*(centreEst.x + upC - state.at<float>(0)); // Column location
                state.at<float>(1) = state.at<float>(1) + moveFac*(centreEst.y + upR - state.at<float>(1)); // Row location
                pixRangeFac = 1;
            }
            else {
                state.at<float>(2) = moveFac*(centreEst.x - curX)/2; // Column velocity
                state.at<float>(3) = moveFac*(centreEst.y - curY)/2; // Row velocity
                state.at<float>(0) = state.at<float>(0) + moveFac*(centreEst.x - state.at<float>(0)); // Column location
                state.at<float>(1) = state.at<float>(1) + moveFac*(centreEst.y - state.at<float>(1)); // Row location
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
            
            // Press esc to exit
            
            if (waitKey(10) == 27) {
                break;
            }
            
            ++frameCount;
            if (frameCount == trainingFrames) {
                thresh = thresh/trainingFrames/2;
            }
        }
        
    }
    return 0;
}

