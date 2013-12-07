//
//  PopupWebView.h
//  Toe2Toe
//
//  Created by Cole Krumbholz on 5/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalUIView.h"

@protocol InterceptLinkDelegate 
- (BOOL) shouldLoad: (NSURL *) URL;
@end
	

@interface ModalWebView : ModalUIView <UIWebViewDelegate, UIAlertViewDelegate> {
	BOOL _checkReachable;
	id<InterceptLinkDelegate> linkdelegate;
}

@property (readwrite, retain) id<InterceptLinkDelegate> linkdelegate;

- (void) launchWithTitle: (NSString *) title 
				 andView: (UIWebView *) view 
		  fromController: (UIViewController *) parent 
		  checkReachable: (BOOL) checkReachable		 
		 whenDonePerform: (SEL) selector 
					  on: (NSObject *) object;

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void) webViewDidStartLoad: (UIWebView *) webView;
- (void) webViewDidFinishLoad: (UIWebView *) webView;
- (void) webView: (UIWebView *) webView didFailLoadWithError: (NSError *) error;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
