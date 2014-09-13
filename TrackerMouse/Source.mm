//
//  Source.m
//  TrackerMouse
//
//  Source captures frames from the camera.
//  Additional sources of frame may be added by initialising
//  the source object to load images from elsewhere.
//
//  Created by Clare Matthews on 23/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "Source.h"

@implementation Source

/*
 * Initialise the source as the system camera.
 * Returns source object
 */

-(id) initWithCamera {
    self = [self init];
    if (self) {
        capture = VideoCapture(0);
    }
    return self;
}

/*
 * Read in frame from the source.
 * Returns frame as array
 */

-(Mat) captureFrame {
    Mat frame;
    capture.read(frame);
    return frame;
}

/*
 * Check souce is open.
 * Returns true if open
 */

-(bool) isOpen {
    return capture.isOpened();
}

@end