//
//  Ball.h
//  TrackerMouse
//
//  Ball representing the coloured controller.
//  Application attempts to detect a ball in each frame.
//
//  Created by Clare Matthews on 11/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "opencv2/opencv.hpp"
#import <Foundation/Foundation.h>
#import "Circle.h"
using namespace cv;

@interface Ball : NSObject {
    int*** colour;
    cv::Point centre;
    int initPixels;
}

-(void) setHistogram:(Mat*)frame withBins:(int)bins fromCircle:(Circle*)circ;
-(bool) findCentre:(Mat*)frame inRegion:(cv::Rect) subFrame withBins:(int) bins withRadius:(int) radius inTraining:(bool) isTraining withThreshold:(double &)threshold;
-(cv::Point) centre;

@end
