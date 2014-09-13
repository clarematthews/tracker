//
//  Circle.mm
//  TrackerClick
//
//  Circle describes a circle to display on screen to initialise the colour of the controller
//
//  Created by Clare Matthews on 11/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "Circle.h"

@implementation Circle

-(id) initWithCentre:(cv::Point)cent withRadius:(double)rad {
    self = [self initWithCentre:cent withRadius:rad withColour:Scalar(100, 100, 255)];
    return self;
}

-(id) initWithCentre:(cv::Point)cent withRadius:(double)rad withColour:(Scalar)col {
    self = [self init];
    if (self) {
        _centre = cent;
        _radius = rad;
        _colour = col;
        _width =  3;
    }
    return self;
}

@synthesize centre = _centre;
@synthesize radius = _radius;
@synthesize width = _width;
@synthesize colour = _colour;

@end
