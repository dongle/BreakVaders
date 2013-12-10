//
//  ModalUIView.h
//  Toe2Toe
//
//  Created by Cole Krumbholz on 3/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ModalUIView : NSObject {
	UIViewController *_parentvc;
	UIView *_content;
	NSValue *_doneSelector;
	NSObject *_doneObject;
}

- (void) launchWithTitle: (NSString *) title 
				 andView: (UIView *) view 
		  fromController: (UIViewController *) parent 
			  useSpinner: (BOOL) spinner 
		 whenDonePerform: (SEL) selector 
					  on: (NSObject *) object;

- (void) dismiss;

@end

@interface ModalViewController : UIViewController {
}
@end