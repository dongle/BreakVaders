//
//  GameStates.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"
#import "cocos2d.h"
#import "BeatSequencer.h"
#import "ModalWebView.h"
#import "GameSettings.h"
#import "SpriteBody.h"
#import "Invader.h"

@interface SelectedNode : NSObject
{
	NSString *labelname;
	BOOL selected, selectable;
	CCNode *node;
}
@property (nonatomic, retain) NSString *labelname;
@property (readwrite, assign) BOOL selected;
@property (readwrite, assign) BOOL selectable;
@property (nonatomic, retain) CCNode *node;
@end

@interface StateMenu : GameState {
	NSMutableArray *_labels;
	CCSprite *pvTitle;
	BOOL setupTitle;
	BOOL shouldClearFirst;
}

@property (readwrite, assign) BOOL shouldClearFirst;

- (GameState *) doHover:(SelectedNode *) label;
- (GameState *) doSelected:(SelectedNode *) label;
- (void) provideContent: (NSString*) productID;
@end

@interface StateMainMenu : StateMenu {

}

@end

@interface StateSettingsMenu : StateMenu  {
	CCSprite *arrow[3];
	// CCLabelBMFont *ptype[2];
}
@end

@interface StatePausedMenu : StateMenu {
	CCSprite *arrow[3];
	// CCLabelBMFont *ptype[2];
	CCLayerColor *flash;
}
@end

@interface StateLoseMenu : StateMenu {
	CCLabelBMFont *scores[2];
	CCLabelBMFont *scoreLabels[2];
	CCLabelBMFont *maxChains[2];
	CCLabelBMFont *curChains[2];
	CCLabelBMFont *combinedChain;
	CCLabelBMFont *combinedScore;
	
	UIAlertView * signupAlert;
	UIAlertView * appStoreAlert;
}
@end

@interface StateInfo : GameState <InterceptLinkDelegate, UIAlertViewDelegate> {
	ModalWebView * modalView;
	UIAlertView * appStoreAlert;
	GameState * returnState;
}
@end

@interface StateMoreGames : GameState {
}
@end

@interface StateGetReady : GameState {
	CCLabelBMFont *_label[4];
	BOOL shouldClearFirst;
}
@property (readwrite, assign) BOOL shouldClearFirst;
@end

@interface StatePlaying : GameState
{
	CCLabelBMFont *scores[2];
	CCLabelBMFont *scoreLabels[2];
	CCLabelBMFont *maxChains[2];
	CCLabelBMFont *curChains[2];
	CCLabelBMFont *bulletLabels[2];
	//CCLabelBMFont *pauseLabels[2];
	CCSprite *pauseLabels[2];
	BOOL hasEnteredBulletTime;
	BOOL btLabelDisplayed;
	BOOL isPaused;
	BOOL touchingPause;
	BOOL shouldClearFirst;
	int lastScores[2];
}
@property (readwrite, assign) BOOL shouldClearFirst;
@end

@interface StatePostPlaying : GameState
{
	CCLabelBMFont *_label[4];
}
- (id) initWithString1: (NSString *) l1 andString2: (NSString *) l2;
@end

@interface StateDeath : StatePostPlaying {
}
@end

@interface StateWin : StatePostPlaying {
}
@end

@interface StateTransition : GameState {
	UIAlertView * appStoreAlert;
}
@end

@interface StateMovie : GameState
{
	NSTimeInterval times[MAX_MOVIE_ACTIONS];
	int curAction;
	CCSprite *textBubble;
	CCNode *messageLabel;
	CCSprite *textWedge;	
	CCSprite *ltrbox[2];
	//SelectedNode *skiplabel;
	CCLabelBMFont *skiplabel;
}
- (GameState *) doAction: (int) action;
- (void) placeBubble:(CGPoint) p rlen: (float) rowlength rc:(int) rowcount;
- (void) placeBubble:(CGPoint) p rlen: (float) rowlength rc:(int) rowcount sp:(int) speaker;
- (void) clearMessageAndBubble;
- (void) skip;
@end

@interface StateCredits : StateMovie {
	CCNode *scrollNode;
	
	// logos
	CCSprite *pvLogo, *kdcLogo, *apLogo, *nsLogo, *humaneLogo;
	CCSprite *jonvader, *colevader;
	
	// captions
	CCLabelBMFont *producedBy, *artBy, *musicBy, *starring, *supportedBy;
	CCLabelBMFont *cameos, *humaneNotice1, *humaneNotice2, *humaneTitle;
	
	// labels
	CCLabelBMFont *ensign, *lieutenant, *commander, *tank, *sweetCheeks;
	CCLabelBMFont *seaman, *captain, *admiral;
	
	// characters
	Invader *ensPrance, *ltWaddle, *cdrBobble, *shieldvader, *redvader;
	Invader *smnEye, *cptDawdle, *admBrain;
}
@end

@interface StateTutorial : StateMovie
{
	CGFloat pad1x, pad2x;
	CGPoint powerupSpawn, i1, i2;
	BOOL viewReset;
	
	CCLabelBMFont *tutorialLabel;
	
	Invader *invader1, *invader2;
}
@end

@interface StateTutorialShort : StateMovie
{
	CGFloat pad1x, pad2x;
	CGPoint powerupSpawn;
	BOOL viewReset;
}
@end

@interface StateIntro : StateMovie
{
}
@end

@interface StateOutro : StateMovie
{
	SpriteBody *peon;
}
@end

@interface StateOutroPro : StateMovie
{
	CGFloat pad1x, pad2x;
	CGPoint powerupSpawn, i1, i2;
	BOOL viewReset;
	
	Invader *invader1, *invader2;
}
@end

@interface StateOutroProUpsell : StateMovie
{
	CGFloat pad1x, pad2x;
	CGPoint powerupSpawn, i1, i2;
	BOOL viewReset;
	UIAlertView *appStoreAlert;
	Invader *invader1, *invader2;
}
@end

@interface StateOutroEp2 : StateMovie
{
	SpriteBody *peon;
}
@end

@interface StateOutroOld : StateMovie
{
	SpriteBody *peon;
}
@end

// PLAYABLE LEVELS

@interface StateLevelMadison : StatePlaying
{
}
@end

@interface StateLevelBoxers : StatePlaying
{
}
@end

@interface StateLevel1972 : StatePlaying
{
}
@end

@interface StateLevelClockwork : StatePlaying
{
}
@end

@interface StateLevelNoEscape : StatePlaying
{
}
@end

@interface StateLevelLabyrinth : StatePlaying
{
}
@end

@interface StateLevelWeakest : StatePlaying
{
}
@end

@interface StateLevelKey : StatePlaying
{
}
@end

@interface StateLevelGutter : StatePlaying
{
}
@end

@interface StateLevelFish : StatePlaying
{
}
@end

@interface StateLevelPeace : StatePlaying
{
}
@end

@interface StateBattlePro : StatePlaying
{
}
@end

@interface StateLevelSizzurp : StatePlaying
{
}
@end

@interface StateLevel1978 : StatePlaying
{
}
@end

@interface StateLevelPasties : StatePlaying
{
}
@end

@interface StateLevelElectricSlide: StatePlaying
{
}
@end

@interface StateLevelFlipside: StatePlaying
{
}
@end

@interface StateLevelSteady : StatePlaying
{
}
@end

@interface StateLevelShine : StatePlaying
{
}
@end

@interface StateLevelSoMeta : StatePlaying
{
}
@end

@interface StateLevelLastStraw : StatePlaying
{
}
@end

@interface StateLevelGimmeShelter : StatePlaying
{
}
@end

@interface StateLevelPanicBomber : StatePlaying
{
}
@end

@interface StateLevelEscalator: StatePlaying
{
}
@end

@interface StateBattle1 : StatePlaying
{
}
@end

@interface StateLevelConveyor: StatePlaying
{
}
@end

@interface StateLevelPachinko: StatePlaying
{
}
@end

@interface StateLevelLockbox: StatePlaying
{
}
@end

@interface StateLevelRockBlocked: StatePlaying
{
}
@end

@interface StateLevelSaturdayNight: StatePlaying
{
}
@end

@interface StateLevelGalacticIntruders: StatePlaying
{
}
@end



@interface StateLevelWhopper: StatePlaying
{
}
@end

@interface StateLevelDrano: StatePlaying
{
}
@end

@interface StateLevelBombsAway: StatePlaying
{
}
@end


@interface StateLevelSuperAstroBall: StatePlaying
{
}
@end

@interface StateBattle2: StatePlaying
{
}
@end

// SCRAPPED

@interface StateLevel20a: StatePlaying
{
}
@end

@interface StateLevel19a : StatePlaying
{
}
@end

@interface StateLevel17a: StatePlaying
{
}
@end



@interface StateLevel15b: StatePlaying
{
}
@end

@interface StateLevel16b: StatePlaying
{
}
@end

@interface StateLevel17b: StatePlaying
{
}
@end

@interface StateLevel18: StatePlaying
{
}
@end

@interface StateLevel14a: StatePlaying
{
}
@end

@interface StateLevelPAX : StatePlaying
{
}
@end

@interface StateLevel16: StatePlaying
{
}
@end
