#import "CCOFDelegate.h"
#import "OpenFeint+UserOptions.h"
#import "cocos2d.h"

@implementation CCOFDelegate

- (void)dashboardWillAppear
{
}

- (void)dashboardDidAppear
{
	[[CCDirector sharedDirector] pause];
	[[CCDirector sharedDirector] stopAnimation];
}

- (void)dashboardWillDisappear
{
}

- (void)dashboardDidDisappear
{
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] startAnimation];
}

- (void)userLoggedIn:(NSString*)userId
{
	OFLog(@"New user logged in! Hello %@", [OpenFeint lastLoggedInUserName]);
}

- (BOOL)showCustomOpenFeintApprovalScreen
{
	return NO;
}

@end
