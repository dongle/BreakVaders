//
//  MultiBrickScene.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/27/10.
//  Copyright Koduco Games 2010. All rights reserved.
//


// Import the interfaces
#import "MultiBrickScene.h"



// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagSpriteSheet = 1,
	kTagAnimation1 = 1,
};


// MultiBrick implementation
@implementation MultiBrick

+(id) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MultiBrick *layer = [MultiBrick node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// initialize your instance here
-(id) init {
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, 0.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
		
		// Debug Draw functions
		//m_debugDraw = new GLESDebugDraw( PTM_RATIO );
//		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		//flags += b2DebugDraw::e_shapeBit;
		//		flags += b2DebugDraw::e_jointBit;
		//		flags += b2DebugDraw::e_aabbBit;
		//		flags += b2DebugDraw::e_pairBit;
		//		flags += b2DebugDraw::e_centerOfMassBit;
		//m_debugDraw->SetFlags(flags);		
		
		
		// Define the ground body.
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner
		
		// Call the body factory which allocates memory for the ground body
		// from a pool and creates the ground box shape (also from a pool).
		// The body is also added to the world.
		groundBody = world->CreateBody(&groundBodyDef);
		
		// Define the ground box shape.
		b2PolygonShape groundBox;		
		
		// bottom
		groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
		bottomFixture = groundBody->CreateFixture(&groundBox,0);
		
		// top
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
		topFixture = groundBody->CreateFixture(&groundBox,0);
		
		// left
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// right
		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// make paddles
		paddle1 = [self addPaddleWithCoords:ccp(screenSize.width/2, 32)];
		paddle2 = [self addPaddleWithCoords:ccp(screenSize.width/2, 982)];
		
		// make starting ball
		[self addBallWithCoords:ccp(100,100)];
		
		// make some bricks
		for(int i = 0; i < 6; i++) {
			int xOffset = 120;
			[self addBrickWithCoords:ccp(20 + i * xOffset, 250)];
		}
		
		touchedSprites = [[NSMutableArray alloc] initWithCapacity:11];
		
		_contactListener = new ContactListener();
		world->SetContactListener(_contactListener);
				
		[self schedule: @selector(tick:)];
	}
	return self;
}

-(void) draw {
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	//world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
}


-(void) tick: (ccTime) dt {
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
	
	
	//Iterate over the bodies in the physics world & tick
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())	{
		if (b->GetUserData() != NULL) {
			SpriteBody *myActor = (SpriteBody*)b->GetUserData();
			[myActor tick: dt];
		}	
	}
	
	std::vector<Contact>::iterator pos;
	for(pos = _contactListener->_contacts.begin(); 
		pos != _contactListener->_contacts.end(); ++pos) {
		Contact contact = *pos;
		
		
		if ((contact.fixtureA == bottomFixture && contact.fixtureB->GetBody() == ball.b2dBody) ||
			(contact.fixtureA->GetBody() == ball.b2dBody && contact.fixtureB == bottomFixture) ||
			(contact.fixtureA == topFixture && contact.fixtureB->GetBody() == ball.b2dBody) ||
			(contact.fixtureA->GetBody() == ball.b2dBody && contact.fixtureB == topFixture) ) {
			NSLog(@"Ball got past paddles!");
		}
	}
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	for( UITouch *touch in touches ) {
		
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		NSLog(@"%.2f, %.2f", location.x, location.y);
		
		// check for collision with … paddle itself? define larger rect to test collision?
		if (CGRectContainsPoint([paddle1 getRect], location)) {
			
			[paddle1 moveTo: location.x];
			
			TouchedSprite *touched = [[TouchedSprite alloc] initWithSpriteBody:paddle1 touch:touch];
			[touchedSprites addObject: touched];
		}
		if (CGRectContainsPoint([paddle2 getRect], location)) {
			
			[paddle2 moveTo: location.x];
			
			TouchedSprite *touched = [[TouchedSprite alloc] initWithSpriteBody:paddle2 touch:touch];
			[touchedSprites addObject: touched];
		}
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	for (TouchedSprite *touched in touchedSprites) {
		for( UITouch *touch in touches ) {
			if ([touch isEqual: touched.touch]) {
				
				CGPoint location = [touch locationInView: [touch view]];
				
				location = [[CCDirector sharedDirector] convertToGL: location];
				
				// move paddle under finger
				[(Paddle*) touched.sb moveTo: location.x];
			}
			
		}
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSMutableArray *discardedItems = [NSMutableArray array];
	
	for (TouchedSprite *touched in touchedSprites) {
		for( UITouch *touch in touches ) {
			if ([touch isEqual: touched.touch]) {
				
				[discardedItems addObject: touched];
			}
			
		}
	}
	
	[touchedSprites removeObjectsInArray:discardedItems];
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {	
	
}

- (void) addBallWithCoords: (CGPoint) p {
	// Create sprite and add it to the layer
	//Ball *ball = [Ball spriteWithFile:@"Ball.png" rect:CGRectMake(0, 0, 2*BALL_RADIUS, 2*BALL_RADIUS)];
	ball = [Ball spriteWithFile:@"Ball.png" rect:CGRectMake(0, 0, 2*BALL_RADIUS, 2*BALL_RADIUS)];
	ball.position = p;
	[self addChild:ball]; 
	
	// Create ball body and add to ball SpriteBody
	b2BodyDef ballBodyDef;
	ballBodyDef.type = b2_dynamicBody;
	ballBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	ballBodyDef.userData = ball;
	b2Body *ballBody = world->CreateBody(&ballBodyDef);
	ball.b2dBody = ballBody;
	ballBody->SetFixedRotation(1);
	
	// Create circle shape
	b2CircleShape circle;
	circle.m_radius = (float) BALL_RADIUS/PTM_RATIO;
	
	// Create shape definition and add to body
	b2FixtureDef ballShapeDef;
	ballShapeDef.shape = &circle;
	ballShapeDef.density = 1.0f;
	ballShapeDef.friction = 0.0f; // We don't want the ball to have friction!
	ballShapeDef.restitution = 1.0f;
	b2Fixture *ballFixture = ballBody->CreateFixture(&ballShapeDef);
	
	// Give shape initial impulse...
	b2Vec2 force = b2Vec2(5, 5);
	ball.b2dBody->ApplyLinearImpulse(force, ballBodyDef.position);
	
	//return ball;
}

- (void) addBrickWithCoords: (CGPoint) p {
	// Create block and add it to the layer
    Brick *brick = [Brick spriteWithFile:@"Block.png"];

    brick.position = p;
    [self addChild:brick];
	
    // Create block body
    b2BodyDef brickBodyDef;
    brickBodyDef.type = b2_dynamicBody;
    brickBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    brickBodyDef.userData = brick;
    b2Body *brickBody = world->CreateBody(&brickBodyDef);
	brick.b2dBody = brickBody;
	
    // Create block shape
    b2PolygonShape brickShape;
    brickShape.SetAsBox(brick.contentSize.width/PTM_RATIO/2,
                        brick.contentSize.height/PTM_RATIO/2);
	
    // Create shape definition and add to body
    b2FixtureDef brickShapeDef;
    brickShapeDef.shape = &brickShape;
    brickShapeDef.density = 10.0;
    brickShapeDef.friction = 0.0;
    brickShapeDef.restitution = 0.1f;
    brickBody->CreateFixture(&brickShapeDef);
}

- (Paddle*) addPaddleWithCoords: (CGPoint) p {
	// Create sprite and add it to the layer
	Paddle *paddle = [Paddle spriteWithFile:@"Paddle.png"];
	paddle.position = p;
	[self addChild:paddle];
	
	// Create paddle body
	b2BodyDef paddleBodyDef;
	paddleBodyDef.type = b2_staticBody;
	paddleBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	paddleBodyDef.userData = paddle;
	b2Body *paddleBody = world->CreateBody(&paddleBodyDef);
	paddle.b2dBody = paddleBody;
	
	// Create paddle shape
	b2PolygonShape paddleShape;
	paddleShape.SetAsBox(paddle.contentSize.width/PTM_RATIO/2, 
						 paddle.contentSize.height/PTM_RATIO/2);
	
	// Create shape definition and add to body
	b2FixtureDef paddleShapeDef;
	paddleShapeDef.shape = &paddleShape;
//	paddleShapeDef.density = 10.0f;
//	paddleShapeDef.friction = 0.4f;
//	paddleShapeDef.restitution = 0.0f;
	b2Fixture *paddleFixture = paddle.b2dBody->CreateFixture(&paddleShapeDef);
	
	// Restrict paddle along the x axis
	//b2PrismaticJointDef jointDef;
	//	b2Vec2 worldAxis(1.0f, 0.0f);
	//	jointDef.collideConnected = true;
	//	jointDef.Initialize(paddle.b2dBody, groundBody, paddle.b2dBody->GetWorldCenter(), worldAxis);
	//	world->CreateJoint(&jointDef);
	
	return paddle;
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc {
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	
	delete _contactListener;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
