//
//  MainLayer.h
//  AccelerometerCalibration
//
//  Created by Aiham Hammami on 27/03/12.
//  Copyright Aiham Hammami 2012. All rights reserved.
//

#import "cocos2d.h"
#import "kazmath.h"

@interface MainLayer : CCLayer {
    kmVec3 raw_acceleration, max_acceleration, min_acceleration;
    kmVec3 calibration;
    
    CCLayerColor *square;
    CGPoint accumulated_acceleration;
}

- (void) calibrate;
- (void) updateRawAcceleration:(UIAcceleration *)acceleration;
- (float) normaliseAcceleration:(float)acceleration;
- (float) limitAcceleration:(float)acceleration;
- (void) updateXYZLabels:(kmVec3)vec x:(int)x_tag y:(int)y_tag z:(int)z_tag;
- (void) updateMinMaxXYZLabels;
- (void) moveSquare;
- (void) resetSquare;

@end
