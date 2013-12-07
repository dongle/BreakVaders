//
//  MultiBrickScene.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/27/10.
//  Copyright Koduco Games 2010. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "SpriteBody.h"
#import "Ball.h"
#import "Paddle.h"
#import "TouchedSprite.h"
#import "ContactListener.h"

// MultiBrick Layer
@interface MultiBrick : CCLayer {
	GLESDebugDraw *m_debugDraw;
	
	// Box2D stuff
	b2World *world;
	b2Body *groundBody;
	
	// hold these fixtures to determine when ball has escaped
	b2Fixture *bottomFixture;
	b2Fixture *topFixture;
	
	ContactListener *_contactListener;
	
	// player stuff
	Paddle *paddle1;
	Paddle *paddle2;
	
	
	// keeping track of things
	NSMutableArray *touchedSprites;
	Ball *ball;
	
}

// returns a Scene that contains the MultiBrick as the only child
+(id) scene;

- (void) addBallWithCoords: (CGPoint) p;
- (void) addBrickWithCoords: (CGPoint) p;

- (Paddle*) addPaddleWithCoords: (CGPoint) p;
- (CCNode *) addPlanet: (CGPoint) p withSize: (CGSize) s;


@end
