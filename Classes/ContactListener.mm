//
//  ContactListener.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/29/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "ContactListener.h"
#import "Ball.h"
#import "Invader.h"
#import "Rock.h"
#import "DynamicInvader.h"

ContactListener::ContactListener() : _contacts() {
}

ContactListener::~ContactListener() {
}

void ContactListener::BeginContact(b2Contact* contact) {
    // We need to copy out the data because the b2Contact passed in
    // is reused.
    Contact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<Contact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), myContact);
    if (pos == _contacts.end()) {
		_contacts.push_back(myContact);
    }
}

void ContactListener::EndContact(b2Contact* contact) {
    Contact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<Contact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), myContact);
    if (pos != _contacts.end()) {
        _contacts.erase(pos);
    }
}

// this is a great place to b2Contact::SetEnabled(false) on stuff we want to disable per-collision
// also good to determine point state & approach velocity (can only break through if the ball is going fast enough
void ContactListener::PreSolve(b2Contact* contact, 
							   const b2Manifold* oldManifold) {
	
	// Check for ball-invader contact when ball is "hot"
	// HACK: this probably would be better handled in PongVaderScene, 
	// but since we are disabling the contact for a specific case,
	// it needs to be done now
	
	SpriteBody<Shooter> *shooter = nil;
	Ball *ball = nil;
	
	NSObject *objA = (NSObject *) contact->GetFixtureA()->GetBody()->GetUserData();
	NSObject *objB = (NSObject *) contact->GetFixtureB()->GetBody()->GetUserData();
	
	if ([objA isKindOfClass:[Ball class]] && 
		[objB isKindOfClass:[SpriteBody class]] && 
		[objB conformsToProtocol: @protocol(Shooter)])
	{
		ball = (Ball *) objA;
		shooter = (SpriteBody<Shooter> *) objB;
	}

	else if ([objB isKindOfClass:[Ball class]] && 
			 [objA isKindOfClass:[SpriteBody class]] && 
			 [objA conformsToProtocol: @protocol(Shooter)])
	{
		ball = (Ball *) objB;
		shooter = (SpriteBody<Shooter> *) objA;
	}
	
	// the whole point of this routine:
	// disable the contact so the ball keeps going
	
	if (ball && shooter) {
		if ([ball isHot] && ![shooter isKindOfClass:[Rock class]] && ![shooter isBoss] && ![shooter isKindOfClass:[DynamicInvader class]]) {
			contact->SetEnabled(false);
		}
	}
}

void ContactListener::PostSolve(b2Contact* contact, 
								  const b2ContactImpulse* impulse) {
}

void ContactListener::clearContacts() {
	_contacts.erase(_contacts.begin(), _contacts.end());
}
