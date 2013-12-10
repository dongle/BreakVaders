    //
//  OverlayViewController.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 8/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OverlayViewController.h"


@implementation OverlayViewController

@synthesize window = _window;

static OverlayViewController *_ovc = nil;

+ (id) sharedController {
	if (!_ovc) {
		_ovc = [[OverlayViewController alloc] init];
	}
	return _ovc;
}

- (id) init
{
	if ((self = [super init])) {
		UIWindow *tempWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		[tempWindow setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
		self.window = tempWindow;
		[tempWindow release];
		[self.window addSubview:self.view];
	}
	return self;
}


- (void) show
{
	UIWindow *curWindow = [[UIApplication sharedApplication] keyWindow];
	if (_window != curWindow) {
		_prevWindow = curWindow;
		[_window makeKeyAndVisible];
	}	
}

- (void) hide 
{
	[_prevWindow makeKeyAndVisible];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *viewContainer = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	[viewContainer setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
	self.view = viewContainer;	
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.view = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[_window release];
    [super dealloc];
}



@end
