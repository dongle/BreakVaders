//
//  ModalUIView.m
//  Toe2Toe
//
//  Created by Cole Krumbholz on 3/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ModalUIView.h"

@implementation ModalUIView

- (void) dealloc {
	[doneSelector release];
	[doneObject release];
	[parentvc release];
	[content release];
	[super dealloc];
}

- (void) dismiss {
	[parentvc dismissModalViewControllerAnimated:YES];
	[doneObject performSelector:[doneSelector pointerValue] withObject:nil afterDelay:0.5];   
}


- (void) launchWithTitle:(NSString *) title andView: (UIView *) view fromController: (UIViewController *) parent useSpinner: (BOOL) spinner whenDonePerform: (SEL) selector on: (NSObject *) object
{
	[content autorelease];
	content = [view retain];
	
	[doneObject autorelease];
	doneObject = [object retain];
	[doneSelector autorelease];
	doneSelector = [[NSValue valueWithPointer:selector] retain];
	
	// pause main view
	
	//[((Toe2ToeAppDelegate *)[UIApplication sharedApplication].delegate) pause];
	
	// create nav controller from provided title and view
	
	ModalViewController *tempViewController = [[[ModalViewController alloc] init] autorelease];
	UINavigationController *tempNavigationController = [[UINavigationController alloc] initWithRootViewController:tempViewController];
	tempNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	tempNavigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	tempNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;

	UIView *containerView = [[[UIView alloc] init] autorelease];
	tempViewController.title = title;
	tempViewController.view = containerView;

	// create a black background to replace the default white background of the passed view
	
	CGRect temprect = CGRectMake(0, 44, 540, 576); // size of content region
	containerView.frame = temprect;
	containerView.center  = CGPointMake (temprect.size.width / 2.0, temprect.size.height / 2.0);
	[containerView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];

	if (spinner) {
		UIActivityIndicatorView *indicator = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
		CGAffineTransform transform = CGAffineTransformMakeTranslation(temprect.size.width/2.0-12, temprect.size.height/2.0-12);  
		transform = CGAffineTransformScale(transform, 1.5, 1.5);
		indicator.transform = transform;  
		[indicator startAnimating];
		[containerView addSubview:indicator];
	}
	
	// add the passed view
	
	view.frame = containerView.frame;
	[containerView addSubview:view];
	
	// setup navbar on top with single done button
	
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithTitle: @"Done" 
																	style: UIBarButtonItemStyleDone
																   target: self
																   action: @selector(dismiss)] 
								   autorelease];
	[tempViewController.navigationItem setLeftBarButtonItem:doneButton animated:NO];

	[parentvc autorelease];
	parentvc = [parent retain];
	
	[parent presentModalViewController:tempNavigationController animated:YES];
	[tempNavigationController release];
}


@end


@implementation ModalViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


@end