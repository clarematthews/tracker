//
//  Circle.m
//  TrackerMouse
//
//  Created by Clare Matthews on 11/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "Circle.h"

@implementation Circle

-(id) initWithCentre:(Point)cent WithRadius:(double)rad {
    self = [self init];
    if (self) {
        centre = cent;
        radius = rad;
        colour = Scalar(100, 100, 255);
        width =  3;
    }
    return self;
}

@end
