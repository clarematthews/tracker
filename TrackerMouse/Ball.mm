//
//  Ball.m
//  TrackerMouse
//
//  Created by Clare Matthews on 11/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "Ball.h"

@implementation Ball

-(void) setHistogram:(Mat*)frame withBins:(int)bins fromCircle:(Circle*)circ withPixels:(int*)histSum {
    
//    circle(*frame, circ.centre, circ.radius, circ.colour, circ.width);
//    imshow("Circle", *frame);
//    waitKey(0);
    
    int ***hist = new int**[bins];
    for (int x = 0; x < bins; ++x) {
        hist[x] = new int*[bins];
        for (int y = 0; y < bins; ++y) {
            hist[x][y] = new int[bins];
            for (int z = 0; z < bins; ++z) {
                hist[x][y][z] = 0;
            }
        }
    }
    
    int chan0, chan1, chan2;
    Vec3b intensity;
    
    int cx = (circ.centre).x;
    int cy = (circ.centre).y;
    double radius = circ.radius;
    double rows = (*frame).rows;
    double cols = (*frame).cols;

    cvtColor(*frame, *frame, COLOR_BGR2HSV);
    
    histSum = 0;
    for (int i = max(cx - radius, 0.0); i <= min(cx + radius, rows); ++i) {
        for (int j = max(cy - radius, 0.0); j <= min(cy + radius, cols); ++j) {
            if ((i - cx)*(i - cx) + (j - cy)*(j - cy) < radius*radius) {
                ++histSum;
                intensity = (*frame).at<Vec3b>(j, i);
                chan0 = (int)intensity(0)*bins/256;
                chan1 = (int)intensity(1)*bins/256;
                chan2 = (int)intensity(2)*bins/256;
                ++hist[chan0][chan1][chan2];
            }
        }
    }
    
    colour = hist;

    
}

@end
