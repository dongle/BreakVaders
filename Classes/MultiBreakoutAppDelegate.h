//
//  MultiBreakoutAppDelegate.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/27/10.
//  Copyright Koduco Games 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShakeEnabledUIWindow.h"
#import "CCOFDelegate.h"
#import "Crittercism.h"
#import "OverlayViewController.h"

@interface MultiBreakoutAppDelegate : NSObject <UIApplicationDelegate> {
	ShakeEnabledUIWindow *window;
	//CCOFDelegate *ofDelegate;
}

@property (nonatomic, retain) ShakeEnabledUIWindow *window;

@end
