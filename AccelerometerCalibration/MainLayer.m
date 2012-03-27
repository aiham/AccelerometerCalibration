//
//  MainLayer.m
//  AccelerometerCalibration
//
//  Created by Aiham Hammami on 27/03/12.
//  Copyright Aiham Hammami 2012. All rights reserved.
//

#import "MainLayer.h"

@implementation MainLayer

- (id) init {
	if ((self = [super init])) {
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Moving square
        
        square = [CCLayerColor layerWithColor:ccc4(255, 0, 0, 255) width:30 height:30];
        square.position = ccp(size.width / 2, size.height / 2);
        [self addChild:square z:20];
        
        // Calibrate button
        
		CCLabelTTF *calibrate_label = [CCLabelTTF labelWithString:@"Calibrate" fontName:@"Marker Felt" fontSize:30];
        CCMenu *calibrate = [CCMenu menuWithItems:[CCMenuItemLabel itemWithLabel:calibrate_label target:self selector:@selector(calibrate)], nil];
        calibrate.position = ccp( size.width / 2, size.height / 2);
        [self addChild:calibrate];
        
        // Raw acceleration values
		
		CCLabelTTF *x = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
		CCLabelTTF *y = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
		CCLabelTTF *z = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
	
		x.position =  ccp( 150 , size.height - 20 );
		y.position =  ccp( 150 , size.height - 20 - 40 );
		z.position =  ccp( 150 , size.height - 20 - 40 - 40 );
		
		[self addChild:x z:0 tag:1];
		[self addChild:y z:0 tag:2];
		[self addChild:z z:0 tag:3];
        
        // Calibrated acceleration values
		
		CCLabelTTF *calibrated_x = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
		CCLabelTTF *calibrated_y = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
		CCLabelTTF *calibrated_z = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
        
		calibrated_x.position =  ccp( size.width - 150 , size.height - 20 );
		calibrated_y.position =  ccp( size.width - 150 , size.height - 20 - 40 );
		calibrated_z.position =  ccp( size.width - 150 , size.height - 20 - 40 - 40 );
		
		[self addChild:calibrated_x z:0 tag:7];
		[self addChild:calibrated_y z:0 tag:8];
		[self addChild:calibrated_z z:0 tag:9];
        
        // Saved calibration offset
		
		CCLabelTTF *cal_x_label = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
		CCLabelTTF *cal_y_label = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
		CCLabelTTF *cal_z_label = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
        
		cal_x_label.position =  ccp( 80 , 20 + 40 + 40 );
		cal_y_label.position =  ccp( 80 , 20 + 40 );
		cal_z_label.position =  ccp( 80 , 20 );
		
		[self addChild:cal_x_label z:0 tag:4];
		[self addChild:cal_y_label z:0 tag:5];
		[self addChild:cal_z_label z:0 tag:6];
        
        // Maximum and minimum raw acceleration values
		
		CCLabelTTF *maxmin_x_label = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
		CCLabelTTF *maxmin_y_label = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
		CCLabelTTF *maxmin_z_label = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:24];
        
		maxmin_x_label.position =  ccp( size.width - 150 , 20 + 40 + 40 );
		maxmin_y_label.position =  ccp( size.width - 150 , 20 + 40 );
		maxmin_z_label.position =  ccp( size.width - 150 , 20 );
		
		[self addChild:maxmin_x_label z:0 tag:10];
		[self addChild:maxmin_y_label z:0 tag:11];
		[self addChild:maxmin_z_label z:0 tag:12];
        
        // Initialise
        
        [self calibrate];
        
        self.isAccelerometerEnabled = YES;
	}
	return self;
}

- (void) calibrate {
    kmVec3Fill(&calibration, raw_acceleration.x, raw_acceleration.y, raw_acceleration.z);
    
    if (calibration.z != 0) {
        calibration.z += calibration.z < 0 ? 1.0f : -1.0f;
    }
    
    [self resetSquare];
    
    [self updateXYZLabels:calibration x:4 y:5 z:6];
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    [self updateRawAcceleration:acceleration];
    
    kmVec2 acceleration_2d;
    kmVec3 calibrated_acceleration, ax, ay, az;
    
    kmVec3Fill(&calibrated_acceleration,
               [self normaliseAcceleration:(raw_acceleration.x - calibration.x)],
               [self normaliseAcceleration:(raw_acceleration.y - calibration.y)],
               [self normaliseAcceleration:(raw_acceleration.z - calibration.z)]);
    
    ax.x = 1;
    ay.x = 0, ay.z = -1;
    
    kmVec3Normalize(&az, kmVec3Cross(&az, &ay, &ax));
    kmVec3Normalize(&ax, kmVec3Cross(&ax, &az, &ay));
    
    acceleration_2d.x = kmVec3Dot(&calibrated_acceleration, &ax);
    acceleration_2d.y = kmVec3Dot(&calibrated_acceleration, &az);
    
    const float sensitivity = 0.5f;
    const float tiltAmplifier = 1.5f;
    
    accumulated_acceleration.x += acceleration_2d.x * sensitivity * tiltAmplifier;
    accumulated_acceleration.y += -acceleration_2d.y * sensitivity * tiltAmplifier;
    
    accumulated_acceleration.x *= 1.0f - sensitivity;
    accumulated_acceleration.y *= 1.0f - sensitivity;
    
    accumulated_acceleration.x = [self limitAcceleration:accumulated_acceleration.x];
    accumulated_acceleration.y = [self limitAcceleration:accumulated_acceleration.y];
    
    [self moveSquare];
    
    [self updateXYZLabels:raw_acceleration x:1 y:2 z:3];
    [self updateXYZLabels:calibrated_acceleration x:7 y:8 z:9];
    [self updateMinMaxXYZLabels];
}

- (void) updateRawAcceleration:(UIAcceleration *)acceleration {
    kmVec3Fill(&raw_acceleration, acceleration.x, acceleration.y, acceleration.z);
    
    kmVec3Fill(&max_acceleration,
               MAX(max_acceleration.x, raw_acceleration.x),
               MAX(max_acceleration.y, raw_acceleration.y),
               MAX(max_acceleration.z, raw_acceleration.z));
    
    kmVec3Fill(&min_acceleration,
               MIN(min_acceleration.x, raw_acceleration.x),
               MIN(min_acceleration.y, raw_acceleration.y),
               MIN(min_acceleration.z, raw_acceleration.z));
}

- (float) normaliseAcceleration:(float)acceleration {
    if (acceleration > 1.0f || acceleration < -1.0f) {
        acceleration = [self normaliseAcceleration:(acceleration > 0 ? 1 : -1) * 2.0f - acceleration];
    }
    return acceleration;
}

- (float) limitAcceleration:(float)acceleration {
    float limited_acceleration = ABS(acceleration);
    float sign_convention = acceleration / limited_acceleration;
    const float min = 0.01f, max = 0.2f;
    
    if (limited_acceleration < min) {
        limited_acceleration = min;
    } else if (limited_acceleration > max) {
        limited_acceleration = max;
    }
    
    return limited_acceleration * sign_convention;
}

- (void) updateXYZLabels:(kmVec3)vec x:(int)x_tag y:(int)y_tag z:(int)z_tag {
    CCLabelTTF *x, *y, *z;
    
    x = (CCLabelTTF *)[self getChildByTag:x_tag];
    y = (CCLabelTTF *)[self getChildByTag:y_tag];
    z = (CCLabelTTF *)[self getChildByTag:z_tag];
    
    x.string = [NSString stringWithFormat:@"x = %f", vec.x];
    y.string = [NSString stringWithFormat:@"y = %f", vec.y];
    z.string = [NSString stringWithFormat:@"z = %f", vec.z];
}

- (void) updateMinMaxXYZLabels {
    CCLabelTTF *x, *y, *z;
    
    x = (CCLabelTTF *)[self getChildByTag:10];
    y = (CCLabelTTF *)[self getChildByTag:11];
    z = (CCLabelTTF *)[self getChildByTag:12];
    
    x.string = [NSString stringWithFormat:@"x = (%f - %f)", min_acceleration.x, max_acceleration.x];
    y.string = [NSString stringWithFormat:@"y = (%f - %f)", min_acceleration.y, max_acceleration.y];
    z.string = [NSString stringWithFormat:@"z = (%f - %f)", min_acceleration.z, max_acceleration.z];
}

- (void) moveSquare {
    CGSize win_size = [[CCDirector sharedDirector] winSize];
    
    float speed = 50;
    
    CGPoint smooth_movement = ccp(-accumulated_acceleration.y * speed, accumulated_acceleration.x * speed);
    CGPoint move_to = ccpAdd(square.position, smooth_movement);
    
    if (move_to.x < 0) {
        move_to.x = 0;
        accumulated_acceleration.x = 0;
    }
    if (move_to.y < 0) {
        move_to.y = 0;
        accumulated_acceleration.y = 0;
    }
    if (move_to.x > win_size.width - 30) {
        move_to.x = win_size.width - 30;
        accumulated_acceleration.x = 0;
    }
    if (move_to.y > win_size.height - 30) {
        move_to.y = win_size.height - 30;
        accumulated_acceleration.y = 0;
    }
    
    square.position = move_to;
}

- (void) resetSquare {
    CGSize win_size = [[CCDirector sharedDirector] winSize];
    
    square.position = ccp(win_size.width / 2, win_size.height / 2);
    accumulated_acceleration = CGPointZero;
}

- (void) dealloc {
    [square release], square = nil;
	[super dealloc];
}

@end
