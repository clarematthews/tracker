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
//    VideoCapture capture(0);
//    Mat frame;
//    capture.read(frame);
    
    Mat frame = imread("frame_00001.jpg");
    
    namedWindow("OpenCV Window", CV_WINDOW_NORMAL);
    moveWindow("OpenCV Window", 0, 0);
    imshow("OpenCV Window", frame);
    
    waitKey(0);
    
}

@end
