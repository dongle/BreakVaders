//
//  GameStates.mm
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameStates.h"
#import "PongVaderScene.h"
#import "BeatEvents.h"
#import "Utils.h"

// game entities and such
#import "BlockFleets.h"
#import "Boss2Fleet.h"
#import "MultiBreakoutAppDelegate.h"
#import "OverlayViewController.h"
#import "Reachable.h"
#import "ENSPrance.h"
#import "LTWaddle.h"
#import	"CDRBobble.h"
#import "ShieldInvader.h"
#import "StationaryInvader.h"
#import "ADMBrain.h"
#import "SNEye.h"
#import "CPTDawdle.h"

// OF
#import "OpenFeint.h"
#import "OFInvite.h"
#import "OFInviteDefinition.h"
#import "OFRequestHandle.h"
#import "OFSocialNotificationService.h"
#import "OFAchievementService.h"

#import "FlurryAPI.h"

// -------------- defs and globals

#define GAME_FONT @"px10.ttf"
#define SCORE_FONT @"pvaders.fnt"

static int curLevel = 0;
static int numLevels = 33;

// -------------------------------


@implementation CCSprite (GetRect) 
-(CGRect) getRect {
	return CGRectMake(self.position.x - (self.contentSize.width/2*self.scale),
					  self.position.y - (self.contentSize.height/2*self.scale),
					  self.contentSize.width*self.scale, self.contentSize.height*self.scale);
}
@end

/*
@implementation CCLabelBMFont (GetRect) 
-(CGRect) getRect {
	return CGRectMake(self.position.x - (self.contentSize.width/2*self.scale),
					  self.position.y - (self.contentSize.height/2*self.scale),
					  self.contentSize.width*self.scale, self.contentSize.height*self.scale);
}
@end
*/

@interface CCLabelBMFont (PVAccess)
- (NSString *) getString;
@end

@implementation CCLabelBMFont (PVAccess)

- (NSString *) getString {
	return string_;
}

@end


@implementation SelectedNode
@synthesize selected, selectable, labelname, node;
- (void) setString:(NSString*)str {
	self.labelname = str;
	if ([node isKindOfClass:[CCLabelBMFont class]])
		[(CCLabelBMFont *)node setString:str];
}
-(void) dealloc {
	[node release];
	[labelname release];
	[super dealloc];
}
-(CGRect) getRect {
	int labelPadding;
	if _IPAD {
		labelPadding = 20;
	}
	else {
		labelPadding = 10;
	}
	return CGRectMake(node.position.x - ((node.anchorPoint.x*node.contentSize.width*node.scale) + labelPadding),
					  node.position.y - ((node.anchorPoint.y*node.contentSize.height*node.scale) + labelPadding),
					  node.contentSize.width*node.scale + labelPadding * 2,
					  node.contentSize.height*node.scale + labelPadding * 2);
}
- (void) setNode:(CCNode *) innode {
	if (!self.labelname && [innode isKindOfClass:[CCLabelBMFont class]])
		self.labelname = [(CCLabelBMFont*) innode getString];
	[node autorelease];
	node = [innode retain];
}
@end

@implementation StateAd
@synthesize nState;

// set nextState value
- (id) initWithHighFreq: (BOOL) hf nextState: (GameState *) ns {
	if ((self=[super init])) {
		_highFreq = hf;
		nState = [ns retain];
	}
	return self;
}

- (void) dealloc {
	[nState release];
	[super dealloc];
}

- (void) afterAd {
	
}

static int _hfAdCount = 0;

- (void) enter {
	if (_highFreq) _hfAdCount++;
	_hasShownAd = NO;
}

- (GameState *) doTimer: (CFTimeInterval) dTime {
	if (!_hasShownAd) {
		_hasShownAd = YES;
		if (!_highFreq || (_hfAdCount > 1)) {
			[[AdLoader sharedLoader] showAd: [Reachable connectedToNetwork]
								   highFreq: _highFreq
								thenPerform: nil
										 on: nil];
		} 
	}
	
	return nState;
}

@end

// -------------------------------

@implementation StatePurchase
@synthesize nState;

// set nextState value
- (id) initWithNextState: (Class) ns {
	if ((self=[super init])) {
		nState = [ns retain];
	}
	return self;
}

- (void) dealloc {
	[nState release];
	[super dealloc];
}

- (void) enter {
	[[StoreObserver getInstance] addResponder: self];
	
	if (![Reachable connectedToNetwork]) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Not connected to network" 
														 message:@"You must be connected to the network in order to purchase more levels." 
														delegate:nil 
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil] autorelease];
		[alert show];
		[self changeTo:[[[nState alloc] init] autorelease] after:0.5];
	} else if ([[[PongVader getInstance].settings get:@"EpisodesProduct"] isEqualToString: @""]) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Still loading..." 
														 message:@"PongVaders Episodes One and Two are still loading. Please try your puchase again soon." 
														delegate:nil 
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil] autorelease];
		[alert show];
		[self changeTo:[[[nState alloc] init] autorelease] after:0.5];
	} else {
		[[StoreObserver getInstance] makePurchase:[[PongVader getInstance].settings get:@"EpisodesProduct"]];
	}
}

- (void) leave {
	[[StoreObserver getInstance] removeResponder: self];
}

- (void) provideContent: (NSString*) productID 
{
	PongVader *pv = [PongVader getInstance];
	if ([productID isEqualToString: [pv.settings get:@"EpisodesProduct"]]) {
		[pv.settings set:@"EpisodesBought" toInt: 1];
	}
	[self changeTo:[[[nState alloc] init] autorelease] after:0.5];
}

- (void) transactionCancelled {
	[self changeTo:[[[nState alloc] init] autorelease] after:0.5];
}

- (void) transactionFailed {
	[self changeTo:[[[nState alloc] init] autorelease] after:0.5];
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	return self;
}

@end

// -------------------------------

@implementation StateMenu
@synthesize shouldClearFirst;

- (id) init {
	if ((self = [super init])) {
		_labels = [[NSMutableArray array] retain];
		setupTitle = YES;
		shouldClearFirst = YES;
	}
	return self;
}

- (void) dealloc {
	[_labels release];
	[super dealloc];
}

/*
 - (GameState *) doTimer:(CFTimeInterval)dTime {
 if ([SimpleAudioEngine sharedEngine].backgroundMusicVolume > 0) 
 [SimpleAudioEngine sharedEngine].backgroundMusicVolume -= dTime;
 
 if (timeElapsed < 3) return self;
 else return [[[StateGetReady alloc] init] autorelease];
 }
 */

- (void) enter {
	PongVader *pv = [PongVader getInstance];
	for (SelectedNode *_label in _labels) [pv addChild:_label.node];

	if (shouldClearFirst) {
		[pv clearScene];
		[pv resetScene];
		[pv showPaddles:NO];
	}
	[pv clearTouches];
	
	if ((![lastState isKindOfClass:[StateMenu class]] && shouldClearFirst) || ([lastState isKindOfClass:[StatePausedMenu class]])){
		[[BeatSequencer getInstance] addResponder:pv.starfield];
		[[BeatSequencer getInstance] startWithSong:pv.track2 andBPM:114 shifted: -0.1];
	}

	// set up logo
	if (setupTitle) {
		CGSize ssz = [CCDirector sharedDirector].winSize;
		pvTitle = [CCSprite spriteWithFile:@"pvTitle.png"];
		ccTexParams tp = {GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT};
		[pvTitle.texture setTexParameters:&tp];
		
		if (_IPAD) {
			pvTitle.position = ccp(ssz.width/2, ssz.height - 300);
			pvTitle.scale = 4;
		}
		else {
			pvTitle.position = ccp(ssz.width/2, ssz.height - 100);
			pvTitle.scale = 2;
		}
		
		[pv addChild:pvTitle];
	}
}

- (void) leave {

	if ((![nextState isKindOfClass:[StateMenu class]] && shouldClearFirst) || 
		[lastState isKindOfClass:[StatePausedMenu class]] ||
		[lastState isKindOfClass:[StateMovie class]]) 
	{
		[[BeatSequencer getInstance] end];
		[[BeatSequencer getInstance] clearResponders];
		[[BeatSequencer getInstance] reset];
		[[BeatSequencer getInstance] clearEvents];
	}

	PongVader *pv = [PongVader getInstance];
	for (SelectedNode *_label in _labels) [pv removeChild:_label.node cleanup:YES];
	
	if (setupTitle) {
		[pv removeChild:pvTitle cleanup:YES];
	}
}


- (void) leaving {
	if (![nextState isKindOfClass:[StateMenu class]] && shouldClearFirst) {
		id action = [CCPropertyAction actionWithDuration:MUSIC_FADE_TIME key:@"BackgroundVolume" from:1.0 to:0.0];
		[[PongVader getInstance] runAction:action];
	}
}

- (GameState *) doStartTouch:(NSSet *)touches withEvent:(UIEvent *)event {
	return [self doDrag:touches withEvent:event];
}

- (GameState *) doDrag:(NSSet *)touches withEvent:(UIEvent *)event {
	SelectedNode *selLabel = nil;

	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		for (SelectedNode *label in _labels) {
			if (CGRectContainsPoint([label getRect], location)) {
				if (label.selectable && !label.selected) {
					[label.node runAction:
					 [CCEaseExponentialOut actionWithAction:
					  [CCScaleTo actionWithDuration:0.5 scale:1.5]]];
					label.selected = YES;
					selLabel = label;
				}
			}
			else {
				if (label.selected) {
					[label.node runAction:
					 [CCEaseExponentialOut actionWithAction:
					  [CCScaleTo actionWithDuration:0.5 scale:1.0]]];
					label.selected = NO;
				}
			}
		}	
	}
	
	if (selLabel) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"redpaddle.wav"];	
		return [self doHover:selLabel];
	}
	return self;
}

- (GameState *) doEndTouch:(NSSet *)touches withEvent:(UIEvent *)event {
	SelectedNode *selLabel = nil;
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		for (SelectedNode *label in _labels) {
			if (label.selected && CGRectContainsPoint([label getRect], location)) {
				selLabel = label;
			}
		}
	}
	for (SelectedNode *label in _labels) {
		[label.node runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCScaleTo actionWithDuration:0.5 scale:1.0]]];
		label.selected = NO;
	}
	if (selLabel) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"blip.wav"];	
		return [self doSelected:selLabel];
	}
		
	else return self;
}

- (GameState *) doHover:(SelectedNode *) label {
	return self;
}

- (GameState *) doSelected:(SelectedNode *) label {
	return self;
}

/*
 - (GameState *) doTimer:(CFTimeInterval)dTime {
 if ([SimpleAudioEngine sharedEngine].backgroundMusicVolume > 0) 
 [SimpleAudioEngine sharedEngine].backgroundMusicVolume -= dTime;
 
 if (timeElapsed < 3) return self;
 else return [[[StateGetReady alloc] init] autorelease];
 }
 */

- (GameState *) doTimer:(CFTimeInterval)dTime {
	[[BeatSequencer getInstance] doTimer:dTime];
	[[PongVader getInstance] doTick: dTime];	
	return self;
}

- (void) provideContent: (NSString*) productID {
	// change the setting to unlock stuff
}

@end

@implementation StateMainMenu
- (id) init {
	if ((self = [super init])) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		PongVader *pv = [PongVader getInstance];
		
		NSString *menuText[5];
		
		menuText[0] = @"PLAY GAME";
		menuText[1] = @"SELECT EPISODE";
		menuText[2] = @"OPENFEINT";
		menuText[3] = @"FEEDBACK";
		menuText[4] = @"MORE BY KODUCO";

		//int menuSize[] = {64, 32, 32, 18};
		BOOL menuSel[] = {YES, YES, YES, YES, YES};

		ccColor3B menuColor[] = {
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255)};
		
		CGPoint menuPos[5];
		
		if (_IPAD) {
			menuPos[0] = ccp(winSize.width/2, winSize.height/2+100);
			menuPos[1] = ccp(winSize.width/2, winSize.height/2-60);
			menuPos[2] = ccp(winSize.width/2, winSize.height/2-120);
			menuPos[3] = ccp(winSize.width/2, winSize.height/2-180);
			menuPos[4] = ccp(3*winSize.width/4, 120);
		}
		
		else {
			menuPos[0] = ccp(winSize.width/2, winSize.height/2+50);
			menuPos[1] = ccp(winSize.width/2, winSize.height/2-10);
			menuPos[2] = ccp(winSize.width/2, winSize.height/2-50);
			menuPos[3] = ccp(winSize.width/2, winSize.height/2-90);
			menuPos[4] = ccp(winSize.width/2, 55);
		}
		
		
		int maxLabels = 5;
		if (PV_UNIVERSAL && !BOUGHT_FULLGAME && ![pv.settings getInt:@"EpisodesBought"]) maxLabels = 4;
		
		for (int i=0; i<maxLabels; i++) {
			NSString *font = pv.mediumFont;

			// special case for first label - play game
			if (i == 0) {
				if ([pv.settings getInt:@"lastLevel"] != 0) {
					menuText[0] = @"RESUME GAME";
				} else {
					if (!_IPAD) menuText[0] = @"PLAY";
					font = pv.largeFont;
				}
			}
			
			
			CCLabelBMFont *bmlabel = [CCLabelBMFont bitmapFontAtlasWithString:menuText[i] fntFile:font];
			
			bmlabel.color = menuColor[i];
			bmlabel.position = menuPos[i];
			
			// special case to hide resume game if there is no game to resume
			if (i == 1) {
				
				if ([pv.settings getInt:@"lastLevel"] == 0) {
					bmlabel.position = ccp(2000, 2000);
				}
			}
			
//			if ([menuText[i] isEqualToString:@"TOGGLE SCOREBOARDS"]) {
//				PongVader *pv = [PongVader getInstance];
//				if ([pv.settings getInt:@"Scoreboards"] == 1) {
//					[_label setString:@"TURN SCOREBOARDS OFF"];
//				}
//				else {
//					[_label setString:@"TURN SCOREBOARDS ON"];
//				}
//			}
			
			SelectedNode *_label = [[[SelectedNode alloc] init] autorelease];
			_label.node = bmlabel;
			_label.selectable = menuSel[i];
			
			[_labels addObject:_label];
		}
		
		if (PV_UNIVERSAL && !BOUGHT_FULLGAME && ![pv.settings getInt:@"EpisodesBought"]) {
			CCSprite *splabel = [CCSprite spriteWithFile:_IPAD?@"morelevels2.png":@"morelevels.png"];

			splabel.position = ccp(winSize.width/2, menuPos[4].y);			
			splabel.rotation = -8;

			SelectedNode *_label = [[[SelectedNode alloc] init] autorelease];
			_label.node = splabel;
			_label.selectable = YES;
			_label.labelname = @"BUY";
			
			[_labels addObject:_label];
		}
		
		signupAlert = [[UIAlertView alloc] initWithTitle:@"Join our forum…" 
												 message:@"You've played this game a lot. You're awesome. We'd like you to join a private forum to discuss game design and hang out."
												delegate:self 
									   cancelButtonTitle:@"Cancel" 
									   otherButtonTitles:nil];
		[signupAlert addButtonWithTitle:@"Let's do this."];

		appStoreAlert = [[UIAlertView alloc] initWithTitle:@"To the App Store…" 
												   message:@"Since you've played this game a few times, could you kindly give us a review? More love leads to more games, you know."
												  delegate:self
										 cancelButtonTitle:@"Cancel"
										 otherButtonTitles:nil];
		[appStoreAlert addButtonWithTitle:@"Let's do this."];	

	}
	return self;
}

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	if (!pv.sentRequest && [pv.settings getInt:@"TimesRun"] >= 4 && [pv.settings getInt:@"Reviewed"] == 0 && [Reachable connectedToNetwork]) {
		[pv.settings set:@"Reviewed" toInt:1];
		pv.sentRequest = YES;
		[appStoreAlert show];
	} else if (!pv.sentRequest && [pv.settings getInt:@"TimesRun"] >= 10 && [pv.settings getInt:@"SignedUp"] == 0 && [Reachable connectedToNetwork]) {
		pv.sentRequest = YES;
		[pv.settings set:@"SignedUp" toInt:1];
		[signupAlert show];
	}
	
	// display alert when new content is unlocked
	if (([pv.settings getInt:@"BeatPrologue"] == 1) && ([pv.settings getInt:@"StartedEpOne"] == 0 && [pv.settings getInt:@"UnlockedEpOneNag"] <= 3)) {
		newContentAlert = [[[UIAlertView alloc] initWithTitle:@"New Episode Unlocked" 
													  message:@"Now that you've beaten the prologue, you'll be able to select Episode One when you start a new game." 
													 delegate:self 
											cancelButtonTitle:@"Schwing!" 
											otherButtonTitles:nil] autorelease];
		[newContentAlert show];
		
		int nagCount = [pv.settings getInt:@"UnlockedEpOneNag"];
		nagCount++;
		[pv.settings set:@"UnlockedEpOneNag" toInt:nagCount];
	}
	else if (([pv.settings getInt:@"BeatEpOne"] == 1) && ([pv.settings getInt:@"StartedEpTwo"] == 0) && [pv.settings getInt:@"UnlockedEpTwoNag"] <= 3) {
		newContentAlert = [[[UIAlertView alloc] initWithTitle:@"New Episode Unlocked" 
													  message:@"Now that you've beaten Episode One, you'll be able to select Episode Two when you start a new game." 
													 delegate:self 
											cancelButtonTitle:@"Game on!" 
											otherButtonTitles:nil] autorelease];
		[newContentAlert show];
		
		int nagCount = [pv.settings getInt:@"UnlockedEpTwoNag"];
		nagCount++;
		[pv.settings set:@"UnlockedEpTwoNag" toInt:nagCount];
	}
}

- (void) dealloc {
	[appStoreAlert release];
	[signupAlert release];
	[super dealloc];
}

- (GameState *) doSelected:(SelectedNode *) label {
	PongVader *pv = [PongVader getInstance];
	GameState *next = self;
	if ([label.labelname isEqualToString:@"PLAY GAME"] || 
		[label.labelname isEqualToString:@"SELECT EPISODE"] || 
		[label.labelname isEqualToString:@"PLAY"]) 
	{
		[FlurryAPI logEvent:@"NEWGAME"];
		for (int i = 0; i < 2; i++) {
			[pv.player[i] resetPropsNewGame];
		}
		curLevel = RESTART_LEVEL;
		//curLevel = 5;
		[pv.settings set:@"lastLevel" toInt:curLevel];
		next = [[[StateSettingsMenu alloc] init] autorelease];
		//next = [[[StateCredits alloc] init] autorelease];
	} else if ([label.labelname isEqualToString:@"RESUME GAME"]) {
		for (int i = 0; i < 2; i++) {
			[pv.player[i] restoreLastLevelScore];
			[pv.player[i] restoreLastLevelChain];
		}
		curLevel = [pv.settings getInt:@"lastLevel"];
		next = [[[StateGetReady alloc] init] autorelease];
	} else if ([label.labelname isEqualToString:@"FEEDBACK"]) {
		[FlurryAPI logEvent:@"CLICKED_FEEDBACK"];
		
		[[OverlayViewController sharedController] show];
		
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Give Us Feedback"
																 delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"I love it", @"Give feedback", nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		OverlayViewController *ovc = [OverlayViewController sharedController];
		[actionSheet showInView:ovc.view];	// show from our table view (pops up in the middle of the table)
		[actionSheet release];

	} else if ([label.labelname isEqualToString:@"OPENFEINT"]) {
		[FlurryAPI logEvent:@"CHECKED_OF"];
		if (!pv.OFstarted) {
			[pv initOpenFeint];	
			if ([pv.settings getInt:@"OFwanted"] == 0) {
				[pv.settings set:@"OFwanted" toInt:1];
			}
		}
		// otherwise
		else {
			[OpenFeint launchDashboard];
		}
	} else if ([label.labelname isEqualToString:@"MORE BY KODUCO"]) {
		[FlurryAPI logEvent:@"CHECKED_MORE"];
		next = [[[StateMoreGames alloc] init] autorelease];
	}
	else if ([label.labelname isEqualToString:@"BUY"]) {
		next = [[[StatePurchase alloc] initWithNextState:[self class]] autorelease];
	}
	
	//else if ([label.labelname isEqualToString:@"TURN SCOREBOARDS OFF"]) {
//		PongVader *pv = [PongVader getInstance];
//		[pv.settings set:@"Scoreboards" toInt:0];
//		[label setString:@"TURN SCOREBOARDS ON"];
//	} else if ([label.labelname isEqualToString:@"TURN SCOREBOARDS ON"]) {
//		PongVader *pv = [PongVader getInstance];
//		[pv.settings set:@"Scoreboards" toInt:1];
//		[label setString:@"TURN SCOREBOARDS OFF"];
//	}
	
	if (next != self) [self changeTo:next after:MENU_TRANSITION_PAUSE];
	return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (![Reachable connectedToNetwork]) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Not connected to network" 
														 message:@"You must be connected to the network to complete this action." 
														delegate:nil 
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil] autorelease];
		[alert show];
		return;
	}		
	if (alertView == appStoreAlert) {
		switch(buttonIndex) {
			case 0:
				break;
			case 1:
				//[FlurryAPI logEvent:@"ILoveThisGame"];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=388469398&mt=8"]];
				break;
		}
	}
	else if (alertView == signupAlert) {
		switch(buttonIndex) {
			case 0:
				break;
			case 1:
				//[FlurryAPI logEvent:@"ILoveThisGame"];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://koduco.com/signup"]];
				break;
		}
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[[OverlayViewController sharedController] hide];
		appStoreAlert = [[UIAlertView alloc] initWithTitle:@"To the App Store…" message:@"Since you love this game, could you kindly give us a review? More stars leads to more games, you know." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[appStoreAlert addButtonWithTitle:@"Let's do this."];	
		[appStoreAlert show];
	}
	else if (buttonIndex == 1)
	{
		[Crittercism sharedInstance].delegate = self;
		[[Crittercism sharedInstance] showCrittercism];
	}
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 2) {
		[[OverlayViewController sharedController] hide];
	}
}

- (void) crittercismDidClose {
	[[OverlayViewController sharedController] hide];
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	SelectedNode *label = [_labels objectAtIndex:0];
	if (!label.selected) {
		label.node.scale = 1.125+(0.125)*sin(timeElapsed*1.5);
	}
	return [super doTimer:dTime];
}

@end

@implementation StateSettingsMenu
- (id) init {
	if ((self = [super init])) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		PongVader *pv = [PongVader getInstance];
		
		NSString *menuTextiPad[] = {@"EPISODE SELECT", @"PLAYER ONE", @"HUMAN", @"ROBOT",  
			@"PLAYER TWO", @"HUMAN", @"ROBOT", @"PLAY", @"PROLOGUE", @"EPISODE 1", @"EPISODE 2"};
		NSString *menuTextiPhn[] = {@"EPISODE SELECT", @"PLAYER 1", @"HUMAN", @"ROBOT",  
			@"PLAYER 2", @"HUMAN", @"ROBOT", @"PLAY", @"PROLOGUE", @"EPISODE 1", @"EPISODE 2"};
		//int menuSize[] = {64, 32, 32, 18};
		BOOL menuSel[11] = {NO, NO, YES, YES, NO, YES, YES, YES, YES, YES, YES};
		
		if (!PV_UNIVERSAL || BOUGHT_FULLGAME || [pv.settings getInt:@"EpisodesBought"]) {
			menuSel[0] = NO;
			menuSel[1] = NO;
			menuSel[2] = YES;
			menuSel[3] = YES;
			menuSel[4] = NO;
			menuSel[5] = YES;
			menuSel[6] = YES;
			menuSel[7] = YES;
			menuSel[8] = YES;
			menuSel[9] = YES;
			menuSel[10] = YES;
		}
		else {
			menuSel[0] = NO;
			menuSel[1] = NO;
			menuSel[2] = YES;
			menuSel[3] = YES;
			menuSel[4] = NO;
			menuSel[5] = YES;
			menuSel[6] = YES;
			menuSel[7] = YES;
			menuSel[8] = YES;
			menuSel[9] = NO;
			menuSel[10] = NO;
		}
		
		CGPoint anchorPoint[] = {
			ccp(0.5, 0.5),
			ccp(0.0, 0.5),
			ccp(0.0, 0.5),
			ccp(0.0, 0.5),
			ccp(0.0, 0.5),
			ccp(0.0, 0.5),
			ccp(0.0, 0.5),
			ccp(0.5, 0.5),
			ccp(0.0, 0.5),
			ccp(0.0, 0.5),
			ccp(0.0, 0.5),
		};
		
		ccColor3B menuColor[] = {
			ccc3(255, 64, 64),
			ccc3(255, 64, 64),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
			ccc3(255, 64, 64),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
		};
		
		CGPoint menuPos[11];
		
		if (_IPAD) {
			// EPISODE SELECT
			menuPos[0] = ccp(winSize.width/2, winSize.height/2+210);
			menuPos[8] = ccp(winSize.width/2, winSize.height/2+120);
			menuPos[9] = ccp(winSize.width/2, winSize.height/2+60);
			menuPos[10] = ccp(winSize.width/2, winSize.height/2);
			
			// PLAYER ONE
			menuPos[1] = ccp(winSize.width/2 - 300, winSize.height/2-360); 
			menuPos[2] = ccp(winSize.width/2 + 50,  winSize.height/2-390); 
			menuPos[3] = ccp(winSize.width/2 + 50,  winSize.height/2-330);
			
			// PLAYER TWO
			menuPos[4] = ccp(winSize.width/2 - 300, winSize.height/2+360);
			menuPos[5] = ccp(winSize.width/2 + 50,  winSize.height/2+390); 
			menuPos[6] = ccp(winSize.width/2 + 50,  winSize.height/2+330);
			
			// PLAY
			menuPos[7] = ccp(winSize.width/2,  winSize.height/2-180);
			
		}
		else {
			// EPISODE SELECT
			menuPos[0]  = ccp(winSize.width/2,      winSize.height/2+95);
			menuPos[8]  = ccp(winSize.width/2 - 60, winSize.height/2+50);
			menuPos[9]  = ccp(winSize.width/2 - 60, winSize.height/2+15);
			menuPos[10] = ccp(winSize.width/2 - 60, winSize.height/2-20);
			
			// PLAYER ONE
			menuPos[1] = ccp(winSize.width/2 - 125, winSize.height/2-180); 
			menuPos[2] = ccp(winSize.width/2 + 35,  winSize.height/2-195); 
			menuPos[3] = ccp(winSize.width/2 + 35,  winSize.height/2-165);
			
			// PLAYER TWO
			menuPos[4] = ccp(winSize.width/2 - 125, winSize.height/2+180);
			menuPos[5] = ccp(winSize.width/2 + 35,  winSize.height/2+195); 
			menuPos[6] = ccp(winSize.width/2 + 35,  winSize.height/2+165);
			
			// PLAY
			menuPos[7] = ccp(winSize.width/2,  winSize.height/2-100);
		}

		
		for (int i=0; i<11; i++) {
			SelectedNode *_label = [[[SelectedNode alloc] init] autorelease];
			CCLabelBMFont *bmlabel = [CCLabelBMFont bitmapFontAtlasWithString:_IPAD?menuTextiPad[i]:menuTextiPhn[i] fntFile:(i==7)?pv.largeFont:pv.mediumFont];
			
			_label.selectable = menuSel[i];			
			bmlabel.color = menuColor[i];
			bmlabel.position = menuPos[i];
			bmlabel.anchorPoint = anchorPoint[i];
			
			if (i==2) _label.labelname = [NSString stringWithFormat:@"%@-%d", @"HUMAN", 1];
			if (i==3) _label.labelname = [NSString stringWithFormat:@"%@-%d", @"COMPUTER", 1];
			if (i==5) _label.labelname = [NSString stringWithFormat:@"%@-%d", @"HUMAN", 2];
			if (i==6) _label.labelname = [NSString stringWithFormat:@"%@-%d", @"COMPUTER", 2];
			if (i == 8) _label.labelname = [NSString stringWithFormat:@"PRO"];
			if (i == 9) {
				_label.labelname = [NSString stringWithFormat:@"EP1"];
				if ([pv.settings getInt:@"BeatPrologue"] == 0 && !ALL_LEVELS_AVAIL) {
					bmlabel.color = ccc3(92, 92, 92);
					_label.selectable = NO;
				}
			}
			if (i == 10) { 
				_label.labelname = [NSString stringWithFormat:@"EP2"];
				if ([pv.settings getInt:@"BeatEpOne"] == 0 && !ALL_LEVELS_AVAIL) {
					bmlabel.color = ccc3(92, 92, 92);
					_label.selectable = NO;
				}
			}
			
			_label.node = bmlabel;
			
			[_labels addObject:_label];
		}
		setupTitle = NO;
		
		if _IPAD {
			arrow[0] = [[CCSprite spriteWithFile:@"arrow.png"] retain];
			arrow[1] = [[CCSprite spriteWithFile:@"arrow.png"] retain];
			arrow[2] = [[CCSprite spriteWithFile:@"arrow.png"] retain];
		}
		else {
			arrow[0] = [[CCSprite spriteWithFile:@"arrow-low.png"] retain];
			arrow[1] = [[CCSprite spriteWithFile:@"arrow-low.png"] retain];
			arrow[2] = [[CCSprite spriteWithFile:@"arrow-low.png"] retain];
		}
		
		if (PV_UNIVERSAL && (UPGRADE_BUTTON || ![pv.settings getInt:@"EpisodesBought"])) {
			
			CCSprite *splabel = [CCSprite spriteWithFile:_IPAD?@"buysmall2.png":@"buysmall.png"];
			if _IPAD splabel.position = ccp(100+winSize.width/2, 32+winSize.height/2);
			else splabel.position = ccp(winSize.width/2, -8+winSize.height/2);
			splabel.rotation = -12;
			
			SelectedNode *_label = [[[SelectedNode alloc] init] autorelease];
			_label.node = splabel;
			_label.selectable = YES;
			_label.labelname = @"BUY";
			
			[_labels addObject:_label];
		}
		
		// ptype[0] = [[CCLabelBMFont bitmapFontAtlasWithString:@"HUMAN" fntFile:pv.mediumFont] retain];
		// ptype[1] = [[CCLabelBMFont bitmapFontAtlasWithString:@"HUMAN" fntFile:pv.mediumFont] retain];
		// ptype[0].color = ccc3(255, 64, 64);
		// ptype[1].color = ccc3(255, 64, 64);

	}
	return self;
}

- (void) dealloc {
	[arrow[0] release];
	[arrow[1] release];
	[arrow[2] release];
//	[ptype[0] release];
//	[ptype[1] release];
	[super dealloc];
}

- (void) enter {
	CGSize ssz = [CCDirector sharedDirector].winSize;
	PongVader *pv = [PongVader getInstance];
	[super enter];
	CGPoint p;
	int xOffset, yOffset;
	
	if _IPAD {
		xOffset = 32;
		yOffset = 5;
	}
	else {
		xOffset = 16;
		yOffset = 3;
	}
//	if ([pv.settings getInt:@"Player1Type"] == 0) 
		p = [[(SelectedNode*)[_labels objectAtIndex:2] node] position];
//	else
//		p = [(SelectedNode*)[_labels objectAtIndex:3] position];
	arrow[0].position = ccp(p.x-xOffset, p.y+yOffset);
//	if ([pv.settings getInt:@"Player2Type"] == 0) 
//		p = [(SelectedNode*)[_labels objectAtIndex:5] position];
//	else
		p = [[(SelectedNode*)[_labels objectAtIndex:6] node] position];
	arrow[1].position = ccp(p.x-xOffset, p.y+yOffset);
	
	p = [[(SelectedNode*)[_labels objectAtIndex:8] node] position];
	arrow[2].position = ccp(p.x-xOffset, p.y+yOffset);
	
	[pv.settings set:@"Player1Type" toInt:0];
		[pv.settings set:@"Player2Type" toInt:1];
	
	//if (_IPAD) {
//	ptype[0].position = ccp(ssz.width/2.0, 125);
//	ptype[1].position = ccp(ssz.width/2.0, ssz.height-125);
//	}
//	else {
//		ptype[0].position = ccp(ssz.width/2.0, 60);
//		ptype[1].position = ccp(ssz.width/2.0, ssz.height-60);
//	}
//
//	ptype[1].rotation = 180;
//	
//	[ptype[0] setString:[pv.settings get:@"Player1Type"]];
//	[ptype[1] setString:[pv.settings get:@"Player2Type"]];
	
	[pv addChild:arrow[0]];
	[pv addChild:arrow[1]];
	[pv addChild:arrow[2]];
		
//	[pv addChild:ptype[0]];
//	[pv addChild:ptype[1]];
}

- (void) leave {
	PongVader *pv = [PongVader getInstance];
	[pv removeChild:arrow[0] cleanup: YES];
	[pv removeChild:arrow[1] cleanup: YES];
	[pv removeChild:arrow[2] cleanup: YES];
//	[pv removeChild:ptype[0] cleanup: YES];
//	[pv removeChild:ptype[1] cleanup: YES];
	[super leave];
}

- (GameState *) doHover:(SelectedNode *) label {
	PongVader *pv = [PongVader getInstance];

	CGPoint p;
	int xOffset, yOffset;
	if _IPAD {
		xOffset = 32;
		yOffset = 5;
	}
	else {
		xOffset = 16;
		yOffset = 3;
	}
	
	if ([label.labelname isEqualToString:@"HUMAN-1"]) {
		p = [[(SelectedNode*)[_labels objectAtIndex:2] node] position];
		arrow[0].position = ccp(p.x-xOffset, p.y+yOffset);
		[pv.settings set:@"Player1Type" to:@"HUMAN"];
	} else if ([label.labelname isEqualToString:@"COMPUTER-1"]) {
		p = [[(SelectedNode*)[_labels objectAtIndex:3] node] position];
		arrow[0].position = ccp(p.x-xOffset, p.y+yOffset);
		[pv.settings set:@"Player1Type" to:@"COMPUTER"];
	} else if ([label.labelname isEqualToString:@"HUMAN-2"]) {
		p = [[(SelectedNode*)[_labels objectAtIndex:5] node] position];
		arrow[1].position = ccp(p.x-xOffset, p.y+yOffset);
		[pv.settings set:@"Player2Type" to:@"HUMAN"];
	} else if ([label.labelname isEqualToString:@"COMPUTER-2"]) {
		p = [[(SelectedNode*)[_labels objectAtIndex:6] node] position];
		arrow[1].position = ccp(p.x-xOffset, p.y+yOffset);
		[pv.settings set:@"Player2Type" to:@"COMPUTER"];
	} 
	else if ([label.labelname isEqualToString:@"PRO"]) {
		p = [[(SelectedNode*)[_labels objectAtIndex:8] node] position];
		arrow[2].position = ccp(p.x-xOffset, p.y+yOffset);
		curLevel = 0;
	} 
	else if ([label.labelname isEqualToString:@"EP1"]) {
		p = [[(SelectedNode*)[_labels objectAtIndex:9] node] position];
		arrow[2].position = ccp(p.x-xOffset, p.y+yOffset);
		curLevel = EPISODE_ONE_LEVEL;
	} 
	else if ([label.labelname isEqualToString:@"EP2"]) {
		p = [[(SelectedNode*)[_labels objectAtIndex:10] node] position];
		arrow[2].position = ccp(p.x-xOffset, p.y+yOffset);
		curLevel = EPISODE_TWO_LEVEL;
	} 
	
	return self;
}

- (GameState *) doSelected:(SelectedNode *) label {
	GameState *next = self;	
	if ([label.labelname isEqualToString:@"PLAY"]) {
		if (curLevel == 0) {
			//next = [[[StateGetReady alloc] init] autorelease];
			next = [[[StateTutorial alloc] init] autorelease];
		} else {
			next = [[[StateGetReady alloc] init] autorelease];
		}
	} else if ([label.labelname isEqualToString:@"BUY"]) {
		next = [[[StatePurchase alloc] initWithNextState:[self class]] autorelease];
	}
	
	if (next != self) [self changeTo:next after:MENU_TRANSITION_PAUSE];
	return self;
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	SelectedNode *label = [_labels objectAtIndex:7];
	if (!label.selected) {
		label.node.scale = 1.125+(0.125)*sin(timeElapsed*1.5);
	}
	return [super doTimer:dTime];
}


@end

@implementation StatePausedMenu
- (id) init {
	if ((self = [super init])) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		PongVader *pv = [PongVader getInstance];
		
		NSString *menuTextiPad[] = {@"MAIN MENU", @"PLAYER ONE", @"HUMAN", @"ROBOT",  
			@"PLAYER TWO", @"HUMAN", @"ROBOT", @"RESUME"};
		NSString *menuTextiPhn[] = {@"MAIN MENU", @"PLAYER 1", @"HUMAN", @"ROBOT",  
			@"PLAYER 2", @"HUMAN", @"ROBOT", @"RESUME"};
		//int menuSize[] = {64, 32, 32, 18};
		BOOL menuSel[] = {YES, NO, YES, YES, NO, YES, YES, YES, YES, YES, YES};
		
		CGPoint anchorPoint[] = {
			ccp(0.5, 0.5),
			ccp(0.0, 0.5),
			ccp(0.0, 0.5),
			ccp(0.0, 0.5),
			ccp(0.0, 0.5),
			ccp(0.0, 0.5),
			ccp(0.0, 0.5),
			ccp(0.5, 0.5),
		};
		
		ccColor3B menuColor[] = {
			ccc3(255, 255, 255),
			ccc3(255, 64, 64),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
			ccc3(255, 64, 64),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
		};
		
		CGPoint menuPos[11];
		
		if (_IPAD) {
			// EPISODE SELECT
			menuPos[0] = ccp(winSize.width/2, winSize.height/2+210);
			
			// PLAYER ONE
			menuPos[1] = ccp(winSize.width/2 - 300, winSize.height/2-360); 
			menuPos[2] = ccp(winSize.width/2 + 50,  winSize.height/2-390); 
			menuPos[3] = ccp(winSize.width/2 + 50,  winSize.height/2-330);
			
			// PLAYER TWO
			menuPos[4] = ccp(winSize.width/2 - 300, winSize.height/2+360);
			menuPos[5] = ccp(winSize.width/2 + 50,  winSize.height/2+390); 
			menuPos[6] = ccp(winSize.width/2 + 50,  winSize.height/2+330);
			
			// PLAY
			menuPos[7] = ccp(winSize.width/2,  winSize.height/2-180);
			
		}
		else {
			// EPISODE SELECT
			menuPos[0]  = ccp(winSize.width/2,      winSize.height/2+95);
			
			// PLAYER ONE
			menuPos[1] = ccp(winSize.width/2 - 125, winSize.height/2-180); 
			menuPos[2] = ccp(winSize.width/2 + 35,  winSize.height/2-195); 
			menuPos[3] = ccp(winSize.width/2 + 35,  winSize.height/2-165);
			
			// PLAYER TWO
			menuPos[4] = ccp(winSize.width/2 - 125, winSize.height/2+180);
			menuPos[5] = ccp(winSize.width/2 + 35,  winSize.height/2+195); 
			menuPos[6] = ccp(winSize.width/2 + 35,  winSize.height/2+165);
			
			// PLAY
			menuPos[7] = ccp(winSize.width/2,  winSize.height/2-100);
		}
		
		
		for (int i=0; i<8; i++) {
			SelectedNode *_label = [[[SelectedNode alloc] init] autorelease];
			CCLabelBMFont *bmlabel = [CCLabelBMFont bitmapFontAtlasWithString:_IPAD?menuTextiPad[i]:menuTextiPhn[i] fntFile:(i==7)?pv.largeFont:pv.mediumFont];
			
			_label.selectable = menuSel[i];			
			bmlabel.color = menuColor[i];
			bmlabel.position = menuPos[i];
			bmlabel.anchorPoint = anchorPoint[i];
			
			if (i==2) _label.labelname = [NSString stringWithFormat:@"%@-%d", @"HUMAN", 1];
			if (i==3) _label.labelname = [NSString stringWithFormat:@"%@-%d", @"COMPUTER", 1];
			if (i==5) _label.labelname = [NSString stringWithFormat:@"%@-%d", @"HUMAN", 2];
			if (i==6) _label.labelname = [NSString stringWithFormat:@"%@-%d", @"COMPUTER", 2];			
			
			_label.node = bmlabel;
			
			[_labels addObject:_label];
		}
		setupTitle = NO;
		
		if _IPAD {
			arrow[0] = [[CCSprite spriteWithFile:@"arrow.png"] retain];
			arrow[1] = [[CCSprite spriteWithFile:@"arrow.png"] retain];
			arrow[2] = [[CCSprite spriteWithFile:@"arrow.png"] retain];
		}
		else {
			arrow[0] = [[CCSprite spriteWithFile:@"arrow-low.png"] retain];
			arrow[1] = [[CCSprite spriteWithFile:@"arrow-low.png"] retain];
			arrow[2] = [[CCSprite spriteWithFile:@"arrow-low.png"] retain];
		}
		
		flash = [[CCLayerColor layerWithColor:ccc4(0, 0, 0, 128) width: winSize.width height: winSize.height] retain];
		
	}
	return self;
}

- (void) dealloc {
	[arrow[0] release];
	[arrow[1] release];
	[arrow[2] release];
	[flash release];
	[super dealloc];
}

- (void) enter {
	CGSize ssz = [CCDirector sharedDirector].winSize;
	PongVader *pv = [PongVader getInstance];
	
	[pv addChild: flash];
	
	[pv showPaddles:NO];
	[super enter];
	CGPoint p;
	int xOffset, yOffset;
	
	if _IPAD {
		xOffset = 32;
		yOffset = 5;
	}
	else {
		xOffset = 16;
		yOffset = 3;
	}
	if ([pv.settings getInt:@"Player1Type"] == 0) 
		p = [[(SelectedNode*)[_labels objectAtIndex:2] node] position];
	else
		p = [[(SelectedNode*)[_labels objectAtIndex:3] node] position];
	arrow[0].position = ccp(p.x-xOffset, p.y+yOffset);
	if ([pv.settings getInt:@"Player2Type"] == 0) 
		p = [[(SelectedNode*)[_labels objectAtIndex:5] node] position];
	else
		p = [[(SelectedNode*)[_labels objectAtIndex:6] node] position];
	arrow[1].position = ccp(p.x-xOffset, p.y+yOffset);
	
	[pv addChild:arrow[0]];
	[pv addChild:arrow[1]];
	//[pv addChild:arrow[2]];
	
	[[BeatSequencer getInstance] pause];
}

- (void) leave {
	PongVader *pv = [PongVader getInstance];
	[pv removeChild:arrow[0] cleanup: YES];
	[pv removeChild:arrow[1] cleanup: YES];
	[pv removeChild:arrow[2] cleanup: YES];
	[pv removeChild:flash cleanup:YES];
	[pv showPaddles:YES];
	[[BeatSequencer getInstance] unpause];
	
	if ([nextState isKindOfClass:[StateMainMenu class]]) {
		[[BeatSequencer getInstance] end];
		[[BeatSequencer getInstance] clearResponders];
		[[BeatSequencer getInstance] reset];
		[[BeatSequencer getInstance] clearEvents];
	}
	
	[super leave];
}

- (GameState *) doHover:(SelectedNode *) label {
	PongVader *pv = [PongVader getInstance];
	
	CGPoint p;
	int xOffset, yOffset;
	if _IPAD {
		xOffset = 32;
		yOffset = 5;
	}
	else {
		xOffset = 16;
		yOffset = 3;
	}
	
	if ([label.labelname isEqualToString:@"HUMAN-1"]) {
		p = [[(SelectedNode*)[_labels objectAtIndex:2] node] position];
		arrow[0].position = ccp(p.x-xOffset, p.y+yOffset);
		[pv.settings set:@"Player1Type" to:@"HUMAN"];
	} else if ([label.labelname isEqualToString:@"COMPUTER-1"]) {
		p = [[(SelectedNode*)[_labels objectAtIndex:3] node] position];
		arrow[0].position = ccp(p.x-xOffset, p.y+yOffset);
		[pv.settings set:@"Player1Type" to:@"COMPUTER"];
	} else if ([label.labelname isEqualToString:@"HUMAN-2"]) {
		p = [[(SelectedNode*)[_labels objectAtIndex:5] node] position];
		arrow[1].position = ccp(p.x-xOffset, p.y+yOffset);
		[pv.settings set:@"Player2Type" to:@"HUMAN"];
	} else if ([label.labelname isEqualToString:@"COMPUTER-2"]) {
		p = [[(SelectedNode*)[_labels objectAtIndex:6] node] position];
		arrow[1].position = ccp(p.x-xOffset, p.y+yOffset);
		[pv.settings set:@"Player2Type" to:@"COMPUTER"];
	} 
	
	return self;
}

- (GameState *) doSelected:(SelectedNode *) label {
	GameState *next = self;	
	if ([label.labelname isEqualToString:@"RESUME"]) {
		next = [[[StatePlaying alloc] init] autorelease];
		((StatePlaying *) next).shouldClearFirst = NO;
	}	
	else if ([label.labelname isEqualToString:@"MAIN MENU"]) {
		next = [[[StateMainMenu alloc] init] autorelease]; 
		((StatePlaying *) next).shouldClearFirst = YES;
	}	
	
	if (next != self) [self changeTo:next after:0];
	return self;
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	SelectedNode *label = [_labels objectAtIndex:7];
	if (!label.selected) {
		label.node.scale = 1.125+(0.125)*sin(timeElapsed*1.5);
	}
	
	return self;
	//return [super doTimer:dTime];
}


@end


@implementation StateLoseMenu

- (id) init {
	if ((self = [super init])) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		PongVader *pv = [PongVader getInstance];
		BOOL p1h = [[pv.settings get:@"Player1Type"] isEqualToString:@"HUMAN"];
		BOOL p2h = [[pv.settings get:@"Player2Type"] isEqualToString:@"HUMAN"];
		
		int menuitems;
		// NSString *menuText[] = { @"REPLAY LEVEL", @"SELECT EPISODE", @"HELP", @"TOP SCORES", @"POST SCORE"};
		NSString *menuText[] = { @"REPLAY LEVEL", @"MAIN MENU", @"TOP SCORES", @"POST SCORE"};
		if ([PongVader getInstance].OFstarted) {
			if (p1h || p2h)	menuitems = 4;
			else menuitems = 3;
		}
		else {
			menuitems = 2;
		}
		
		//int menuSize[] = {64, 32, 32, 32, 32, 18};
		BOOL menuSel[] = {YES, YES, YES, YES, YES, YES};
		
		ccColor3B menuColor[] = {
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255),
			ccc3(255, 255, 255)};
		
		CGPoint menuPos[4];
		
		if (_IPAD) {
			menuPos[0] = ccp(winSize.width/2, winSize.height/2+100);
			menuPos[1] = ccp(winSize.width/2, winSize.height/2-60);
			menuPos[2] = ccp(winSize.width/2, winSize.height/2-120);
			menuPos[3] = ccp(winSize.width/2, winSize.height/2-180);
		} else {
			menuPos[0] = ccp(winSize.width/2, winSize.height/2+50);
			menuPos[1] = ccp(winSize.width/2, winSize.height/2-10);
			menuPos[2] = ccp(winSize.width/2, winSize.height/2-50);
			menuPos[3] = ccp(winSize.width/2, winSize.height/2-90);
		}
		
		
		for (int i=0; i<menuitems; i++) {			
			SelectedNode *_label = [[[SelectedNode alloc] init] autorelease];
			CCLabelBMFont *bmlabel = [CCLabelBMFont bitmapFontAtlasWithString:menuText[i] fntFile:pv.mediumFont];

			_label.selectable = menuSel[i];
			bmlabel.color = menuColor[i];
			bmlabel.position = menuPos[i];
			
			_label.node = bmlabel;
			
			[_labels addObject:_label];
			
			// hide first menu option if we have already beaten the game
			// also increment # of times game beaten and invite players to join group if appropriate
			if ((i == 0) && (curLevel == 0)) {
				_label.node.position = ccp(2000,2000);	
			}
		}
		
		if (PV_UNIVERSAL && !BOUGHT_FULLGAME && ![pv.settings getInt:@"EpisodesBought"] &&
			!(p1h && p2h && [PongVader getInstance].OFstarted))
		{
			CCSprite *splabel = [CCSprite spriteWithFile:_IPAD?@"morelevels2.png":@"morelevels.png"];
			
			int offset = _IPAD?((menuitems+0.5)*60):((menuitems-0.5)*40);
			splabel.position = ccp(winSize.width/2, winSize.height/2-offset);
			splabel.rotation = -8;
			
			SelectedNode *_label = [[[SelectedNode alloc] init] autorelease];
			_label.node = splabel;
			_label.selectable = YES;
			_label.labelname = @"BUY";
			
			[_labels addObject:_label];
		}
		
		scores[0] = [[CCLabelBMFont bitmapFontAtlasWithString:@"0" fntFile:pv.mediumFont] retain];
		scores[1] = [[CCLabelBMFont bitmapFontAtlasWithString:@"0" fntFile:pv.mediumFont] retain];

		scores[0].rotation = 0;
		scores[1].rotation = 180;
		[scores[0] setAnchorPoint:ccp(0, 0.5f)];
		[scores[1] setAnchorPoint:ccp(0, 0.5f)];
		
		// points labels
		scoreLabels[0] = [[CCLabelBMFont bitmapFontAtlasWithString:@"SCORE:" fntFile:pv.mediumFont] retain];
		scoreLabels[1] = [[CCLabelBMFont bitmapFontAtlasWithString:@"SCORE:" fntFile:pv.mediumFont] retain];

		scoreLabels[0].rotation = 0;
		scoreLabels[1].rotation = 180;
		[scoreLabels[0] setAnchorPoint:ccp(0, 0.5f)];
		[scoreLabels[1] setAnchorPoint:ccp(0, 0.5f)];
	
		// max chains
		maxChains[0] = [[CCLabelBMFont bitmapFontAtlasWithString:@"MAX CHAIN: 0" fntFile:pv.mediumFont] retain];
		maxChains[1] = [[CCLabelBMFont bitmapFontAtlasWithString:@"MAX CHAIN: 0" fntFile:pv.mediumFont] retain];
		
		maxChains[0].rotation = 0;
		maxChains[1].rotation = 180;
		[maxChains[0] setAnchorPoint:ccp(1, 0.5f)];
		[maxChains[1] setAnchorPoint:ccp(1, 0.5f)];

		for (int i=0; i<2; i++) {			
			int curScore = pv.player[i].score;
			//int curChain = pv.player[i].chain;
			int maxChain = pv.player[i].maxChain;
			
			[scores[i] setString:[NSString stringWithFormat:@"%d", curScore]];
			[maxChains[i] setString:[NSString stringWithFormat:@"MAX CHAIN: %d", maxChain]];
		}
		
		// combined stuff
		int combChain = (p1h?pv.player[0].maxChain:0) + (p2h?pv.player[1].maxChain:0);
		int combScore = (p1h?pv.player[0].score:0) + (p2h?pv.player[1].score:0);
		
		combinedChain = [[CCLabelBMFont bitmapFontAtlasWithString:[NSString stringWithFormat:@"COMBINED CHAIN: %d", combChain] fntFile:pv.mediumFont] retain];
		combinedScore = [[CCLabelBMFont bitmapFontAtlasWithString:[NSString stringWithFormat:@"COMBINED SCORE: %d", combScore] fntFile:pv.mediumFont] retain];

		combinedChain.color = ccc3(255,0,0);
		combinedScore.color = ccc3(255,0,0);

	}
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	if (_IPAD) {
		scores[0].position = ccp(winSize.width-175, 65);
		scores[1].position = ccp(175, winSize.height-65);
		scoreLabels[0].position = ccp(winSize.width-175, 90);
		scoreLabels[1].position = ccp(175, winSize.height-90);
		maxChains[0].position = ccp(295, 90);
		maxChains[1].position = ccp(winSize.width-295, winSize.height-90);
		combinedChain.position = ccp(winSize.width/2, winSize.height/2-250);
		combinedScore.position = ccp(winSize.width/2, winSize.height/2-300);
	}
	else {
		scores[0].position = ccp(winSize.width-100, 25);
		scores[1].position = ccp(100, winSize.height-25);
		scoreLabels[0].position = ccp(winSize.width-100, 45);
		scoreLabels[1].position = ccp(100, winSize.height-45);
		maxChains[0].position = ccp(180, 45);
		maxChains[1].position = ccp(winSize.width-180, winSize.height-45);
		combinedChain.position = ccp(winSize.width/2, winSize.height/2-120);
		combinedScore.position = ccp(winSize.width/2, winSize.height/2-145);
	}
	
	if ([PongVader getInstance].OFstarted) {
		[[PongVader getInstance] updateOFScores];
	}
	
	signupAlert = [[UIAlertView alloc] initWithTitle:@"Join our forum…" message:@"You've beaten several boss fights. You're awesome. We'd like you to join a private forum to discuss game design and hang out." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[signupAlert addButtonWithTitle:@"Let's do this."];
	appStoreAlert = [[UIAlertView alloc] initWithTitle:@"To the App Store…" message:@"Great job beating that boss! How about taking a quick break to write us a review? We're fighting our own battle, and could really use your help!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
	[appStoreAlert addButtonWithTitle:@"Let's do this."];	

	return self;
}

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];

	BOOL p1h = [[pv.settings get:@"Player1Type"] isEqualToString:@"HUMAN"];
	BOOL p2h = [[pv.settings get:@"Player2Type"] isEqualToString:@"HUMAN"];

	if (p1h) {
		[pv addChild:scores[0]];
		[pv addChild:scoreLabels[0]];
		[pv addChild:maxChains[0]];
	}
	
	if (p2h) {
		[pv addChild:scores[1]];
		[pv addChild:scoreLabels[1]];
		[pv addChild:maxChains[1]];
	}
	
	if (p1h && p2h) {
		[pv addChild:combinedChain];
		[pv addChild:combinedScore];
	}
	
	if (pv.gameBeat) {
		[pv.settings inc:@"BeatBoss" by:1];
		
		if (!pv.sentRequest && [pv.settings getInt:@"ReviewBoss"] == 0 && [Reachable connectedToNetwork]) {
			pv.sentRequest = YES;
			[pv.settings set:@"ReviewBoss" toInt:1];
			[appStoreAlert show];
		} else if (!pv.sentRequest && [pv.settings getInt:@"BeatBoss"] >= 3 && 
				   [pv.settings getInt:@"Beat3SignUp"] == 0 && 
				   [Reachable connectedToNetwork]) {
			pv.sentRequest = YES;
			[pv.settings set:@"Beat3SignUp" toInt:1];
			[signupAlert show];
		}
	}
}

- (void) leave {
	[super leave];
	PongVader *pv = [PongVader getInstance];

	BOOL p1h = [[pv.settings get:@"Player1Type"] isEqualToString:@"HUMAN"];
	BOOL p2h = [[pv.settings get:@"Player2Type"] isEqualToString:@"HUMAN"];

	if (p1h) {
		[pv removeChild:scores[0] cleanup:YES];
		[pv removeChild:scoreLabels[0] cleanup:YES];
		[pv removeChild:maxChains[0] cleanup:YES];
	}
	
	if (p2h) {
		[pv removeChild:scores[1] cleanup:YES];
		[pv removeChild:scoreLabels[1] cleanup:YES];
		[pv removeChild:maxChains[1] cleanup:YES];
	}

	if (p1h && p2h) {
		[pv removeChild:combinedChain cleanup:YES];
		[pv removeChild:combinedScore cleanup:YES];
	}
}

- (void) dealloc {
	[scores[0] release];
	[scores[1] release];
	[scoreLabels[0] release];
	[scoreLabels[1] release];
	[maxChains[0] release];
	[maxChains[1] release];
	[combinedChain release];
	[combinedScore release];
	[super dealloc];
}

- (GameState *) doSelected:(SelectedNode *) label {
	PongVader *pv = [PongVader getInstance];
	GameState *next = self;
	if ([label.labelname isEqualToString:@"REPLAY LEVEL"]) {
		for (int i = 0; i < 2; i++) {
			[pv.player[i] resetChain];
			[pv.player[i] restoreLastLevelScore];
		}
		[pv.settings set:@"lastLevel" toInt:curLevel];
		next = [[[StateGetReady alloc] init] autorelease];
	}
	if ([label.labelname isEqualToString:@"MAIN MENU"]) {
		next = [[[StateMainMenu alloc] init] autorelease];
	}
	else if ([label.labelname isEqualToString:@"START OVER"]) {
		[FlurryAPI logEvent:@"NEWGAME"];
		curLevel = 0;
		[pv.settings set:@"lastLevel" toInt:0];
		pv.gameBeat = NO;
		for (int i = 0; i < 2; i++) {
			[pv.player[i] resetPropsNewGame];
		}
		next = [[[StateSettingsMenu alloc] init] autorelease];
	}
	else if ([label.labelname isEqualToString:@"HELP"]) {
		[FlurryAPI logEvent:@"CHECKED_INFO"];
		next = [[[StateInfo alloc] init] autorelease];
	}
	else if ([label.labelname isEqualToString:@"TOP SCORES"]) {
		[FlurryAPI logEvent:@"CHECKED_OF"];	
		if ([PongVader getInstance].OFstarted) {
			[OpenFeint launchDashboardWithHighscorePage:@"438984"];
		}
	}
	else if ([label.labelname isEqualToString:@"POST SCORE"]) {
		BOOL p1h = [[pv.settings get:@"Player1Type"] isEqualToString:@"HUMAN"];
		BOOL p2h = [[pv.settings get:@"Player2Type"] isEqualToString:@"HUMAN"];
		[FlurryAPI logEvent:@"POSTED_SCORE"];	
		if ([PongVader getInstance].OFstarted) {
			int combScore = (p1h?pv.player[0].score:0) + (p2h?pv.player[1].score:0);
			[OFSocialNotificationService sendWithText:[NSString stringWithFormat:@"scored %d points while saving the world from PongVaders. http://bit.ly/koduco", combScore] imageNamed:@"default"];
			[OFAchievementService updateAchievement:BIG_BALLER andPercentComplete:100 andShowNotification:YES];
		}
	} else if ([label.labelname isEqualToString:@"BUY"]) {
		next = [[[StatePurchase alloc] initWithNextState:[self class]] autorelease];
	}
	
	if (next != self) {
		if ([pv.settings getInt:@"EpisodesBought"] == 1) {
			[self changeTo:next after:MENU_TRANSITION_PAUSE];
		}
		else {
			[self changeTo:[[[StateAd alloc] initWithHighFreq: NO nextState:next] autorelease] after:MENU_TRANSITION_PAUSE];
		}
	}
	return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView == appStoreAlert) {
		switch(buttonIndex) {
			case 0:
				break;
			case 1:
				//[FlurryAPI logEvent:@"ILoveThisGame"];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=388469398&mt=8"]];
				break;
		}
	}
	else if (alertView == signupAlert) {
		switch(buttonIndex) {
			case 0:
				break;
			case 1:
				//[FlurryAPI logEvent:@"ILoveThisGame"];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://koduco.com/signup"]];
				break;
		}
	}
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	SelectedNode *label = [_labels objectAtIndex:0];
	if (!label.selected) {
		label.node.scale = 1.125+(0.125)*sin(timeElapsed*1.5);
	}
	return [super doTimer:dTime];
}

@end

@implementation StateInfo

- (id) init {
	if ((self == [super init])) {
		modalView = [[ModalWebView alloc] init];
		modalView.linkdelegate = self;
		appStoreAlert = [[UIAlertView alloc] initWithTitle:@"To the App Store…" message:@"You are headed to the Apple App Store, hopefully to write us a great review. (Thanks.)" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
		[appStoreAlert addButtonWithTitle:@"Let's do this."];
	}
	return self;
}

- (void) dealloc {
	[returnState release];
	[modalView release];
	[appStoreAlert release];
	[super dealloc];
}

- (void) enter {
	returnState = [lastState retain];
	
	[[OverlayViewController sharedController] show];
	UIWebView *webView = [[[UIWebView alloc] init] autorelease];
	
	
	//NSString *htmlIndex = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
//	NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
	//[webView loadHTMLString:htmlIndex baseURL:baseURL];

	//NSURL *nsurl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]];
	[webView loadRequest:[NSURLRequest requestWithURL:
						  [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"]
									 isDirectory:NO]]];
	[modalView launchWithTitle:@"" 
					andView:webView 
			 fromController:[OverlayViewController sharedController] 
			checkReachable:NO
			whenDonePerform:@selector(done)
						 on:self];
}

- (void) done {
	[[OverlayViewController sharedController] hide];
	[GameState handleEvent:returnState];
}

- (BOOL) shouldLoad:(NSURL *)url {
	if([[url scheme] isEqualToString:@"file"]) {
		return YES;
	} else if([[url scheme] isEqualToString:@"koduco"])
    {
        NSArray *parts = [[url host] componentsSeparatedByString:@"."];
        NSString *methodStr = [parts objectAtIndex:0];
        NSString *objectStr = [parts objectAtIndex:1];
        NSLog(@"called: %@.%@", methodStr, objectStr);

        if([methodStr isEqualToString:@"launch"])
        {
			if([objectStr isEqualToString:@"love"]) 
			{
				[appStoreAlert show];
			} 
			/* can't call a modal view from a modal view :(
			else if([objectStr isEqualToString:@"hate"]) 
			{
				[FlurryAPI logEvent:@"SomethingsWrong"];
				webView = [[[UIWebView alloc] init] autorelease];
				[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://checkers360.koduco.com/feedback/bug"]]];
				[modalView launchWithTitle:@"Checkers 360 Feedback" andView:webView fromController: self checkReachable: YES];
			}
			 */
		}
        return NO;
    } else {
		if (![Reachable connectedToNetwork]) {
			[[[[UIAlertView alloc] initWithTitle:@"Network not available" message:@"You need to be in range of your cellular carrier's network, or a wifi network." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
			return NO;	
		} else {
			return YES;	
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch(buttonIndex) {
		case 0:
			break;
		case 1:
			if (![Reachable connectedToNetwork]) {
				[[[[UIAlertView alloc] initWithTitle:@"Network not available" message:@"You need to be in range of your cellular carrier's network, or a wifi network to provide feedback." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
			} else {
				[FlurryAPI logEvent:@"ILoveThisGame"];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=388469398&mt=8"]];
			}
			break;
	}
}

@end

@implementation StateMoreGames

- (GameState *) doTimer:(CFTimeInterval)dTime {
	if (![Reachable connectedToNetwork]) {
		[[[[UIAlertView alloc] initWithTitle:@"Network not available" message:@"You need to be in range of your cellular carrier's network, or a wifi network." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
	} else {
		[FlurryAPI logEvent:@"MoreGames"];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://koduco.com/ourgames"]];
	}
	return [[[StateMainMenu alloc] init] autorelease];	
}
@end


@implementation StateGetReady
@synthesize shouldClearFirst;

- (id) init {
	if ((self = [super init])) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		PongVader *pv = [PongVader getInstance];
		
		NSString *l1 = nil;
		NSString *l2 = nil;
		
		switch (curLevel) {
			case 0: l1 = @"WORK TOGETHER"; l2 = @"DEFEAT THE INVADERS"; break;
			case 1: l1 = @"LEVEL 02  GET READY"; l2 = @"BOXERS OR BRIEFS"; break;
			case 2: l1 = @"LEVEL 03  GET READY"; l2 = @"1972"; break;
			case 3: l1 = @"LEVEL 04  GET READY"; l2 = @"CLOCKWORK"; break;
			case 4: l1 = @"LEVEL 05  GET READY"; l2 = @"NO ESCAPE"; break;
			case 5: l1 = @"LEVEL 06  GET READY"; l2 = @"LABYRINTH"; break;
			case 6: l1 = @"LEVEL 07  GET READY"; l2 = @"GUTTERBALL"; break;
			case 7: l1 = @"LEVEL 08  GET READY"; l2 = @"KEY"; break;
			case 8: l1 = @"LEVEL 09  GET READY"; l2 = @"FISH IN A BARREL"; break;
			case 9: l1 = @"LEVEL 10  GET READY"; l2 = @"PEACE"; break;
			case 10: l1 = @"WARNING ??? DETECTED"; l2 = @"NEEDLE IN A CAMEL'S EYE"; break;
			case 11: l1 = @"LEVEL 11  GET READY"; l2 = @"SIZZURP"; break;
			case 12: l1 = @"LEVEL 12  GET READY"; l2 = @"PACHINKO"; break;
			case 13: l1 = @"LEVEL 13  GET READY"; l2 = @"1978"; break;
			case 14: l1 = @"LEVEL 14  GET READY"; l2 = @"WEAKEST LINK"; break;
			case 15: l1 = @"LEVEL 15  GET READY"; l2 = @"PASTIES"; break;
			case 16: l1 = @"LEVEL 16  GET READY"; l2 = @"STEADY HANDS"; break;
			case 17: l1 = @"LEVEL 17  GET READY"; l2 = @"ELECTRIC SLIDE"; break;
			case 18: l1 = @"LEVEL 18  GET READY"; l2 = @"ON THE FLIPSIDE"; break;
			case 19: l1 = @"LEVEL 19  GET READY"; l2 = @"ESCALATOR TO HEAVEN"; break;
			case 20: l1 = @"LEVEL 20  GET READY"; l2 = @"SHINE"; break;
			case 21: l1 = @"WARNING ??? DETECTED"; l2 = @"MASSIVE DAMAGE"; break;
				case 22: l1 = @"LEVEL 21  GET READY"; l2 = @"GIMME SHELTER"; break;
				case 23: l1 = @"LEVEL 22  GET READY"; l2 = @"CONVEYOR"; break;
				case 24: l1 = @"LEVEL 23  GET READY"; l2 = @"SO META"; break;
				case 25: l1 = @"LEVEL 24  GET READY"; l2 = @"LOCKBOX"; break;
				case 26: l1 = @"LEVEL 25  GET READY"; l2 = @"BOMBS AWAY"; break;
				case 27: l1 = @"LEVEL 26  GET READY"; l2 = @"SUPER ASTRO BALL"; break;
				case 28: l1 = @"LEVEL 27  GET READY"; l2 = @"GALACTIC INTRUDERS"; break;
				case 29: l1 = @"LEVEL 28  GET READY"; l2 = @"WHOPPER"; break;
				case 30: l1 = @"LEVEL 29  GET READY"; l2 = @"PANIC BOMBER"; break;
				case 31: l1 = @"LEVEL 30  GET READY"; l2 = @"LAST STRAW"; break;
				case 32: l1 = @"WARNING ??? DETECTED"; l2 = @"BE PRAYING BE PRAYING BE PRAYING BE PRAYING"; break;
			default: l1 = @"Level X Get Ready"; break;
		}
				
		
		if (_IPAD) {
			_label[0] = [[CCLabelBMFont bitmapFontAtlasWithString:l1 fntFile:pv.mediumFont] retain];
			_label[0].position = ccp(winSize.width/2+1000, winSize.height/2-(l2?200:250));

			[_label[0] runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2-(l2?200:250))]]];
			
			_label[1] = [[CCLabelBMFont bitmapFontAtlasWithString:l1 fntFile:pv.mediumFont] retain];
			_label[1].position = ccp(winSize.width/2-1000, winSize.height/2+(l2?200:250));
			_label[1].rotation = 180;
			[_label[1] runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2+(l2?200:250))]]];
			
			if (l2) {
				_label[2] = [[CCLabelBMFont bitmapFontAtlasWithString:l2 fntFile:pv.mediumFont] retain];
				_label[2].position = ccp(winSize.width/2+1000, winSize.height/2-250);
				[_label[2] runAction:
				 [CCEaseExponentialOut actionWithAction:
				  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2-250)]]];
				
				_label[3] = [[CCLabelBMFont bitmapFontAtlasWithString:l2 fntFile:pv.mediumFont] retain];
				_label[3].position = ccp(winSize.width/2-1000, winSize.height/2+250);
				_label[3].rotation = 180;
				[_label[3] runAction:
				 [CCEaseExponentialOut actionWithAction:
				  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2+250)]]];
			}
		}
		else {
			_label[0] = [[CCLabelBMFont bitmapFontAtlasWithString:l1 fntFile:pv.mediumFont] retain];
			_label[0].position = ccp(winSize.width/2+1000, winSize.height/2-125);
			[_label[0] runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2-125)]]];
			
			_label[1] = [[CCLabelBMFont bitmapFontAtlasWithString:l1 fntFile:pv.mediumFont] retain];
			_label[1].position = ccp(winSize.width/2-1000, winSize.height/2+125);
			_label[1].rotation = 180;
			[_label[1] runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2+125)]]];
			
			if (l2) {
				_label[2] = [[CCLabelBMFont bitmapFontAtlasWithString:l2 fntFile:pv.mediumFont] retain];
				_label[2].position = ccp(winSize.width/2+1000, winSize.height/2-150);
				[_label[2] runAction:
				 [CCEaseExponentialOut actionWithAction:
				  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2-150)]]];
				
				_label[3] = [[CCLabelBMFont bitmapFontAtlasWithString:l2 fntFile:pv.mediumFont] retain];
				_label[3].position = ccp(winSize.width/2-1000, winSize.height/2+150);
				_label[3].rotation = 180;
				[_label[3] runAction:
				 [CCEaseExponentialOut actionWithAction:
				  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2+150)]]];
			}
		}
		
		
		shouldClearFirst = YES;
	}
	return self;
}

- (void) enter {
	PongVader *pv = [PongVader getInstance];
	for (int i=0; i<4; i++) if (_label[i]) [pv addChild:_label[i]];
	
	if (shouldClearFirst) {
		[pv clearScene];
		[pv resetScene];
	}
	[pv clearTouches];
	[pv showPaddles:YES];
	[pv setDifficulty: curLevel];
	
	NSString *music;
	int bpm;
	
	//[pv.settings set:pv.player[0].scoreKey toInt:0];
	//[pv.settings set:pv.player[1].scoreKey toInt:0];
	
	switch (curLevel) {
		case 0:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelMadison alloc] init] autorelease] after:0]];
			music = pv.track1; bpm = 120;
			pv.bossTime = NO;
			break;
		case 1:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelBoxers alloc] init] autorelease] after:0]];
			music = pv.track1; bpm = 120;
			pv.bossTime = NO;
			break;
		case 2:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevel1972 alloc] init] autorelease] after:0]];
			music = pv.track1; bpm = 120;
			pv.bossTime = NO;
			break;
		case 3:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelClockwork alloc] init] autorelease] after:0]];
			music = pv.track1; bpm = 120;
			pv.bossTime = NO;
			break;			
		case 4:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelNoEscape alloc] init] autorelease] after:0]];
			music = pv.track1; bpm = 120;
			pv.bossTime = NO;
			break;
		case 5:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelLabyrinth alloc] init] autorelease] after:0]];
			music = pv.track1; bpm = 120;
			pv.bossTime = NO;
			break;
		case 6:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelGutter alloc] init] autorelease] after:0]];
			music = pv.track1; bpm = 120;
			pv.bossTime = NO;
			break;
		case 7:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelKey alloc] init] autorelease] after:0]];
			music = pv.track1; bpm = 120;
			pv.bossTime = NO;
			break;
		case 8:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelFish alloc] init] autorelease] after:0]];
			music = pv.track1; bpm = 120;
			pv.bossTime = NO;
			break;
		case 9:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelPeace alloc] init] autorelease] after:0]];
			music = pv.track1; bpm = 120;
			pv.bossTime = NO;
			break;
		case 10:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateBattlePro alloc] init] autorelease] after:0]];
			music = pv.track3; bpm = 110;
			pv.bossTime = YES;
			break;
		case 11:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelSizzurp alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 12:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelPachinko alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 13:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevel1978 alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 14:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelWeakest alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 15:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelPasties alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 16:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelSteady alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 17:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelElectricSlide alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 18:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelFlipside alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 19:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelEscalator alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 20:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelShine alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 21:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateBattle1 alloc] init] autorelease] after:0]];
			music = pv.track3; bpm = 110;
			pv.bossTime = YES;
			break;
			
		case 22:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelGimmeShelter alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 23:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelConveyor alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 24:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelSoMeta alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 25:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelLockbox alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 26:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelBombsAway alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 27:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelSuperAstroBall alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 28:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelGalacticIntruders alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 29:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelWhopper alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 30:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelPanicBomber alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 31:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateLevelLastStraw alloc] init] autorelease] after:0]];
			music = pv.track4; bpm = 110;
			pv.bossTime = NO;
			break;
		case 32:
			[[BeatSequencer getInstance] addEvent:[ChangeStateEvent eventOnBeat:6 to:[[[StateBattle2 alloc] init] autorelease] after:0]];
			music = pv.track3; bpm = 110;
			pv.bossTime = YES;
			break;
		default:
			music = pv.track1; bpm = 120;
			pv.bossTime = NO;
			break;
	}
	
	[[BeatSequencer getInstance] addResponder:pv.starfield];
	[[BeatSequencer getInstance] startWithSong:music andBPM:bpm shifted: -0.1];
	
	// set Ep1 or Ep2 as played if entering first level
	if (curLevel == EPISODE_ONE_LEVEL) {
		[pv.settings set:@"PlayedEpOne" toInt:1];
	}
	else if (curLevel == EPISODE_TWO_LEVEL) {
		[pv.settings set:@"PlayedEpTwo" toInt:1];
	}
	
	pv.accelNormalized = NO;
	
}

- (void) leave {
	CGSize winSize = [[CCDirector sharedDirector] winSize];
//	PongVader *pv = [PongVader getInstance];
	//[pv removeChild:_label cleanup:YES];
//	[pv removeChild:_label2 cleanup:YES];
	
	CCSequence *label1removal = [CCSequence actions:
								 [CCEaseExponentialOut actionWithAction:
								  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2-1000, winSize.height/2-(_label[2]?200:250))]],
								 [CCCallFuncN actionWithTarget:self selector:@selector(cleanupLabel:)], nil];
	
	[_label[0] runAction: label1removal];
	
	CCSequence *label2removal = [CCSequence actions:
								 [CCEaseExponentialOut actionWithAction:
								  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2+1000, winSize.height/2+(_label[2]?200:250))]],
								 [CCCallFuncN actionWithTarget:self selector:@selector(cleanupLabel:)], nil];
	
	[_label[1] runAction: label2removal];
	
	if (_label[2]) {
		CCSequence *label3removal = [CCSequence actions:
									 [CCEaseExponentialOut actionWithAction:
									  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2-1000, winSize.height/2-250)]],
									 [CCCallFuncN actionWithTarget:self selector:@selector(cleanupLabel:)], nil];
		
		[_label[2] runAction: label3removal];
		
		CCSequence *label4removal = [CCSequence actions:
									 [CCEaseExponentialOut actionWithAction:
									  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2+1000, winSize.height/2+250)]],
									 [CCCallFuncN actionWithTarget:self selector:@selector(cleanupLabel:)], nil];
		
		[_label[3] runAction: label4removal];
	}
}

/*
- (GameState *) doTimer:(CFTimeInterval)dTime {
	if (timeElapsed < 3) {
		[[PongVader getInstance] doTick: dTime];
		return self;
	} else {
		switch (curLevel) {
			case 0:	
				curLevel++;
				return [[[StateLevel1 alloc] init] autorelease];
				break;
			case 1:	
				curLevel++;
				return [[[StateLevel2 alloc] init] autorelease];
				break;
			case 2:	
				curLevel = 0;
				return [[[StateLevel3 alloc] init] autorelease];
				break;
			case 9:	
				curLevel = 0;
				return [[[StateLevel9 alloc] init] autorelease];
				break;
		}
	}
	return self;
}
 */

- (GameState *) doTimer:(CFTimeInterval)dTime {
	[[BeatSequencer getInstance] doTimer:dTime];
	[[PongVader getInstance] doTick: dTime];	
	return self;
}


- (GameState *) doStartTouch:(NSSet *)touches withEvent:(UIEvent *)event {
	[[PongVader getInstance] doTouchesBegan:touches withEvent:event];	
	return self;
}

- (GameState *) doDrag:(NSSet *)touches withEvent:(UIEvent *)event {
	[[PongVader getInstance] doTouchesMoved:touches withEvent:event];	
	return self;
}

- (GameState *) doEndTouch:(NSSet *)touches withEvent:(UIEvent *)event {
	[[PongVader getInstance] doTouchesEnded:touches withEvent:event];	
	return self;
}

@end

@implementation StatePostPlaying

- (id) initWithString1: (NSString *) l1 andString2: (NSString *) l2 {
	if ((self = [super init])) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		PongVader *pv = [PongVader getInstance];
		
		if (_IPAD) {
			_label[0] = [[CCLabelBMFont bitmapFontAtlasWithString:l1 fntFile:pv.mediumFont] retain];
			_label[0].position = ccp(winSize.width/2+1000, winSize.height/2-(l2?200:250));
			
			[_label[0] runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2-(l2?200:250))]]];
			
			_label[1] = [[CCLabelBMFont bitmapFontAtlasWithString:l1 fntFile:pv.mediumFont] retain];
			_label[1].position = ccp(winSize.width/2-1000, winSize.height/2+(l2?200:250));
			_label[1].rotation = 180;
			[_label[1] runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2+(l2?200:250))]]];
			
			if (l2) {
				_label[2] = [[CCLabelBMFont bitmapFontAtlasWithString:l2 fntFile:pv.mediumFont] retain];
				_label[2].position = ccp(winSize.width/2+1000, winSize.height/2-250);
				[_label[2] runAction:
				 [CCEaseExponentialOut actionWithAction:
				  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2-250)]]];
				
				_label[3] = [[CCLabelBMFont bitmapFontAtlasWithString:l2 fntFile:pv.mediumFont] retain];
				_label[3].position = ccp(winSize.width/2-1000, winSize.height/2+250);
				_label[3].rotation = 180;
				[_label[3] runAction:
				 [CCEaseExponentialOut actionWithAction:
				  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2+250)]]];
			}
		}
		else {
			_label[0] = [[CCLabelBMFont bitmapFontAtlasWithString:l1 fntFile:pv.mediumFont] retain];
			_label[0].position = ccp(winSize.width/2+1000, winSize.height/2-125);
			[_label[0] runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2-125)]]];
			
			_label[1] = [[CCLabelBMFont bitmapFontAtlasWithString:l1 fntFile:pv.mediumFont] retain];
			_label[1].position = ccp(winSize.width/2-1000, winSize.height/2+125);
			_label[1].rotation = 180;
			[_label[1] runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2+125)]]];
			
			if (l2) {
				_label[2] = [[CCLabelBMFont bitmapFontAtlasWithString:l2 fntFile:pv.mediumFont] retain];
				_label[2].position = ccp(winSize.width/2+1000, winSize.height/2-150);
				[_label[2] runAction:
				 [CCEaseExponentialOut actionWithAction:
				  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2-150)]]];
				
				_label[3] = [[CCLabelBMFont bitmapFontAtlasWithString:l2 fntFile:pv.mediumFont] retain];
				_label[3].position = ccp(winSize.width/2-1000, winSize.height/2+150);
				_label[3].rotation = 180;
				[_label[3] runAction:
				 [CCEaseExponentialOut actionWithAction:
				  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2, winSize.height/2+150)]]];
			}
		}	
		
	}
	return self;
}

- (void) enter {
	PongVader *pv = [PongVader getInstance];
	
	[pv clearBalls];
	[pv clearPowerups];
	
	for (int i=0; i<4; i++) if (_label[i]) [pv addChild:_label[i]];
}

- (void) leave {
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	CCSequence *label1removal = [CCSequence actions:
								 [CCEaseExponentialOut actionWithAction:
								  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2-1000, winSize.height/2-(_label[2]?200:250))]],
								 [CCCallFuncN actionWithTarget:self selector:@selector(cleanupLabel:)], nil];
	
	[_label[0] runAction: label1removal];
	
	CCSequence *label2removal = [CCSequence actions:
								 [CCEaseExponentialOut actionWithAction:
								  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2+1000, winSize.height/2+(_label[2]?200:250))]],
								 [CCCallFuncN actionWithTarget:self selector:@selector(cleanupLabel:)], nil];
	
	[_label[1] runAction: label2removal];
	
	if (_label[2]) {
		CCSequence *label3removal = [CCSequence actions:
									 [CCEaseExponentialOut actionWithAction:
									  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2-1000, winSize.height/2-250)]],
									 [CCCallFuncN actionWithTarget:self selector:@selector(cleanupLabel:)], nil];
		
		[_label[2] runAction: label3removal];
		
		CCSequence *label4removal = [CCSequence actions:
									 [CCEaseExponentialOut actionWithAction:
									  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:ccp(winSize.width/2+1000, winSize.height/2+250)]],
									 [CCCallFuncN actionWithTarget:self selector:@selector(cleanupLabel:)], nil];
		
		[_label[3] runAction: label4removal];
	}
	[[BeatSequencer getInstance] end];
	[[BeatSequencer getInstance] clearResponders];
	[[BeatSequencer getInstance] reset];
	[[BeatSequencer getInstance] clearEvents];
}


- (GameState *) doTimer:(CFTimeInterval)dTime {
	if ([SimpleAudioEngine sharedEngine].backgroundMusicVolume > 0) 
		[SimpleAudioEngine sharedEngine].backgroundMusicVolume -= dTime/MUSIC_FADE_TIME;
	return self;
}

@end


@implementation StateDeath

- (id) init {
	PongVader *pv = [PongVader getInstance];
	NSString *deathMsg1, *deathMsg2 = @"MISSED TOO MANY BALLS";
	if ([pv.planet[0] isDead]) {
		deathMsg1 = _IPAD?@"PLAYER ONE'S PLANET DESTROYED":@"P1  PLANET  DESTROYED";
	} else {
		deathMsg1 = _IPAD?@"PLAYER TWO'S PLANET DESTROYED":@"P2  PLANET  DESTROYED";
	}
	if ((self = [super initWithString1:deathMsg1 andString2:deathMsg2])) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"lose.wav"];
	}
	return self;
}
- (GameState *) doTimer:(CFTimeInterval)dTime {
	[super doTimer:dTime];
	if (timeElapsed < POST_GAME_PAUSE) return self;
	else return [[[StateLoseMenu alloc] init] autorelease];
}
@end

@implementation StateWin

- (id) init {
	if ((self = [super initWithString1:@"VICTORY" andString2:nil])) {
	}
	return self;
}
- (void) enter {
	PongVader *pv = [PongVader getInstance];

	curLevel ++;
	if (curLevel == EPISODE_ONE_LEVEL) {
		curLevel = 50;
		pv.gameBeat = YES;
	} else if (curLevel == EPISODE_TWO_LEVEL) {
		curLevel = 60;
		pv.gameBeat = YES;
	} else if (curLevel >= numLevels) {
		curLevel = 70;
		pv.gameBeat = YES;
	}
	
	[pv.settings set:@"lastLevel" toInt:curLevel];
	for (int i = 0; i < 2; i++) {
		[pv.player[i] setLastLevelScore];
		[pv.player[i] setLastLevelChain];
	}
	
	[super enter];
	
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	[super doTimer:dTime];
	if (timeElapsed < POST_GAME_PAUSE) return self;
	else {
		if (curLevel == 50) {
			PongVader *pv = [PongVader getInstance];
			if (!PV_UNIVERSAL || BOUGHT_FULLGAME || ([pv.settings getInt:@"EpisodesBought"] == 1)) {
				return [[[StateOutroPro alloc] init] autorelease];
			}
			else {
				return [[[StateOutroProUpsell alloc] init] autorelease];
			}
			
		}
		else if (curLevel == 60) {
			return [[[StateOutro alloc] init] autorelease];
		} 
		else if (curLevel == 70) {
			return [[[StateOutroEp2 alloc] init] autorelease];
		}
		else
			return [[[StateTransition alloc] init] autorelease];
	}
}
@end

@implementation StateTransition

- (void) enter {
	PongVader *pv = [PongVader getInstance];
	if (!pv.sentRequest && curLevel >= 12 && [pv.settings getInt:@"Review12"] == 0 && [Reachable connectedToNetwork]) {
		pv.sentRequest = YES;
		[pv.settings set:@"Review12" toInt:1];
		appStoreAlert = [[UIAlertView alloc] initWithTitle:@"To the App Store…" message:@"Wow, you've come a long way! How about taking a quick break? If you're enjoying this game, we'd really appreciate a 5 star review!" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:nil];
		[appStoreAlert addButtonWithTitle:@"Let's do this."];	
		[appStoreAlert show];
	} else if (!pv.sentRequest && curLevel >= 6 && [pv.settings getInt:@"Review6"] == 0 && [Reachable connectedToNetwork]) {
		pv.sentRequest = YES;
		[pv.settings set:@"Review6" toInt:1];
		appStoreAlert = [[UIAlertView alloc] initWithTitle:@"To the App Store…" message:@"Thanks for playing PongVaders! If you are enjoying the game, please consider writing us a 5 star review in the AppStore!" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:nil];
		[appStoreAlert addButtonWithTitle:@"Let's do this."];
		[appStoreAlert show];
	}
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch(buttonIndex) {
		case 0:
			break;
		case 1:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=388469398&mt=8"]];
 			break;
	}
	appStoreAlert = nil;
}


- (GameState *) doTimer:(CFTimeInterval)dTime {
	if (appStoreAlert) {
		return self;
	} 
	else if (([[PongVader getInstance].settings getInt:@"EpisodesBought"] == 1)) {
		return [[[StateGetReady alloc] init] autorelease];
	}
	else {
		return [[[StateAd alloc] initWithHighFreq: YES nextState: [[[StateGetReady alloc] init] autorelease]] autorelease];
	}
}

@end


@implementation StatePlaying

@synthesize shouldClearFirst;

- (id) init {
	if ((self = [super init])) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		PongVader *pv = [PongVader getInstance];
		
		scores[0] = [[CCLabelBMFont bitmapFontAtlasWithString:@"0" fntFile:pv.mediumFont] retain];
		scores[1] = [[CCLabelBMFont bitmapFontAtlasWithString:@"0" fntFile:pv.mediumFont] retain];
		
		scores[0].rotation = 0;
		scores[1].rotation = 180;
		[scores[0] setAnchorPoint:ccp(0, 0.5f)];
		[scores[1] setAnchorPoint:ccp(0, 0.5f)];
		
		lastScores[0] = 0;
		lastScores[1] = 0;
		
		// points labels
		scoreLabels[0] = [[CCLabelBMFont bitmapFontAtlasWithString:@"SCORE:" fntFile:pv.mediumFont] retain];
		scoreLabels[1] = [[CCLabelBMFont bitmapFontAtlasWithString:@"SCORE:" fntFile:pv.mediumFont] retain];
		
		scoreLabels[0].rotation = 0;
		scoreLabels[1].rotation = 180;
		[scoreLabels[0] setAnchorPoint:ccp(0, 0.5f)];
		[scoreLabels[1] setAnchorPoint:ccp(0, 0.5f)];
		
//		// max chains
//		maxChains[0] = [[CCLabelBMFont bitmapFontAtlasWithString:@"MAX: 0" fntFile:pv.mediumFont] retain];
//		maxChains[1] = [[CCLabelBMFont bitmapFontAtlasWithString:@"MAX: 0" fntFile:pv.mediumFont] retain];
//		maxChains[0].position = ccp(200, 65);
//		maxChains[1].position = ccp(winSize.width-200, winSize.height-65);
//		maxChains[0].rotation = 0;
//		maxChains[1].rotation = 180;
//		[maxChains[0] setAnchorPoint:ccp(1, 0.5f)];
//		[maxChains[1] setAnchorPoint:ccp(1, 0.5f)];
		
		// current chains
		curChains[0] = [[CCLabelBMFont bitmapFontAtlasWithString:@"CHAIN: 0" fntFile:pv.mediumFont] retain];
		curChains[1] = [[CCLabelBMFont bitmapFontAtlasWithString:@"CHAIN: 0" fntFile:pv.mediumFont] retain];
		
		curChains[0].rotation = 0;
		curChains[1].rotation = 180;
		[curChains[0] setAnchorPoint:ccp(0, 0.5f)];
		[curChains[1] setAnchorPoint:ccp(0, 0.5f)];
		
		//pauseLabels[0] = [[CCLabelBMFont bitmapFontAtlasWithString:@"=" fntFile:pv.largeFont] retain];
		//pauseLabels[1] = [[CCLabelBMFont bitmapFontAtlasWithString:@"=" fntFile:pv.largeFont] retain];
		//pauseLabels[0].rotation = 90;
		//pauseLabels[1].rotation = 270;
		
		pauseLabels[0] = [[CCSprite spriteWithSpriteFrameName:@"pause-pv.png"] retain];
		pauseLabels[1] = [[CCSprite spriteWithSpriteFrameName:@"pause-pv.png"] retain];
		
		if (_IPAD) {
			pauseLabels[0].scale = 2.0;
			pauseLabels[1].scale = 2.0;
		}
		
		[pauseLabels[0] setAnchorPoint:ccp(0, 0.5f)];
		[pauseLabels[1] setAnchorPoint:ccp(0, 0.5f)];
		
		if _IPAD{
			bulletLabels[0] = [[CCLabelBMFont bitmapFontAtlasWithString:@"TILT IPAD TO STEER BALL" fntFile:pv.mediumFont] retain];
			bulletLabels[1] = [[CCLabelBMFont bitmapFontAtlasWithString:@"TILT IPAD TO STEER BALL" fntFile:pv.mediumFont] retain];
		}
		else {
			bulletLabels[0] = [[CCLabelBMFont bitmapFontAtlasWithString:@"TILT TO STEER BALL" fntFile:pv.mediumFont] retain];
			bulletLabels[1] = [[CCLabelBMFont bitmapFontAtlasWithString:@"TILT TO STEER BALL" fntFile:pv.mediumFont] retain];
		}
		bulletLabels[0].color = ccc3(255,0,0);
		bulletLabels[1].color = ccc3(255,0,0);
		bulletLabels[1].rotation = 180;
		
		hasEnteredBulletTime = NO;
		btLabelDisplayed = NO;
		
		// conditionally position labels	
		if (_IPAD) {
			scores[0].position = ccp(winSize.width-175, 65);
			scores[1].position = ccp(175, winSize.height-65);
			scoreLabels[0].position = ccp(winSize.width-175, 90);
			scoreLabels[1].position = ccp(175, winSize.height-90);
			curChains[0].position = ccp(20, 90);
			curChains[1].position = ccp(winSize.width-20, winSize.height-90);
			bulletLabels[1].position = ccp(winSize.width/2-1000, winSize.height/2+250);
			bulletLabels[0].position = ccp(winSize.width/2+1000, winSize.height/2-250);
			pauseLabels[0].position = ccp(20, 40);
			pauseLabels[1].position = ccp(winSize.width-80, winSize.height-40);		}
		else {
			scores[0].position = ccp(winSize.width-100, 25);
			scores[1].position = ccp(100, winSize.height-25);
			scoreLabels[0].position = ccp(winSize.width-100, 45);
			scoreLabels[1].position = ccp(100, winSize.height-45);
			curChains[0].position = ccp(10, 45);
			curChains[1].position = ccp(winSize.width-10, winSize.height-45);
			bulletLabels[1].position = ccp(winSize.width/2-1000, winSize.height/2+125);
			bulletLabels[0].position = ccp(winSize.width/2+1000, winSize.height/2-125);
			pauseLabels[0].position = ccp(10, 20);
			pauseLabels[1].position = ccp(winSize.width-40, winSize.height-20);
		}
		
		//pauseLabels[0].scale = 1.5;
		//pauseLabels[1].scale = 1.5;
		
		isPaused = NO;
		touchingPause = NO;
		shouldClearFirst = YES;
		
	}
	return self;
}

- (void) dealloc {
	[scores[0] release];
	[scores[1] release];
	[scoreLabels[0] release];
	[scoreLabels[1] release];
//	[maxChains[0] release];
//	[maxChains[1] release];
	[curChains[0] release];
	[curChains[1] release];
	[bulletLabels[0] release];
	[bulletLabels[1] release];
	[pauseLabels[0] release];
	[pauseLabels[1] release];
	[super dealloc];
}

- (void) enter {
	PongVader *pv = [PongVader getInstance];
	if ([pv.settings getInt:@"Scoreboards"] == 1) {
	
		if ([[pv.settings get:@"Player1Type"] isEqualToString:@"HUMAN"]) {
			[pv addChild:scores[0]];
			[pv addChild:scoreLabels[0]];
			//[pv addChild:maxChains[0]];
			[pv addChild:curChains[0]];
		}		

		if ([[pv.settings get:@"Player2Type"] isEqualToString:@"HUMAN"]) {
			[pv addChild:scores[1]];
			[pv addChild:scoreLabels[1]];
			//[pv addChild:maxChains[1]];
			[pv addChild:curChains[1]];
		}
	}
	
	[pv addChild:bulletLabels[0]];
	[pv addChild:bulletLabels[1]];
	
	[pv addChild:pauseLabels[0]];
	[pv addChild:pauseLabels[1]];
	
	touchingPause = NO;
	
	//for (int i = 0; i < 2; i++) {
//		[pv.player[i] setLastLevelScore];
//		[pv.player[i] setLastLevelChain];
//	}
//	[pv.settings set:@"lastLevel" toInt:curLevel];
}

- (void) leave {
	PongVader *pv = [PongVader getInstance];
	if ([pv.settings getInt:@"Scoreboards"] == 1) {

		if ([[pv.settings get:@"Player1Type"] isEqualToString:@"HUMAN"]) {
			[pv removeChild:scores[0] cleanup:YES];
			[pv removeChild:scoreLabels[0] cleanup:YES];
			//[pv removeChild:maxChains[0] cleanup:YES];
			[pv removeChild:curChains[0] cleanup:YES];
		}
		
		if ([[pv.settings get:@"Player2Type"] isEqualToString:@"HUMAN"]) {
			[pv removeChild:scores[1] cleanup:YES];
			[pv removeChild:scoreLabels[1] cleanup:YES];
			//[pv removeChild:maxChains[1] cleanup:YES];
			[pv removeChild:curChains[1] cleanup:YES];
		}
	}
	
	btLabelDisplayed = NO;
	
	[pv removeChild:bulletLabels[0] cleanup:YES];
	[pv removeChild:bulletLabels[1] cleanup:YES];
	
	[pv removeChild:pauseLabels[0] cleanup:YES];
	[pv removeChild:pauseLabels[1] cleanup:YES];
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	PongVader *pv = [PongVader getInstance];
	
	if ([pv isGameLost]) return [[[StateDeath alloc] init] autorelease];
	
	if ([pv isGameWon]) return [[[StateWin alloc] init] autorelease];
	
	[pv doTick: dTime];
	
	if (!pv.bulletTime)
		[[BeatSequencer getInstance] doTimer:dTime];
	
	// update score labels
	
	for (int i=0; i<2; i++) {
		
		int curScore = pv.player[i].score;
		int curChain = pv.player[i].chain;
		int maxChain = pv.player[i].maxChain;
		
		if (lastScores[i] != curScore) {
			[scores[i] setString:[NSString stringWithFormat:@"%d", curScore]];
			lastScores[i] = curScore;
		}
		[maxChains[i] setString:[NSString stringWithFormat:@"MAX: %d", maxChain]];
		[curChains[i] setString:[NSString stringWithFormat:@"CHAIN: %d", curChain]];
	}

	if (pv.bulletTime) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		hasEnteredBulletTime = YES;
		// if ball also within inner radius, display labels
		if (pv.innerBulletRadius) {
			btLabelDisplayed = YES;	
		}
		if (btLabelDisplayed) {
		if (_IPAD) {
			bulletLabels[0].position = ccp(winSize.width/2, winSize.height/2-250);
			bulletLabels[1].position = ccp(winSize.width/2, winSize.height/2+250);
		}
		else {
			bulletLabels[0].position = ccp(winSize.width/2, winSize.height/2-120);
			bulletLabels[1].position = ccp(winSize.width/2, winSize.height/2+120);
		}
		}
		
	}
	
	else  {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		btLabelDisplayed = NO;
		if (_IPAD) {
			bulletLabels[0].position = ccp(winSize.width/2 + 1000, winSize.height/2-250);
			bulletLabels[1].position = ccp(winSize.width/2 - 1000, winSize.height/2+250);
		}
		else {
			bulletLabels[0].position = ccp(winSize.width/2 + 1000, winSize.height/2-120);
			bulletLabels[1].position = ccp(winSize.width/2 - 1000, winSize.height/2+120);
		}
		
		
	}
	
	return self;
}

- (GameState *) doStartTouch:(NSSet *)touches withEvent:(UIEvent *)event {
	
	touchingPause = NO;
	
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];

		location = [[CCDirector sharedDirector] convertToGL: location];
			
		if (CGRectContainsPoint([pauseLabels[0] boundingBox], location) ||
			CGRectContainsPoint([pauseLabels[1] boundingBox], location) ) {
			touchingPause = YES;
		}
	} 
	
	if (!touchingPause) {
		[[PongVader getInstance] doTouchesBegan:touches withEvent:event];	
	}
	return self;
}
- (GameState *) doDrag:(NSSet *)touches withEvent:(UIEvent *)event {
	if (touchingPause) return self;
	[[PongVader getInstance] doTouchesMoved:touches withEvent:event];	
	return self;
}
- (GameState *) doEndTouch:(NSSet *)touches withEvent:(UIEvent *)event {

	if (!touchingPause) {
		[[PongVader getInstance] doTouchesEnded:touches withEvent:event];	
	}
		
	GameState *next = self;	
	// detect attempts to pause
	
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];

		location = [[CCDirector sharedDirector] convertToGL: location];
		
		if (touchingPause && (CGRectContainsPoint([pauseLabels[0] boundingBox], location) ||
							  CGRectContainsPoint([pauseLabels[1] boundingBox], location)) ) {
		
			[[SimpleAudioEngine sharedEngine] playEffect:@"redpaddle.wav"];
			isPaused = YES;
			
			next = [[[StatePausedMenu alloc] init] autorelease];
			((StatePausedMenu *) next).shouldClearFirst = NO;
			
		}
	}
	
	touchingPause = NO;
	
	if (next != self) [self changeTo:next after:0];
	return self;
}
@end

@implementation StateMovie
- (id) init {
	if ((self = [super init])) {
		for (int i=0; i<MAX_MOVIE_ACTIONS; i++) times[i] = DBL_MAX;
		curAction = 0;
		PongVader *pv = [PongVader getInstance];
		
		//skiplabel = [[SelectedNode alloc] init];
//		CCLabelBMFont *labelnode = [[CCLabelBMFont bitmapFontAtlasWithString:@"SKIP" fntFile:pv.largeFont] retain];
//		labelnode.color = ccc3(255, 255, 255);
//		labelnode.position = SKIP_POS;
//		skiplabel.selectable = YES;
//		skiplabel.node = labelnode;
		
		skiplabel = [[CCLabelBMFont bitmapFontAtlasWithString:@"SKIP" fntFile:pv.largeFont] retain];
		skiplabel.position = SKIP_POS;
		skiplabel.color = ccc3(255, 255, 255);
				
		NSString *tbubble, *twedge;
		
		if (_IPAD) {
			tbubble = [NSString stringWithString:@"textbubble.png"];
			twedge = [NSString stringWithString:@"textbubblewedge.png"];
		}
		else {
			tbubble = [NSString stringWithString:@"textbubble-low.png"];
			twedge = [NSString stringWithString:@"textbubblewedge-low.png"];
		}
		textBubble = [[CCSprite spriteWithFile:tbubble] retain];
		[textBubble.texture setAliasTexParameters];
		textWedge = [[CCSprite spriteWithFile:twedge] retain];
		[textBubble.texture setAliasTexParameters];
		ltrbox[0] = [[CCSprite spriteWithFile:tbubble] retain];
		[ltrbox[0].texture setAliasTexParameters];
		[ltrbox[0] setColor:ccc3(0, 0, 0)];
		ltrbox[1] = [[CCSprite spriteWithFile:tbubble] retain];
		[ltrbox[1].texture setAliasTexParameters];
		[ltrbox[1] setColor:ccc3(0, 0, 0)];
	}
	return self;
}


-(void) dealloc {
	[skiplabel release];
	[textBubble release];
	[textWedge release];
	[ltrbox[0] release];
	[ltrbox[1] release];
	[super dealloc];
}




- (void) enter {
	CGSize ssz = [CCDirector sharedDirector].winSize;
	PongVader *pv = [PongVader getInstance];
	pv.bossTime = YES;
	
	[[BeatSequencer getInstance] addResponder:pv.starfield];
	[[BeatSequencer getInstance] startWithSong:@"fuzz.mp3" andBPM:114 shifted: -0.1];
	
	int offset;
	
	if _IPAD {
		offset = 56;
	}
	else {
		offset = 28;	
	}

	[ltrbox[0] setPosition:ccp(ssz.width/2.0, offset)];
	[ltrbox[1] setPosition:ccp(ssz.width/2.0, ssz.height-offset)];
	ltrbox[0].scaleX = ssz.width / (float) (offset * 2.0);
	ltrbox[1].scaleX = ssz.width / (float) (offset * 2.0);
	
	ltrbox[0].opacity = 0;
	ltrbox[1].opacity = 0;
	
	[pv showPaddles:NO];
	[pv setDifficulty:1];
	[pv addChild:ltrbox[0]];
	[pv addChild:ltrbox[1]];
	[pv addChild:skiplabel z:100];

	[skiplabel runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCFadeIn actionWithDuration:1.0]]];
	
	[ltrbox[0] runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCFadeIn actionWithDuration:1.0]]];
	
	[ltrbox[1] runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCFadeIn actionWithDuration:1.0]]];
}

- (void) leave {
	PongVader *pv = [PongVader getInstance];
	
	[[BeatSequencer getInstance] end];
	[[BeatSequencer getInstance] clearResponders];
	[[BeatSequencer getInstance] reset];
	[[BeatSequencer getInstance] clearEvents];

	[self clearMessageAndBubble];
	[pv removeChild:ltrbox[0] cleanup: YES];
	[pv removeChild:ltrbox[1] cleanup: YES];
	[pv removeChild:skiplabel cleanup: YES];
}

- (void) leaving {
	id action = [CCPropertyAction actionWithDuration:MUSIC_FADE_TIME key:@"BackgroundVolume" from:1.0 to:0.0];
	[[PongVader getInstance] runAction:action];

	[skiplabel runAction:
	 [CCEaseExponentialIn actionWithAction:
	  [CCFadeOut actionWithDuration:1.0]]];
	
	[ltrbox[0] runAction:
	 [CCEaseExponentialIn actionWithAction:
	  [CCFadeOut actionWithDuration:1.0]]];
	
	[ltrbox[1] runAction:
	 [CCEaseExponentialIn actionWithAction:
	  [CCFadeOut actionWithDuration:1.0]]];
}

-(void) placeBubble:(CGPoint) p rlen: (float) rowlength rc:(int) rowcount {

	[self placeBubble:p rlen:rowlength rc:rowcount sp:1];
}

-(void) placeBubble:(CGPoint) p rlen: (float) rowlength rc:(int) rowcount sp:(int) speaker
{
	PongVader *pv = [PongVader getInstance];
	
//	if _IPAD {
//		textBubble.scaleX = (rowlength*20+25)/128.0;
//		textBubble.scaleY = (rowcount*20+25)/128.0;
//	}
//	else {
//		textBubble.scaleX = (rowlength*12+12)/128.0;
//		textBubble.scaleY = (rowcount*12+12)/128.0;
//	}
	
	textBubble.scaleX = (rowlength*20+25)/128.0;
	textBubble.scaleY = (rowcount*20+25)/128.0;
	
	CGPoint tbs = ccp((int)p.x+textWedge.contentSize.width/2.0, (int) p.y+textWedge.contentSize.height/2.0);
	CGPoint pos = ccp((int)tbs.x+textBubble.scaleX*textBubble.contentSize.width / 2.0, (int) tbs.y+textBubble.scaleY*textBubble.contentSize.height/2.0);
	
	messageLabel.position = pos;
	textBubble.position = pos;
	textWedge.position = tbs;
	
	for (int i=0; i<[[messageLabel children] count]; i++) {
		CCLabelBMFont *line = [[messageLabel children] objectAtIndex:i];
		
		if (speaker == 1) {
			line.color = ccc3(0, 0, 0);	
		}
		else if (speaker == 2) {
			line.color = ccc3(255,0,0);
		}
	}
	
	[pv addChild:textBubble];
	[pv addChild:textWedge];
	[pv addChild:messageLabel];
	[[SimpleAudioEngine sharedEngine] playEffect:@"speech.wav"];
}

-(void) clearMessageAndBubble {
	if (!messageLabel) return;
	[textWedge removeFromParentAndCleanup:YES];
	[textBubble removeFromParentAndCleanup:YES];
	[messageLabel removeFromParentAndCleanup:YES];
	[messageLabel release];
	messageLabel = nil;
}

- (GameState *) doTimer:(CFTimeInterval)dTime
{
	PongVader *pv = [PongVader getInstance];
	[[BeatSequencer getInstance] doTimer:dTime];
	[pv doTick:dTime];
	GameState *next = self;
	for (int i=MAX_MOVIE_ACTIONS-1; i>=curAction; i--) {
		if (timeElapsed >= times[i]) {
			next = [self doAction:curAction];
			curAction++;
		}
	}
	return next;
}

- (GameState *) doAction:(int) action 
{
	return self;
}

- (void) skip {

}

//- (GameState *) doStartTouch:(NSSet *)touches withEvent:(UIEvent *)event {
//	[self doDrag:touches withEvent:event];
//	return self;
//}
//
//- (GameState *) doDrag:(NSSet *)touches withEvent:(UIEvent *)event {
//	for( UITouch *touch in touches ) {
//		CGPoint location = [touch locationInView: [touch view]];
//		location = [[CCDirector sharedDirector] convertToGL: location];
//		
//		if (CGRectContainsPoint(SKIP_RECT, location)) {
//			if (!skiplabel.selected) {
//				[skiplabel runAction:
//				 [CCEaseExponentialOut actionWithAction:
//				  [CCScaleTo actionWithDuration:0.5 scale:1.25]]];
//				skiplabel.selected = YES;
//			}
//		}
//		else {
//			if (skiplabel.selected) {
//				[skiplabel runAction:
//				 [CCEaseExponentialOut actionWithAction:
//				  [CCScaleTo actionWithDuration:0.5 scale:1.0]]];
//				skiplabel.selected = NO;
//			}
//		}
//	}
//	return self;
//}

- (GameState *) doEndTouch:(NSSet *)touches withEvent:(UIEvent *)event {
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		if (CGRectContainsPoint([skiplabel getRect], location)) {			
			[[SimpleAudioEngine sharedEngine] playEffect:@"redpaddle.wav"];
			[self skip];
		}
	}
	return self;
}

@end

@implementation StateCredits : StateMovie 
- (id) init {
	if ((self = [super init])) {
		PongVader *pv = [PongVader getInstance];
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		int vPadSmall, vPadLarge, lMargin;
		
		if (_IPAD) {
			vPadSmall = 60;
			vPadLarge = 120;
			lMargin = 60;
			
			jonvader = [CCSprite spriteWithFile:@"jon-bobble-ipad.png"];
			colevader = [CCSprite spriteWithFile:@"cole-waddle-ipad.png"];
		}
		else {
			vPadSmall = 30;
			vPadLarge = 60;
			lMargin = 30;
			
			jonvader = [[CCSprite spriteWithFile:@"jon-bobble-iphone.png"] retain];
			colevader = [[CCSprite spriteWithFile:@"cole-waddle-iphone.png"] retain];
		}
		
		jonvader.opacity = 0;
		jonvader.rotation = 90;
		colevader.opacity = 0;
		colevader.rotation = 90;
		
		times[0] = 1;
		times[1] = times[0] + CREDITS_LENGTH;
		times[2] = times[1] + PICTURE_LENGTH;
		times[3] = times[2] + PICTURE_TRANSITION;
		times[4] = times[3] + PICTURE_LENGTH;
		times[5] = times[4] + PICTURE_TRANSITION;

		
		// make everything a child of this node so only the node needs to be moved
		scrollNode = [[CCNode node] retain];
		scrollNode.position = ccp(0,0);
		
		// LOGOS AND HUMAN CREDITS
		
		pvLogo = [CCSprite spriteWithFile:@"pvTitle.png"];
		pvLogo.position = ccp(ssz.width/2, 0);
		pvLogo.scale = 2.0;
		
		producedBy = [CCLabelBMFont bitmapFontAtlasWithString:@"PRODUCED BY" fntFile:pv.largeFont];
		producedBy.position = ccp(ssz.width/2, pvLogo.position.y - ((pvLogo.contentSize.height) + vPadSmall + (_IPAD? 200 : 400)));
		producedBy.color = ccc3(255, 255, 255);
		
		kdcLogo = [CCSprite spriteWithFile:@"kdcLogo.png"];
		kdcLogo.position = ccp(ssz.width/2, producedBy.position.y - ((producedBy.contentSize.height) + vPadSmall * 2.5));
		
		artBy = [CCLabelBMFont bitmapFontAtlasWithString:@"ART BY" fntFile:pv.largeFont];
		artBy.position = ccp(ssz.width/2, kdcLogo.position.y - ((kdcLogo.contentSize.height) + vPadSmall));
		artBy.color = ccc3(255, 255, 255);
		
		apLogo = [CCSprite spriteWithFile:@"apLogo.png"];
		apLogo.position = ccp(ssz.width/2, artBy.position.y - ((artBy.contentSize.height) + vPadSmall));
		
		musicBy = [CCLabelBMFont bitmapFontAtlasWithString:@"MUSIC BY" fntFile:pv.largeFont];
		musicBy.position = ccp(ssz.width/2, apLogo.position.y - ((apLogo.contentSize.height) + vPadSmall));
		musicBy.color = ccc3(255, 255, 255);
		
		nsLogo = [CCSprite spriteWithFile:@"nsLogo.png"];
		nsLogo.position = ccp(ssz.width/2, musicBy.position.y - ((musicBy.contentSize.height) + vPadSmall));
		
		// STARRING
		starring = [CCLabelBMFont bitmapFontAtlasWithString:@"STARRING" fntFile:pv.largeFont];
		starring.position = ccp(ssz.width/2, nsLogo.position.y - ((nsLogo.contentSize.height) + vPadLarge));
		starring.color = ccc3(255, 255, 255);
		
		ensign = [CCLabelBMFont bitmapFontAtlasWithString:@"ENSIGN PRANCE" fntFile:pv.mediumFont];
		ensign.position = ccp(ssz.width/2, starring.position.y - ((starring.contentSize.height) + vPadSmall));
		ensign.color = ccc3(255, 255, 255);
		
		ensPrance = (Invader *) [ENSPrance spriteBodyAt: ccp(ssz.width/2, ensign.position.y - ((ensign.contentSize.height) + vPadSmall)) withForce:ccp(0,0) inWorld: pv.world];
		[ensPrance promote: 1];
		
		lieutenant = [CCLabelBMFont bitmapFontAtlasWithString:@"LIEUTENANT WADDLE" fntFile:pv.mediumFont];
		lieutenant.position = ccp(ssz.width/2, ensPrance.position.y - ((ensPrance.contentSize.height) + vPadSmall));
		lieutenant.color = ccc3(255, 255, 255);
		
		ltWaddle = (Invader *) [LTWaddle spriteBodyAt: ccp(ssz.width/2, lieutenant.position.y - ((lieutenant.contentSize.height) + vPadSmall)) withForce:ccp(0,0) inWorld: pv.world];
		[ltWaddle promote: 1];
		
		commander = [CCLabelBMFont bitmapFontAtlasWithString:@"COMMANDER BOBBLE" fntFile:pv.mediumFont];
		commander.position = ccp(ssz.width/2, ltWaddle.position.y - ((ltWaddle.contentSize.height) + vPadSmall));
		commander.color = ccc3(255, 255, 255);
		
		cdrBobble = (Invader *) [CDRBobble spriteBodyAt: ccp(ssz.width/2, commander.position.y - ((commander.contentSize.height) + vPadSmall)) withForce:ccp(0,0) inWorld: pv.world];
		[cdrBobble promote: 1];


		
		// SUPPORTED BY
		supportedBy = [CCLabelBMFont bitmapFontAtlasWithString:@"SUPPORTED BY" fntFile:pv.largeFont];
		supportedBy.position = ccp(ssz.width/2, cdrBobble.position.y - ((cdrBobble.contentSize.height) + vPadLarge));
		supportedBy.color = ccc3(255, 255, 255);
		
		tank = [CCLabelBMFont bitmapFontAtlasWithString:@"TANK" fntFile:pv.mediumFont];
		tank.position = ccp(ssz.width/2, supportedBy.position.y - ((supportedBy.contentSize.height) + vPadSmall));
		tank.color = ccc3(255, 255, 255);
		
		shieldvader = (Invader *) [ShieldInvader spriteBodyAt: ccp(ssz.width/2, tank.position.y - ((tank.contentSize.height) + vPadSmall)) withForce:ccp(0,0) inWorld: pv.world];
		
		sweetCheeks = [CCLabelBMFont bitmapFontAtlasWithString:@"SWEET CHEEKS" fntFile:pv.mediumFont];
		sweetCheeks.position = ccp(ssz.width/2, shieldvader.position.y - ((shieldvader.contentSize.height) + vPadSmall));
		sweetCheeks.color = ccc3(255, 255, 255);	
		
		redvader = (Invader *) [StationaryInvader spriteBodyAt: ccp(ssz.width/2, sweetCheeks.position.y - ((sweetCheeks.contentSize.height) + vPadSmall)) withForce:ccp(0,0) inWorld: pv.world];
		
		// CAMEOS
		
		cameos = [CCLabelBMFont bitmapFontAtlasWithString:@"CAMEOS" fntFile:pv.largeFont];
		cameos.position = ccp(ssz.width/2, redvader.position.y - ((redvader.contentSize.height) + vPadLarge));
		cameos.color = ccc3(255, 255, 255);

		seaman = [CCLabelBMFont bitmapFontAtlasWithString:@"SEAMAN EYE" fntFile:pv.mediumFont];
		seaman.position = ccp(ssz.width/2, cameos.position.y - ((cameos.contentSize.height) + vPadSmall));
		seaman.color = ccc3(255, 255, 255);
		
		smnEye = (Invader *) [SNEye spriteBodyAt: ccp(ssz.width/2, seaman.position.y - ((seaman.contentSize.height) + vPadSmall)) withForce:ccp(0,0) inWorld: pv.world];
		
		captain = [CCLabelBMFont bitmapFontAtlasWithString:@"CAPTAIN DAWDLE" fntFile:pv.mediumFont] ;
		captain.position = ccp(ssz.width/2, smnEye.position.y - ((smnEye.contentSize.height) + vPadSmall));
		captain.color = ccc3(255, 255, 255);
		
		cptDawdle = (Invader *) [CPTDawdle spriteBodyAt: ccp(ssz.width/2, captain.position.y - ((captain.contentSize.height) + vPadSmall)) withForce:ccp(0,0) inWorld: pv.world];
		
		admiral = [CCLabelBMFont bitmapFontAtlasWithString:@"ADMIRAL BRAIN" fntFile:pv.mediumFont] ;
		admiral.position = ccp(ssz.width/2, cptDawdle.position.y - ((cptDawdle.contentSize.height) + vPadSmall));
		admiral.color = ccc3(255, 255, 255);
		
		admBrain = (Invader *) [ADMBrain spriteBodyAt: ccp(ssz.width/2, admiral.position.y - ((admiral.contentSize.height) + vPadSmall)) withForce:ccp(0,0) inWorld: pv.world];
		
		// DISCLAIMER
		
		humaneNotice1 = [CCLabelBMFont bitmapFontAtlasWithString:@"NO ALIENS WERE HARMED" fntFile:pv.largeFont];
		humaneNotice1.position = ccp(ssz.width/2, admBrain.position.y - ((admBrain.contentSize.height) + vPadLarge));
		humaneNotice1.color = ccc3(255, 255, 255);
		
		humaneNotice2 = [CCLabelBMFont bitmapFontAtlasWithString:@"MAKING THIS GAME" fntFile:pv.largeFont];
		humaneNotice2.position = ccp(ssz.width/2, humaneNotice1.position.y - ((humaneNotice1.contentSize.height) + vPadSmall));
		humaneNotice2.color = ccc3(255, 255, 255);
		
		humaneLogo = [CCSprite spriteWithFile:@"hsLogo.png"];
		humaneLogo.position = ccp(ssz.width/2, humaneNotice2.position.y - ((humaneNotice2.contentSize.height) + vPadLarge *2.0));
		
		humaneTitle = [CCLabelBMFont bitmapFontAtlasWithString:@"GALACTIC HUMANE SOCIETY" fntFile:pv.largeFont];
		humaneTitle.position = ccp(ssz.width/2, humaneLogo.position.y - ((humaneLogo.contentSize.height) + vPadLarge));
		humaneTitle.color = ccc3(255, 255, 255);		

		// double scale for iPad
		if (_IPAD) {
			pvLogo.scale = 4.0;
			//producedBy.scale = 2.0;
			kdcLogo.scale = 2.0;
			//artBy.scale = 2.0;
			apLogo.scale = 2.0;
			//musicBy.scale = 2.0;
			nsLogo.scale = 2.0;
			
			//starring.scale = 2.0;
			//ensign.scale = 2.0;
			ensPrance.scale = 2.0;
			//lieutenant.scale = 2.0;
			ltWaddle.scale = 2.0;
			//commander.scale = 2.0;
			cdrBobble.scale = 2.0;
			
			//supportedBy.scale = 2.0;
			//tank.scale = 2.0;
			shieldvader.scale = 2.0;
			//sweetCheeks.scale = 2.0;
			redvader.scale = 2.0;
			
			//cameos.scale = 2.0;
			//seaman.scale = 2.0;
			smnEye.scale = 2.0;
			//captain.scale = 2.0;
			cptDawdle.scale = 2.0;
			//admiral.scale = 2.0;
			admBrain.scale = 2.0;
			
			//humaneNotice1.scale = 2.0;
			//humaneNotice2.scale = 2.0;
			humaneLogo.scale = 2.0;
			//humaneTitle.scale = 2.0;
		}
		
		
		// add to node
		
		// people credits
		[scrollNode addChild:pvLogo];
		[scrollNode addChild:producedBy];
		[scrollNode addChild:kdcLogo];
		[scrollNode addChild:artBy];
		[scrollNode addChild:apLogo];
		[scrollNode addChild:musicBy];
		[scrollNode addChild:nsLogo];
		
		// starring
		[scrollNode addChild:starring];
		[scrollNode addChild:ensign];
		[scrollNode addChild:ensPrance];
		[scrollNode addChild:lieutenant];
		[scrollNode addChild:ltWaddle];
		[scrollNode addChild:commander];
		[scrollNode addChild:cdrBobble];
		
		// supported
		[scrollNode addChild:supportedBy];
		[scrollNode addChild:tank];
		[scrollNode addChild:shieldvader];
		[scrollNode addChild:sweetCheeks];
		[scrollNode addChild:redvader];
		
		// cameos
		[scrollNode addChild:cameos];
		[scrollNode addChild:seaman];
		[scrollNode addChild:smnEye];
		[scrollNode addChild:captain];
		[scrollNode addChild:cptDawdle];
		[scrollNode addChild:admiral];
		[scrollNode addChild:admBrain];
		
		// disclaimer
		[scrollNode addChild:humaneNotice1];
		[scrollNode addChild:humaneNotice2];
		[scrollNode addChild:humaneLogo];
		[scrollNode addChild:humaneTitle];
		
		
	}
	
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];

	//viewReset = NO;
	[pv addChild:scrollNode];
	
}

- (void) leaving {
	PongVader *pv = [PongVader getInstance];
	[pv removeChild:scrollNode cleanup:YES];
	[pv removeChild:jonvader cleanup:YES];
	[pv removeChild:colevader cleanup:YES];
	
	[super leaving];
}

- (void) leave {
	
	[super leave];
}

- (GameState *) doAction:(int)action {
	CGSize ssz = [CCDirector sharedDirector].winSize;
	PongVader *pv = [PongVader getInstance];
	GameState *next = self;
	
	if (action == 0) {
		[scrollNode runAction:[CCMoveBy actionWithDuration:CREDITS_LENGTH position:_IPAD ? ccp(0,-humaneTitle.position.y + 1.5* ssz.height) : ccp(0, -humaneTitle.position.y + 1.5*ssz.height)]];
	}
	else if (action == 1) {
		//[scrollNode runAction:[CCFadeOut actionWithDuration:PICTURE_TRANSITION]];
		[pv addChild:jonvader];
		[jonvader runAction:[CCFadeIn actionWithDuration:PICTURE_TRANSITION]];
		jonvader.position = ccp(ssz.width/2, ssz.height/2);
	}
	else if (action == 2) {
		[jonvader runAction:[CCFadeOut actionWithDuration:PICTURE_TRANSITION]];
	}
	else if (action == 3) {
		[pv addChild:colevader];
		[colevader runAction:[CCFadeIn actionWithDuration:PICTURE_TRANSITION]];
		colevader.position = ccp(ssz.width/2, ssz.height/2);
	}
	else if (action == 4) {
		[colevader runAction:[CCFadeOut actionWithDuration:PICTURE_TRANSITION]];
	}
	else if (action == 5) {
		GameState *state = [[[StateLoseMenu alloc] init] autorelease];
		[self changeTo:state after:TRANSITION_PAUSE];	
	}
	
	return next;
}

- (void) skip {
	GameState *state = [[[StateLoseMenu alloc] init] autorelease];
	//state.shouldClearFirst = NO;
	[self changeTo:state after:TRANSITION_PAUSE];
}


@end


@implementation StateTutorial

- (id) init {
	if ((self = [super init])) {
		times[0] = 0.5; // spawn fleet1
		times[1] = times[0]; // "greetings"
		times[2] = times[1] + 2; // 
		times[3] = times[2] + 5; // 
		
		times[4] = times[3]; // 
		times[5] = times[4] + 3; // 
		times[6] = times[5] + 3; // 
		times[7] = times[6] + 3; // 
		times[8] = times[7] + 3; // 
		
		times[9] = times[8] + 3; //
		times[10] = times[9] + 2;// 
		times[11] = times[10]+ 2; // 
		times[12] = times[11]; // 
		times[13] = times[12]; // 
		times[14] = times[13] + 3.5; // 
		
		times[15] = times[14] + 4; // 
		times[16] = times[15] + 3; // 
		times[17] = times[16] + 3; // 
		
		times[18] = times[17] + 3; // 
		times[19] = times[18] + 3; // 
		times[20] = times[19] + 3; // 
		times[21] = times[20] + 3; // 
		times[22] = times[21] + 3; // 
		times[23] = times[22] + 3; // 
		times[24] = times[23]; // 
		times[25] = times[24]; // 
		times[26] = times[25]; // 
		times[27] = times[26]; // 
		times[28] = times[27] + 3; // 
		
		pad1x = pad2x = [CCDirector sharedDirector].winSize.width / 2.0;
		
		PongVader *pv = [PongVader getInstance];
		tutorialLabel = [[CCLabelBMFont bitmapFontAtlasWithString:@"TUTORIAL" fntFile:pv.largeFont] retain];
		tutorialLabel.position = TUTLABEL_POS;
		tutorialLabel.color = ccc3(255, 0, 0);
		
		skiplabel.position = SKIP_POS_TOP;
	}
	return self;
}

- (void) dealloc {
	[tutorialLabel release];
	[super dealloc];
}

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	[pv addChild:tutorialLabel];
	
	[pv runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
	[skiplabel runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
	[tutorialLabel runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
	[ltrbox[0] runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
	[ltrbox[1] runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
	
//	if ([pv.settings getInt:@"TutorialPlayed"] == 0) {
//		[skiplabel setVisible:NO];
//	}
	
	viewReset = NO;
	
	if _IPAD {
		i1 = ccp(240, 300);
		i2 = ccp(320, 300);
	}
	else {
		i1 = ccp(90, 150);
		i2 = ccp(130, 150);
	}
	
	invader1 = [[pv addSpriteBody:[ENSPrance class] atPos:ccp(i1.x + 1000, i1.y) withForce:ccp(0,0)] retain];
	[invader1 promote: 1];

	
	invader2 = [[pv addSpriteBody:[LTWaddle class] atPos:ccp(i2.x + 1000, i2.y) withForce:ccp(0,0)] retain];
	[invader2 promote: 1];
	if (_IPAD) {
		invader1.baseScale = 2.0;
	invader1.scale = 2.0;
	invader2.baseScale = 2.0;
	invader2.scale = 2.0;
	}
}

- (void) leaving {
	if (!viewReset) {
		PongVader *pv = [PongVader getInstance];
		[pv runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
		[skiplabel runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
		[tutorialLabel runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
		[tutorialLabel runAction:
		 [CCEaseExponentialIn actionWithAction:
		  [CCFadeOut actionWithDuration:1.0]]];
		[ltrbox[0] runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
		[ltrbox[1] runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
	}
	[super leaving];
}

- (void) leave {
	[[PongVader getInstance] destroyInvader:invader1 inGame:NO];
	[invader1 release];
	[[PongVader getInstance] destroyInvader:invader2 inGame:NO];
	[invader2 release];
	[[PongVader getInstance] removeChild:tutorialLabel cleanup:YES];
	[super leave];
}

- (GameState *) doAction:(int) action {
	CGSize ssz = [CCDirector sharedDirector].winSize;
	PongVader *pv = [PongVader getInstance];
	GameState *next = self;
	
	

	
	NSLog(@"action: %d\n", action);
	
	char block1[] = "xxxxxxxxxxxxxxxxxxxxxxxxqqqqqqxxaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxx";
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	if (action == 0) {
		[pv addFleet: [[[BlockFleet alloc] initWithConfig:block1
												  andDims:ccp(8,8) 
											  withSpacing: _IPAD ? 40 : 20 
												 atOrigin:origins[0]
												fromRight:NO
												  playing: @"x"
											   difficulty:curLevel] autorelease]];
		
		[invader1 runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.5 position:i1]]];
		
		[invader2 runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.8 position:i2]]];
		
	} 
	
	
	
		 
	
	// GREETINGS
	else if (action == 1) {
		//messageLabel = [[Utils multilineNodeWithText:@"GREETINGS HUMANS!" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
//		[self placeBubble:i1 rlen:22 rc:3];
	} 
	else if (action == 2) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"WE HAVE COME TO COLLECT YOUR DEBT TO US FROM WHEN WE BAILED YOU OUT OF THE 3007 FINANCIAL CRISIS." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:12];
	} 
	else if (action == 3) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"REPAY US OR MEET YOUR DOOM." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i2 rlen:20 rc:4 sp:2];
	} 
	else if (action == 4) {
//		[self clearMessageAndBubble];
//		messageLabel = [[Utils multilineNodeWithText:@"BUT FIRST WE FIGURED IT WOULD BE SPORTING TO EXPLAIN THE RULES TO YOU." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
//		[self placeBubble:i1 rlen:22 rc:8];
	}
	
	// LAUNCHING BALLS
	else if (action == 5) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"WE'RE GOING TO LAUNCH BALLS OF ENERGY AT YOU IN TIME TO THE MUSIC." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:8];
	} 
	else if (action == 6) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"DON'T LET THE SHOTS HIT YOUR PLANET." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i2 rlen:20 rc:5 sp:2];
		
		Ball *newball;
		if (_IPAD) {
			newball = [[[[pv.fleets objectAtIndex:0] invaders] objectAtIndex:7] ballWithDirection:ccp(0.3, -1.00) ];
		}
		else {
			newball = [[[[pv.fleets objectAtIndex:0] invaders] objectAtIndex:7] ballWithDirection:ccp(0.04, -.12) ];
		}
		[[PongVader getInstance] addChild:newball];
		[[PongVader getInstance].balls addObject:newball];
		[[SimpleAudioEngine sharedEngine] playEffect:@"shoot.wav"];
	} 
	else if (action == 7) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"TOO MANY MISSED SHOTS AND YOU LOSE." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i2 rlen:20 rc:5 sp:2];
	} 
	else if (action == 8) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"MOVE THE WHITE SHIELD WITH YOUR FINGER (NOT YET)." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:5];
		
		[pv.paddle1 moveTo: ssz.width / 2.0];
		[pv.paddle2 moveTo: ssz.width / 2.0];
		[pv showPaddles:YES];
	} 
	else if (action == 9) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"USE IT TO DEFLECT OUR SHOTS BACK TO US." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:5];
		
		Ball *newball;
		if (_IPAD) {
			newball = [[[[pv.fleets objectAtIndex:0] invaders] objectAtIndex:7] ballWithDirection:ccp(0.3, -1.00) ];
		}
		else {
			newball = [[[[pv.fleets objectAtIndex:0] invaders] objectAtIndex:7] ballWithDirection:ccp(0.04, -.12) ];
		}
		[[PongVader getInstance] addChild:newball];
		[[PongVader getInstance].balls addObject:newball];
		[[SimpleAudioEngine sharedEngine] playEffect:@"shoot.wav"];
		
		pad2x = ssz.width / 2.0;
		pad1x = ssz.width / 2.0;

	}
	else if (action == 10) {
		[self clearMessageAndBubble];
	}
	
	// VOLLEY / SECOND SHIELD
	else if (action == 11) {
		[pv runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
		[skiplabel runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
		[tutorialLabel runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
//		[ltrbox[0] runAction:
//		 [CCEaseExponentialOut actionWithAction:
//		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
//		[ltrbox[1] runAction:
//		 [CCEaseExponentialOut actionWithAction:
//		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
		
		[ltrbox[0] runAction:
		 [CCFadeOut actionWithDuration:1.0]];
		[ltrbox[1] runAction:
		 [CCFadeOut actionWithDuration:1.0]];
		
		viewReset = YES;
		
		if (_IPAD) {
			pad2x = ssz.width / 2.0 - 250;
			pad1x = ssz.width / 2.0 - 200;
		}
		else {
			pad2x = ssz.width / 2.0 - 125;
			pad1x = ssz.width / 2.0 - 100;
		}
		
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"A FRIEND OR A CPU CONTROLS THE OTHER SHIELD" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i1 rlen:24 rc:9];
	} 
//	else if (action == 11) {
		//[self clearMessageAndBubble];
//		messageLabel = [[Utils multilineNodeWithText:@"WE SHOULD HAVE ASSUMED YOU WOULDN'T PLAY FAIR." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
//		[self placeBubble:i1 rlen:24 rc:8];
//	} 
	else if (action == 12) {
//		[self clearMessageAndBubble];
//		messageLabel = [[Utils multilineNodeWithText:@"TWO ENTIRE PLANETS AGAINST JUST US." font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
//		[self placeBubble:i2 rlen:20 rc:8 sp:2];
	} 
	else if (action == 13) {
//		[self clearMessageAndBubble];
//		messageLabel = [[Utils multilineNodeWithText:@"YOU SHOULD FEEL AT LEAST A LITTLE BIT PATHETIC." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
//		[self placeBubble:i2 rlen:20 rc:6 sp:2];
	} 
	else if (action == 14) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"VOLLEY A SHOT BETWEEN THE SHIELDS TO CHARGE IT IN TO A FIREBALL." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i1 rlen:24 rc:9];
		
		Ball *newball;
		if _IPAD {
			newball = [[[[pv.fleets objectAtIndex:0] invaders] objectAtIndex:7] ballWithDirection:ccp(-0.75, -1.87) ];
		}
		else {
			newball = [[[[pv.fleets objectAtIndex:0] invaders] objectAtIndex:7] ballWithDirection:ccp(-0.085, -0.21) ];
		}
		
		[[PongVader getInstance] addChild:newball];
		[[PongVader getInstance].balls addObject:newball];
		[[SimpleAudioEngine sharedEngine] playEffect:@"shoot.wav"];
	} 
	else if (action == 15) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"A FIREBALL CAN CUT THROUGH SEVERAL INVADERS. BUT DON'T LET IT GET PAST YOUR SHIELD." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i2 rlen:24 rc:10 sp:2];
		
		if (_IPAD) {
			pad2x = ssz.width / 2.0;
			pad1x = ssz.width / 2.0;
		}
		else {
			pad2x = ssz.width / 2.0;
			pad1x = ssz.width / 2.0;
		}
	} 
	
	// POWERUP
	else if (action == 16) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"GIVE ME A SECOND TO SQUEEZE OUT A POWERUP." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i2 rlen:20 rc:5 sp:2];
	} 
	else if (action == 17) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"URGGHH" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i2 rlen:20 rc:3 sp:2];
	} 
	else if (action == 18) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"THERE WE GO." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		
		[[SimpleAudioEngine sharedEngine] playEffect:@"portal.wav"];
		[self placeBubble:i2 rlen:20 rc:3 sp:2];
		
		CGPoint dir = _IPAD ? ccp(0, -2) : ccp(0, -0.25);
		Powerup *powerup = (Powerup *) [Powerup spriteBodyAt:i2 withEffect: POW_ENSPRANCE withForce:dir inWorld:pv.world];
		[pv addChild:powerup];
		[pv.powerups addObject:powerup];
		if (_IPAD) {
			pad1x = ssz.width/2 - 100;
		}
		else {
			pad1x = ssz.width/2 - 50;
		}
	} 
	else if (action == 19) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"CATCH A POWERUP WITH YOUR PADDLE TO GAIN A SPECIAL ABILITY." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:7];
		
	} 
	
	// FAREWELL
	else if (action == 20) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"AND DON'T FORGET THAT YOU ARE COOPERATING." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:5];
	} 
	else if (action == 21) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"AFTER ALL, YOU'RE BINARY PLANETS." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:5];
	} 
	else if (action == 22) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"YOUR ORBITS ARE DEFINED BY MUTUAL GRAVITATIONAL INTERACTION." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:7];
	} 
	else if (action == 23) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"THUS YOUR FATES ARE TIED." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:5];
	} 
	else if (action == 24) {
		//[self clearMessageAndBubble];
//		messageLabel = [[Utils multilineNodeWithText:@"SO PLAY NICE WITH EACH OTHER" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
//		[self placeBubble:i2 rlen:20 rc:5 sp:2];
	} 
	else if (action == 25) {
		//[self clearMessageAndBubble];
//		messageLabel = [[Utils multilineNodeWithText:@"THAT'S ALL FROM US. ANYTHING FROM YOU, ADMIRAL BRAIN?" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
//		[self placeBubble:i2 rlen:20 rc:7 sp:2];
	} 
	else if (action == 26) {
		//[[SimpleAudioEngine sharedEngine] playEffect:@"wail.wav"];
	} 
	else if (action == 27) {
		//[self clearMessageAndBubble];
//		messageLabel = [[Utils multilineNodeWithText:@"HAVE AT YOU!" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
//		[self placeBubble:i1 rlen:22 rc:5];
	} 
	else if (action == 28) {
		[self clearMessageAndBubble];
		[invader1 runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.5 position:ccp(i1.x + 1000, i1.y)]]];
		
		[invader2 runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.8 position:ccp(i2.x + 1000, i2.y)]]];
		
		StateGetReady *state = [[[StateGetReady alloc] init] autorelease];
		//state.shouldClearFirst = NO;
		[self changeTo:state after:TRANSITION_PAUSE];
	}
	
	
	return next;
}

- (void) skip {
	[self clearMessageAndBubble];
	PongVader *pv = [PongVader getInstance];
	for (int i = 0; i < 2; i++) {
		[pv.player[i] resetScore];
	}
	
	StateGetReady *state = [[[StateGetReady alloc] init] autorelease];
	//state.shouldClearFirst = NO;
	[self changeTo:state after:TRANSITION_PAUSE];
	[pv clearBalls];
}

- (GameState *) doEndTouch:(NSSet *)touches withEvent:(UIEvent *)event {
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		
//		if ((location.x > _IPAD ? 500 : 200) && (location.y < _IPAD ? 50 : 25)) {
		
		if (_IPAD) {
		
			/* bottom
		if ((location.x > 500) && (location.y < 50)) {	
			[[SimpleAudioEngine sharedEngine] playEffect:@"redpaddle.wav"];
			[self skip];
		}
			*/
			
			if ((location.x > 500) && (location.y > 950)) {	
				[[SimpleAudioEngine sharedEngine] playEffect:@"redpaddle.wav"];
				[self skip];
			}
		}
			 
		
		else {
			
			/* bottom
			if ((location.x > 200) && (location.y < 30)) {	
				[[SimpleAudioEngine sharedEngine] playEffect:@"redpaddle.wav"];
				[self skip];
			}
			 
			 */
			
			if ((location.x > 200) && (location.y > 430)) {	
				[[SimpleAudioEngine sharedEngine] playEffect:@"redpaddle.wav"];
				[self skip];
			}
		}
	}
	return self;
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	PongVader *pv = [PongVader getInstance];
	
	[pv.paddle1 moveTo: (pv.paddle1.position.x * 3 + pad1x) / 4.0];
	[pv.paddle2 moveTo: (pv.paddle2.position.x * 3 + pad2x) / 4.0];
	
	return [super doTimer:dTime];
}
- (int) getPowerup { return 0; }

/*
- (GameState *) doEndTouch:(NSSet *)touches withEvent:(UIEvent *)event {
	[self skip];
	PongVader *pv = [PongVader getInstance];
	if ([pv.settings getInt:@"TutorialPlayed"] > 0) [self skip];
	return self;
}
 */

@end

@implementation StateTutorialShort

- (id) init {
	if ((self = [super init])) {
		times[0] = 0.5; // spawn fleet1
		times[1] = 1.5; // "were scary invaders, look out!"
		times[2] = 3.0; // shoot
		times[3] = 4.0; // "use your paddle to deflect our shots"
		times[4] = 5.0; // paddle spawn / move
		times[5] = 6.0; // shoot
		times[6] = 7.0; // "don't let the shots hit your planet"
		times[7] = 9.0; // "ouch!"
		times[8] = 10.0; // "volley shots to charge"
		times[9] = 10.5; // move screen 
		times[10] = 12.5; // "Oh no!"
		times[11] = 13.5; // spawn powerup
		times[12] = 14.5; // move screen
		times[13] = 15.0; // ".. powerups"
		times[14] = 18.0; // ".. fates"
		times[15] = 21.0; // ".. defend harmony"
		times[16] = 24.0; // end
		
		pad1x = pad2x = [CCDirector sharedDirector].winSize.width / 2.0;
	}
	return self;
}

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	[pv runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
	[skiplabel runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
	[ltrbox[0] runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
	[ltrbox[1] runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
	
	if ([pv.settings getInt:@"TutorialPlayed"] == 0) {
		[skiplabel setVisible:NO];
	}
	
	viewReset = NO;
}

- (void) leaving {
	if (!viewReset) {
		PongVader *pv = [PongVader getInstance];
		[pv runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
		[skiplabel runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
		[ltrbox[0] runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
		[ltrbox[1] runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
	}
	[super leaving];
}

- (GameState *) doAction:(int) action {
	CGSize ssz = [CCDirector sharedDirector].winSize;
	PongVader *pv = [PongVader getInstance];
	GameState *next = self;

	NSLog(@"action: %d\n", action);
	
	char block1[] = "xxxxxxxxxxxxxxxxxxxxxxxxqqqqqqxxaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxx";
	//char block[] = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxqxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	if (action == 0) {
		[pv addFleet: [[[BlockFleet alloc] initWithConfig:block1
												  andDims:ccp(8,8) 
											  withSpacing: _IPAD ? 40 : 20 
												 atOrigin:origins[0]
												fromRight:NO
												  playing: @"x"
											   difficulty:curLevel] autorelease]];
		
	} else if (action == 1) {
		messageLabel = [[Utils multilineNodeWithText:@"WE'RE SCARY INVADERS, LOOK OUT!" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:ccp(300, 580) rlen:22 rc:3];
	} else if (action == 2) {
		Ball *newball = [[[[pv.fleets objectAtIndex:0] invaders] objectAtIndex:7] ballWithDirection:ccp(-0.3, -0.75) ];
		[[PongVader getInstance] addChild:newball];
		[[PongVader getInstance].balls addObject:newball];
		[[SimpleAudioEngine sharedEngine] playEffect:@"shoot.wav"];
	} else if (action == 3) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"USE YOUR SHEILD TO DEFLECT OUR SHOTS" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:ccp(300, 580) rlen:18 rc:3];
	} else if (action == 4) {
		[pv.paddle1 moveTo: ssz.width / 2.0];
		[pv.paddle2 moveTo: ssz.width / 2.0];
		[pv showPaddles:YES];
		pad1x = ssz.width / 2.0 - 200;
	} else if (action == 5) {
		[self clearMessageAndBubble];
		Ball *newball = [[[[pv.fleets objectAtIndex:0] invaders] objectAtIndex:7] ballWithDirection:ccp(0.3, -1.00) ];
		[[PongVader getInstance] addChild:newball];
		[[PongVader getInstance].balls addObject:newball];
		[[SimpleAudioEngine sharedEngine] playEffect:@"shoot.wav"];
	} else if (action == 6) {
		messageLabel = [[Utils multilineNodeWithText:@"DON'T LET THE SHOTS HIT YOUR PLANET" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:ccp(300, 580) rlen:18 rc:3];
	} else if (action == 7) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"OUCH!" font:pv.smallFont color: ccc3(0,0,0) rowlength:8 rowheight:16] retain];
		[self placeBubble:ccp(300,580) rlen:10 rc:2];
	} else if (action == 8) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"VOLLEY SHOTS TO CREATE A FIREBALL" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:ccp(300, 580) rlen:22 rc:3];
	} else if (action == 9) {
		[pv runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
		[skiplabel runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
		
//		[ltrbox[0] runAction:
//		 [CCEaseExponentialOut actionWithAction:
//		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
//		[ltrbox[1] runAction:
//		 [CCEaseExponentialOut actionWithAction:
//		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
		
		[ltrbox[0] runAction:
		 [CCFadeOut actionWithDuration:1.0]];
		[ltrbox[1] runAction:
		 [CCFadeOut actionWithDuration:1.0]];
		
		viewReset = YES;
		pad2x = ssz.width / 2.0 - 250;
	} else if (action == 10) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"OH NO!" font:pv.smallFont color: ccc3(0,0,0) rowlength:8 rowheight:16] retain];
		[self placeBubble:ccp(375,580) rlen:10 rc:2];
		powerupSpawn = ((CCNode *)[[[pv.fleets objectAtIndex:0] invaders] objectAtIndex:9]).position;
	} else if (action == 11) {
		CGPoint dir = _IPAD ? ccp(0, -2) : ccp(0, -0.25);
		Powerup *powerup = (Powerup *) [Powerup spriteBodyAt:powerupSpawn withEffect: POW_ENSPRANCE withForce:dir inWorld:pv.world];
		[pv addChild:powerup];
		[pv.powerups addObject:powerup];
	} else if (action == 12) {
//		[pv runAction:
//		 [CCEaseExponentialOut actionWithAction:
//		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT*2.0)]]];
//		[skiplabel runAction:
//		 [CCEaseExponentialOut actionWithAction:
//		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT*2.0)]]];
//		[ltrbox[0] runAction:
//		 [CCEaseExponentialOut actionWithAction:
//		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT*2.0)]]];
//		[ltrbox[1] runAction:
//		 [CCEaseExponentialOut actionWithAction:
//		  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT*2.0)]]];
//		
		pad1x = ssz.width / 2.0;
	} else if (action == 13) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"COLLECT POWERUPS TO GAIN SPECIAL ABILITIES" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:ccp(300, 580) rlen:22 rc:3];
	} else if (action == 14) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"HELP YOUR NEIGHBOR PLANET, YOUR FATES ARE TIED" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:ccp(300, 580) rlen:22 rc:3];
	} else if (action == 15) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"NOW, PREPARE TO DEFEND GALACTIC HARMONY!" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:ccp(300, 580) rlen:22 rc:3];
	} else if (action == 16) {
		[pv.settings set:@"TutorialPlayed" toInt: 1];
		[self skip];
	}
	return next;
}

- (void) skip {
	[self clearMessageAndBubble];
	PongVader *pv = [PongVader getInstance];
	for (int i = 0; i < 2; i++) {
		[pv.player[i] resetScore];
	}
	
	StateGetReady *state = [[[StateGetReady alloc] init] autorelease];
	//state.shouldClearFirst = NO;
	[self changeTo:state after:TRANSITION_PAUSE];
	[pv clearBalls];
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	PongVader *pv = [PongVader getInstance];
	
	[pv.paddle1 moveTo: (pv.paddle1.position.x * 3 + pad1x) / 4.0];
	[pv.paddle2 moveTo: (pv.paddle2.position.x * 3 + pad2x) / 4.0];
	
	return [super doTimer:dTime];
}
- (int) getPowerup { return 0; }

- (GameState *) doEndTouch:(NSSet *)touches withEvent:(UIEvent *)event {
	[self skip];
	PongVader *pv = [PongVader getInstance];
	if ([pv.settings getInt:@"TutorialPlayed"] > 0) [self skip];
	return self;
}

@end

@implementation StateIntro

- (id) init {
	if ((self = [super init])) {
		times[0] = 0.5;
		times[1] = 1.5;
		times[2] = 4.0;
		times[3] = 5.0;
		times[4] = 8.0;
	}
	return self;
}

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	[pv runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
	[skiplabel runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
	[ltrbox[0] runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
	[ltrbox[1] runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
	
}

- (void) leaving {
	PongVader *pv = [PongVader getInstance];
	[pv runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, -INTRO_YSHIFT)]]];
	[skiplabel runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
	[ltrbox[0] runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
	[ltrbox[1] runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveBy actionWithDuration:1.0 position:ccp(0, INTRO_YSHIFT)]]];
	[super leaving];
}

- (GameState *) doAction:(int) action {
	CGSize ssz = [CCDirector sharedDirector].winSize;
	PongVader *pv = [PongVader getInstance];
	GameState *next = self;
	if (action == 0) {
		char block[] = "xxxxxxxxxxxxxxxxxxxxxxxxqqqqqqqqaaaaaaaaxxxxxxxxxxxxxxxxxxxxxxxx";
		//  char block[] = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxqxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
		
		CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig:block
										   andDims:ccp(8,8) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin:origins[0]
										  maxWidth: _IPAD ? 400 : 200 
										   initDir:ccp(1,0)
											  step:_IPAD ? 50 : 20
										 fromRight:NO
										   playing: @"bxxxbxxx"
										difficulty:curLevel] autorelease]};	
		[pv addFleet: fleets[0]];

	} else if (action == 1) {
		messageLabel = [[Utils multilineNodeWithText:@"GREETINGS HUMANS, WE COME IN..." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:ccp(400, 580) rlen:18 rc:3];
	} else if (action == 2) {
		[self clearMessageAndBubble];
		Ball *newball = [[[[pv.fleets objectAtIndex:0] invaders] objectAtIndex:10] ballWithDirection:ccp(-0.3, -1.2) ];
		[[PongVader getInstance] addChild:newball];
		[[PongVader getInstance].balls addObject:newball];
		[[SimpleAudioEngine sharedEngine] playEffect:@"shoot.wav"];
	} else if (action == 3) {
		messageLabel = [[Utils multilineNodeWithText:@"OOPS..." font:pv.smallFont color: ccc3(0,0,0) rowlength:8 rowheight:16] retain];
		[self placeBubble:ccp(500,580) rlen:10 rc:2];
	} else if (action == 4) {
		[self skip];
	}
	return next;
}

- (void) skip {
	[self clearMessageAndBubble];
	PongVader *pv = [PongVader getInstance];
	for (int i = 0; i < 2; i++) {
		[pv.player[i] resetScore];
	}
	
	StateGetReady *state = [[[StateGetReady alloc] init] autorelease];
	state.shouldClearFirst = NO;
	[self changeTo:state after:TRANSITION_PAUSE];
	[pv clearBalls];
}
				
@end

@implementation StateOutro

- (id) init {
	if ((self = [super init])) {
		
//		CGSize ssz = [CCDirector sharedDirector].winSize;
//		PongVader *pv = [PongVader getInstance];
//		
//char block[] = "\
//xxxxxxxx\
//xxxxxxxx\
//xxxxxxxx\
//xxx1xxxx\
//xxxxxxxx\
//xxxxxxxx\
//xxxxxxxx\
//xxxxxxxx";
//		
//		CGPoint origins[] = {ccp(ssz.width/2+25, ssz.height/2+25)};
//		
//		Fleet *fleets[] = {
//			[[[BlockFleet alloc] initWithConfig: block 
//										andDims: ccp(8,8)
//									withSpacing: _IPAD ? 50 : 25
//									   atOrigin: origins[0]
//									  fromRight: YES 
//										playing: @"sxxxxxxx"
//									 difficulty: curLevel] autorelease]};
//		
//		[pv addFleet: fleets[0]];
//		
//		[[BeatSequencer getInstance] addEvent:
//		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]]];
		
		times[0] = 1.0; // dawdle hurt
		times[1] = times[0] + 1.5; // invader enters
		times[2] = times[1] + 2.0; // are you hurt
		times[3] = times[2] + 2.0; // dawdle hurt
		times[4] = times[3] + 2.0; // "you'll pay"
		times[5] = times[4] + 2.0; // "literally"
		times[6] = times[5] + 3.0; // "expect an invoice"
		times[7] = times[6] + 3.0; // "adieu"
		times[8] = times[7] + 3.0;
		times[9] = times[8] + 1.5;// exit
		times[10] = times[9] + 1.5;// main menu
		
	}
	return self;
}


- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	pv.bossTime = YES;
	Fleet *bossFleet = [pv.fleets objectAtIndex:0];
	SpriteBody *boss = [bossFleet.invaders objectAtIndex:0];
	[boss reset];
	[boss runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveTo actionWithDuration:0.8 position: _IPAD ? ccp(200, 512) : ccp(100,216)]]];
	peon = [[pv addSpriteBody:[ENSPrance class] atPos: _IPAD ? ccp(800, boss.position.y) : ccp(400, boss.position.y)  withForce:ccp(0,0)] retain];
	[(ENSPrance *) peon promote: 1];
	if (_IPAD) {
		peon.scale = 2.0;
		peon.baseScale = 2.0;
	}
	if (pv.OFstarted) {
		[OFAchievementService updateAchievement:BALL_MASTER andPercentComplete:100 andShowNotification:YES];
	}
	[pv.settings set:@"BeatEpOne" toInt:1];
	[pv.settings set:@"lastLevel" toInt:0];
}

- (void) leave {
	[[PongVader getInstance] destroyInvader:peon inGame:NO];
	[peon release];
	[super leave];
}

- (GameState *) doAction:(int) action {
	PongVader *pv = [PongVader getInstance];
	CGSize ssz = [CCDirector sharedDirector].winSize;
	Fleet *bossFleet = [pv.fleets objectAtIndex:0];
	SpriteBody *boss = [bossFleet.invaders objectAtIndex:0];
	GameState *next = self;
	
	CGPoint dawdle, inv;
	if _IPAD {
		dawdle = ccp(200, 512);
		inv = ccp(400,530);
	}
	else {
		dawdle = ccp(400, 416);
		inv = ccp(100,100);
	}
	
	if (action == 0) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"DawdleHurt.wav"];
	} 
	else if (action == 1) {
		[peon runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.8 position:inv]]];
	} 
	else if (action == 2) {
		messageLabel = [[Utils multilineNodeWithText:@"YOU'VE HURT CAPTAIN DAWDLE!" font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:inv rlen:20 rc:4];
	} 
	else if (action == 3) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"DawdleHurt.wav"];
	} 
	else if (action == 4) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"YOU'LL PAY FOR THIS!" font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:inv rlen:20 rc:3];
	} 
	else if (action == 5) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"... LITERALLY." font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:inv rlen:20 rc:3];
	} 
	else if (action == 6) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"DAWDLE'S REPAIR COSTS ARE BEING ADDED TO YOUR DEBT." font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:inv rlen:20 rc:8];
	} 
	else if (action == 7) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"EXPECT AN INVOICE FROM ADMIRAL BRAIN." font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:inv rlen:20 rc:6];
	} 
	else if (action == 8) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"ADIEU!" font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:inv rlen:20 rc:3];
	} 
	else if (action == 9) {
		[self clearMessageAndBubble];
		[peon runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.4 position:ccp(1000, inv.y)]]];
		[boss runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.8 position:ccp(1000, dawdle.y)]]];
	} 
	else if (action == 10) {
		[self skip];
	}
	return next;
}

- (void) skip {
	[self clearMessageAndBubble];
	curLevel = 0;
	[self changeTo: [[[StateLoseMenu alloc] init] autorelease] after:TRANSITION_PAUSE];
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	
	PongVader *pv = [PongVader getInstance];
	Fleet *bossFleet = [pv.fleets objectAtIndex:0];
	SpriteBody *boss = [bossFleet.invaders objectAtIndex:0];
	[boss tick:dTime];
	return [super doTimer:dTime];
}

@end

@implementation StateOutroPro

- (id) init {
	if ((self = [super init])) {
		times[0] = 2.0;			       // warp in invaders
		times[1] = times[0] + 3.0; // made it this far
		times[2] = times[1] + 3.0; // proud of you
		times[3] = times[2] + 3.0; // don't get cocky
		times[4] = times[3] + 3.0; // these are only training levels
		times[5] = times[4] + 3.0; // warmups are over
		times[6] = times[5] + 3.0; // prepare for the onslaught of ep1
		times[7] = times[6] + 3.0; // exit
		times[8] = times[7] + 3.0;
		
		PongVader *pv = [PongVader getInstance];
		pv.bossTime = YES;
		
		[pv.settings set:@"BeatPrologue" toInt:1];
	}
	return self;
}


- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	pv.bossTime = YES;
	[pv clearScene];
	[pv resetScene];
	
	if _IPAD {
		i1 = ccp(240, 300);
		i2 = ccp(320, 300);
	}
	else {
		i1 = ccp(90, 150);
		i2 = ccp(130, 150);
	}
	
	invader1 = [[pv addSpriteBody:[ENSPrance class] atPos:ccp(i1.x + 1000, i1.y) withForce:ccp(0,0)] retain];
	[invader1 promote: 1];
	
	
	invader2 = [[pv addSpriteBody:[LTWaddle class] atPos:ccp(i2.x + 1000, i2.y) withForce:ccp(0,0)] retain];
	[invader2 promote: 1];
	
	if (_IPAD) {
	invader1.baseScale = 2.0;
	invader1.scale = 2.0;
	invader2.baseScale = 2.0;
	invader2.scale = 2.0;
	}
	
	[pv.settings set:@"lastLevel" toInt:0];
}

- (void) leave {
	[[PongVader getInstance] destroyInvader:invader1 inGame:NO];
	[invader1 release];
	[[PongVader getInstance] destroyInvader:invader2 inGame:NO];
	[invader2 release];
	[super leave];
}

- (GameState *) doAction:(int) action {
	PongVader *pv = [PongVader getInstance];
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	GameState *next = self;
	
	CGPoint dawdle, inv;
	if _IPAD {
		dawdle = ccp(200, 512);
		inv = ccp(400,530);
	}
	else {
		dawdle = ccp(100, 216);
		inv = ccp(200,245);
	}
	
	if (action == 0) {
		[invader1 runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.5 position:i1]]];
		
		[invader2 runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.8 position:i2]]];
	} 
	else if (action == 1) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"AHA YOU'VE MADE IT THIS FAR." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:3];
	} 
	else if (action == 2) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"WE'RE PROUD OF YOU." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i2 rlen:22 rc:3 sp:2];
	} 
	else if (action == 3) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"BUT DON'T GET COCKY." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i2 rlen:22 rc:3 sp:2];
	} 
	else if (action == 4) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"THESE ARE ONLY TRAINING LEVELS." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i2 rlen:22 rc:3 sp:2];
	} 
	else if (action == 5) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"WARMUPS ARE OVER." font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:i1 rlen:20 rc:3 sp:1];
	} 
	else if (action == 6) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"PREPARE FOR THE ONSLAUGHT OF EPISODE 1." font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:i1 rlen:20 rc:8 sp:1];
	} 
	else if (action == 7) {
		[self clearMessageAndBubble];
		[invader1 runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.5 position:ccp(i1.x + 1000, i1.y)]]];
		
		[invader2 runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.8 position:ccp(i2.x + 1000, i2.y)]]];
	}
	else if (action == 8) {
		[self skip];
	}

	return next;
}

- (void) skip {
	[self clearMessageAndBubble];
	curLevel = 0;
	[self changeTo: [[[StateLoseMenu alloc] init] autorelease] after:TRANSITION_PAUSE];
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	
	
	return [super doTimer:dTime];
}

@end

@implementation StateOutroProUpsell

- (id) init {
	if ((self = [super init])) {
		times[0] = 2.0; // warp in invaders
		times[1] = times[0] + 3.0; // doesn't have to end like this
		times[2] = times[1] + 3.0; // could buy full version
		times[3] = times[2] + 3.0; // thend you'd get a ton of new levels
		times[4] = times[3] + 3.0; // plus two boss fights
		times[5] = times[4] + 3.0; // new music
		times[6] = times[5] + 3.0; // nullsleep comment
		times[7] = times[6] + 3.0; // give me a second
		times[8] = times[7] + 3.0; // nggh
		times[9] = times[8] + 1.0; // sound
		times[10] = times[9] + 1.0;// upsell alertview
		
		PongVader *pv = [PongVader getInstance];
		[pv.settings set:@"BeatPrologue" toInt:1];
		
		appStoreAlert = [[UIAlertView alloc] initWithTitle:@"Get more levels??" message:@"Would you like to buy 20 more levels for just a buck?" delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:nil];
		[appStoreAlert addButtonWithTitle:@"Yes! Yes! Yes!"];	

	}
	return self;
}

- (void) dealloc {
	[appStoreAlert release];
	[super dealloc];
}

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	[pv.settings set:@"lastLevel" toInt:0];
	
	if _IPAD {
		i1 = ccp(240, 300);
		i2 = ccp(320, 300);
	}
	else {
		i1 = ccp(90, 150);
		i2 = ccp(130, 150);
	}
	
	invader1 = [[pv addSpriteBody:[ENSPrance class] atPos:ccp(i1.x + 1000, i1.y) withForce:ccp(0,0)] retain];
	[invader1 promote: 1];
	
	invader2 = [[pv addSpriteBody:[LTWaddle class] atPos:ccp(i2.x + 1000, i2.y) withForce:ccp(0,0)] retain];
	[invader2 promote: 1];
	
	if (_IPAD) {
		invader1.baseScale = 2.0;
		invader1.scale = 2.0;
		invader2.baseScale = 2.0;
		invader2.scale = 2.0;
	}
}

- (void) leave {
	[[PongVader getInstance] destroyInvader:invader1 inGame:NO];
	[invader1 release];
	[[PongVader getInstance] destroyInvader:invader2 inGame:NO];
	[invader2 release];
	[super leave];
}

- (GameState *) doAction:(int) action {
	PongVader *pv = [PongVader getInstance];
	CGSize ssz = [CCDirector sharedDirector].winSize;

	GameState *next = self;
	
	CGPoint dawdle, inv;
	if _IPAD {
		dawdle = ccp(200, 512);
		inv = ccp(400,530);
	}
	else {
		dawdle = ccp(100, 216);
		inv = ccp(200,245);
	}
	
	if (action == 0) {
		[invader1 runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.5 position:i1]]];
		
		[invader2 runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.8 position:i2]]];
	} 
	else if (action == 1) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"IT DOESN'T HAVE TO END HERE, YOU KNOW." font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:7 ];
	} 
	else if (action == 2) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"YEAH, YOU COULD BUY THE FULL VERSION FOR A BUCK." font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:i2 rlen:22 rc:7 sp:2];
	} 
	else if (action == 3) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"THEN YOU'D GET 20 NEW LEVELS." font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:i2 rlen:22 rc:5 sp:2];
	} 
	else if (action == 4) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"PLUS TWO MORE BOSS FIGHTS." font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:i2 rlen:22 rc:3 sp:2];
	} 
	else if (action == 5) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"AND SOME MORE MUSIC." font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:i2 rlen:22 rc:3 sp:2];
	} 
	else if (action == 6) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"(THAT NULLSLEEP GUY IS A MACHINE, ISN'T HE)" font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:6];
	} 
	else if (action == 7) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"OK, GIVE ME A SECOND TO OPEN A PORTAL TO THE APP STORE." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:7];
	} 
	else if (action == 8) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"NGGGGGGGH" font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:i1 rlen:22 rc:3];
	} 
	else if (action == 9) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"portal.wav"];
	} 
	else if (action == 10) {
		[appStoreAlert show];
		

	}
	return next;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView == appStoreAlert) {
		switch(buttonIndex) {
			case 0:
				[self changeTo:[[[StateMainMenu alloc] init] autorelease] after:0.5];
				break;
			case 1:
				GameState *next = [[[StatePurchase alloc] initWithNextState:[StateMainMenu class]] autorelease];
				[self changeTo:next after:0.5];
				break;
		}
	}
}

- (void) skip {
//	[self clearMessageAndBubble];
//	curLevel = 0;
//	[self changeTo: [[[StateMainMenu alloc] init] autorelease] after:TRANSITION_PAUSE];
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	return [super doTimer:dTime];
}

@end

@implementation StateOutroEp2

- (id) init {
	if ((self = [super init])) {
		
		//*
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		// initialize fleet
		PongVader *pv = [PongVader getInstance];
		
		CGPoint originsAndDirs[] = {
			ccp(ssz.width+64, ssz.height/2-25), ccp(-1,2),
			ccp(ssz.width+64, ssz.height/2+25), ccp(-1,-2),
			ccp(-64, ssz.height/2-25), ccp(1,2),
			ccp(-64, ssz.height/2+25), ccp(1,-2)};
		
		int idx = 2*(arc4random()%4);
		
		Fleet *fleet = [[[Boss2Fleet alloc] initAtOrigin: originsAndDirs[idx]
												 withDir: originsAndDirs[idx+1]
												 playing: @"s---s-s-s---"
											  difficulty: curLevel] autorelease];	
		
		[pv addFleet: fleet];
		
		((Boss2Fleet *) fleet).brain.paused = YES;
		
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
		//*/
		
		times[0] = 1.5; // enter
		times[1] = times[0] + 2.0; // admiral brain
		times[2] = times[1] + 1.5; // * sound *
		times[3] = times[2] + 3.0; // in light of your 
		times[4] = times[3] + 1.5; // ahem
		times[5] = times[4] + 3.0; // resistance
		times[6] = times[5] + 3.0; // we've extended
		times[7] = times[6] + 2.0; // see you in 4007
		times[8] = times[7] + 1.5; // exit

		
	}
	return self;
}


- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	Fleet *bossFleet = [pv.fleets objectAtIndex:0];
	ADMBrain *boss = [bossFleet.invaders objectAtIndex:0];
	
	//[boss reset];
	boss.paused = YES;
	if (boss.upsidedown) [boss doRotate];
	
	[boss runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveTo actionWithDuration:0.8 position: _IPAD ? ccp(200, 512) : ccp(100,216)]]];
	peon = [[pv addSpriteBody:[ENSPrance class] atPos: _IPAD ? ccp(800, boss.position.y) : ccp(400, boss.position.y)  withForce:ccp(0,0)] retain];
	[(ENSPrance *) peon promote: 1];
	if (_IPAD) {
		peon.scale = 2.0;
		peon.baseScale = 2.0;
	}
	if (pv.OFstarted) {
		[OFAchievementService updateAchievement:@"679092" andPercentComplete:100 andShowNotification:YES];
	}
	pv.bossTime = YES;
	[pv.settings set:@"BeatEpTwo" toInt:1];
	[pv.settings set:@"lastLevel" toInt:0];
}

- (void) leave {
	[[PongVader getInstance] destroyInvader:peon inGame:NO];
	[peon release];
	[super leave];
}

- (GameState *) doAction:(int) action {
	PongVader *pv = [PongVader getInstance];
	CGSize ssz = [CCDirector sharedDirector].winSize;
	Fleet *bossFleet = [pv.fleets objectAtIndex:0];
	SpriteBody *boss = [bossFleet.invaders objectAtIndex:0];
	GameState *next = self;
	
	((Boss2Fleet *) bossFleet).brain.paused = YES;
	
	CGPoint dawdle, inv;
	if _IPAD {
		dawdle = ccp(200, 512);
		inv = ccp(400,530);
	}
	else {
		dawdle = ccp(100, 216);
		inv = ccp(100,100);
	}
	
	if (action == 0) {
		[peon runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.8 position:inv]]];
	} 
	else if (action == 1) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"ADMIRAL BRAIN!" font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:inv rlen:17 rc:6];
	} 
	else if (action == 2) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"wail.wav"];
	} 
	else if (action == 3) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"IN LIGHT OF YOUR" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:inv rlen:22 rc:3];
	} 
	else if (action == 4) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"AHEM" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:inv rlen:15 rc:3];
	}
	else if (action == 5) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"RESILIENCE" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:inv rlen:15 rc:3];
	} 
	else if (action == 6) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"WE'LL BE EXTENDING YOUR LOAN." font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:inv rlen:22 rc:4];
	} 
	else if (action == 7) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"SEE YOU IN 4007!" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:inv rlen:22 rc:3];
	} 
	else if (action == 8) {
		[self clearMessageAndBubble];
		[peon runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.4 position:ccp(1000, inv.y)]]];
		[boss runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.8 position:ccp(1000, dawdle.y)]]];
	} 
	else if (action == 9) {
		[self skip];
	} 

	return next;
}

- (void) skip {
	[self clearMessageAndBubble];
	curLevel = 0;
	[self changeTo: [[[StateLoseMenu alloc] init] autorelease] after:TRANSITION_PAUSE];
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	
	PongVader *pv = [PongVader getInstance];
	Fleet *bossFleet = [pv.fleets objectAtIndex:0];
	SpriteBody *boss = [bossFleet.invaders objectAtIndex:0];
	[boss tick:dTime];
	return [super doTimer:dTime];
}

@end

@implementation StateOutroOld

- (id) init {
	if ((self = [super init])) {
		times[0] = 2.0; // CPT : "why are they hurting me?"
		times[1] = 5.0; // ENS arrives
		times[2] = 6.0; // ENS : "Captain dawdle, you must retreat. You can't take much more of this!"
		times[3] = 12.0; // CPT : "The humans have proven hostile, we must inform admiral brain"
		times[4] = 18.0; // CPT : "We'll be back!"
		times[5] = 22.0; // exit stage right
		times[6] = 25.0; // return to main menu
		
	}
	return self;
}


- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	Fleet *bossFleet = [pv.fleets objectAtIndex:0];
	SpriteBody *boss = [bossFleet.invaders objectAtIndex:0];
	[boss reset];
	[boss runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveTo actionWithDuration:0.8 position:ccp(200, 512)]]];
	peon = [[pv addSpriteBody:[ENSPrance class] atPos:ccp(800, boss.position.y) withForce:ccp(0,0)] retain];
	if (pv.OFstarted) {
		[OFAchievementService updateAchievement:BALL_MASTER andPercentComplete:100 andShowNotification:YES];
	}
}

- (void) leave {
	[[PongVader getInstance] destroyInvader:peon inGame:NO];
	[peon release];
	[super leave];
}

- (GameState *) doAction:(int) action {
	PongVader *pv = [PongVader getInstance];
	CGSize ssz = [CCDirector sharedDirector].winSize;
	Fleet *bossFleet = [pv.fleets objectAtIndex:0];
	SpriteBody *boss = [bossFleet.invaders objectAtIndex:0];
	GameState *next = self;
	if (action == 0) {
		messageLabel = [[Utils multilineNodeWithText:@"WHY ARE THEY HURTING ME?" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:ccp(200, 512 + 60) rlen:15 rc:2];
	} else if (action == 1) {
		[self clearMessageAndBubble];
		[peon runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.8 position:ccp(400, 500)]]];
	} else if (action == 2) {
		messageLabel = [[Utils multilineNodeWithText:@"CAPTAIN DAWDLE, YOU MUST RETREAT. YOU CAN'T TAKE MUCH MORE OF THIS!" font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:ccp(400,530) rlen:17 rc:6];
	} else if (action == 3) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"THE HUMANS HAVE PROVEN HOSTILE. WE MUST INFORM ADMIRAL BRAIN" font:pv.smallFont color: ccc3(0,0,0) rowlength:10 rowheight:16] retain];
		[self placeBubble:ccp(200, 512 + 60) rlen:14 rc:5];
	} else if (action == 4) {
		[self clearMessageAndBubble];
		messageLabel = [[Utils multilineNodeWithText:@"WE SHALL RETURN!" font:pv.smallFont color: ccc3(0,0,0) rowlength:12 rowheight:16] retain];
		[self placeBubble:ccp(200, 512 + 60) rlen:15 rc:1];
	} else if (action == 5) {
		[self clearMessageAndBubble];
		[peon runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.8 position:ccp(1000, 512)]]];
		[boss runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:0.8 position:ccp(1000, 512)]]];
	} else if (action == 6) {
		[self skip];
	}
	return next;
}

- (void) skip {
	[self clearMessageAndBubble];
	curLevel = 0;
	[self changeTo: [[[StateLoseMenu alloc] init] autorelease] after:TRANSITION_PAUSE];
}

- (GameState *) doTimer:(CFTimeInterval)dTime {
	
	PongVader *pv = [PongVader getInstance];
	Fleet *bossFleet = [pv.fleets objectAtIndex:0];
	SpriteBody *boss = [bossFleet.invaders objectAtIndex:0];
	[boss tick:dTime];
	return [super doTimer:dTime];
}

@end


@implementation StateLevelMadison

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
	
		char block[] = "xxxxxxxxxxxxxxxxxxxxxxxxqqqqqqqqaaaaaaaaxxxxxxxxxxxxxxxxxxxxxxxx";
		//char block[] = "qqqqqqqqqqqqqqqqxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxaaaaaaaaaaaaaaaa";
		//char block[] = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxqxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

		CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block 
										   andDims: ccp(8,8) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: origins[0] 
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"bxxxbxxx"
										difficulty: curLevel] autorelease]};	
		[pv addFleet: fleets[0]];
	}

	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 1; }

@end

@implementation StateLevel1972

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block1[] = "qqqaaa";
		char block2[] = "WwwW";
		
		CGPoint originspad[] = {ccp(64,ssz.height/2), ccp(ssz.width-64,ssz.height/2), ccp(ssz.width/2, ssz.height/2)};
		CGPoint originsphn[] = {ccp(32,ssz.height/2), ccp(ssz.width-32,ssz.height/2), ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block1 
										   andDims: ccp(1,6) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD? originspad[0] : originsphn[0]
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(0,-1) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"bxmx"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block1 
										   andDims: ccp(1,6) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD? originspad[1] : originsphn[1]
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(0,1) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"bxmx"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block2 
										   andDims: ccp(2,2) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD? originspad[2] : originsphn[2]
										  maxWidth: _IPAD ? 600 : 250
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"mxsx"
										difficulty: curLevel] autorelease],
		};	
		
		[pv addFleet: fleets[0]];
		[pv addFleet: fleets[1]];
		[pv addFleet: fleets[2]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 1; }

@end

@implementation StateLevelLabyrinth

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block1[] = "zzzzzz\
zxxxxz\
zxxxxz\
xxxxxx\
zxxxxz\
zxxxxz\
zzzzzz";
		char block2[] = "Q";
		
		CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block1 
										   andDims: ccp(6,7) 
									   withSpacing: _IPAD ? 54 : 27 
										  atOrigin: origins[0] 
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"x"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block2
										   andDims: ccp(1,1) 
									   withSpacing: _IPAD ? 40 : 25 
										  atOrigin: origins[0] 
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 0 : 0
										 fromRight: NO 
										   playing: @"sxxx"
										difficulty: curLevel] autorelease],
		
		};	
		[pv addFleet: fleets[0]];
		[pv addFleet: fleets[1]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 1; }

@end

@implementation StateLevelKey

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block1[] = "\
QQQQQxxxxx\
QwwwQqqqqq\
QwwwQqqqqq\
QwwwQxxqxq\
QwwwQxxqxq\
QQQQQxxqxq";
		
		char block2[] = "\
		QwwwQxxqxq\
		QwwwQxxqxq\
		QQQQQxxqxq";
		
		CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block1 
										   andDims: ccp(10,6) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: origins[0] 
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"bxxxbxxx"
										difficulty: curLevel] autorelease]};	
		[pv addFleet: fleets[0]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 1; }

@end

@implementation StateLevelFish

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block[] = "xxzqqqqqqzxx\
xzqqqqqqqqzx\
xzqqqqqqqqzx\
zqqqqqqqqqqz\
zqqqqzzqqqqz\
zqqqqzzqqqqz\
zqqqqqqqqqqz\
xzqqqqqqqqzx\
xzqqqqqqqqzx\
xxzqqqqqqzxx";
		
		CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block 
										   andDims: ccp(12,10) 
									   withSpacing: _IPAD ? 50 : 25 
										  atOrigin: origins[0] 
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 0 : 0
										 fromRight: NO 
										   playing: @"ssxx"
										difficulty: curLevel] autorelease]};	
		[pv addFleet: fleets[0]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 4; }
- (int) getPowerupChance { return 100; }

@end

@implementation StateLevelPeace

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block[] = "\
xxxaaaxxx\
xxaxwxaxx\
xaxxwxxax\
axxxwxxxa\
axxwxwxxa\
axxwxwxxa\
xawxxxwax\
xxaxxxaxx\
xxxaaaxxx";		
		CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block 
										   andDims: ccp(9,9) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: origins[0] 
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"sxxx"
										difficulty: curLevel] autorelease]};	
		[pv addFleet: fleets[0]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 1; }

@end
/*
@implementation StateLevelKaboom

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block[] = "\
		xxxxxQ\
		xxxxQx\
		xxxQxx\
		xxQQxx\
		xQwwQx\
		QwwwwQ\
		QwwwwQ\
		xQwwQx\
		xxQQxx";
		
		CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block 
										   andDims: ccp(6,9) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: origins[0] 
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"bxxxbxxx"
										difficulty: curLevel] autorelease]};	
		[pv addFleet: fleets[0]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 1; }

@end
 */

@implementation StateBattlePro

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block[] = "0";
		
		CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block 
										   andDims: ccp(1,1) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: origins[0] 
										  maxWidth: _IPAD ? 700 : 300
										   initDir: ccp(1,0)
											  step: 20
										 fromRight: NO 
										   playing: @"mmmmsmmmmmmmm"
										difficulty: curLevel] autorelease]};	
		[pv addFleet: fleets[0]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 1; }

@end

@implementation StateLevelSizzurp

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block[] = "\
xxxxxxxaaxxxxxxx\
xxxxxxaddaxxxxxx\
xxxxaaaaaaaaxxxx\
DSASDSASDSASDSAS\
WEWQWEWQWEWQWEWQ\
xxxxqqqqqqqqxxxx\
xxxxxxqeeqxxxxxx\
xxxxxxxqqxxxxxxx";
		
		CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block 
										   andDims: ccp(16,8) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: origins[0] 
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 0 : 0
										 fromRight: NO 
										   playing: @"sxsxsssx"
										difficulty: curLevel] autorelease]};	
		[pv addFleet: fleets[0]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 3; }

- (int) getPowerupChance { return 100; }

@end

@implementation StateLevel1978

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block[] = "\
xxxQQxxx\
xxQQQQxx\
xQQQQQQx\
QQxQQxQQ\
qqqqqqqq\
xxqxxqxx\
xqxqqxqx\
qxqxxqxq";
		
		CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block 
										   andDims: ccp(8,8) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: origins[0] 
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"bsxxbsxx"
										difficulty: curLevel] autorelease]};	
		[pv addFleet: fleets[0]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 1; }

@end

@implementation StateLevelSteady

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
char block1[] = "rrrrr\
rxxxr\
xxxxx\
fxxxf\
fffff";
char block2[] = "Q";
		
		CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block1 
										   andDims: ccp(5,5) 
									   withSpacing: _IPAD ? 50 : 25 
										  atOrigin: origins[0] 
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"x"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block2
										   andDims: ccp(1,1) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: origins[0] 
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 0 : 0
										 fromRight: NO 
										   playing: @"sxxx"
										difficulty: curLevel] autorelease],
			
		};	
		[pv addFleet: fleets[0]];
		[pv addFleet: fleets[1]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 1; }

@end

@implementation StateLevelShine

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block1[] = "\
xxxxQQxxxx\
xxxQEEQxxx\
xxQxEExQxx\
xxxEEEExxx\
xxxxEExxxx\
xxxxQQxxxx";
		
char block2[] = "\
DDxxxxxxDD\
xxDDxxDDxx\
xxxxDDxxxx\
xxDDxxDDxx\
AAxxxxxxAA";
		
		CGPoint originspad[] = {ccp(ssz.width/2, ssz.height/2 + 150), ccp(ssz.width/2, ssz.height/2 - 150)};
		CGPoint originsphn[] = {ccp(ssz.width/2, ssz.height/2 + 75), ccp(ssz.width/2, ssz.height/2 - 75) };
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block1
										   andDims: ccp(10,6) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD? originspad[0] : originsphn[0] 
										  maxWidth: _IPAD ? 200	: 100
										   initDir: ccp(0,1) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"bxxxbxsx"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block2
										   andDims: ccp(10,5) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD? originspad[1] : originsphn[1] 
										  maxWidth: _IPAD ? 200	: 100
										   initDir: ccp(0,-1) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"bxsxbxxx"
										difficulty: curLevel] autorelease]
		
		};	
		[pv addFleet: fleets[0]];
		[pv addFleet: fleets[1]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 5; }
- (int) getPowerupChance { return 75; }

@end

@implementation StateLevelGimmeShelter

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block1[] = "xxxxxxxxxxxxxxxxxxxxxxxxqqqqqqqqaaaaaaaaxxxxxxxxxxxxxxxxxxxxxxxx";
		char block2[] = "xrxrrrryr";
		char block3[] = "fyffffxfx";
		
		CGPoint originspad[] = {ccp(ssz.width/2, ssz.height/2), 
			ccp(ssz.width/2 - 150, ssz.height/2 - 150), ccp(ssz.width/2 + 150, ssz.height/2 - 150),
			ccp(ssz.width/2-150, ssz.height/2+150), ccp(ssz.width/2+150, ssz.height/2+150)};
		CGPoint originsphn[] = {ccp(ssz.width/2, ssz.height/2), 
			ccp(ssz.width/2 - 75, ssz.height/2 - 75), ccp(ssz.width/2 + 75, ssz.height/2 - 75),
			ccp(ssz.width/2-75, ssz.height/2+75), ccp(ssz.width/2+75, ssz.height/2+75)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block1
										   andDims: ccp(8,8) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD ? originspad[0] : originsphn[0]
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"bxxxbxxx"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block2 
										   andDims: ccp(3,3) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD ? originspad[1] : originsphn[1]
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"x"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block2 
										   andDims: ccp(3,3) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD ? originspad[2] : originsphn[2]
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"x"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block3 
										   andDims: ccp(3,3) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD ? originspad[3] : originsphn[3]
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"x"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block3 
										   andDims: ccp(3,3) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD ? originspad[4] : originsphn[4]
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"x"
										difficulty: curLevel] autorelease],
		
		
		};	
		[pv addFleet: fleets[0]];
		[pv addFleet: fleets[1]];
		[pv addFleet: fleets[2]];
		[pv addFleet: fleets[3]];
		[pv addFleet: fleets[4]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 1; }

@end

@implementation StateLevelSoMeta

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block1[] = "fffrrr";
		char block2[] = "\
xxxQQxxx\
xxQQQQxx\
xQEEEEQx\
QExEExEQ\
adddddda\
xxDxxDxx\
xAxAAxAx\
AxAxxAxA";
		
		CGPoint originspad[] = {ccp(64,ssz.height/2), ccp(ssz.width-64,ssz.height/2), ccp(ssz.width/2, ssz.height/2)};
		CGPoint originsphn[] = {ccp(32,ssz.height/2), ccp(ssz.width-32,ssz.height/2), ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block1 
										   andDims: ccp(1,6) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD? originspad[0] : originsphn[0]
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(0,-1) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"mxxx"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block1 
										   andDims: ccp(1,6) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD? originspad[1] : originsphn[1]
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(0,1) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"mxxx"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block2
										   andDims: ccp(8,8) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD? originspad[2] : originsphn[2] 
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"bssxbsxx"
										difficulty: curLevel] autorelease],
		};	
		
		[pv addFleet: fleets[0]];
		[pv addFleet: fleets[1]];
		[pv addFleet: fleets[2]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 1; }

@end

@implementation StateLevelLastStraw

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block1[] = "rrrrrr";
		
		char block2[] = "\
QxxAAAxAAA\
xQxAAAxAAA\
xxQAAAxAAA\
xxxxAAAAAx\
xxxxAAAAAx";
		
		CGPoint originspad[] = {ccp(ssz.width/2+60,ssz.height/2+50), ccp(ssz.width/2,ssz.height/2-50)};
		CGPoint originsphn[] = {ccp(ssz.width/2+30,ssz.height/2+25), ccp(ssz.width/2,ssz.height/2-25)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block1 
										   andDims: ccp(1,6) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD? originspad[0] : originsphn[0]
										  maxWidth: _IPAD ? 200 : 100
										   initDir: ccp(0,-1) 
											  step: _IPAD ? 40 : 20
										 fromRight: NO 
										   playing: @"m"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block2 
										   andDims: ccp(10,5) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD? originspad[1] : originsphn[1]
										  maxWidth: _IPAD ? 200 : 100
										   initDir: ccp(0,1) 
											  step: _IPAD ? 20 : 20
										 fromRight: NO 
										   playing: @"bm"
										difficulty: curLevel] autorelease]
		};	
		
		[pv addFleet: fleets[0]];
		[pv addFleet: fleets[1]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup {
//	int effect;
//	int powerupType = arc4random() % 2;
//	switch (powerupType) {
//		case 0:
//			effect = POW_ENSPRANCE;
//			break;
//		case 1:
//			effect = POW_STAT;
//			break;
//	}
	return POW_STAT;
}

- (int) getPowerupChance { return 100; }

@end

@implementation StateLevelPanicBomber

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) { // This will not be zero after intro
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block1[] = "\
rrrrrrrrrrrr\
rrrrrrrrrrrr\
rrrrrrrrrrrr\
rrrrrrrrrrrr\
rrrrrrrrrrrr\
rrxrrrfffxff\
ffffffffffff\
ffffffffffff\
ffffffffffff\
ffffffffffff\
ffffffffffff";
		
		char block2[] = "DxxxxxxD";
		char block3[] = "ya";
		
		CGPoint originspad[] = {ccp(ssz.width/2, ssz.height/2), ccp(ssz.width/2, ssz.height/2-20), 
			ccp(ssz.width/2, ssz.height/2-240), ccp(ssz.width/2, ssz.height/2+240)};
		CGPoint originsphn[] = {ccp(ssz.width/2, ssz.height/2), ccp(ssz.width/2, ssz.height/2-10),
								ccp(ssz.width/2, ssz.height/2-120), ccp(ssz.width/2, ssz.height/2+120)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block1
										   andDims: ccp(12,10) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD ? originspad[0] : originsphn[0]
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"x"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block2
										   andDims: ccp(8,1) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD ? originspad[1] : originsphn[1]
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"sx"
										difficulty: curLevel] autorelease],
			
			
			[[[DirBlockFleet alloc] initWithConfig: block3
										   andDims: ccp(2,1) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD ? originspad[2] : originsphn[2]
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"mx"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block3
										   andDims: ccp(2,1) 
									   withSpacing: _IPAD ? 40 : 20 
										  atOrigin: _IPAD ? originspad[3] : originsphn[3]
										  maxWidth: _IPAD ? 400 : 200
										   initDir: ccp(1,0) 
											  step: _IPAD ? 50 : 20
										 fromRight: NO 
										   playing: @"mx"
										difficulty: curLevel] autorelease]};	
		[pv addFleet: fleets[0]];
		[pv addFleet: fleets[1]];
		
		[pv addFleet: fleets[2]];
		[pv addFleet: fleets[3]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return 1; }

@end

@implementation StateLevelPAX

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) {
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		//char block[] = "xxxxxxxxxxxxxxxxxxxxxxxxqqqqqqqqaaaaaaaaxxxxxxxxxxxxxxxxxxxxxxxx";
		//char block[] = "qqqqqqqqqqqqqqqqxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxaaaaaaaaaaaaaaaa";
		//  char block[] = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxqxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
		
		char block0[] = "\
		aaaa\
		axxa\
		aaaa\
		axxx\
		axxx";
		
		char block1[] = "\
		aaaa\
		axxa\
		aaaa\
		axxa\
		axxa";
		
		char block2[] = "\
		axxa\
		axxa\
		xssx\
		axxa\
		axxa";
		
		CGPoint origins[] = {ccp(ssz.width/2 - 250, ssz.height/2), ccp(ssz.width/2, ssz.height/2), ccp(ssz.width/2 + 250, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block0
										   andDims: ccp(4,5) 
									   withSpacing: 40 
										  atOrigin: origins[0] 
										  maxWidth: 250 
										   initDir: ccp(1,0) 
											  step: 50
										 fromRight: NO 
										   playing: @"bxxx"
										difficulty: curLevel] autorelease],
			
			[[[DirBlockFleet alloc] initWithConfig: block1
										   andDims: ccp(4,5) 
									   withSpacing: 40 
										  atOrigin: origins[1] 
										  maxWidth: 250 
										   initDir: ccp(1,0) 
											  step: 50
										 fromRight: NO 
										   playing: @"xbxx"
										difficulty: curLevel] autorelease],
			[[[DirBlockFleet alloc] initWithConfig: block2
										   andDims: ccp(4,5) 
									   withSpacing: 40 
										  atOrigin: origins[2] 
										  maxWidth: 250 
										   initDir: ccp(1,0) 
											  step: 50
										 fromRight: NO 
										   playing: @"xxbx"
										difficulty: curLevel] autorelease],};	
		[pv addFleet: fleets[0]];
		[pv addFleet: fleets[1]];
		[pv addFleet: fleets[2]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

@implementation StateLevelBoxers

- (void) enter {
	[super enter];

	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	/*
//	char block1[] = "\
//	xxxqqxxx\
//	xxqqqqxx\
//	xqqxxqqx\
//	qqxxxxqq\
//	aaxxxxaa\
//	xaaxxaax\
//	xxaaaaxx\
//	xxxaaxxx";
//	
//	char block2[] = "\
//	xxxqqxxx\
//	xxqqqqxx\
//	xqqxxqqx\
//	qqxxxxqq\
//	aaxxxxaa\
//	xaaxxaax\
//	xxaaaaxx\
//	xxxaaxxx"; */
	
	
	char block1[] = "\
xxxxxxxx\
xxxqqxxx\
xxqqqqxx\
xqqxxqqx\
xaaxxaax\
xxaaaaxx\
xxxaaxxx\
xxxxxxxx";
	
	CGPoint originspad[] = {ccp(ssz.width/3-25, ssz.height/2), ccp(2*ssz.width/3+25, ssz.height/2)};
	CGPoint originsphn[] = {ccp(ssz.width/2-66, ssz.height/2), ccp(ssz.width/2+66, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(8,8)
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: _IPAD ? originspad[0] : originsphn[0] 
									  maxWidth: _IPAD ? 250 : 85 
									   initDir: ccp(1, 0) 
		  							      step: _IPAD ? 50 : 20
									 fromRight: YES  
									   playing: @"xmxs"
									difficulty: curLevel] autorelease],
		
		[[[DirBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(8,8)
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: _IPAD ? originspad[1] : originsphn[1]
									  maxWidth: _IPAD ? 250 : 85
									   initDir: ccp(-1, 0)
		  							      step: _IPAD ? 50 : 20
									 fromRight: NO
									   playing: @"xsxm"
									difficulty: curLevel] autorelease]};
	
	
	/*
	LineFleet *fleets[] = {
		[[[LineFleet alloc] initWithSize:3 andWidth:400 maxWidth:768 atOrigin:origins[0] upsideDown:NO  stationary:NO difficulty:0 classes:classes0] autorelease],
		[[[LineFleet alloc] initWithSize:3 andWidth:400 maxWidth:768 atOrigin:origins[1] upsideDown:YES stationary:NO difficulty:0 classes:classes1] autorelease]}; 
	 */
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	
	[[BeatSequencer getInstance] addEvents: 2, 
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]]];
	
}
- (int) getPowerup {
//	int effect;
//	// spawn powerups of random type
//	int powerupType = arc4random() % 2;
//	switch (powerupType) {
//		case 1:
//			effect = POW_LTWADDLE;
//			break;
//		default:
//			effect = 0;
//			break;
//	}
	return POW_LTWADDLE;
}

@end


@implementation StateLevelClockwork

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	char block[] = "\
xxxqqxxx\
xxqqqqxx\
xqqxxqqx\
qqxqwxqq\
aaxsaxaa\
xaaxxaax\
xxaaaaxx\
xxxaaxxx";
	
	/*
	 char cycle[] = {
	 0,  1,  2,  3,  4,  5,  6,  7,
	 8,  9,  10, 11, 12, 13, 14, 15,
	 16, 17, 18, 19, 20, 21, 22, 23, 
	 24, 25, 26, 27, 28, 29, 30, 31,
	 32, 33, 34, 35, 36, 37, 38, 39,
	 40, 41, 42, 43, 44, 45, 46, 47,
	 48, 49, 50, 51, 52, 53, 54, 55,
	 56, 57, 58, 59, 60, 61, 62, 63};
	 */
	
	unsigned char cycle[] = {
		0,  1,  2,  4,  13,  5,  6,  7,
		8,  9,  3,  18, 11, 22, 14, 15,
		16, 10, 25, 19, 20, 12, 31, 23, 
		17, 33, 26, 27, 28, 29, 21, 39,
		24, 42, 34, 35, 36, 37, 30, 46,
		40, 32, 51, 43, 44, 38, 53, 47,
		48, 49, 41, 52, 45, 60, 54, 55,
		56, 57, 58, 50, 59, 61, 62, 63};
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block
										 andDims: ccp(8,8) 
									 withSpacing: _IPAD ? 50 : 25
										atOrigin: origins[0]
										cycleMap: cycle 
									   fromRight: YES  
										 playing: @"mxss"
									  difficulty: curLevel] autorelease]};		
	
	/*
	 LineFleet *fleets[] = {
	 [[[LineFleet alloc] initWithSize:3 andWidth:400 maxWidth:768 atOrigin:origins[0] upsideDown:NO  stationary:NO difficulty:0 classes:classes0] autorelease],
	 [[[LineFleet alloc] initWithSize:3 andWidth:400 maxWidth:768 atOrigin:origins[1] upsideDown:YES stationary:NO difficulty:0 classes:classes1] autorelease]}; 
	 */
	
	[pv addFleet: fleets[0]];
	//[pv addFleet: fleets[1]];
	
	[[BeatSequencer getInstance] addEvent:
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]]];
}	

- (int) getPowerup {
	return POW_LTWADDLE;
}

@end

@implementation StateLevelNoEscape

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	char block1[] = "\
xQQQQQQx\
qqqqqqqq\
aaaaaaaa\
xAAAAAAx";
	
	/*
	 char block2[] = "\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
zxxxxzzxxxxz\
zxxxxxxxxxxz\
zxxxxxxxxxxz\
zxxxxxxxxxxz\
zxxxxxxxxxxz\
zxxxxzzxxxxz\
xxxxxxxxxxxx\
xxxxxxxxxxxx"; */

	
	 char block2[] = "\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxzzzzxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxzzzzxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx";

	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(8,4)
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: origins[0]
									  maxWidth: _IPAD ? 250 : 120
									   initDir: ccp(1, 0) 
		  							      step: _IPAD ? 50 : 20
									 fromRight: YES
									   playing: @"mxsxmxsxmmssmxsx"
									difficulty: curLevel] autorelease],

		[[[BlockFleet alloc]    initWithConfig: block2 
									   andDims: ccp(12,10) 
								   withSpacing: _IPAD ? 64 : 32 
									  atOrigin: origins[0]
									 fromRight: NO 
									   playing: nil
									difficulty: curLevel] autorelease]};
	
	/*
	 LineFleet *fleets[] = {
	 [[[LineFleet alloc] initWithSize:3 andWidth:400 maxWidth:768 atOrigin:origins[0] upsideDown:NO  stationary:NO difficulty:0 classes:classes0] autorelease],
	 [[[LineFleet alloc] initWithSize:3 andWidth:400 maxWidth:768 atOrigin:origins[1] upsideDown:YES stationary:NO difficulty:0 classes:classes1] autorelease]}; 
	 */
	
	fleets[1].shouldShoot = NO;
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	
	[[BeatSequencer getInstance] addEvents: 2, 
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]]];
	
	/*
Rock *rock = (Rock *)[pv addSpriteBody:[Rock class] atPos:ccp(300,300) withForce:ccp(0,0)];
	rock.opacity = 0;
	[rock runAction:[CCFadeTo actionWithDuration:1.0 opacity: 255]];
	*/
	
}

- (int) getPowerup {
//	int effect;
//	// spawn powerups of random type
//	int powerupType = arc4random() % 2;
//	switch (powerupType) {
//		case 0:
//			effect = POW_ENSPRANCE;
//			break;
//		case 1:
//			effect = POW_LTWADDLE;
//			break;
//		default:
//			effect = 0;
//			break;
//	}
	return POW_ENSPRANCE;
}


@end

@implementation StateLevelEscalator

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	
	 char block1[] = "\
xxxxxxxx\
xzzxxxaa\
xxxxxaax\
xxxxasxx\
xxxaaxxx\
xxsaxxxx\
xaaxxxxx\
aaxxxxxx";

	char block2[] = "\
xxxxxxqq\
xxxxxqqx\
xxxxqwxx\
xxxqqxxx\
xxwqxxxx\
xqqxxxxx\
qqxxxzzx\
xxxxxxxx";
	
	char block3[] = "\
xxxxxxxx\
xxxxxxxx\
xxxQQxxx\
xxQEEQxx\
xxADDAxx\
xxxAAxxx\
xxxxxxxx\
xxxxxxxx";

	/*
	 char cycle[] = {
	 0,  1,  2,  3,  4,  5,  6,  7,
	 8,  9,  10, 11, 12, 13, 14, 15,
	 16, 17, 18, 19, 20, 21, 22, 23, 
	 24, 25, 26, 27, 28, 29, 30, 31,
	 32, 33, 34, 35, 36, 37, 38, 39,
	 40, 41, 42, 43, 44, 45, 46, 47,
	 48, 49, 50, 51, 52, 53, 54, 55,
	 56, 57, 58, 59, 60, 61, 62, 63};
	 */
	
	unsigned char cycle1[] = {
		0,  1,  2,  3,  4,  5,  6,  7,
		8,  9,  10, 11, 12, 13, 15, 22,
		16, 17, 18, 19, 20, 14, 29, 23, 
		24, 25, 26, 27, 21, 36, 30, 31,
		32, 33, 34, 28, 43, 37, 38, 39,
		40, 41, 35, 50, 44, 45, 46, 47,
		48, 42, 57, 51, 52, 53, 54, 55,
		49, 56, 58, 59, 60, 61, 62, 63};
	
	unsigned char cycle2[] = {
		0,  1,  2,  3,  4,  5,  13,  6,
		8,  9,  10, 11, 12, 20, 7,  15,
		16, 17, 18, 19, 27, 14, 22, 23, 
		24, 25, 26, 34, 21, 29, 30, 31,
		32, 33, 41, 28, 36, 37, 38, 39,
		40, 48, 35, 43, 44, 45, 46, 47,
		49, 42, 50, 51, 52, 53, 54, 55,
		56, 57, 58, 59, 60, 61, 62, 63};
	
	unsigned char cycle3[] = {
		0,  1,  2,  3,  4,  5,  6,  7,
		8,  9,  10, 11, 12, 13, 14, 15,
		16, 17, 18, 26, 19, 21, 22, 23, 
		24, 25, 34, 27, 28, 20, 30, 31,
		32, 33, 43, 35, 36, 29, 38, 39,
		40, 41, 42, 44, 37, 45, 46, 47,
		48, 49, 50, 51, 52, 53, 54, 55,
		56, 57, 58, 59, 60, 61, 62, 63};
	
	
	CGPoint originspad[] = {ccp(200, ssz.height/2+150), ccp(ssz.width-200, ssz.height/2-150), ccp(ssz.width/2, ssz.height/2)};
	CGPoint originsphn[] = {ccp(100, ssz.height/2+75), ccp(ssz.width-100, ssz.height/2-75), ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block1 
										 andDims: ccp(8,8)  
									 withSpacing: _IPAD ? 35 : 16
										atOrigin: _IPAD ? originspad[0] : originsphn[0]
										cycleMap: cycle1 
									   fromRight: YES  
										 playing: @"smsmmm"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig: block2 
										 andDims: ccp(8,8) 
									 withSpacing: _IPAD ? 35 : 16
										atOrigin: _IPAD ? originspad[1] : originsphn[1]
										cycleMap: cycle2 
									   fromRight: YES 
										 playing: @"mmmsms"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig: block3 
										 andDims: ccp(8,8) 
									 withSpacing: _IPAD ? 35 : 16
										atOrigin: _IPAD ? originspad[2] : originsphn[2]
										cycleMap: cycle3 
									   fromRight: YES  
										 playing: @"smmmsmmm"
									  difficulty: curLevel] autorelease]};		
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	
	[[BeatSequencer getInstance] addEvents: 3,
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]]];	
	
}	

- (int) getPowerup {
	int effect;
	// spawn powerups of random type
	int powerupType = arc4random() % 3;
	switch (powerupType) {
		case 0:
			effect = POW_ENSPRANCE;
			break;
		case 1:
			effect = POW_LTWADDLE;
			break;
		case 3:
			effect = POW_STAT;
			break;
		default:
			effect = 0;
			break;
	}
	return effect;
}

@end

/* original level six -- could still be fun once we implement more robust sequencing for fleets
@implementation StateLevel6

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	
	char block1[] = "\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx\
xxaaaaxx\
xxxDDxxx\
xttttttx\
xxxxxxxx";
	
	char block2[] = "\
xxxxxxxx\
xTTTTTTx\
xxxEExxx\
xxqqqqxx\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx";
	
	char block3[] = "\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
zzzxxxxxxzzz\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx";
	
	
	CGPoint origins[] = {
		ccp(225, ssz.height/2-100), ccp(ssz.width-225, ssz.height/2-100), 
		ccp(225, ssz.height/2+100), ccp(ssz.width-225, ssz.height/2+100), 
		ccp(ssz.width/2, ssz.height/2-32)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig:block1 andDims:ccp(8,8) withSpacing: 40 atOrigin:origins[0] maxWidth: 250 initDir: ccp(1, 0)  fromRight: NO  difficulty:curLevel] autorelease],
		[[[DirBlockFleet alloc] initWithConfig:block1 andDims:ccp(8,8) withSpacing: 40 atOrigin:origins[1] maxWidth: 250 initDir: ccp(-1, 0)  fromRight: YES  difficulty:curLevel] autorelease],
		[[[DirBlockFleet alloc] initWithConfig:block2 andDims:ccp(8,8) withSpacing: 40 atOrigin:origins[2] maxWidth: 250 initDir: ccp(1, 0)  fromRight: NO  difficulty:curLevel] autorelease],
		[[[DirBlockFleet alloc] initWithConfig:block2 andDims:ccp(8,8) withSpacing: 40 atOrigin:origins[3] maxWidth: 250 initDir: ccp(-1, 0)  fromRight: YES  difficulty:curLevel] autorelease],
		[[[BlockFleet alloc]    initWithConfig:block3 andDims:ccp(12,10) withSpacing: 64 atOrigin:origins[4] fromRight: NO difficulty:curLevel] autorelease]};
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	[pv addFleet: fleets[3]];
	[pv addFleet: fleets[4]];
	
	[[BeatSequencer getInstance] addEvents: 4,
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[3] andSequencer:[BeatSequencer getInstance]]];	
	
}	

@end
 */

@implementation StateLevelFlipside

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	
	char block1[] = "\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx\
xxaaaaxx\
xxxDDxxx\
xttttttx\
xxxxxxxx";
	
	char block2[] = "\
xxxxxxxx\
xTTTTTTx\
xxxEExxx\
xxqqqqxx\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx";
	
	char block3[] = "\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxzzzzzzxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx";
	
	
	CGPoint originspad[] = {
		ccp(ssz.width/2, ssz.height/2-100), ccp(ssz.width/2, ssz.height/2+100), 
		ccp(ssz.width/2, ssz.height/2-32)};
	CGPoint originsphn[] = {
		ccp(ssz.width/2, ssz.height/2-50), ccp(ssz.width/2, ssz.height/2+50), 
		ccp(ssz.width/2, ssz.height/2-16)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(8,8) 
								   withSpacing: _IPAD ? 40 : 20 
									  atOrigin: _IPAD ? originspad[0] : originsphn[0]
									  maxWidth: _IPAD ? 500 : 250
									   initDir: ccp(1, 0)
		  							      step: _IPAD ? 50 : 20
									 fromRight: NO  
									   playing: @"mxmxmsxs"
									difficulty: curLevel] autorelease],
		
		[[[DirBlockFleet alloc] initWithConfig: block2 
									   andDims: ccp(8,8)
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: _IPAD ? originspad[1] : originsphn[1]
									  maxWidth: _IPAD ? 500 : 250
									   initDir: ccp(1, 0) 
		  							      step: _IPAD ? 50 : 20
									 fromRight: NO 
									   playing: @"msxsmxmx"
									difficulty: curLevel] autorelease],
		
		[[[BlockFleet alloc]    initWithConfig: block3
									   andDims: ccp(12,10)
								   withSpacing: _IPAD ? 64 : 32
									  atOrigin: _IPAD ? originspad[2] : originsphn[2]
									 fromRight: NO
									   playing: nil
									difficulty: curLevel] autorelease]};
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	
	[[BeatSequencer getInstance] addEvents: 3,
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]]];	
	
}	

- (int) getPowerup {
//	int effect;
//	// spawn powerups of random type
//	int powerupType = arc4random() % 4;
//	switch (powerupType) {
//		case 0:
//			effect = POW_ENSPRANCE;
//			break;
//		case 1:
//			effect = POW_LTWADDLE;
//			break;
//		case 2:
//			effect = POW_STAT;
//			break;
//		default:
//			effect = 0;
//			break;
//	}
	return POW_STAT;
}

@end

@implementation StateLevelWeakest

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	
	char block1[] = "\
xxxxxxxx\
zTTtTTTz\
zxwxxwxz\
zxxxxxxz\
zxxxxxxz\
zxsxxsxz\
ztttTttz\
xxxxxxxx";
	
	char block2[] = "\
zzz\
";
	
	
	/*
	 char cycle[] = {
	 0,  1,  2,  3,  4,  5,  6,  7,
	 8,  9,  10, 11, 12, 13, 14, 15,
	 16, 17, 18, 19, 20, 21, 22, 23, 
	 24, 25, 26, 27, 28, 29, 30, 31,
	 32, 33, 34, 35, 36, 37, 38, 39,
	 40, 41, 42, 43, 44, 45, 46, 47,
	 48, 49, 50, 51, 52, 53, 54, 55,
	 56, 57, 58, 59, 60, 61, 62, 63};
	 */
	
	unsigned char cycle1[] = {
		0,  1,  2,  3,  4,  5,  6,  7,
		8,  9,  10, 11, 12, 13, 14, 15,
		16, 17, 19, 20, 21, 29, 22, 23, 
		24, 25, 18, 27, 28, 37, 30, 31,
		32, 33, 26, 35, 36, 45, 38, 39,
		40, 41, 34, 42, 43, 44, 46, 47,
		48, 49, 50, 51, 52, 53, 54, 55,
		56, 57, 58, 59, 60, 61, 62, 63};
	
	
	CGPoint originsphn[] = {ccp(ssz.width/2, ssz.height/2), 
		ccp(133 + ssz.width/2, 60 + ssz.height/2), ccp(133 + ssz.width/2, -60 + ssz.height/2), 
		ccp(-133 + ssz.width/2, 60 +ssz.height/2), ccp(-133 + ssz.width/2, -60 +ssz.height/2) };
	
	CGPoint originspad[] = {ccp(ssz.width/2, ssz.height/2), 
		ccp(300 + ssz.width/2, 100 + ssz.height/2), ccp(300 + ssz.width/2, -100 + ssz.height/2), 
		ccp(-300 + ssz.width/2, 100 +ssz.height/2), ccp(-300 + ssz.width/2, - 100 +ssz.height/2) };
	
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig:block1 
										 andDims:ccp(8,8)   
									 withSpacing: _IPAD ? 50 : 25 
										atOrigin: _IPAD ? originspad[0] : originsphn[0] 
										cycleMap: cycle1 
									   fromRight: YES 
										 playing:@"ssmsxxxx" 
									  difficulty:curLevel] autorelease],
		
		[[[BlockFleet alloc]    initWithConfig: block2 
									   andDims: ccp(3,1) 
								   withSpacing: _IPAD ? 65 : 30 
									  atOrigin: _IPAD ? originspad[1] : originsphn[1]
									 fromRight: NO 
									   playing: nil
									difficulty: curLevel] autorelease],
		
		[[[BlockFleet alloc]    initWithConfig: block2 
									   andDims: ccp(3,1) 
								   withSpacing: _IPAD ? 65 : 30
									  atOrigin: _IPAD ? originspad[2] : originsphn[2]
									 fromRight: NO 
									   playing: nil
									difficulty: curLevel] autorelease],
		[[[BlockFleet alloc]    initWithConfig: block2 
									   andDims: ccp(3,1) 
								   withSpacing: _IPAD ? 65 : 30
									  atOrigin: _IPAD ? originspad[3] : originsphn[3]
									 fromRight: NO 
									   playing: nil
									difficulty: curLevel] autorelease],
		[[[BlockFleet alloc]    initWithConfig: block2 
									   andDims: ccp(3,1) 
								   withSpacing: _IPAD ? 65 : 30
									  atOrigin: _IPAD ? originspad[4] : originsphn[4]
									 fromRight: NO 
									   playing: nil
									difficulty: curLevel] autorelease]
	};		
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	[pv addFleet: fleets[3]];
	[pv addFleet: fleets[4]];
	
	[[BeatSequencer getInstance] addEvents: 5,
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[3] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[4] andSequencer:[BeatSequencer getInstance]]
	 ];	
	
}	
- (int) getPowerup {
	int effect;
	// spawn powerups of random type
	int powerupType = arc4random() % 2;
	switch (powerupType) {
		case 0:
			effect = POW_ENSPRANCE;
			break;
		case 1:
			effect = POW_LTWADDLE;
			break;
		default:
			effect = 0;
			break;
	}
	return effect;
}

- (int) getPowerupChance { return 0; }

@end

@implementation StateLevelGutter

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	char block1[] = "\
xxxx\
zxxz\
zxxz\
zxxz\
zxxz\
zxxz\
zxxz\
xxxx";
	
	char block2[] = "\
AAAAAA\
AADADA\
AAAAAA\
AADADA\
AAAAAA";
	
	char block2phn[] = "\
AAAAA\
ADADA\
AAAAA\
ADADA\
AAAAA";
	
	
	CGPoint originspad[] = { ccp(250 + ssz.width/2, ssz.height/2), ccp(-250 + ssz.width/2, ssz.height/2), ccp(ssz.width/2, ssz.height/2) };
	CGPoint originsphn[] = { ccp(110 + ssz.width/2, ssz.height/2), ccp(-110 + ssz.width/2, ssz.height/2), ccp(ssz.width/2, ssz.height/2) };
	
	Fleet *fleets[] = {
		
		[[[DirBlockFleet alloc] initWithConfig: _IPAD ?	block2 : block2phn
									   andDims: _IPAD ? ccp(6,5) : ccp(5,5)
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: _IPAD ? originspad[0] : originsphn[0]
									  maxWidth: _IPAD ? 450 : 275
									   initDir: ccp(0, 1) 
										  step: _IPAD ? 50 : 20  
									 fromRight: YES  
									   playing: @"ssmbxxxxxxxxxxxx" 
									difficulty: curLevel] autorelease],
		[[[DirBlockFleet alloc] initWithConfig: _IPAD ?	block2 : block2phn 
									   andDims: _IPAD ? ccp(6,5) : ccp(5,5)
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: _IPAD ? originspad[1] : originsphn[1]
									  maxWidth: _IPAD ? 450 : 275
									   initDir: ccp(0, 1) 
										  step: _IPAD ? 50 : 20 
									 fromRight: YES  
									   playing: @"xxxxxxxxssmbxxxx" 
									difficulty: curLevel] autorelease],
		[[[BlockFleet alloc]    initWithConfig: block1 
									   andDims: ccp(4,8) 
								   withSpacing: _IPAD ? 65 : 30
									  atOrigin: _IPAD ? originspad[2] : originsphn[2]
									 fromRight: NO 
									   playing: @"x" 
									difficulty: curLevel] autorelease]};
	
	// fleets[1].shouldShoot = NO;
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	
	[[BeatSequencer getInstance] addEvents: 3, 
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]]
	 ];
}

- (int) getPowerup {
	int effect;
	// spawn powerups of random type
	int powerupType = arc4random() % 2;
	switch (powerupType) {
		case 0:
			effect = POW_CDRBOBBLE;
			break;
		case 1:
			effect = POW_LTWADDLE;
			break;
		default:
			effect = 0;
			break;
	}
	return effect;
}


@end

@implementation StateLevelPasties

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	char block1[] = "\
xzxtxzxxxzxTxzx\
xxtxtxxxxxTxTxx\
ztxsxtzzzTxwxTz\
xxTxTxxxxxtxtxx\
xzxTxzxxxzxtxzx";
	
	/*
	char cycle[] = {
		0,  1,  2,  3,  4,  5,  6,  7,	8,  9,  10, 11, 12, 13, 14, 
		15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
		30, 31,	32, 33, 34, 35, 36, 37, 38, 39,	40, 41, 42, 43, 44, 
		45, 46, 47,	48, 49, 50, 51, 52, 53, 54, 55,	56, 57, 58, 59, 
		60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74};
	 */
	
	unsigned char cycle[] = {
		0,  1,  2,  19,  4,  5,  6,  7,	8,  9,  10, 27, 12, 13, 14, 
		15, 16, 3, 18, 35, 20, 21, 22, 23, 24, 11, 26, 43, 28, 29, 
		30, 17,	32, 33, 34, 49, 36, 37, 38, 25,	40, 41, 42, 57, 44, 
		45, 46, 31,	48, 63, 50, 51, 52, 53, 54, 39,	56, 71, 58, 59, 
		60, 61, 62, 47, 64, 65, 66, 67, 68, 69, 70, 55, 72, 73, 74};
		
	CGPoint origins[] = { ccp(ssz.width/2, ssz.height/2) };
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block1
										 andDims: ccp(15,5)
									 withSpacing: _IPAD ? 50 : 22
										atOrigin: origins[0]
										cycleMap: cycle
									   fromRight: YES
										 playing: @"sxmxsxbx"
									  difficulty: curLevel] autorelease]};
	
	// fleets[1].shouldShoot = NO;
	
	[pv addFleet: fleets[0]];
	
	[[BeatSequencer getInstance] addEvents: 1, 
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]]
	 ];
}

- (int) getPowerup { return POW_ENSPRANCE;}

@end

@implementation StateLevelElectricSlide

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];	
	
	char block1[] = "\
TTTETTTxxxxxxxx";
	
	char block2[] = "\
xxxxqxqxqxqxqxqxqxqxqxxxxxxxxx";
	
	char block3[] = "\
xxxxxxxxxaxaxaxaxaxaxaxaxaxxxx";

	char block4[] = "\
xxxxxxxxtttDttt";
	
	/*
	 char cycle[] = {
	 0,  1,  2,  3,  4,  5,  6,  7,	8,  9,  10, 11, 12, 13, 14, 15,  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
	 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,  43, 44,
	 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59};
	 */
	
	unsigned char cycle1[] = {
		8,  9,  10,  11,  12,  13,  14,  7,	0,  1,  2, 3, 4, 5, 6};
	unsigned char cycle2[] = {
		0,  1,  2,  3,  9,  5,  11,  7,	13,  4,  15, 6, 17, 8, 19, 10,  21, 12, 23, 14, 25, 16, 22, 18, 24, 20, 26, 27, 28, 29};
	
	
	
	CGPoint originspad[] = { ccp(ssz.width/2, ssz.height/2+150), ccp(ssz.width/2, ssz.height/2+50), ccp(ssz.width/2, ssz.height/2-50), ccp(ssz.width/2, ssz.height/2-150) };
	CGPoint originsphn[] = { ccp(ssz.width/2, ssz.height/2+75), ccp(ssz.width/2, ssz.height/2+25), ccp(ssz.width/2, ssz.height/2-25), ccp(ssz.width/2, ssz.height/2-75) };
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block1
										 andDims: ccp(15,1)
									 withSpacing: _IPAD ? 50 : 20
										atOrigin: _IPAD ? originspad[0] : originsphn[0]
										cycleMap: cycle1
									   fromRight: YES
										 playing: @"mxxsxxxxx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig: block2
										 andDims: ccp(30,1)
									 withSpacing: _IPAD ? 25 : 10
										atOrigin: _IPAD ? originspad[1] : originsphn[1]
										cycleMap: cycle2
									   fromRight: YES
										 playing: @"xxmxxsxsx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig: block3
										 andDims: ccp(30,1)
									 withSpacing: _IPAD ? 25 : 10
										atOrigin: _IPAD ? originspad[2] : originsphn[2]
										cycleMap: cycle2
									   fromRight: YES
										 playing: @"xxxxmxsxx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig: block4
										 andDims: ccp(15,1)
									 withSpacing: _IPAD ? 50 : 20
										atOrigin: _IPAD ? originspad[3] : originsphn[3]
										cycleMap: cycle1
									   fromRight: YES
										 playing: @"sxxxxxmxx"
									  difficulty: curLevel] autorelease],
	};
	
	// fleets[1].shouldShoot = NO;
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	[pv addFleet: fleets[3]];
	
	[[BeatSequencer getInstance] addEvents: 4, 
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[3] andSequencer:[BeatSequencer getInstance]]
	 ];
}

- (int) getPowerup {
	int effect;
	// spawn powerups of random type
	int powerupType = arc4random() % 2;
	switch (powerupType) {
		case 0:
			effect = POW_ENSPRANCE;
			break;
		case 1:
			effect = POW_LTWADDLE;
			break;
		default:
			effect = 0;
			break;
	}
	return effect;
}


@end

@implementation StateBattle1

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	char block[] = "\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx\
xxx1xxxx\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx";

	CGPoint origins[] = {ccp(ssz.width/2+25, ssz.height/2+25)};
	
	Fleet *fleets[] = {
		[[[BlockFleet alloc] initWithConfig: block 
									andDims: ccp(8,8)
								withSpacing: _IPAD ? 50 : 25
								   atOrigin: origins[0]
								  fromRight: YES 
									playing: @"sxxxxxxx"
								 difficulty: curLevel] autorelease]};	
	
	/*
	 LineFleet *fleets[] = {
	 [[[LineFleet alloc] initWithSize:3 andWidth:400 maxWidth:768 atOrigin:origins[0] upsideDown:NO  stationary:NO difficulty:0 classes:classes0] autorelease],
	 [[[LineFleet alloc] initWithSize:3 andWidth:400 maxWidth:768 atOrigin:origins[1] upsideDown:YES stationary:NO difficulty:0 classes:classes1] autorelease]}; 
	 */
	
	[pv addFleet: fleets[0]];
	//[pv addFleet: fleets[1]];
	
	[[BeatSequencer getInstance] addEvent:
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]]];
}	
- (int) getPowerup { return 0;}

@end

@implementation StateLevelPachinko

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
char block[] = "\
zxzxzxz\
AWAWAWA\
xzDzDzx\
SSQSQSS\
zxzxzxz";
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block 
									   andDims: ccp(7,5) 
								   withSpacing: _IPAD ? 90 : 40
									  atOrigin: origins[0] 
									  maxWidth: _IPAD ? 600 : 200
									   initDir: ccp(1,0) 
		  							      step: _IPAD ? 25 : 20
									 fromRight: NO 
									   playing: @"sxsxsxxx"
									difficulty: curLevel] autorelease]};	
	[pv addFleet: fleets[0]];
	
	[[BeatSequencer getInstance] addEvent:
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]]];
}

@end

@implementation StateLevelRockBlocked

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
char block[] = "\
xxxttxxx\
xxTqqTxx\
xTqxxqTx\
tqxqwxqt\
taxsaxat\
xTaxxaTx\
xxTaaTxx\
xxxttxxx";
	
char rockBlock[] = "\
fff\
xxx\
xxx\
xxx\
rrr";
	
	/*
	 char cycle[] = {
	 0,  1,  2,  3,  4,  5,  6,  7,
	 8,  9,  10, 11, 12, 13, 14, 15,
	 16, 17, 18, 19, 20, 21, 22, 23, 
	 24, 25, 26, 27, 28, 29, 30, 31,
	 32, 33, 34, 35, 36, 37, 38, 39,
	 40, 41, 42, 43, 44, 45, 46, 47,
	 48, 49, 50, 51, 52, 53, 54, 55,
	 56, 57, 58, 59, 60, 61, 62, 63};
	 */
	
	unsigned char cycle[] = {
		0,  1,  2,  4,  13,  5,  6,  7,
		8,  9,  3,  18, 11, 22, 14, 15,
		16, 10, 25, 19, 20, 12, 31, 23, 
		17, 33, 26, 27, 28, 29, 21, 39,
		24, 42, 34, 35, 36, 37, 30, 46,
		40, 32, 51, 43, 44, 38, 53, 47,
		48, 49, 41, 52, 45, 60, 54, 55,
		56, 57, 58, 50, 59, 61, 62, 63};
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2), ccp(ssz.width/2-250, ssz.height/2), ccp(ssz.width/2+250, ssz.height/2)};
	CGPoint originsphn[] = {ccp(ssz.width/2, ssz.height/2), ccp(ssz.width/2-125, ssz.height/2), ccp(ssz.width/2+125, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block
										 andDims: ccp(8,8) 
									 withSpacing: _IPAD ? 50 : 25
										atOrigin: _IPAD ? origins[0] : originsphn[0]
										cycleMap: cycle 
									   fromRight: YES  
										 playing: @"bxss"
									  difficulty: curLevel] autorelease],
		[[[DirBlockFleet alloc] initWithConfig: rockBlock 
									   andDims: ccp(3,5) 
								   withSpacing: _IPAD ?  50 : 25
									  atOrigin: _IPAD ? origins[1] : originsphn[1]
									  maxWidth: _IPAD ? 50 : 20
									   initDir: ccp(0,0) 
		  							      step: _IPAD ? 50 : 20
									 fromRight: NO 
									   playing: @"xxxxxxxx"
									difficulty: curLevel] autorelease],
		[[[DirBlockFleet alloc] initWithConfig: rockBlock 
									   andDims: ccp(3,5) 
								   withSpacing: _IPAD ? 50 : 25
									  atOrigin: _IPAD ? origins[2] : originsphn[2]
									  maxWidth: _IPAD ? 50 : 20
									   initDir: ccp(0,0) 
		  							      step: _IPAD ? 50 : 20
									 fromRight: NO 
									   playing: @"xxxxxxxx"
									difficulty: curLevel] autorelease]};
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	
	[[BeatSequencer getInstance] addEvents: 3,
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]]];
}	

- (int) getPowerup {
	return POW_LTWADDLE;
}

@end

@implementation StateLevelLockbox

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
//char block1[] = "\
//xxxxxxxxx\
//xxxzyzzzx\
//xxxxxxxzx\
//xzxxxxxzx\
//xzxxxxxzx\
//xzxxxxxzx\
//xxxxxxxxx\
//xxxzyzxxx\
//xxxxxxxxx";
	
char block1[] = "\
xxxxxxxyx\
xfffffffx\
xfxxxxxfx\
xfxxxxxfx\
xfxxxxxrx\
xrxxxxxrx\
xrxxxxxrx\
xrrrrrrrx\
xyxxxxxx";

char block2[] = "\
xxxxxxxxx\
xxxxxxxxx\
xxxxxxxxx\
xxxxxxxxx\
xxxQEQxxx\
xxxxxxxxx\
xxxxxxxxx\
xxxxxxxxx\
xxxxxxxxx";

	char block3[]="ttttx";	
	char block4[]="xTTTT";	
	
	CGPoint origins[] = {
		ccp(ssz.width/2, ssz.height/2),
		ccp(ssz.width/2, ssz.height/2-50),
		ccp(ssz.width/2, ssz.height/2+50)};
	
	CGPoint originsphn[] = {
		ccp(ssz.width/2, ssz.height/2),
		ccp(ssz.width/2, ssz.height/2-25),
		ccp(ssz.width/2, ssz.height/2+25)};
	
	Fleet *fleets[] = {
		[[[BlockFleet alloc] initWithConfig: block1
									andDims: ccp(9,9) 
								withSpacing: _IPAD ? 50 : 25
								   atOrigin: _IPAD ? origins[0] : originsphn[0]
								  fromRight: NO 
									playing: @"xxxxxxxx"
								 difficulty: curLevel] autorelease],
		
		[[[BlockFleet alloc] initWithConfig: block2 
									andDims: ccp(9,9) 
								withSpacing: _IPAD ? 40 : 20
								   atOrigin: _IPAD ? origins[0] : originsphn[0]
//								   maxWidth: 200 
//									initDir: ccp(1,0) 
//									   step: _IPAD ? 50 : 20
								  fromRight: NO 
									playing: @"xxsxxxsx"
								 difficulty: curLevel] autorelease],
		[[[DirBlockFleet alloc] initWithConfig: block3 
									andDims: ccp(5,1) 
								   withSpacing: _IPAD ? 50 : 25
								   atOrigin: _IPAD ? origins[1] : originsphn[1]
									  maxWidth: _IPAD ? 250 : 80
									initDir: ccp(1,0) 
										  step: _IPAD ? 25 : 12
								  fromRight: NO 
									playing: @"xmsmxmsm"
								 difficulty: curLevel] autorelease],
		[[[DirBlockFleet alloc] initWithConfig: block4
									andDims: ccp(5,1) 
								   withSpacing: _IPAD ? 50 : 25
								   atOrigin: _IPAD ? origins[2] : originsphn[2]
									  maxWidth: _IPAD ? 250 : 125
									initDir: ccp(-1,0) 
										  step: _IPAD ? 25 : 12
								  fromRight: NO 
									playing: @"msmxmsmx"
								 difficulty: curLevel] autorelease]};	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	[pv addFleet: fleets[3]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

@implementation StateLevelWhopper

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	char block1[] = "zzzz";
	
char block2[] = "\
TTTTTTTTTTT\
qqqqqqqqqQQ\
aaDESWSEDAA\
aaaaaaaaaAA\
ttttttttttt";
	
	
	//	unsigned char cycle[] = {
	//		0,    1,    2,    3,    4,    5,    6,    7,    8,    9,  
	//		10,   11,   12,   13,   14,   15,   16,   17,   18,   19,  
	//		20,   21,   22,   23,   24,   25,   26,   27,   28,   29,  
	//		30,   31,   32,   33,   34,   35,   36,   37,   38,   39,  
	//		40,   41,   42,   43,   44,   45,   46,   47,   48,   49,  
	//	};
	
	CGPoint origins[] = {
		ccp(ssz.width-160, ssz.height/2+225),
		ccp(ssz.width-160, ssz.height/2-225),
		ccp(220, ssz.height/2),
	};
	
	CGPoint originsphn[] = {
		ccp(ssz.width-65, ssz.height/2+117),
		ccp(ssz.width-65, ssz.height/2-117),
		ccp(110, ssz.height/2),
	};
	
	Fleet *fleets[] = {
		[[[BlockFleet alloc] initWithConfig: block1
									andDims: ccp(4,1) 
								withSpacing: _IPAD ? 64 : 32
								   atOrigin: _IPAD ?  origins[0] : originsphn[0]
								  fromRight: NO 
									playing: @"bxxxxxxx"
								 difficulty: curLevel] autorelease],		
		
		[[[BlockFleet alloc] initWithConfig: block1
									andDims: ccp(4,1) 
								withSpacing: _IPAD ? 64 : 32
								   atOrigin: _IPAD ?  origins[1] : originsphn[1]
								  fromRight: NO 
									playing: @"bxxxxxxx"
								 difficulty: curLevel] autorelease],		
		
		[[[DirBlockFleet alloc] initWithConfig: block2
									   andDims: ccp(11,5) 
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: _IPAD ?  origins[2] : originsphn[2]
									  maxWidth: _IPAD ? 350 : 175
									   initDir: ccp(0, 1) 
										  step: _IPAD ? 50 : 20 
									 fromRight: YES  
									   playing:@"xbxbxbxb" 
									difficulty:curLevel] autorelease],
	};	
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

- (int) getPowerup { return POW_LTWADDLE;}

@end

@implementation StateLevel17a

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	/*
	 //	char block1[] = "\
	 //	xxxqqxxx\
	 //	xxqqqqxx\
	 //	xqqxxqqx\
	 //	qqxxxxqq\
	 //	aaxxxxaa\
	 //	xaaxxaax\
	 //	xxaaaaxx\
	 //	xxxaaxxx";
	 //	
	 //	char block2[] = "\
	 //	xxxqqxxx\
	 //	xxqqqqxx\
	 //	xqqxxqqx\
	 //	qqxxxxqq\
	 //	aaxxxxaa\
	 //	xaaxxaax\
	 //	xxaaaaxx\
	 //	xxxaaxxx"; */
	
	
	char block1[] = "\
xxxxxxxx\
xxxQQxxx\
xxQqqQxx\
xQqxxqQx\
xAaxxaAx\
xxAaaAxx\
xxxAAxxx\
xxxxxxxx";
	
	CGPoint origins[] = {ccp(ssz.width/3-50, ssz.height/3+10), ccp(2*ssz.width/3+50, ssz.height/3+10),
						 ccp(ssz.width/3-50, 2*ssz.height/3-10), ccp(2*ssz.width/3+50, 2*ssz.height/3-10)};
	
	CGPoint originsphn[] = {ccp(ssz.width/3-25, ssz.height/3+5), ccp(2*ssz.width/3+25, ssz.height/3+5),
		ccp(ssz.width/3-25, 2*ssz.height/3-5), ccp(2*ssz.width/3+25, 2*ssz.height/3-5)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(8,8)
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: _IPAD ? origins[0] : originsphn[0]
									  maxWidth: _IPAD ? 250 : 125
									   initDir: ccp(1, 0) 
		  							      step: _IPAD ? 50 : 20
									 fromRight: YES  
									   playing: @"xmxsxmxs"
									difficulty: curLevel] autorelease],
		
		[[[DirBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(8,8)
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: _IPAD ? origins[1] : originsphn[1]
									  maxWidth: _IPAD ? 250 : 125 
									   initDir: ccp(-1, 0) 
		  							      step: _IPAD ? 50 : 20
									 fromRight: YES  
									   playing: @"xsxmxsxm"
									difficulty: curLevel] autorelease],
		
		[[[DirBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(8,8)
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: _IPAD ? origins[2] : originsphn[2] 
									  maxWidth: _IPAD ? 250 : 125  
									   initDir: ccp(-1, 0) 
		  							      step: _IPAD ? 50 : 20
									 fromRight: YES  
									   playing: @"xsxmxsxm"
									difficulty: curLevel] autorelease],
		
		[[[DirBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(8,8)
								   withSpacing: _IPAD ? 40 : 20 
									  atOrigin: _IPAD ? origins[3] : originsphn[3] 
									  maxWidth: _IPAD ? 250 : 125  
									   initDir: ccp(1, 0)
		  							      step: _IPAD ? 50 : 20
									 fromRight: NO
									   playing: @"xmxsxmxs"
									difficulty: curLevel] autorelease]};
	
	
	/*
	 LineFleet *fleets[] = {
	 [[[LineFleet alloc] initWithSize:3 andWidth:400 maxWidth:768 atOrigin:origins[0] upsideDown:NO  stationary:NO difficulty:0 classes:classes0] autorelease],
	 [[[LineFleet alloc] initWithSize:3 andWidth:400 maxWidth:768 atOrigin:origins[1] upsideDown:YES stationary:NO difficulty:0 classes:classes1] autorelease]}; 
	 */
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	[pv addFleet: fleets[3]];
	
	[[BeatSequencer getInstance] addEvents: 4, 
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[3] andSequencer:[BeatSequencer getInstance]]];
	
}

@end

@implementation StateLevel16

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	char block1[] = "\
xQQQQQQx\
QEQEEQEQ\
ADADDADA\
xAAAAAAx";
	
	/*
	 char block2[] = "\
	 xxxxxxxxxxxx\
	 xxxxxxxxxxxx\
	 zxxxxzzxxxxz\
	 zxxxxxxxxxxz\
	 zxxxxxxxxxxz\
	 zxxxxxxxxxxz\
	 zxxxxxxxxxxz\
	 zxxxxzzxxxxz\
	 xxxxxxxxxxxx\
	 xxxxxxxxxxxx"; */
	
	
//	char block2[] = "\
//xxrrrrrrrrxx\
//xrrrrrrrrryx\
//xxxxxxxxxxxx\
//xxxxxxxxxxxx\
//xxxxxxxxxxxx\
//xxxxxxxxxxxx\
//xxxxxxxxxxxx\
//xxxxxxxxxxxx\
//xyfffffffffx\
//xxffffffffxx";
	
char block2[] = "\
xxrrrrrrrrxx\
xxrrrrrrrryx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xyffffffffxx\
xxffffffffxx";

	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(8,4)
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: origins[0]
									  maxWidth: 250
									   initDir: ccp(1, 0) 
		  							      step: _IPAD ? 50 : 20
									 fromRight: YES
									   playing: @"mmssmxsxmmssmxsx"
									difficulty: curLevel] autorelease],
		
		[[[BlockFleet alloc]    initWithConfig: block2 
									   andDims: ccp(12,10) 
								   withSpacing: _IPAD ? 40 : 20 
									  atOrigin: origins[0]
									 fromRight: NO 
									   playing: nil
									difficulty: curLevel] autorelease]};
	
	/*
	 LineFleet *fleets[] = {
	 [[[LineFleet alloc] initWithSize:3 andWidth:400 maxWidth:768 atOrigin:origins[0] upsideDown:NO  stationary:NO difficulty:0 classes:classes0] autorelease],
	 [[[LineFleet alloc] initWithSize:3 andWidth:400 maxWidth:768 atOrigin:origins[1] upsideDown:YES stationary:NO difficulty:0 classes:classes1] autorelease]}; 
	 */
	
	fleets[1].shouldShoot = NO;
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	
	[[BeatSequencer getInstance] addEvents: 2, 
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]]];
	
	/*
	 Rock *rock = (Rock *)[pv addSpriteBody:[Rock class] atPos:ccp(300,300) withForce:ccp(0,0)];
	 rock.opacity = 0;
	 [rock runAction:[CCFadeTo actionWithDuration:1.0 opacity: 255]];
	 */
	
}	

@end

@implementation StateLevelDrano

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	char block1[] = "\
	xxxxx\
	zxxxz\
	zxxxz\
	zxxxz\
	zxxxz\
	zxxxz\
	zxxxz\
	xxxxx";
	
	char block2[] = "\
	AAAAA\
	AADAD\
	DADAA\
	AADAD\
	AAAAA";
	
	CGPoint origins[] = { 
		ccp(266 + ssz.width/2, ssz.height/2), 
		ccp(ssz.width/2, ssz.height/2), 
		ccp(-266 + ssz.width/2, ssz.height/2), 
		ccp(ssz.width/2, ssz.height/2)};
	
	CGPoint originsphn[] = { 
		ccp(133 + ssz.width/2, ssz.height/2), 
		ccp(ssz.width/2, ssz.height/2), 
		ccp(-133 + ssz.width/2, ssz.height/2), 
		ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig:block2 
									   andDims:ccp(5,5) 
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: _IPAD? origins[0] : originsphn[0]
									  maxWidth: _IPAD ? 450 : 225
									   initDir: ccp(0, 1) 
										  step:_IPAD ? 50 : 20 
									 fromRight: YES  
									   playing:@"bbxxxxxxbbmmmmxx" 
									difficulty:curLevel] autorelease],
		
		[[[DirBlockFleet alloc] initWithConfig:block2 
									   andDims:ccp(5,5) 
								   withSpacing: _IPAD ? 40 : 20 
									  atOrigin: _IPAD ? origins[1] : originsphn[1]
									  maxWidth: _IPAD ? 450 : 225 
									   initDir: ccp(0, 1) 
										  step:_IPAD ? 50 : 20
									 fromRight: YES
									   playing:@"xxbbxxxxxxbbmmmm"
									difficulty:curLevel] autorelease],
		
		[[[DirBlockFleet alloc] initWithConfig:block2 
									   andDims:ccp(5,5) 
								   withSpacing: _IPAD ? 40 : 20 
									  atOrigin: _IPAD ? origins[2] : originsphn[2] 
									  maxWidth: _IPAD ? 450 : 225 
									   initDir: ccp(0, 1) 
										  step:_IPAD ? 50 : 20 
									 fromRight: YES  
									   playing:@"mmxxbbxxxxxxbbmm" 
									difficulty:curLevel] autorelease],
		
		[[[BlockFleet alloc]    initWithConfig:block1 
									   andDims:ccp(5,8) 
								   withSpacing: _IPAD ? 67 : 33
									  atOrigin: _IPAD ? origins[3] : originsphn[3]
									 fromRight: NO playing:@"" 
									difficulty:curLevel] autorelease]};
	
	// fleets[1].shouldShoot = NO;
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	[pv addFleet: fleets[3]];
	
	[[BeatSequencer getInstance] addEvents: 4, 
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[3] andSequencer:[BeatSequencer getInstance]]
	 ];
}
@end

@implementation StateLevel19a

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	char block1[] = "\
xxxxx\
zxxxz\
zxxxz\
zxxxz\
zxxxz\
zxxxz\
zxxxz\
xxxxx";
	
	char block2[] = "\
AAAAA\
AADAD\
DADAA\
AADAD\
AAAAA";
	
	CGPoint origins[] = { 
		ccp(266 + ssz.width/2, ssz.height/2), 
		ccp(ssz.width/2, ssz.height/2), 
		ccp(-266 + ssz.width/2, ssz.height/2), 
		ccp(ssz.width/2, ssz.height/2)};
	
	CGPoint originsphn[] = { 
		ccp(133 + ssz.width/2, ssz.height/2), 
		ccp(ssz.width/2, ssz.height/2), 
		ccp(-133 + ssz.width/2, ssz.height/2), 
		ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig:block2 
									   andDims:ccp(5,5) 
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: _IPAD? origins[0] : originsphn[0]
									  maxWidth: _IPAD ? 450 : 225
									   initDir: ccp(0, 1) 
										  step:_IPAD ? 50 : 20 
									 fromRight: YES  
									   playing:@"bbxxxxxxbbmmmmxx" 
									difficulty:curLevel] autorelease],
		
		[[[DirBlockFleet alloc] initWithConfig:block2 
									   andDims:ccp(5,5) 
								   withSpacing: _IPAD ? 40 : 20 
									  atOrigin: _IPAD ? origins[1] : originsphn[1]
									  maxWidth: _IPAD ? 450 : 225 
									   initDir: ccp(0, 1) 
										  step:_IPAD ? 50 : 20
									 fromRight: YES
									   playing:@"xxbbxxxxxxbbmmmm"
									difficulty:curLevel] autorelease],
		
		[[[DirBlockFleet alloc] initWithConfig:block2 
									   andDims:ccp(5,5) 
								   withSpacing: _IPAD ? 40 : 20 
									  atOrigin: _IPAD ? origins[2] : originsphn[2] 
									  maxWidth: _IPAD ? 450 : 225 
									   initDir: ccp(0, 1) 
										  step:_IPAD ? 50 : 20 
									 fromRight: YES  
									   playing:@"mmxxbbxxxxxxbbmm" 
									difficulty:curLevel] autorelease],
		
		[[[BlockFleet alloc]    initWithConfig:block1 
									   andDims:ccp(5,8) 
								   withSpacing: _IPAD ? 67 : 33
									  atOrigin: _IPAD ? origins[3] : originsphn[3]
									 fromRight: NO playing:@"" 
									difficulty:curLevel] autorelease]};
	
	// fleets[1].shouldShoot = NO;
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	[pv addFleet: fleets[3]];
	
	[[BeatSequencer getInstance] addEvents: 4, 
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[3] andSequencer:[BeatSequencer getInstance]]
	 ];
}
@end

@implementation StateLevelSaturdayNight

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	char block1[] = "rrErErrxxxxxxxx";
	char block2[] = "xxQxQxQxQxQxQxQxQxQxxxxxxxxxxx";
	char block3[] = "xxxxqxqxwxqxwxqxwxqxqxxxxxxxxx";
	char block4[] = "xxxxxxxxxaxaxsxaxsxaxsxaxaxxxx";
	char block5[] = "xxxxxxxxxxxAxAxAxAxAxAxAxAxAxx";
	char block6[] = "xxxxxxxxffDfDff";
	char block7[] = "y";
	
	/*
	 char cycle[] = {
	 0,  1,  2,  3,  4,  5,  6,  7,	8,  9,  10, 11, 12, 13, 14, 15,  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
	 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,  43, 44,
	 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59};
	 */
	
	unsigned char cycle1[] = {
		8,  9,  10,  11,  12,  13,  14,  7,	0,  1,  2, 3, 4, 5, 6};
	unsigned char cycle2[] = {
		0,  1,  2,  3,  9,  5,  11,  7,	13,  4,  15, 6, 17, 8, 19, 10,  21, 12, 23, 14, 25, 16, 22, 18, 24, 20, 26, 27, 28, 29};
	unsigned char cycle3[] = {
		0,  1,  11,  3,  13,  5,  15,  7,  17,  9,  19, 2, 21, 4, 23, 6, 25, 8, 27, 10, 20, 12, 22, 14, 24, 16, 26, 18, 28, 29};
	
	
	
	CGPoint origins[] = { 
		ccp(ssz.width/2, ssz.height/2+175), 
		ccp(ssz.width/2, ssz.height/2+90), 
		ccp(ssz.width/2, ssz.height/2+30), 
		ccp(ssz.width/2, ssz.height/2-30), 
		ccp(ssz.width/2, ssz.height/2-90), 
		ccp(ssz.width/2, ssz.height/2-175),
		ccp(ssz.width/2, ssz.height/2 - 250),
		ccp(ssz.width/2, ssz.height/2 + 250)};
	
	
	CGPoint originsphn[] = { 
		ccp(ssz.width/2, ssz.height/2+85), 
		ccp(ssz.width/2, ssz.height/2+45), 
		ccp(ssz.width/2, ssz.height/2+15), 
		ccp(ssz.width/2, ssz.height/2-15), 
		ccp(ssz.width/2, ssz.height/2-45), 
		ccp(ssz.width/2, ssz.height/2-85),
		ccp(ssz.width/2, ssz.height/2-125),
		ccp(ssz.width/2, ssz.height/2+125)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig:block1
										 andDims:ccp(15,1)
									 withSpacing: _IPAD ? 50: 25
										atOrigin: _IPAD ? origins[0] : originsphn[0]
										cycleMap: cycle1
									   fromRight: YES
										 playing: @"sxxxxxxm"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig:block2
										 andDims:ccp(30,1)
									 withSpacing: _IPAD ? 25: 12
										atOrigin: _IPAD ? origins[1] : originsphn[1]
										cycleMap: cycle3
									   fromRight: YES
										 playing: @"msxxxxxx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig:block3
										 andDims:ccp(30,1)
									 withSpacing: _IPAD ? 25: 12
										atOrigin: _IPAD ? origins[2] : originsphn[2]
										cycleMap: cycle2
									   fromRight: YES
										 playing: @"xmsxxxxx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig:block4
										 andDims:ccp(30,1)
									 withSpacing: _IPAD ? 25: 12
										atOrigin: _IPAD ? origins[3] : originsphn[3]
										cycleMap: cycle2
									   fromRight: YES
										 playing: @"xxxmsxxx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig:block5
										 andDims:ccp(30,1)
									 withSpacing: _IPAD ? 25: 12
										atOrigin: _IPAD ? origins[4] : originsphn[4]
										cycleMap: cycle3
									   fromRight: YES
										 playing: @"xxxxmsxx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig:block6
										 andDims:ccp(15,1)
									 withSpacing: _IPAD ? 50: 25
										atOrigin: _IPAD ? origins[5] : originsphn[5]
										cycleMap: cycle1
									   fromRight: YES
										 playing: @"xxxxxmsx"
									  difficulty: curLevel] autorelease],
		
		[[[BlockFleet alloc] initWithConfig:block7
									andDims:ccp(1,1)
								withSpacing: _IPAD ? 50:25
								   atOrigin: _IPAD ? origins[6] : originsphn[6]
								  fromRight: YES
									playing:@"x"
								 difficulty: curLevel] autorelease],
		[[[BlockFleet alloc] initWithConfig:block7
									andDims:ccp(1,1)
								withSpacing: _IPAD ? 50:25
								   atOrigin: _IPAD ? origins[7] : originsphn[7]
								  fromRight: YES
									playing:@"x"
								 difficulty: curLevel] autorelease],
	};
	
	// fleets[1].shouldShoot = NO;
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	[pv addFleet: fleets[3]];
	[pv addFleet: fleets[4]];
	[pv addFleet: fleets[5]];
	
	[[BeatSequencer getInstance] addEvents: 6, 
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[3] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[4] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[5] andSequencer:[BeatSequencer getInstance]]
	 ];
}
@end

// Maze
@implementation StateLevelSuperAstroBall

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
char block1[] = "\
rrrrrrrr\
rxxxaxxr\
rxrrrrxr\
rxxxxxxr\
rrrrxrrr\
xxrrxrxx\
rxxxxxxr\
rrrrrrrr";

	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[BlockFleet alloc] initWithConfig: block1
										 andDims: ccp(8,8) 
									 withSpacing: _IPAD ? 50 : 25
										atOrigin: origins[0] 
									   fromRight: NO 
										 playing: @"sxxxsxxx"
									  difficulty: curLevel] autorelease],
	};	
	
	[pv addFleet: fleets[0]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
	
	pv.bulletTimeDistance = ssz.height;
}

@end


@implementation StateLevel14a

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	char block1[] = "rrErErrxxxxxxxx";
	char block2[] = "xxQxQxQxQxQxQxQxQxQxxxxxxxxxxx";
	char block3[] = "xxxxqxqxwxqxwxqxwxqxqxxxxxxxxx";
	char block4[] = "xxxxxxxxxaxaxsxaxsxaxsxaxaxxxx";
	char block5[] = "xxxxxxxxxxxAxAxAxAxAxAxAxAxAxx";
	char block6[] = "xxxxxxxxffDfDff";
	
	/*
	 char cycle[] = {
	 0,  1,  2,  3,  4,  5,  6,  7,	8,  9,  10, 11, 12, 13, 14, 15,  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 
	 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,  43, 44,
	 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59};
	 */
	
	unsigned char cycle1[] = {
		8,  9,  10,  11,  12,  13,  14,  7,	0,  1,  2, 3, 4, 5, 6};
	unsigned char cycle2[] = {
		0,  1,  2,  3,  9,  5,  11,  7,	13,  4,  15, 6, 17, 8, 19, 10,  21, 12, 23, 14, 25, 16, 22, 18, 24, 20, 26, 27, 28, 29};
	unsigned char cycle3[] = {
		0,  1,  11,  3,  13,  5,  15,  7,  17,  9,  19, 2, 21, 4, 23, 6, 25, 8, 27, 10, 20, 12, 22, 14, 24, 16, 26, 18, 28, 29};
	
	
	
	CGPoint origins[] = { 
		ccp(ssz.width/2, ssz.height/2+175), 
		ccp(ssz.width/2, ssz.height/2+90), 
		ccp(ssz.width/2, ssz.height/2+30), 
		ccp(ssz.width/2, ssz.height/2-30), 
		ccp(ssz.width/2, ssz.height/2-90), 
		ccp(ssz.width/2, ssz.height/2-175) };
	
	
	CGPoint originsphn[] = { 
		ccp(ssz.width/2, ssz.height/2+85), 
		ccp(ssz.width/2, ssz.height/2+45), 
		ccp(ssz.width/2, ssz.height/2+15), 
		ccp(ssz.width/2, ssz.height/2-15), 
		ccp(ssz.width/2, ssz.height/2-45), 
		ccp(ssz.width/2, ssz.height/2-85) };
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig:block1
										 andDims:ccp(15,1)
									 withSpacing: _IPAD ? 50: 25
										atOrigin: _IPAD ? origins[0] : originsphn[0]
										cycleMap: cycle1
									   fromRight: YES
										 playing: @"sxxxxxxm"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig:block2
										 andDims:ccp(30,1)
									 withSpacing: _IPAD ? 25: 12
										atOrigin: _IPAD ? origins[1] : originsphn[1]
										cycleMap: cycle3
									   fromRight: YES
										 playing: @"msxxxxxx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig:block3
										 andDims:ccp(30,1)
									 withSpacing: _IPAD ? 25: 12
										atOrigin: _IPAD ? origins[2] : originsphn[2]
										cycleMap: cycle2
									   fromRight: YES
										 playing: @"xmsxxxxx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig:block4
										 andDims:ccp(30,1)
									 withSpacing: _IPAD ? 25: 12
										atOrigin: _IPAD ? origins[3] : originsphn[3]
										cycleMap: cycle2
									   fromRight: YES
										 playing: @"xxxmsxxx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig:block5
										 andDims:ccp(30,1)
									 withSpacing: _IPAD ? 25: 12
										atOrigin: _IPAD ? origins[4] : originsphn[4]
										cycleMap: cycle3
									   fromRight: YES
										 playing: @"xxxxmsxx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig:block6
										 andDims:ccp(15,1)
									 withSpacing: _IPAD ? 50: 25
										atOrigin: _IPAD ? origins[5] : originsphn[5]
										cycleMap: cycle1
									   fromRight: YES
										 playing: @"xxxxxmsx"
									  difficulty: curLevel] autorelease],
	};
	
	// fleets[1].shouldShoot = NO;
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	[pv addFleet: fleets[3]];
	[pv addFleet: fleets[4]];
	[pv addFleet: fleets[5]];
	
	[[BeatSequencer getInstance] addEvents: 6, 
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[3] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[4] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[5] andSequencer:[BeatSequencer getInstance]]
	 ];
}
@end

// old school
@implementation StateLevelGalacticIntruders

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	char block1[] = "\
xxxxxxxxxxxxxxxx\
aaaaaaxxxxxxxxxx\
aaaaaaxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx";
	char block2[] = "\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxaaaaaaxxxxxxx\
xxxaaaaaaxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx";
	char block3[] = "\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxaaaaaaxxx\
xxxxxxxaaaaaaxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx";
	char block4[] = "\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxaaaaaa\
xxxxxxxxxxaaaaaa\
xxxxxxxxxxxxxxxx";
	
	unsigned char cycle[] =
	{    1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,  79,
		17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,  95,  
		33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47, 111,  
		49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63, 127,
		
		128, 64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,   
		144, 80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,   
		160, 96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110,  
		176, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 
		
		129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 207,
		145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 223,
		161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 239,
		177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 255,
		
		0, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206,  
		16, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222,  
		32, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238,  
		48, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254
	};
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block1
										 andDims: ccp(16,16) 
									 withSpacing: _IPAD ? 40 : 20
										atOrigin: origins[0] 
										cycleMap: cycle
									   fromRight: NO 
										 playing: @"bxbxmxmx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig: block2
										 andDims: ccp(16,16) 
									 withSpacing: _IPAD ? 40 : 20 
										atOrigin: origins[0] 
										cycleMap: cycle
									   fromRight: NO 
										 playing: @"mxbxbxmx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig: block3
										 andDims: ccp(16,16) 
									 withSpacing: _IPAD ? 40 : 20 
										atOrigin: origins[0] 
										cycleMap: cycle
									   fromRight: NO 
										 playing: @"mxmxbxbx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig: block4
										 andDims: ccp(16,16) 
									 withSpacing: _IPAD ? 40 : 20 
										atOrigin: origins[0] 
										cycleMap: cycle
									   fromRight: NO 
										 playing: @"bxmxmxbx"
									  difficulty: curLevel] autorelease]
	};	
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	[pv addFleet: fleets[3]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

@implementation StateLevel18

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
//	char block1[] = "zzzzz";
	char block1[] = "yxxxx";
	
//	char block2[] = "\
//TTTTTTTTTTT\
//qqqqqqqqqQQ\
//aaDESWSEDAA\
//aaaaaaaaaAA\
//ttttttttttt";
	
char block2[] = "\
rrrrrrrrrrr\
rqqqqqqqqQr\
raDESWSEDAf\
faaaaaaaaAf\
fffffffffff";
	
//	unsigned char cycle[] = {
//		0,    1,    2,    3,    4,    5,    6,    7,    8,    9,  
//		10,   11,   12,   13,   14,   15,   16,   17,   18,   19,  
//		20,   21,   22,   23,   24,   25,   26,   27,   28,   29,  
//		30,   31,   32,   33,   34,   35,   36,   37,   38,   39,  
//		40,   41,   42,   43,   44,   45,   46,   47,   48,   49,  
//	};
	
	CGPoint origins[] = {
		ccp(ssz.width-160, ssz.height/2+225),
		ccp(ssz.width-160, ssz.height/2-225),
		ccp(ssz.width/2, ssz.height/2),
	};
	
	CGPoint originsphn[] = {
		ccp(ssz.width-80, ssz.height/2+112),
		ccp(ssz.width-80, ssz.height/2-112),
		ccp(ssz.width/2, ssz.height/2),
	};
	
	Fleet *fleets[] = {
		[[[BlockFleet alloc] initWithConfig: block1
									andDims: ccp(5,1) 
								withSpacing: _IPAD ? 64 : 32
								   atOrigin: _IPAD ?  origins[0] : originsphn[0]
								  fromRight: NO 
									playing: @"bxxxxxxx"
								 difficulty: curLevel] autorelease],		
		
		[[[BlockFleet alloc] initWithConfig: block1
									andDims: ccp(5,1) 
								withSpacing: _IPAD ? 64 : 32
								   atOrigin: _IPAD ?  origins[1] : originsphn[1]
								  fromRight: NO 
									playing: @"bxxxxxxx"
								 difficulty: curLevel] autorelease],		
		
		[[[DirBlockFleet alloc] initWithConfig: block2
									   andDims: ccp(11,5) 
								   withSpacing: _IPAD ? 40 : 20
									  atOrigin: _IPAD ?  origins[2] : originsphn[2]
									  //maxWidth: _IPAD ? 450 : 225
									  maxWidth: _IPAD ? 50 : 25
									   initDir: ccp(0, 1) 
										  step: _IPAD ? 50 : 20 
									 fromRight: YES  
									   playing:@"mbmbmbmb" 
									difficulty:curLevel] autorelease],
	};	
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end


@implementation StateLevelBombsAway

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	char block1[] = "\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxrrffxxxx\
xxxxxxxrQQAAfxxx\
xxxxxxrQQQAAAfxx\
xxxxxrQQxxxxAAfx\
xxxxrQQxxxxxxAAf\
xxxxrQQxxxxxxAAf\
xxxxfAAxxxxxxQQr\
xxxxfAAxxxxxxQQr\
xxxxxfAAxxxxQQrx\
xxxxxxfAAAQQQrxx\
xxxxxxxfAAQQrxxx\
xxxxxxxxffrrxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx";
	
	char block2[] = "\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxWxxWxxxx\
xxxxxxxxxEExxxxx\
xxxxxxxxxDDxxxxx\
xxxxxxxxSxxSxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx";

	char block3[] = "y";
	
	unsigned char cycle1[] = {
		0,    1,    2,    3,    4,    5,    6,    7,    8,    9,    10,   11,   12,   13,   14,   15,  
		16,   17,   18,   19,   20,   21,   22,   23,   24,   25,   26,   27,   28,   29,   30,   31,  
		32,   33,   34,   35,   36,   37,   38,   39,   55.,  40.,  41.,  42.,  44,   45,   46,   47,  
		48,   49,   50,   51,   52,   53,   54,   70.,  57.,  58.,  59.,  76.,  43.,  61,   62,   63,  
		64,   65,   66,   67,   68,   69,   85.,  56.,  73.,  74.,  75.,  92.,  93.,  60.,  78,   79,  
		80,   81,   82,   83,   84,   100., 71.,  72.,  88,   89,   90,   91,   109.,  110., 77.,  95,  
		96,   97,   98,   99,   116., 86.,  87., 103,  104,  105,  106,  107,  108,  125., 126., 94., 
		112,  113,  114,  115,  132., 101., 102., 119,  120,  121,  122,  123,  124,  141., 142., 111., 
		128,  129,  130,  131,  148., 117., 118., 135,  136,  137,  138,  139,  140,  157., 158., 127., 
		144,  145,  146,  147,  165., 133., 134., 151,  152,  153,  154,  155,  156,  172., 173., 143., 
		160,  161,  162,  163,  164,  182., 149., 150., 168,  169,  170,  171,  187., 188., 159., 175,  
		176,  177,  178,  179,  180,  181,  199., 166., 167., 184., 185., 186., 203., 174., 190,  191,  
		192,  193,  194,  195,  196,  197,  198,  216., 183., 200., 201., 202., 189., 205,  206,  207,  
		208,  209,  210,  211,  212,  213,  214,  215,  217., 218., 219., 204., 220,  221,  222,  223,  
		224,  225,  226,  227,  228,  229,  230,  231,  232,  233,  234,  235,  236,  237,  238,  239,  
		240,  241,  242,  243,  244,  245,  246,  247,  248,  249,  250,  251,  252,  253,  254,  255,  
	};
	
	unsigned char cycle2[] = {
		0,    1,    2,    3,    4,    5,    6,    7,    8,    9,   10,   11,   12,   13,   14,   15,  
		16,   17,   18,   19,   20,   21,   22,   23,   24,   25,   26,   27,   28,   29,   30,   31,  
		32,   33,   34,   35,   36,   37,   38,   39,   40,   41,   42,   43,   44,   45,   46,   47,  
		48,   49,   50,   51,   52,   53,   54,   55,   56,   57,   58,   59,   60,   61,   62,   63,  
		64,   65,   66,   67,   68,   69,   70,   71,   72,   73,   74,   75,   76,   77,   78,   79,  
		80,   81,   82,   83,   84,   85,   86,   87,   88,   89,   90,   91,   92,   93,   94,   95,  
		96,   97,   98,   99,  100,  101,  102,  103,  104,  105,  106,  107,  108,  109,  110,  111,  
		112,  113,  114,  115,  116,  117,  118,  119,  120,  121,  122,  123,  124,  125,  126,  127,  
		128,  129,  130,  131,  132,  133,  134,  135,  136,  137,  138,  139,  140,  141,  142,  143,  
		144,  145,  146,  147,  148,  149,  150,  151,  152,  153,  154,  155,  156,  157,  158,  159,  
		160,  161,  162,  163,  164,  165,  166,  167,  168,  169,  170,  171,  172,  173,  174,  175,  
		176,  177,  178,  179,  180,  181,  182,  183,  184,  185,  186,  187,  188,  189,  190,  191,  
		192,  193,  194,  195,  196,  197,  198,  199,  200,  201,  202,  203,  204,  205,  206,  207,  
		208,  209,  210,  211,  212,  213,  214,  215,  216,  217,  218,  219,  220,  221,  222,  223,  
		224,  225,  226,  227,  228,  229,  230,  231,  232,  233,  234,  235,  236,  237,  238,  239,  
		240,  241,  242,  243,  244,  245,  246,  247,  248,  249,  250,  251,  252,  253,  254,  255,  
	};
	
	
	CGPoint origins[] = {
		ccp(ssz.width/2, ssz.height/2),
		ccp(ssz.width/2-160-80, ssz.height/2),
		ccp(ssz.width/2, ssz.height/2-320),
		ccp(ssz.width/2, ssz.height/2+320),
	};
	
	CGPoint originsphn[] = {
		ccp(ssz.width/2, ssz.height/2),
		ccp(ssz.width/2-80-40, ssz.height/2),
		ccp(ssz.width/2, ssz.height/2-130),
		ccp(ssz.width/2, ssz.height/2+130),
	};
	
	Fleet *bombFleet1;
	Fleet *bombFleet2;
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block1
										 andDims: ccp(16,16) 
									 withSpacing: _IPAD ? 40 : 20
										atOrigin: _IPAD ? origins[0] : origins[0]
										cycleMap: cycle1
									   fromRight: NO 
										 playing: @"bxbxmxmx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig: block2
										 andDims: ccp(16,16) 
									 withSpacing: _IPAD ? 40 : 20 
										atOrigin: _IPAD ? origins[0] : origins[0]
										cycleMap: cycle2
									   fromRight: NO 
										 playing: @"bxbxmxmx"
									  difficulty: curLevel] autorelease]};
		
		if ([[pv.settings get:@"Player1Type"] isEqualToString:@"HUMAN"] && [[pv.settings get:@"Player2Type"] isEqualToString:@"HUMAN"]) {
			bombFleet1 = [[[BlockFleet alloc] initWithConfig: block3
									andDims: ccp(1,1) 
								withSpacing: _IPAD ? 32 : 16
								   atOrigin: _IPAD ? origins[1] : originsphn[1]
								  fromRight: NO 
									playing: @"xxxxxxxx"
								 difficulty: curLevel] autorelease];
			
		}
		else {
			bombFleet1 = [[[BlockFleet alloc] initWithConfig: block3
										andDims: ccp(1,1) 
									withSpacing: _IPAD ? 32 : 16
									   atOrigin: _IPAD ? origins[2] : originsphn[2]
									  fromRight: NO 
										playing: @"xxxxxxxx"
									 difficulty: curLevel] autorelease];
			
			bombFleet2 = [[[BlockFleet alloc] initWithConfig: block3
													 andDims: ccp(1,1) 
												 withSpacing: _IPAD ? 32 : 16
													atOrigin: _IPAD ? origins[3] : originsphn[3]
												   fromRight: NO 
													 playing: @"xxxxxxxx"
												  difficulty: curLevel] autorelease];
		}
		
//		[[[BlockFleet alloc] initWithConfig: block3
//									andDims: ccp(1,1) 
//								withSpacing: _IPAD ? 28 : 14
//								   atOrigin: _IPAD ? origins[2] : originsphn[2]
//								  fromRight: NO 
//									playing: @"xxxxxxxx"
//								 difficulty: curLevel] autorelease],
//		[[[BlockFleet alloc] initWithConfig: block3
//									andDims: ccp(1,1) 
//								withSpacing: _IPAD ? 28 : 14
//								   atOrigin: _IPAD ? origins[3] : originsphn[3]
//								  fromRight: NO 
//									playing: @"xxxxxxxx"
//								 difficulty: curLevel] autorelease],
//		[[[BlockFleet alloc] initWithConfig: block3
//									andDims: ccp(1,1) 
//								withSpacing: _IPAD ? 28 : 14
//								   atOrigin: _IPAD ? origins[4] : originsphn[4]
//								  fromRight: NO 
//									playing: @"xxxxxxxx"
//								 difficulty: curLevel] autorelease],
		
//	};	
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: bombFleet1];
	
	if ([[pv.settings get:@"Player1Type"] isEqualToString:@"COMPUTER"] || [[pv.settings get:@"Player2Type"] isEqualToString:@"COMPUTER"]) {
		[pv addFleet: bombFleet2];
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:bombFleet2 andSequencer:[BeatSequencer getInstance]]];
	}

	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
	
	[[BeatSequencer getInstance] addEvent:
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:bombFleet1 andSequencer:[BeatSequencer getInstance]]];
}

@end

@implementation StateLevel20a

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
char block1[] = "\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxrrffxxxx\
xxxxxxxrQQAAfxxx\
xxxxxxrQQQAAAfxx\
xxxxxrQQxxxxAAfx\
xxxxrQQxxxxxxAAf\
xxxxrQQxxxxxxAAf\
xxxxfAAxxxxxxQQr\
xxxxfAAxxxxxxQQr\
xxxxxfAAxxxxQQrx\
xxxxxxfAAAQQQrxx\
xxxxxxxfAAQQrxxx\
xxxxxxxxffrrxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx";
	
char block2[] = "\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxWxxWxxxx\
xxxxxxxxxEExxxxx\
xxxxxxxxxDDxxxxx\
xxxxxxxxSxxSxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx";
	
	char block3[] = "xxzxzxxxxxxxxxxxxzxz";	
	char block4[] = "xyxyxy";
	
	unsigned char cycle1[] = {
		0,    1,    2,    3,    4,    5,    6,    7,    8,    9,    10,   11,   12,   13,   14,   15,  
		16,   17,   18,   19,   20,   21,   22,   23,   24,   25,   26,   27,   28,   29,   30,   31,  
		32,   33,   34,   35,   36,   37,   38,   39,   55.,  40.,  41.,  42.,  44,   45,   46,   47,  
		48,   49,   50,   51,   52,   53,   54,   70.,  57.,  58.,  59.,  76.,  43.,  61,   62,   63,  
		64,   65,   66,   67,   68,   69,   85.,  56.,  73.,  74.,  75.,  92.,  93.,  60.,  78,   79,  
		80,   81,   82,   83,   84,   100., 71.,  72.,  88,   89,   90,   91,   109.,  110., 77.,  95,  
		96,   97,   98,   99,   116., 86.,  87., 103,  104,  105,  106,  107,  108,  125., 126., 94., 
		112,  113,  114,  115,  132., 101., 102., 119,  120,  121,  122,  123,  124,  141., 142., 111., 
		128,  129,  130,  131,  148., 117., 118., 135,  136,  137,  138,  139,  140,  157., 158., 127., 
		144,  145,  146,  147,  165., 133., 134., 151,  152,  153,  154,  155,  156,  172., 173., 143., 
		160,  161,  162,  163,  164,  182., 149., 150., 168,  169,  170,  171,  187., 188., 159., 175,  
		176,  177,  178,  179,  180,  181,  199., 166., 167., 184., 185., 186., 203., 174., 190,  191,  
		192,  193,  194,  195,  196,  197,  198,  216., 183., 200., 201., 202., 189., 205,  206,  207,  
		208,  209,  210,  211,  212,  213,  214,  215,  217., 218., 219., 204., 220,  221,  222,  223,  
		224,  225,  226,  227,  228,  229,  230,  231,  232,  233,  234,  235,  236,  237,  238,  239,  
		240,  241,  242,  243,  244,  245,  246,  247,  248,  249,  250,  251,  252,  253,  254,  255,  
	};
	
	unsigned char cycle2[] = {
		0,    1,    2,    3,    4,    5,    6,    7,    8,    9,   10,   11,   12,   13,   14,   15,  
		16,   17,   18,   19,   20,   21,   22,   23,   24,   25,   26,   27,   28,   29,   30,   31,  
		32,   33,   34,   35,   36,   37,   38,   39,   40,   41,   42,   43,   44,   45,   46,   47,  
		48,   49,   50,   51,   52,   53,   54,   55,   56,   57,   58,   59,   60,   61,   62,   63,  
		64,   65,   66,   67,   68,   69,   70,   71,   72,   73,   74,   75,   76,   77,   78,   79,  
		80,   81,   82,   83,   84,   85,   86,   87,   88,   89,   90,   91,   92,   93,   94,   95,  
		96,   97,   98,   99,  100,  101,  102,  103,  104,  105,  106,  107,  108,  109,  110,  111,  
		112,  113,  114,  115,  116,  117,  118,  119,  120,  121,  122,  123,  124,  125,  126,  127,  
		128,  129,  130,  131,  132,  133,  134,  135,  136,  137,  138,  139,  140,  141,  142,  143,  
		144,  145,  146,  147,  148,  149,  150,  151,  152,  153,  154,  155,  156,  157,  158,  159,  
		160,  161,  162,  163,  164,  165,  166,  167,  168,  169,  170,  171,  172,  173,  174,  175,  
		176,  177,  178,  179,  180,  181,  182,  183,  184,  185,  186,  187,  188,  189,  190,  191,  
		192,  193,  194,  195,  196,  197,  198,  199,  200,  201,  202,  203,  204,  205,  206,  207,  
		208,  209,  210,  211,  212,  213,  214,  215,  216,  217,  218,  219,  220,  221,  222,  223,  
		224,  225,  226,  227,  228,  229,  230,  231,  232,  233,  234,  235,  236,  237,  238,  239,  
		240,  241,  242,  243,  244,  245,  246,  247,  248,  249,  250,  251,  252,  253,  254,  255,  
	};
	
	CGPoint origins[] = {
		ccp(ssz.width/2, ssz.height/2),
		ccp(ssz.width/2-160-96, ssz.height/2),
	};
	
	CGPoint originsphn[] = {
		ccp(ssz.width/2, ssz.height/2),
		ccp(ssz.width/2-80-48, ssz.height/2),
	};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block1
										 andDims: ccp(16,16) 
									 withSpacing: _IPAD ? 40 : 20
										atOrigin: _IPAD ? origins[0] : origins[0]
										cycleMap: cycle1
									   fromRight: NO 
										 playing: @"bxbxmxmx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig: block2
										 andDims: ccp(16,16) 
									 withSpacing: _IPAD ? 40 : 20 
										atOrigin: _IPAD ? origins[0] : origins[0]
										cycleMap: cycle2
									   fromRight: NO 
										 playing: @"bxbxmxmx"
									  difficulty: curLevel] autorelease],
		
		[[[BlockFleet alloc] initWithConfig: block3
									andDims: ccp(5,4) 
								withSpacing: _IPAD ? 32 : 16
								   atOrigin: _IPAD ? origins[1] : originsphn[1]
								  fromRight: NO 
									playing: @"xxxxxxxx"
								 difficulty: curLevel] autorelease],		
		
		[[[BlockFleet alloc] initWithConfig: block4
									andDims: ccp(6,1) 
								withSpacing: _IPAD ? 28 : 14
								   atOrigin: _IPAD ? origins[1] : originsphn[1]
								  fromRight: NO 
									playing: @"xxxxxxxx"
								 difficulty: curLevel] autorelease],		
		
	};	
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	[pv addFleet: fleets[3]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

// conveyor belt - maybe double
@implementation StateLevelConveyor

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
char block1[] = "\
xxxrrxxxxxxxrrxxx\
xxrAAxxxxxxxQQrxx\
xyAxxxxxxxxxxxQyx\
xfAxxxxxyxxxxxQrx\
xyAxxxxxxxxxxxQyx\
xxfAAxxxxxxxQQfxx\
xxxffxxxxxxxffxxx";
char block2[] = "\
xxxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxxx\
xxxEExxxxxxxDDxxx\
xxxExxxxxxxxxDxxx\
xxxEExxxxxxxDDxxx\
xxxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxxx";
	

//	 unsigned char cycle[] = {
//	 0,  1,  3,  11,  4,  5,  6,  7, 8,  9,  10, 12, 28, 13, 14, 
//	 15, 2, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 44, 29, 
//	 16, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 58, 
//	 45, 30, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 72, 59, 
//	 60, 61, 46, 62, 64, 65, 66, 67, 68, 69, 70, 63, 71, 73, 74};
// 
 /*
	
	char cycle[] = {
		0,  1,  2,  3,  4,  5,  6,  7,	8,  9,  10, 11, 12, 13, 14, 15, 16,
		17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33,
		34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 
		51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 
		68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84,
		85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100,101,
		102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118};
 
	unsigned char cycle[] = {
		0,  1,  2,  3,  4,  5,  6,  7,	8,  9,  10, 11, 12, 13, 14, 15, 16,
		17, 18, 19, 21, 29, 22, 23, 24, 25, 26, 27, 28, 30, 48, 31, 32, 33,
		34, 35, 20, 54, 37, 39, 40, 41, 42, 43, 44, 45, 38, 46, 65, 49, 50, 
		51, 52, 36, 71, 55, 56, 57, 58, 59, 60, 61, 62, 63, 47, 82, 66, 67, 
		68, 69, 53, 72, 80, 73, 74, 75, 76, 77, 78, 79, 81, 64, 98, 83, 84,
		85, 86, 87, 70, 88, 90, 91, 92, 93, 94, 95, 96, 89, 97, 99, 100,101,
		102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118};
 */
	
	unsigned char cycle[] = {
		0,  1,  2,  3,  4,  5,  6,  7,	8,  9,  10, 11, 12, 13, 14, 15, 16,
		17, 18, 19, 21, 29, 22, 23, 24, 25, 26, 27, 28, 30, 48, 31, 32, 33,
		34, 35, 20, 38, 46, 39, 40, 41, 42, 43, 44, 45, 47, 64, 65, 49, 50, 
		51, 52, 36, 37, 55, 56, 57, 58, 59, 60, 61, 62, 63, 81, 82, 66, 67, 
		68, 69, 53, 54, 71, 73, 74, 75, 76, 77, 78, 79, 72, 80, 98, 83, 84,
		85, 86, 87, 70, 88, 90, 91, 92, 93, 94, 95, 96, 89, 97, 99, 100,101,
		102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118};
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(17,7) 
									 withSpacing: _IPAD? 40 : 20
									  atOrigin: origins[0] 
									  cycleMap: cycle
									 fromRight: NO 
									   playing: @"bxbxbxbx"
									difficulty: curLevel] autorelease],
		[[[CycleBlockFleet alloc] initWithConfig: block2
										 andDims: ccp(17,7) 
									 withSpacing: _IPAD? 40 : 20 
										atOrigin: origins[0] 
										cycleMap: cycle
									   fromRight: NO 
										 playing: @"bxmxbxmx"
									  difficulty: curLevel] autorelease]};
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end


// random movement
@implementation StateLevel15b

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	/*
char block[] = "\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxaaaaaaaaxxxx\
xxxxaaaaaaaaxxxx\
xxxxaaaaaaaaxxxx\
xxxxaaaaaaaaxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx";
	 */
	
char block[] = "\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxaaaaaxxxxxx\
xxxxxaaaaaxxxxxx\
xxxxxaaaaaxxxxxx\
xxxxxaaaaaxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx";
	
	
	unsigned char cycle[] = 
	   {102, 207, 52, 149, 41, 59, 26, 114, 87, 71, 179, 99, 34, 51, 50, 146, 35, 
		   58, 239, 132, 80, 64, 118, 174, 15, 167, 162, 33, 56, 129, 27, 237, 113, 
		   109, 124, 4, 53, 63, 218, 161, 10, 254, 255, 103, 172, 157, 202, 96, 29, 
		   46, 241, 197, 164, 48, 78, 165, 67, 126, 43, 153, 250, 243, 159, 8, 74, 
		   45, 216, 171, 175, 213, 107, 245, 199, 233, 155, 190, 230, 22, 2, 154, 18, 
		   184, 200, 176, 158, 76, 119, 60, 192, 128, 6, 144, 14, 220, 17, 39, 226, 
		   117, 151, 178, 37, 7, 120, 75, 185, 181, 231, 79, 138, 98, 246, 186, 93, 
		   228, 83, 168, 73, 89, 136, 140, 147, 223, 212, 30, 166, 13, 224, 49, 142, 
		   217, 244, 229, 0, 180, 32, 81, 201, 247, 188, 95, 195, 28, 31, 101, 238, 
		   187, 160, 20, 236, 121, 106, 9, 123, 116, 196, 110, 242, 249, 209, 91, 108, 
		   215, 169, 112, 214, 24, 86, 19, 145, 177, 227, 44, 191, 122, 65, 135, 170, 
		   42, 100, 57, 182, 36, 111, 5, 84, 183, 173, 240, 131, 40, 205, 62, 189, 
		   141, 194, 72, 55, 38, 222, 148, 163, 90, 137, 134, 54, 221, 235, 105, 61, 
		   66, 156, 104, 210, 70, 219, 198, 234, 225, 204, 127, 25, 77, 23, 130, 232, 
		   115, 16, 203, 47, 248, 252, 139, 193, 251, 125, 208, 88, 211, 69, 97, 94, 
		   206, 3, 253, 11, 1, 12, 82, 68, 133, 85, 21, 150, 152, 92, 143};
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block 
										 andDims: ccp(16,16) 
									 withSpacing: 40 
										atOrigin: origins[0] 
										cycleMap: cycle
									   fromRight: NO 
										 playing: @"bxmxbxmx"
									  difficulty: curLevel] autorelease]};	
	[pv addFleet: fleets[0]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

// puff
@implementation StateLevel16b

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
char block1[] = "\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxzxzxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxaaaaaxxxxx\
xxxzxaxxxaxzxxx\
xxxxxaxaxaxxxxx\
xxxzxaxxxaxzxxx\
xxxxxaaaaaxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxzxzxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx";
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	
	unsigned char cycle1[] =
   { 80,   1,   2,   3,  81,   5,   6,  82,   8,   9,  83,  11,  12,  13,  84, 
	 15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29, 
	 30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44, 
	 45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59, 
	 95,  61,  62,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  99, 
	 75,  76,  77,  78,  79,   0,   4,   7,  10,  14,  85,  86,  87,  88,  89, 
	 90,  91,  92,  93,  94,  60,  96,  97,  98,  74, 100, 101, 102, 103, 104, 
	110, 106, 107, 108, 109, 105, 111, 112, 113, 119, 115, 116, 117, 118, 114, 
	120, 121, 122, 123, 124, 150, 126, 127, 128, 164, 130, 131, 132, 133, 134, 
	135, 136, 137, 138, 139, 210, 214, 217, 220, 224, 145, 146, 147, 148, 149, 
	125, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 129, 
	165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 
	180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 
	195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 
	140, 211, 212, 213, 141, 215, 216, 142, 218, 219, 143, 221, 222, 223, 144		
	};
	
char block2[] = "\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxaaaxxxxxx\
xxxxxxaxaxxxxxx\
xxxxxxaaaxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx";
	
	unsigned char cycle2[] =
	  {   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14, 
	     15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29, 
		 30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44, 
		 45,  46,  47,  96,  49,  50,  51,  97,  53,  54,  55,  98,  57,  58,  59, 
		 60,  61,  62,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74, 
		 75,  76,  77,  78,  79,  80,  81,  82,  83,  84,  85,  86,  87,  88,  89, 
		 90,  91,  92,  93,  94,  95,  48,  52,  56,  99, 100, 101, 102, 103, 104, 
		105, 106, 107, 111, 109, 110, 108, 112, 116, 114, 115, 113, 117, 118, 119, 
		120, 121, 122, 123, 124, 125, 168, 172, 176, 129, 130, 131, 132, 133, 134, 
		135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 
		150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 
		165, 166, 167, 126, 169, 170, 171, 127, 173, 174, 175, 128, 177, 178, 179, 
		180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 
		195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 
		210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224		
	};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block1
										 andDims: ccp(15,15) 
									 withSpacing: 40 
										atOrigin: origins[0] 
										cycleMap: cycle1
									   fromRight: NO 
										 playing: @"bxxxbxxx"
									  difficulty: curLevel] autorelease],
		[[[CycleBlockFleet alloc] initWithConfig: block2
										 andDims: ccp(15,15) 
									 withSpacing: 40 
										atOrigin: origins[0] 
										cycleMap: cycle2
									   fromRight: NO 
										 playing: @"bxxxbxxx"
									  difficulty: curLevel] autorelease],
	};	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end


// old school
@implementation StateLevel17b

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	char block[] = "\
aaaaaaxxxxxxxxxx\
aaaaaaxxxxxxxxxx\
aaaaaaxxxxxxxxxx\
aaaaaaxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx";
	
	unsigned char cycle[] =
	{    1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,  79,
		17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,  95,  
		33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47, 111,  
		49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63, 127,
		
		128, 64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,   
		144, 80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,   
		160, 96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110,  
		176, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 
		
		129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 207,
		145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 223,
		161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 239,
		177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 255,
		
		0, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206,  
		16, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222,  
		32, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238,  
		48, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254
	};
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block
										 andDims: ccp(16,16) 
									 withSpacing: 40 
										atOrigin: origins[0] 
										cycleMap: cycle
									   fromRight: NO 
										 playing: @"bxmxbxmx"
									  difficulty: curLevel] autorelease]};	
	[pv addFleet: fleets[0]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

@implementation StateBattle2

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	CGPoint originsAndDirs[] = {
		ccp(ssz.width+64, ssz.height/2-25), ccp(-1,2),
		ccp(ssz.width+64, ssz.height/2+25), ccp(-1,-2),
		ccp(-64, ssz.height/2-25), ccp(1,2),
		ccp(-64, ssz.height/2+25), ccp(1,-2)};
	
	int idx = 2*(arc4random()%4);
	
	Fleet *fleet = [[[Boss2Fleet alloc] initAtOrigin: originsAndDirs[idx]
											 withDir: originsAndDirs[idx+1]
											 playing: @"s---s-s-s---"
										  difficulty: curLevel] autorelease];	
	
	[pv addFleet: fleet];
	
	[[BeatSequencer getInstance] addEvent:
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
}	
- (int) getPowerup { return 0;}
- (int) getPowerupChance { return 0; }

@end
	
/*
// begin iphone levels

// scrubbed
@implementation StateLevel1iPhone

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	if ([pv.fleets count] == 0) {
		CGSize ssz = [CCDirector sharedDirector].winSize;
		
		char block[] = "xxxxxxxxxxxxxxxxxxxxxxxxqqqqqqqqaaaaaaaaxxxxxxxxxxxxxxxxxxxxxxxx";
		
		CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
		
		Fleet *fleets[] = {
			[[[DirBlockFleet alloc] initWithConfig: block 
										   andDims: ccp(8,8) 
									   withSpacing: 20 
										  atOrigin: origins[0] 
										  maxWidth: 400 
										   initDir: ccp(1,0) 
										 fromRight: NO 
										   playing: @"bxxxbxxx"
										difficulty: curLevel] autorelease]};	
		[pv addFleet: fleets[0]];
	}
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

// scrubbed
@implementation StateLevel2iPhone

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];	
	
char block1[] = "\
xxxxxxxx\
xxxqqxxx\
xxqqqqxx\
xqqxxqqx\
xaaxxaax\
xxaaaaxx\
xxxaaxxx\
xxxxxxxx";
	
	//CGPoint origins[] = {ccp(ssz.width/3-50, ssz.height/2), ccp(2*ssz.width/3+50, ssz.height/2)};
	CGPoint origins[] = {ccp(ssz.width/2-50, ssz.height/2), ccp(ssz.width/2+50, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(8,8)
								   withSpacing: 20
									  atOrigin: origins[0] 
									  maxWidth: 85
									   initDir: ccp(1, 0) 
									 fromRight: YES  
									   playing: @"xmxs"
									difficulty: curLevel] autorelease],
		
		[[[DirBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(8,8)
								   withSpacing: 20 
									  atOrigin: origins[1]
									  maxWidth: 85 
									   initDir: ccp(-1, 0)
									 fromRight: NO
									   playing: @"xsxm"
									difficulty: curLevel] autorelease]};
	
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	
	[[BeatSequencer getInstance] addEvents: 2, 
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]]];
	
}

@end

// scrubbed
@implementation StateLevel3iPhone

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
char block[] = "\
xxxqqxxx\
xxqqqqxx\
xqqxxqqx\
qqxqwxqq\
aaxsaxaa\
xaaxxaax\
xxaaaaxx\
xxxaaxxx";

	
	unsigned char cycle[] = {
		0,  1,  2,  4,  13,  5,  6,  7,
		8,  9,  3,  18, 11, 22, 14, 15,
		16, 10, 25, 19, 20, 12, 31, 23, 
		17, 33, 26, 27, 28, 29, 21, 39,
		24, 42, 34, 35, 36, 37, 30, 46,
		40, 32, 51, 43, 44, 38, 53, 47,
		48, 49, 41, 52, 45, 60, 54, 55,
		56, 57, 58, 50, 59, 61, 62, 63};
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block
										 andDims: ccp(8,8) 
									 withSpacing: 25
										atOrigin: origins[0]
										cycleMap: cycle 
									   fromRight: YES 
										 playing: @"mxss"
									  difficulty: curLevel] autorelease]};	
	
	[pv addFleet: fleets[0]];
	
	[[BeatSequencer getInstance] addEvent:
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]]];
}	

@end

// scrubbed
@implementation StateLevel4iPhone

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
char block1[] = "\
xQQQQQQx\
qqqqqqqq\
aaaaaaaa\
xAAAAAAx";


char block2[] = "\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxzzzzxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxzzzzxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx";
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(8,4)
								   withSpacing: 20 
									  atOrigin: origins[0]
									  maxWidth: 120
									   initDir: ccp(1, 0) 
									 fromRight: YES
									   playing: @"mxsxmxsxmmssmxsx"
									difficulty: curLevel] autorelease],
		
		[[[BlockFleet alloc]    initWithConfig: block2 
									   andDims: ccp(12,10) 
								   withSpacing: 32 
									  atOrigin: origins[0]
									 fromRight: NO 
									   playing: nil
									difficulty: curLevel] autorelease]};
	
	fleets[1].shouldShoot = NO;
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	
	[[BeatSequencer getInstance] addEvents: 2, 
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]]];	
}	

@end

// scrubbed
@implementation StateLevel10iPhone

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	
char block1[] = "\
xxxxxxxx\
xzzxxxaa\
xxxxxaax\
xxxxasxx\
xxxaaxxx\
xxsaxxxx\
xaaxxxxx\
aaxxxxxx";

char block2[] = "\
xxxxxxqq\
xxxxxqqx\
xxxxqwxx\
xxxqqxxx\
xxwqxxxx\
xqqxxxxx\
qqxxxzzx\
xxxxxxxx";

char block3[] = "\
xxxxxxxx\
xxxxxxxx\
xxxQQxxx\
xxQEEQxx\
xxADDAxx\
xxxAAxxx\
xxxxxxxx\
xxxxxxxx";
	

	
	unsigned char cycle1[] = {
		0,  1,  2,  3,  4,  5,  6,  7,
		8,  9,  10, 11, 12, 13, 15, 22,
		16, 17, 18, 19, 20, 14, 29, 23, 
		24, 25, 26, 27, 21, 36, 30, 31,
		32, 33, 34, 28, 43, 37, 38, 39,
		40, 41, 35, 50, 44, 45, 46, 47,
		48, 42, 57, 51, 52, 53, 54, 55,
		49, 56, 58, 59, 60, 61, 62, 63};
	
	unsigned char cycle2[] = {
		0,  1,  2,  3,  4,  5,  13,  6,
		8,  9,  10, 11, 12, 20, 7,  15,
		16, 17, 18, 19, 27, 14, 22, 23, 
		24, 25, 26, 34, 21, 29, 30, 31,
		32, 33, 41, 28, 36, 37, 38, 39,
		40, 48, 35, 43, 44, 45, 46, 47,
		49, 42, 50, 51, 52, 53, 54, 55,
		56, 57, 58, 59, 60, 61, 62, 63};
	
	unsigned char cycle3[] = {
		0,  1,  2,  3,  4,  5,  6,  7,
		8,  9,  10, 11, 12, 13, 14, 15,
		16, 17, 18, 26, 19, 21, 22, 23, 
		24, 25, 34, 27, 28, 20, 30, 31,
		32, 33, 43, 35, 36, 29, 38, 39,
		40, 41, 42, 44, 37, 45, 46, 47,
		48, 49, 50, 51, 52, 53, 54, 55,
		56, 57, 58, 59, 60, 61, 62, 63};
	
	
	CGPoint origins[] = {ccp(100, ssz.height/2+75), ccp(ssz.width-100, ssz.height/2-75), ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block1 
										 andDims: ccp(8,8)  
									 withSpacing: 16 
										atOrigin: origins[0]
										cycleMap: cycle1 
									   fromRight: YES  
										 playing: @"smsmmm"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig: block2 
										 andDims: ccp(8,8) 
									 withSpacing: 16 
										atOrigin: origins[1] 
										cycleMap: cycle2 
									   fromRight: YES 
										 playing: @"mmmsms"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig: block3 
										 andDims: ccp(8,8) 
									 withSpacing: 16 
										atOrigin: origins[2]
										cycleMap: cycle3 
									   fromRight: YES  
										 playing: @"smmmsmmm"
									  difficulty: curLevel] autorelease]};		
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	
	[[BeatSequencer getInstance] addEvents: 3,
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]]];	
	
}	
@end

// scrubbed
@implementation StateLevel9iPhone

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
	
char block1[] = "\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx\
xxaaaaxx\
xxxDDxxx\
xttttttx\
xxxxxxxx";

char block2[] = "\
xxxxxxxx\
xTTTTTTx\
xxxEExxx\
xxqqqqxx\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx";

char block3[] = "\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxzzzzzzxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx\
xxxxxxxxxxxx";
	
	
	CGPoint origins[] = {
		ccp(ssz.width/2, ssz.height/2-50), ccp(ssz.width/2, ssz.height/2+50), 
		ccp(ssz.width/2, ssz.height/2-16)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block1 
									   andDims: ccp(8,8) 
								   withSpacing: 20 
									  atOrigin: origins[0] 
									  maxWidth: 250
									   initDir: ccp(1, 0)
									 fromRight: NO  
									   playing: @"mxmxmsxs"
									difficulty: curLevel] autorelease],
		
		[[[DirBlockFleet alloc] initWithConfig: block2 
									   andDims: ccp(8,8)
								   withSpacing: 20
									  atOrigin: origins[1]
									  maxWidth: 250 
									   initDir: ccp(1, 0) 
									 fromRight: NO  
									   playing: @"msxsmxmx"
									difficulty: curLevel] autorelease],
		
		[[[BlockFleet alloc]    initWithConfig: block3
									   andDims: ccp(12,10)
								   withSpacing: 32 
									  atOrigin: origins[2]
									 fromRight: NO
									   playing: nil
									difficulty: curLevel] autorelease]};
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	
	[[BeatSequencer getInstance] addEvents: 3,
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]]];	
	
}	

@end

// scrubbed
@implementation StateLevel5iPhone

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
char block1[] = "\
xxxxxxxx\
zTTtTTTz\
zxwxxwxz\
zxxxxxxz\
zxxxxxxz\
zxsxxsxz\
ztttTttz\
xxxxxxxx";

char block2[] = "\
zz\
";
	
	

	
	unsigned char cycle1[] = {
		0,  1,  2,  3,  4,  5,  6,  7,
		8,  9,  10, 11, 12, 13, 14, 15,
		16, 17, 19, 20, 21, 29, 22, 23, 
		24, 25, 18, 27, 28, 37, 30, 31,
		32, 33, 26, 35, 36, 45, 38, 39,
		40, 41, 34, 42, 43, 44, 46, 47,
		48, 49, 50, 51, 52, 53, 54, 55,
		56, 57, 58, 59, 60, 61, 62, 63};
	
	
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2), 
		ccp(133 + ssz.width/2, 60 + ssz.height/2), ccp(133 + ssz.width/2, -60 + ssz.height/2), 
		ccp(-133 + ssz.width/2, 60 +ssz.height/2), ccp(-133 + ssz.width/2, -60 +ssz.height/2) };
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig:block1 
										 andDims:ccp(8,8)   
									 withSpacing: 25 
										atOrigin:origins[0] 
										cycleMap: cycle1 
									   fromRight: YES 
										 playing:@"ssmsxxxx" 
									  difficulty:curLevel] autorelease],
		
		[[[BlockFleet alloc]    initWithConfig: block2 
									   andDims: ccp(2,1) 
								   withSpacing: 30 
									  atOrigin: origins[1]
									 fromRight: NO 
									   playing: nil
									difficulty: curLevel] autorelease],
		[[[BlockFleet alloc]    initWithConfig: block2 
									   andDims: ccp(2,1) 
								   withSpacing: 30
									  atOrigin: origins[2]
									 fromRight: NO 
									   playing: nil
									difficulty: curLevel] autorelease],
		[[[BlockFleet alloc]    initWithConfig: block2 
									   andDims: ccp(2,1) 
								   withSpacing: 30
									  atOrigin: origins[3]
									 fromRight: NO 
									   playing: nil
									difficulty: curLevel] autorelease],
		[[[BlockFleet alloc]    initWithConfig: block2 
									   andDims: ccp(2,1) 
								   withSpacing: 30
									  atOrigin: origins[4]
									 fromRight: NO 
									   playing: nil
									difficulty: curLevel] autorelease]
	};		
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	[pv addFleet: fleets[3]];
	[pv addFleet: fleets[4]];
	
	[[BeatSequencer getInstance] addEvents: 5,
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[3] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[4] andSequencer:[BeatSequencer getInstance]]
	 ];	
	
}	
@end

// scrubbed
@implementation StateLevel6iPhone

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
char block1[] = "\
xxxx\
zxxz\
zxxz\
zxxz\
zxxz\
zxxz\
zxxz\
xxxx";

char block2[] = "\
AAAAAA\
AADADA\
AAAAAA\
AADADA\
AAAAAA";
	
	CGPoint origins[] = { ccp(120 + ssz.width/2, ssz.height/2), ccp(-120 + ssz.width/2, ssz.height/2), ccp(ssz.width/2, ssz.height/2) };
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig:block2 andDims:ccp(6,5) withSpacing: 20 atOrigin:origins[0] maxWidth: 275 initDir: ccp(0, 1)  fromRight: YES  playing:@"ssmbxxxxxxxxxxxx" difficulty:curLevel] autorelease],
		[[[DirBlockFleet alloc] initWithConfig:block2 andDims:ccp(6,5) withSpacing: 20 atOrigin:origins[1] maxWidth: 275 initDir: ccp(0, 1)  fromRight: YES  playing:@"xxxxxxxxssmbxxxx" difficulty:curLevel] autorelease],
		[[[BlockFleet alloc]    initWithConfig:block1 andDims:ccp(4,8) withSpacing: 30 atOrigin:origins[2] fromRight: NO playing:@"" difficulty:curLevel] autorelease]};
	
	// fleets[1].shouldShoot = NO;
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	
	[[BeatSequencer getInstance] addEvents: 3, 
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]]
	 ];
}
@end


// scrubbed
@implementation StateLevel7iPhone

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
char block1[] = "\
xzxtxzxxxzxTxzx\
xxtxtxxxxxTxTxx\
ztxsxtzzzTxwxTz\
xxTxTxxxxxtxtxx\
xzxTxzxxxzxtxzx";
	

	
	unsigned char cycle[] = {
		0,  1,  2,  19,  4,  5,  6,  7,	8,  9,  10, 27, 12, 13, 14, 
		15, 16, 3, 18, 35, 20, 21, 22, 23, 24, 11, 26, 43, 28, 29, 
		30, 17,	32, 33, 34, 49, 36, 37, 38, 25,	40, 41, 42, 57, 44, 
		45, 46, 31,	48, 63, 50, 51, 52, 53, 54, 39,	56, 71, 58, 59, 
		60, 61, 62, 47, 64, 65, 66, 67, 68, 69, 70, 55, 72, 73, 74};
	
	
	
	CGPoint origins[] = { ccp(ssz.width/2, ssz.height/2) };
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig:block1
										 andDims:ccp(15,5)
									 withSpacing:22
										atOrigin: origins[0]
										cycleMap: cycle
									   fromRight: YES
										 playing: @"sxmxsxbx"
									  difficulty: curLevel] autorelease]};
	
	// fleets[1].shouldShoot = NO;
	
	[pv addFleet: fleets[0]];
	
	[[BeatSequencer getInstance] addEvents: 1, 
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]]
	 ];
}
@end

//scrubbed
@implementation StateLevel8iPhone

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
char block1[] = "\
TTTETTTxxxxxxxx";

char block2[] = "\
xxxxqxqxqxqxqxqxqxqxqxxxxxxxxx";

char block3[] = "\
xxxxxxxxxaxaxaxaxaxaxaxaxaxxxx";

char block4[] = "\
xxxxxxxxtttDttt";
	

	
	unsigned char cycle1[] = {
		8,  9,  10,  11,  12,  13,  14,  7,	0,  1,  2, 3, 4, 5, 6};
	unsigned char cycle2[] = {
		0,  1,  2,  3,  9,  5,  11,  7,	13,  4,  15, 6, 17, 8, 19, 10,  21, 12, 23, 14, 25, 16, 22, 18, 24, 20, 26, 27, 28, 29};
	
	
	
	CGPoint origins[] = { ccp(ssz.width/2, ssz.height/2+75), ccp(ssz.width/2, ssz.height/2+25), ccp(ssz.width/2, ssz.height/2-25), ccp(ssz.width/2, ssz.height/2-75) };
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig:block1
										 andDims:ccp(15,1)
									 withSpacing:20
										atOrigin: origins[0]
										cycleMap: cycle1
									   fromRight: YES
										 playing: @"mxxsxxxxx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig:block2
										 andDims:ccp(30,1)
									 withSpacing:10
										atOrigin: origins[1]
										cycleMap: cycle2
									   fromRight: YES
										 playing: @"xxmxxsxsx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig:block3
										 andDims:ccp(30,1)
									 withSpacing:10
										atOrigin: origins[2]
										cycleMap: cycle2
									   fromRight: YES
										 playing: @"xxxxmxsxx"
									  difficulty: curLevel] autorelease],
		
		[[[CycleBlockFleet alloc] initWithConfig:block4
										 andDims:ccp(15,1)
									 withSpacing:20
										atOrigin: origins[3]
										cycleMap: cycle1
									   fromRight: YES
										 playing: @"sxxxxxmxx"
									  difficulty: curLevel] autorelease],
		
	};
	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	[pv addFleet: fleets[2]];
	[pv addFleet: fleets[3]];
	
	[[BeatSequencer getInstance] addEvents: 4, 
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[1] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[2] andSequencer:[BeatSequencer getInstance]],
	 [AddBeatResponderEvent eventOnBeat:7 withResponder:fleets[3] andSequencer:[BeatSequencer getInstance]]
	 ];
}
@end

// scrubbed
@implementation StateBattle1iPhone

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
char block[] = "\
xxxxxxx\
xxxxxxx\
xxxxxxx\
xxx1xxx\
xxxxxxx\
xxxxxxx\
xxxxxxx";
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[BlockFleet alloc] initWithConfig: block 
									andDims: ccp(7,7)
								withSpacing: 25
								   atOrigin: origins[0]
								  fromRight: YES 
									playing: @"sxxxxxxx"
								 difficulty: curLevel] autorelease]};	
	
	[pv addFleet: fleets[0]];
	
	[[BeatSequencer getInstance] addEvent:
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]]];
}	

@end

@implementation StateLevel11iPhone

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
char block[] = "\
zxzxzxz\
AWAWAWA\
xzDzDzx\
SSQSQSS\
zxzxzxz";
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block 
									   andDims: ccp(7,5) 
								   withSpacing: 90 
									  atOrigin: origins[0] 
									  maxWidth: 350 
									   initDir: ccp(1,0) 
									 fromRight: NO 
									   playing: @"bxxxbxxx"
									difficulty: curLevel] autorelease]};	
	[pv addFleet: fleets[0]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

@implementation StateLevel12iPhone

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
	
char block[] = "\
xxxttxxx\
xxTqqTxx\
xTqxxqTx\
tqxqwxqt\
taxsaxat\
xTaxxaTx\
xxTaaTxx\
xxxttxxx";

char rockBlock[] = "\
zzz\
xxx\
xxx\
xxx\
zzz";
	

	
	unsigned char cycle[] = {
		0,  1,  2,  4,  13,  5,  6,  7,
		8,  9,  3,  18, 11, 22, 14, 15,
		16, 10, 25, 19, 20, 12, 31, 23, 
		17, 33, 26, 27, 28, 29, 21, 39,
		24, 42, 34, 35, 36, 37, 30, 46,
		40, 32, 51, 43, 44, 38, 53, 47,
		48, 49, 41, 52, 45, 60, 54, 55,
		56, 57, 58, 50, 59, 61, 62, 63};
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2), ccp(ssz.width/2-250, ssz.height/2), ccp(ssz.width/2+250, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block
										 andDims: ccp(8,8) 
									 withSpacing: 50
										atOrigin: origins[0]
										cycleMap: cycle 
									   fromRight: YES  
										 playing: @"mxss"
									  difficulty: curLevel] autorelease],
		[[[DirBlockFleet alloc] initWithConfig: rockBlock 
									   andDims: ccp(3,5) 
								   withSpacing: 65 
									  atOrigin: origins[1] 
									  maxWidth: 50 
									   initDir: ccp(0,0) 
									 fromRight: NO 
									   playing: @"xxxxxxxx"
									difficulty: curLevel] autorelease],
		[[[DirBlockFleet alloc] initWithConfig: rockBlock 
									   andDims: ccp(3,5) 
								   withSpacing: 65 
									  atOrigin: origins[2] 
									  maxWidth: 50 
									   initDir: ccp(0,0) 
									 fromRight: NO 
									   playing: @"xxxxxxxx"
									difficulty: curLevel] autorelease]};	
	
	
	[pv addFleet: fleets[0]];
	
	[[BeatSequencer getInstance] addEvent:
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]]];
}	

@end

@implementation StateLevel13iPhone

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
char block[] = "\
xxyyxx\
xxxxxx\
zTTTTz\
zttttz\
xxxxxx\
xxyyx";
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block 
									   andDims: ccp(6,6) 
								   withSpacing: 50 
									  atOrigin: origins[0] 
									  maxWidth: 400 
									   initDir: ccp(0,0) 
									 fromRight: NO 
									   playing: @"bxxxbxxx"
									difficulty: curLevel] autorelease]};	
	[pv addFleet: fleets[0]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

// conveyor belt - maybe double
@implementation StateLevel14iPhone

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
char block[] = "\
xxaaxxxxxxxaaxx\
xaxxxxxxxxxxxax\
axxxxxxxxxxxxxa\
xaxxxxxxxxxxxax\
xxaaxxxxxxxaaxx";
	
	
	unsigned char cycle[] = {
		0,  1,  3,  11,  4,  5,  6,  7, 8,  9,  10, 12, 28, 13, 14, 
		15, 2, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 44, 29, 
		16, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 58, 
		45, 30, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 72, 59, 
		60, 61, 46, 62, 64, 65, 66, 67, 68, 69, 70, 63, 71, 73, 74};
	

	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block 
										 andDims: ccp(15,5) 
									 withSpacing: 40 
										atOrigin: origins[0] 
										cycleMap: cycle
									   fromRight: NO 
										 playing: @"bxmxbxmx"
									  difficulty: curLevel] autorelease]};
	[pv addFleet: fleets[0]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

// random movement
@implementation StateLevel15iPhone

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
char block[] = "\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxaaaaaxxxxxx\
xxxxxaaaaaxxxxxx\
xxxxxaaaaaxxxxxx\
xxxxxaaaaaxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx";
	
	
	unsigned char cycle[] = 
	{102, 207, 52, 149, 41, 59, 26, 114, 87, 71, 179, 99, 34, 51, 50, 146, 35, 
		58, 239, 132, 80, 64, 118, 174, 15, 167, 162, 33, 56, 129, 27, 237, 113, 
		109, 124, 4, 53, 63, 218, 161, 10, 254, 255, 103, 172, 157, 202, 96, 29, 
		46, 241, 197, 164, 48, 78, 165, 67, 126, 43, 153, 250, 243, 159, 8, 74, 
		45, 216, 171, 175, 213, 107, 245, 199, 233, 155, 190, 230, 22, 2, 154, 18, 
		184, 200, 176, 158, 76, 119, 60, 192, 128, 6, 144, 14, 220, 17, 39, 226, 
		117, 151, 178, 37, 7, 120, 75, 185, 181, 231, 79, 138, 98, 246, 186, 93, 
		228, 83, 168, 73, 89, 136, 140, 147, 223, 212, 30, 166, 13, 224, 49, 142, 
		217, 244, 229, 0, 180, 32, 81, 201, 247, 188, 95, 195, 28, 31, 101, 238, 
		187, 160, 20, 236, 121, 106, 9, 123, 116, 196, 110, 242, 249, 209, 91, 108, 
		215, 169, 112, 214, 24, 86, 19, 145, 177, 227, 44, 191, 122, 65, 135, 170, 
		42, 100, 57, 182, 36, 111, 5, 84, 183, 173, 240, 131, 40, 205, 62, 189, 
		141, 194, 72, 55, 38, 222, 148, 163, 90, 137, 134, 54, 221, 235, 105, 61, 
		66, 156, 104, 210, 70, 219, 198, 234, 225, 204, 127, 25, 77, 23, 130, 232, 
		115, 16, 203, 47, 248, 252, 139, 193, 251, 125, 208, 88, 211, 69, 97, 94, 
		206, 3, 253, 11, 1, 12, 82, 68, 133, 85, 21, 150, 152, 92, 143};
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block 
										 andDims: ccp(16,16) 
									 withSpacing: 40 
										atOrigin: origins[0] 
										cycleMap: cycle
									   fromRight: NO 
										 playing: @"bxmxbxmx"
									  difficulty: curLevel] autorelease]};	
	[pv addFleet: fleets[0]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

// puff
@implementation StateLevel16iPhone

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
char block1[] = "\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxaaaaaxxxxx\
xxxxxaxxxaxxxxx\
xxxxxaxaxaxxxxx\
xxxxxaxxxaxxxxx\
xxxxxaaaaaxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx";
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	
	unsigned char cycle1[] =
	{ 80,   1,   2,   3,  81,   5,   6,  82,   8,   9,  83,  11,  12,  13,  84, 
		15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29, 
		30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44, 
		45,  46,  47,  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59, 
		95,  61,  62,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  99, 
		75,  76,  77,  78,  79,   0,   4,   7,  10,  14,  85,  86,  87,  88,  89, 
		90,  91,  92,  93,  94,  60,  96,  97,  98,  74, 100, 101, 102, 103, 104, 
		110, 106, 107, 108, 109, 105, 111, 112, 113, 119, 115, 116, 117, 118, 114, 
		120, 121, 122, 123, 124, 150, 126, 127, 128, 164, 130, 131, 132, 133, 134, 
		135, 136, 137, 138, 139, 210, 214, 217, 220, 224, 145, 146, 147, 148, 149, 
		125, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 129, 
		165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 
		180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 
		195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 
		140, 211, 212, 213, 141, 215, 216, 142, 218, 219, 143, 221, 222, 223, 144		
	};
	
char block2[] = "\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxaaaxxxxxx\
xxxxxxaaaxxxxxx\
xxxxxxaaaxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxx";
	
	unsigned char cycle2[] =
	{   0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14, 
		15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29, 
		30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44, 
		45,  46,  47,  96,  49,  50,  51,  97,  53,  54,  55,  98,  57,  58,  59, 
		60,  61,  62,  63,  64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74, 
		75,  76,  77,  78,  79,  80,  81,  82,  83,  84,  85,  86,  87,  88,  89, 
		90,  91,  92,  93,  94,  95,  48,  52,  56,  99, 100, 101, 102, 103, 104, 
		105, 106, 107, 111, 109, 110, 108, 112, 116, 114, 115, 113, 117, 118, 119, 
		120, 121, 122, 123, 124, 125, 168, 172, 176, 129, 130, 131, 132, 133, 134, 
		135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 
		150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 
		165, 166, 167, 126, 169, 170, 171, 127, 173, 174, 175, 128, 177, 178, 179, 
		180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 
		195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 
		210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224		
	};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block1
										 andDims: ccp(15,15) 
									 withSpacing: 40 
										atOrigin: origins[0] 
										cycleMap: cycle1
									   fromRight: NO 
										 playing: @"bxxxbxxx"
									  difficulty: curLevel] autorelease],
		[[[CycleBlockFleet alloc] initWithConfig: block2
										 andDims: ccp(15,15) 
									 withSpacing: 40 
										atOrigin: origins[0] 
										cycleMap: cycle2
									   fromRight: NO 
										 playing: @"bxxxbxxx"
									  difficulty: curLevel] autorelease],
	};	
	[pv addFleet: fleets[0]];
	[pv addFleet: fleets[1]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end


// old school
@implementation StateLevel17iPhone

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
char block[] = "\
aaaaaaxxxxxxxxxx\
aaaaaaxxxxxxxxxx\
aaaaaaxxxxxxxxxx\
aaaaaaxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx\
xxxxxxxxxxxxxxxx";
	
	unsigned char cycle[] =
	{    1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,  79,
		17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,  95,  
		33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47, 111,  
		49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63, 127,
		
		128, 64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,   
		144, 80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,   
		160, 96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110,  
		176, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 
		
		129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 207,
		145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 223,
		161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 239,
		177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 255,
		
		0, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206,  
		16, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222,  
		32, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238,  
		48, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254
	};
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[CycleBlockFleet alloc] initWithConfig: block
										 andDims: ccp(16,16) 
									 withSpacing: 40 
										atOrigin: origins[0] 
										cycleMap: cycle
									   fromRight: NO 
										 playing: @"bxmxbxmx"
									  difficulty: curLevel] autorelease]};	
	[pv addFleet: fleets[0]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end



@implementation StateLevel18iPhone

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	char block[] = "xxxxxxxxxxxxxxxxxxxxxxxxqqqqqqqqaaaaaaaaxxxxxxxxxxxxxxxxxxxxxxxx";
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block 
									   andDims: ccp(8,8) 
								   withSpacing: 40 
									  atOrigin: origins[0] 
									  maxWidth: 400 
									   initDir: ccp(1,0) 
									 fromRight: NO 
									   playing: @"bxxxbxxx"
									difficulty: curLevel] autorelease]};	
	[pv addFleet: fleets[0]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

@implementation StateLevel19iPhone

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	char block[] = "xxxxxxxxxxxxxxxxxxxxxxxxqqqqqqqqaaaaaaaaxxxxxxxxxxxxxxxxxxxxxxxx";
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block 
									   andDims: ccp(8,8) 
								   withSpacing: 40 
									  atOrigin: origins[0] 
									  maxWidth: 400 
									   initDir: ccp(1,0) 
									 fromRight: NO 
									   playing: @"bxxxbxxx"
									difficulty: curLevel] autorelease]};	
	[pv addFleet: fleets[0]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

@implementation StateLevel20iPhone

- (void) enter {
	[super enter];
	PongVader *pv = [PongVader getInstance];
	
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	char block[] = "xxxxxxxxxxxxxxxxxxxxxxxxqqqqqqqqaaaaaaaaxxxxxxxxxxxxxxxxxxxxxxxx";
	
	CGPoint origins[] = {ccp(ssz.width/2, ssz.height/2)};
	
	Fleet *fleets[] = {
		[[[DirBlockFleet alloc] initWithConfig: block 
									   andDims: ccp(8,8) 
								   withSpacing: 40 
									  atOrigin: origins[0] 
									  maxWidth: 400 
									   initDir: ccp(1,0) 
									 fromRight: NO 
									   playing: @"bxxxbxxx"
									difficulty: curLevel] autorelease]};	
	[pv addFleet: fleets[0]];
	
	for (Fleet *fleet in pv.fleets) {
		[[BeatSequencer getInstance] addEvent:
		 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleet andSequencer:[BeatSequencer getInstance]]];
	}
}

@end

@implementation StateBattle2iPhone

- (void) enter {
	[super enter];
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// initialize fleet
	PongVader *pv = [PongVader getInstance];
	
char block[] = "\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx\
xxx1xxxx\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx\
xxxxxxxx";
	
	CGPoint origins[] = {ccp(ssz.width/2+25, ssz.height/2+25)};
	
	Fleet *fleets[] = {
		[[[BlockFleet alloc] initWithConfig: block 
									andDims: ccp(8,8)
								withSpacing: 50
								   atOrigin: origins[0]
								  fromRight: YES 
									playing: @"sxxxxxxx"
								 difficulty: curLevel] autorelease]};	
	
	
	[pv addFleet: fleets[0]];
	
	[[BeatSequencer getInstance] addEvent:
	 [AddBeatResponderEvent eventOnBeat:8 withResponder:fleets[0] andSequencer:[BeatSequencer getInstance]]];
}	

@end
*/
