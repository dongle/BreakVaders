//
//  OverlayViewController.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 8/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverlayViewController : UIViewController {
	UIWindow *_window, *_prevWindow;
}

@property (nonatomic, retain) UIWindow *window;

+ (id) sharedController;
- (void) show;
- (void) hide;

@end
