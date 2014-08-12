//
//  Ball.h
//  TrackerMouse
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
}

-(void) setHistogram:(Mat)frame :(int)bins :(Circle*)circ :(int*)histSum;

@end
