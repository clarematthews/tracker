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

using namespace std;
using namespace cv;

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        int offsetx = 0;
        int offsety = 44;
        int bins = 20;
        int radius = 30;
        Ball *ball = [[Ball alloc] init];
        Circle *circ = [[Circle alloc] initWithCentre:cv::Point(253, 237) withRadius:30];
        Mat frame = imread("frames/frame_00001.jpg");
        [ball setHistogram:&frame withBins:bins fromCircle:circ];
        
        double thresh = 0;
        int training = 5;
        int pixRange = 100; // size for subframes
        
        Mat state(4, 1, CV_32F);
        
        state.at<float>(0) = circ.centre.x;
        state.at<float>(1) = circ.centre.y;
        state.at<float>(2) = 0;
        state.at<float>(3) = 0;
        
        int frameCount = 0;
        
        uint32_t count = 0;
        CGDirectDisplayID displayForPoint;
        
        for (int i = 1; i < 205; i++) {
            NSString *filename;
//            string filename = "frames/frame_00";
            if (i < 10) {
//                filename = filename + "00" + i.str() + ".jpg";
                filename = [[NSString alloc] initWithFormat:@"frames/frame_0000%d.jpg", i];
            }
            else if (i < 100) {
                filename = [[NSString alloc] initWithFormat:@"frames/frame_000%d.jpg", i];
            }
            else {
                filename = [[NSString alloc] initWithFormat:@"frames/frame_00%d.jpg", i];
            }
            string cppname([filename UTF8String]);
            frame = imread(cppname);
            namedWindow("OpenCV Window", CV_WINDOW_NORMAL);
            moveWindow("OpenCV Window", 0, 0);
            imshow("OpenCV Window", frame);
            
            int curX = state.at<float>(0); // col
            int curY = state.at<float>(1); // row
            int curDx = state.at<float>(2); // col velocity
            int curDy = state.at<float>(3); // row velocity
            int upR = 0;
            int upC = 0;
            int downR = frame.rows;
            int downC = frame.cols;
            
            if (curY >= 0 && curX >= 0 && curY < frame.rows && curX < frame.cols) {
                if (curX - pixRange + curDx > 0 && curX - pixRange + curDx < frame.cols) {
                    upC = curX - pixRange + curDx;
                }
                if (curY - pixRange + curDy > 0 && curY - pixRange + curDy < frame.rows) {
                    upR = curY - pixRange + curDy;
                }
                if (curX + pixRange  + curDx < frame.cols && curX + pixRange  + curDx > 0) {
                    downC = curX + pixRange + curDx;
                }
                if (curY + pixRange + curDy < frame.rows && curY + pixRange + curDy > 0) {
                    downR = curY + pixRange + curDy;
                }
            }
            
            [ball findCentre:&frame inRegion:cv::Rect(cv::Point(upC, upR), cv::Point(downC, downR)) withBins:bins withRadius:radius inTraining:frameCount < training withThreshold:thresh];
            
            cv::Point centreEst = ball.centre;
            
            state.at<float>(2) = (centreEst.x + upC - curX)/2; // col velocity
            state.at<float>(3) = (centreEst.y + upR - curY)/2; // row velocity
            state.at<float>(0) = centreEst.x + upC; // col
            state.at<float>(1) = centreEst.y + upR; // row
            
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
            
            
            waitKey(30);
        }
        
        
        
        
//        Frame *oneframe = [[Frame alloc] init];
//        [oneframe showFrame];
        
        
        
        
        
        
        
    }
    return 0;
}

