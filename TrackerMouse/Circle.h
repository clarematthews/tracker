//
//  Circle.h
//  TrackerClick
//
//  Circle describes a circle to display on screen to initialise the colour of the controller
//
//  Created by Clare Matthews on 11/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "opencv2/opencv.hpp"
#import <Foundation/Foundation.h>
using namespace cv;

@interface Circle : NSObject {
}

@property cv::Point centre;
@property double radius;
@property int width;
@property Scalar colour;

-(id) initWithCentre:(cv::Point)centre withRadius:(double)radius;
-(id) initWithCentre:(cv::Point)centre withRadius:(double)radius withColour:(Scalar)colour;

@end
