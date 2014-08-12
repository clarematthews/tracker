//
//  Circle.h
//  TrackerMouse
//
//  Created by Clare Matthews on 11/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "opencv2/opencv.hpp"
#import <Foundation/Foundation.h>
using namespace cv;

@interface Circle : NSObject {
//    Point centre;
//    double radius;
//    Scalar colour;
//    int width;
}

@property cv::Point centre;
@property double radius;
@property int width;
@property Scalar colour;

-(id) initWithCentre:(cv::Point)centre withRadius:(double)radius;

@end
