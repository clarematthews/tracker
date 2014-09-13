//
//  Ball.m
//  TrackerMouse
//
//  Ball representing the coloured controller.
//  Application attempts to detect a ball in each frame.
//
//  Created by Clare Matthews on 11/08/2014.
//  Copyright (c) 2014 Clare Matthews. All rights reserved.
//

#import "Ball.h"

@implementation Ball

-(cv::Point) centre {
    return centre;
}

/* 
 * Initialise the colour description of the ball, using the pixels
 * within a circle of the frame. The colour is represented by a 
 * histogram.
 */

-(void) setHistogram:(Mat*)frame withBins:(int)bins fromCircle:(Circle*)circ {
    
    // Initialise an array with required number of elements for the histogram bins
    
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
    double rows = (*frame).rows;
    double cols = (*frame).cols;

    // Describe the circle that contains the controller
    
    int cx = (circ.centre).x;
    int cy = (circ.centre).y;
    double radius = circ.radius;
    
    
    cvtColor(*frame, *frame, COLOR_BGR2HSV);
    
    // Fill histogram bins with pixel counts
    
    int histSum = 0;
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
    initPixels = histSum;
    
}

/*
 * Find the centre of controller in a frame. 
 * A subregion is checked initially. If the detection does not 
 * pass the given threshold, the full frame is then used.
 * Returns true of the controller was detected in the subregion.
 */

-(bool) findCentre:(Mat*)frame inRegion:(cv::Rect) subRegion withBins:(int) bins withRadius:(int) radius inTraining:(bool) isTraining withThreshold:(double &)threshold {
    
    Mat subFrame(*frame, subRegion);
    
    cv::Point centreEst;
    
    bool isSub = true;
    
    while (true) {
        Mat imgHist(subFrame.rows, subFrame.cols, CV_64FC1);
        
        // Generate a binary kernel with value one if a point is
        // within a given radial distance from the centre of the
        // kernel
        
        Mat kernel(2*radius + 1, 2*radius + 1, CV_8UC1);
        int centrePix = radius + 1;
        uchar *kerRowx;
        for (int x = 0; x <= 2*radius; ++x) {
            kerRowx = kernel.ptr(x);
            for (int y = 0; y <= 2*radius; ++y) {
                if ((centrePix - x)*(centrePix - x) + (centrePix - y)*(centrePix - y) < radius*radius) {
                    kerRowx[y] = 1;
                }
                else {
                    kerRowx[y] = 0;
                }
            }
        }
        
        // Generate a histogram representation of the frame
        
        int ***hist = getHist(&subFrame, bins);
        
        // Compare the frame histogram to the ball histogram
        
        double ***R = new double**[bins];
        int testVal;
        int histSum = subFrame.rows*subFrame.cols;
        int fac = histSum/initPixels; // Multiplcative factor to allow comparison of histograms of different sizes
        for (int x = 0; x < bins; ++x) {
            R[x] = new double*[bins];
            for (int y = 0; y < bins; ++y) {
                R[x][y] = new double[bins];
                for (int z = 0; z < bins; ++z) {
                    if (hist[x][y][z] == 0) {
                        R[x][y][z] = 1;
                    }
                    else {
                        testVal = fac*(colour[x][y][z])/(hist[x][y][z]);
                        if (testVal < 1) {
                            R[x][y][z] = testVal; // Colour more likely in frame than controller
                        }
                        else {
                            R[x][y][z] = 1; // Colour more likely in controller than frame
                        }
                    }
                }
            }
        }
        
        // Replace each pixel value in the image by the indexed value in the histogram ratio R
        
        double *rowx;
        Vec3b intensity;
        int chan0, chan1, chan2;
        for (int x = 0; x < imgHist.rows; ++x) {
            rowx = imgHist.ptr<double>(x);
            for (int y = 0; y < imgHist.cols; ++ y) {
                intensity = subFrame.at<Vec3b>(x, y);
                chan0 = (int)intensity(0)*bins/256;
                chan1 = (int)intensity(1)*bins/256;
                chan2 = (int)intensity(2)*bins/256;
                rowx[y] = R[chan0][chan1][chan2];
            }
        }
        
        // Convolve the indexed image and kernel
        
        Mat imgConv;
        filter2D(imgHist, imgConv, -1, kernel);
        double maxVal;
        
        // Estimate of the controller centre is the point with maximum value in the convolved image
        
        cv::minMaxLoc(imgConv, NULL, &maxVal, NULL, &centreEst);
        
        // If the maximum value does not exceed threshold, repeat detection using full frame
        
        if (isTraining) {
            threshold += maxVal;
            centre = centreEst;
            return true;
        }
        else if (isSub && (maxVal < threshold)) {
            subFrame = *frame;
            isSub = false;
        }
        else if (isSub) {
            centre = centreEst;
            return true;
        }
        else if (!isSub) {
            centre = centreEst;
            return false;
        }
    }
    
    centre = centreEst;
    return false;
    
}

/*
 * Represent the colours of pixels in a RGB image by an HSV histogram
 */

int ***getHist(Mat *imgBGR, int bins) {
    Mat frame = *imgBGR;
    cvtColor(frame, frame, COLOR_BGR2HSV);
    
    // Initialise an array with required number of elements for the histogram bins
    
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
    
    // Fill histogram bins with pixel counts
    
    for (int i = 0; i < frame.rows; ++i) {
        for (int j = 0; j < frame.cols; ++j) {
            intensity = frame.at<Vec3b>(i, j);
            chan0 = (int)intensity(0)*bins/256;
            chan1 = (int)intensity(1)*bins/256;
            chan2 = (int)intensity(2)*bins/256;
            ++hist[chan0][chan1][chan2];
        }
    }
    
    return hist;
}

@end
