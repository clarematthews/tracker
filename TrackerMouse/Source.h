//
//  Source.h
//  TrackerClick
//
//  Source captures frames from the camera.
//  Additional sources of frame may be added by initialising
//  the source object to load images from elsewhere.
//
//  Created by Clare Matthews on 23/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "opencv2/opencv.hpp"
#import <Foundation/Foundation.h>
using namespace cv;

@interface Source : NSObject {
    VideoCapture capture;
}

-(id) initWithCamera;
-(Mat) captureFrame;
-(bool) isOpen;

@end
