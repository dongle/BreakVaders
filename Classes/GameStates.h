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
	NSString *_labelname;
	BOOL _selected, _selectable;
	CCNode *_node;
}
@property (nonatomic, retain) NSString *labelname;
@property (readwrite, assign) BOOL selected;
@property (readwrite, assign) BOOL selectable;
@property (nonatomic, retain) CCNode *node;
@end

@interface StateMenu : GameState {
	NSMutableArray *_labels;
	CCSprite *_pvTitle;
	BOOL _setupTitle;
	BOOL _shouldClearFirst;
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
	CCSprite *_arrow[3];
	// CCLabelBMFont *ptype[2];
}
@end

@interface StatePausedMenu : StateMenu {
	CCSprite *_arrow[3];
	// CCLabelBMFont *ptype[2];
	CCLayerColor *_flash;
}
@end

@interface StateLoseMenu : StateMenu {
	CCLabelBMFont *_scores[2];
	CCLabelBMFont *_scoreLabels[2];
	CCLabelBMFont *_maxChains[2];
	CCLabelBMFont *_curChains[2];
	CCLabelBMFont *_combinedChain;
	CCLabelBMFont *_combinedScore;
}
@end

@interface StateInfo : GameState <InterceptLinkDelegate, UIAlertViewDelegate> {
	ModalWebView *_modalView;
	UIAlertView *_appStoreAlert;
	GameState *_returnState;
}
@end

@interface StateMoreGames : GameState {
}
@end

@interface StateGetReady : GameState {
	CCLabelBMFont *_label[4];
	BOOL _shouldClearFirst;
}
@property (readwrite, assign) BOOL shouldClearFirst;
@end

@interface StatePlaying : GameState
{
	CCLabelBMFont *_scores[2];
	CCLabelBMFont *_scoreLabels[2];
	CCLabelBMFont *_maxChains[2];
	CCLabelBMFont *_curChains[2];
	CCLabelBMFont *_bulletLabels[2];
	//CCLabelBMFont *pauseLabels[2];
	CCSprite *_pauseLabels[2];
	BOOL _hasEnteredBulletTime;
	BOOL _btLabelDisplayed;
	BOOL _isPaused;
	BOOL _touchingPause;
	BOOL _shouldClearFirst;
	int _lastScores[2];
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
	UIAlertView * _appStoreAlert;
}
@end

@interface StateMovie : GameState
{
	NSTimeInterval _times[MAX_MOVIE_ACTIONS];
	int _curAction;
	CCSprite *_textBubble;
	CCNode *_messageLabel;
	CCSprite *_textWedge;
	CCSprite *_ltrbox[2];
	//SelectedNode *skiplabel;
	CCLabelBMFont *_skiplabel;
}
- (GameState *) doAction: (int) action;
- (void) placeBubble:(CGPoint) p rlen: (float) rowlength rc:(int) rowcount;
- (void) placeBubble:(CGPoint) p rlen: (float) rowlength rc:(int) rowcount sp:(int) speaker;
- (void) clearMessageAndBubble;
- (void) skip;
@end

@interface StateCredits : StateMovie {
	CCNode *_scrollNode;
	
	// logos
	CCSprite *_pvLogo, *_kdcLogo, *_apLogo, *_nsLogo, *_humaneLogo;
	CCSprite *_jonvader, *_colevader;
	
	// captions
	CCLabelBMFont *_producedBy, *_artBy, *_musicBy, *_starring, *_supportedBy;
	CCLabelBMFont *_cameos, *_humaneNotice1, *_humaneNotice2, *_humaneTitle;
	
	// labels
	CCLabelBMFont *_ensign, *_lieutenant, *_commander, *_tank, *_sweetCheeks;
	CCLabelBMFont *_seaman, *_captain, *_admiral;
	
	// characters
	Invader *_ensPrance, *_ltWaddle, *_cdrBobble, *_shieldvader, *_redvader;
	Invader *_smnEye, *_cptDawdle, *_admBrain;
}
@end

@interface StateTutorial : StateMovie
{
	CGFloat _pad1x, _pad2x;
	CGPoint _powerupSpawn, _i1, _i2;
	BOOL _viewReset;
	
	CCLabelBMFont *_tutorialLabel;
	
	Invader *_invader1, *_invader2;
}
@end

@interface StateTutorialShort : StateMovie
{
	CGFloat _pad1x, _pad2x;
	CGPoint _powerupSpawn;
	BOOL _viewReset;
}
@end

@interface StateIntro : StateMovie
{
}
@end

@interface StateOutro : StateMovie
{
	SpriteBody *_peon;
}
@end

@interface StateOutroPro : StateMovie
{
	CGFloat _pad1x, _pad2x;
	CGPoint _powerupSpawn, _i1, _i2;
	BOOL _viewReset;
	
	Invader *_invader1, *_invader2;
}
@end

@interface StateOutroProUpsell : StateMovie
{
	CGFloat _pad1x, _pad2x;
	CGPoint _powerupSpawn, _i1, _i2;
	BOOL _viewReset;
	UIAlertView *_appStoreAlert;
	Invader *_invader1, *_invader2;
}
@end

@interface StateOutroEp2 : StateMovie
{
	SpriteBody *_peon;
}
@end

@interface StateOutroOld : StateMovie
{
	SpriteBody *_peon;
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
