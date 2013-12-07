//
//  Paddle.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/27/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "Paddle.h"
#import "Ball.h"

@implementation Paddle
@synthesize player, state, stateRemaining, lastShot;

- (void) dealloc {
	[player release];
	[super dealloc];
}

- (void) moveTo: (int) x {
	self.position = ccp(x, self.position.y);
	b2dBody->SetTransform(b2Vec2((float) x / PTM_RATIO, self.position.y / PTM_RATIO), 0);
}

-(void) tick: (ccTime)dt {
	// sync CC2D w/ Box2D
	self.position = ccp(b2dBody->GetPosition().x * PTM_RATIO,
						b2dBody->GetPosition().y * PTM_RATIO);
}

-(CGRect) getRect {
	return CGRectMake(self.position.x - (self.contentSize.width),
					  self.position.y - (8*self.contentSize.height),
					  2*self.contentSize.width, 16*self.contentSize.height);
}

- (void) extend {
	
	[self runAction:[CCScaleTo actionWithDuration:.5 scaleX: PADDLE_SCALE scaleY: 1]];
	
	b2Fixture *fixture = b2dBody->GetFixtureList();
	
	b2PolygonShape *shape = (b2PolygonShape*) fixture->GetShape();
	
	if (_IPAD) {
		shape->SetAsBox(PADDLE_DEFAULT_WIDTH*PADDLE_SCALE/PTM_RATIO/2.0, 
						self.contentSize.height/PTM_RATIO/2.0);
	}
	else {
		shape->SetAsBox(PADDLE_DEFAULT_WIDTH_IPHONE*PADDLE_SCALE_IPHONE/PTM_RATIO/2.0, 
						self.contentSize.height/PTM_RATIO/2.0);
	}
	

}

- (void) shrink {
	state = SHRINK;
	stateRemaining = POWERUP_LENGTH;
	[self tintEffect:POW_ENSPRANCE];
	[self runAction:[CCScaleTo actionWithDuration:.5 scaleX: 1.0/PADDLE_SCALE scaleY: 1]];
	
	b2Fixture *fixture = b2dBody->GetFixtureList();
	
	b2PolygonShape *shape = (b2PolygonShape*) fixture->GetShape();
	
	if (_IPAD) {
		shape->SetAsBox(PADDLE_DEFAULT_WIDTH/PADDLE_SCALE/PTM_RATIO/2.0, 
						self.contentSize.height/PTM_RATIO/2.0);
	}
	else {
		shape->SetAsBox(PADDLE_DEFAULT_WIDTH_IPHONE/PADDLE_SCALE/PTM_RATIO/2.0, 
						self.contentSize.height/PTM_RATIO/2.0);
	}
	
}

- (void) reset {
	[self runAction:[CCScaleTo actionWithDuration:.5 scaleX: 1 scaleY: 1]];
	[self runAction:[CCTintTo actionWithDuration:.5 red:255 green:255 blue:255]];
	state = 0;
	stateRemaining = 0;
	lastShot = 0;
	
	b2Fixture *fixture = b2dBody->GetFixtureList();
	b2PolygonShape *shape = (b2PolygonShape*) fixture->GetShape();
	
	if (_IPAD) {
		shape->SetAsBox(PADDLE_DEFAULT_WIDTH/PTM_RATIO/2, 
						self.contentSize.height/PTM_RATIO/2);
	}
	else {
		shape->SetAsBox(PADDLE_DEFAULT_WIDTH_IPHONE/PTM_RATIO/2, 
						self.contentSize.height/PTM_RATIO/2);
	}
	
}

- (void) tintEffect: (int) e {	
	switch (e) {
		case POW_ENSPRANCE:
			[self runAction:[CCTintTo actionWithDuration:.5 red:0 green:220 blue:200]];
			break;
		case POW_LTWADDLE:
			[self runAction:[CCTintTo actionWithDuration:.5 red:255 green:0 blue:255]];
			break;
		case POW_CDRBOBBLE:
			[self runAction:[CCTintTo actionWithDuration:.5 red:0 green:250 blue:0]];
			break;
		case POW_STAT:
			[self runAction:[CCTintTo actionWithDuration:.5 red:255 green:0 blue:0]];
			break;
		case POW_SHLD:
			[self runAction:[CCTintTo actionWithDuration:.5 red:0 green:220 blue:200]];
			break;
		default:
			break;
	}
}

- (void) doHitFrom: (Ball *) ball withDamage: (int) d {
	
}

// - (void) dealloc {} // PV manages the deallocation of this spritebody


+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	// Create sprite and add it to the layer
	Paddle *paddle;
	
	if (_IPAD) {
		paddle = [Paddle spriteWithFile:@"Paddle.png"];
	}
	else {
		paddle = [Paddle spriteWithFile:@"Paddle-low.png"];
	}
	
	paddle.position = p;
	paddle.rotation = 180;
	paddle.world = w;
	
	// Create paddle body
	b2BodyDef paddleBodyDef;
	paddleBodyDef.type = USE_DYNAMIC_PADDLES ? b2_dynamicBody : b2_staticBody;
	paddleBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	paddleBodyDef.userData = paddle;
	paddleBodyDef.fixedRotation = true;
	b2Body *paddleBody = w->CreateBody(&paddleBodyDef);
	paddle.b2dBody = paddleBody;
	
	// Create paddle shape
	b2PolygonShape paddleShape;
	
	paddleShape.SetAsBox(paddle.contentSize.width/PTM_RATIO/2.0, 
							 paddle.contentSize.height/PTM_RATIO/2.0);
	
	// Create shape definition and add to body
	b2FixtureDef paddleShapeDef;
	paddleShapeDef.shape = &paddleShape;
	if (USE_DYNAMIC_PADDLES) {
		paddleShapeDef.density = 10.0f;
		paddleShapeDef.friction = 0.0f;
		paddleShapeDef.restitution = 0.0f;
	}
	paddleShapeDef.filter.categoryBits = COL_CAT_PADDLE;
	paddleShapeDef.filter.maskBits = COL_CAT_BALL | COL_CAT_DYNVADER;
	paddle.b2dBody->CreateFixture(&paddleShapeDef);
	
	return paddle;
}
@end