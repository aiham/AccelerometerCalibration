//
//  AppDelegate.h
//  AccelerometerCalibration
//
//  Created by Aiham Hammami on 27/03/12.
//  Copyright Aiham Hammami 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
