//
//  Source.m
//  TrackerMouse
//
//  Created by Clare Matthews on 23/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "Source.h"

@implementation Source

-(id) initWithCamera {
    self = [self init];
    if (self) {
        capture = VideoCapture(0);
    }
    return self;
}

-(Mat) captureFrame {
    Mat frame;
    capture.read(frame);
    return frame;
}

-(bool) isOpen {
    return capture.isOpened();
}

@end