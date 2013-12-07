//
//  PopupWebView.m
//  Toe2Toe
//
//  Created by Cole Krumbholz on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ModalWebView.h"
#import "Reachable.h"

@implementation ModalWebView

@synthesize linkdelegate;

- (void) launchWithTitle: (NSString *) title 
				 andView: (UIWebView *) view 
		  fromController: (UIViewController *) parent 
		  checkReachable: (BOOL) checkReachable 
		 whenDonePerform: (SEL) selector 
					  on: (NSObject *) object
{
	_checkReachable = checkReachable;
	[view setDelegate: self];
	view.alpha = 0.0; 
	[super launchWithTitle:title andView:view fromController:parent useSpinner: checkReachable whenDonePerform:selector on:object];
}

- (void) checkReachable
{
	if (_checkReachable && ![Reachable connectedToNetwork]) {
		[[[[UIAlertView alloc] initWithTitle:@"Network not available" message:@"You need to be in range of your cellular carrier's network, or a wifi network to provide feedback." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
	}
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	return linkdelegate ? [linkdelegate shouldLoad:request.URL] : YES;
}

- (void) webViewDidStartLoad: (UIWebView *) webView {
	if (_checkReachable) {
		[self performSelector:@selector(checkReachable) withObject:nil afterDelay:1];          
	}
}

- (void)showWebView {
	[UIView beginAnimations:@"webFadeIn" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	content.alpha = 1.0;
	[UIView commitAnimations];
}

- (void) webViewDidFinishLoad: (UIWebView *) webView {
	[self performSelector:@selector(showWebView) withObject:nil afterDelay:.2];          
}

- (void) webView: (UIWebView *) webView didFailLoadWithError: (NSError *) error {
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[super dismiss];
}


@end
