//
//  ContactListener.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/29/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "Box2D.h"
#import <vector>
#import <algorithm>

struct Contact {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    bool operator==(const Contact& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};

class ContactListener : public b2ContactListener {
	
public:
    std::vector<Contact>_contacts;
	
    ContactListener();
    ~ContactListener();
	
    void BeginContact(b2Contact* contact);
    void EndContact(b2Contact* contact);
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);    
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
	
	void clearContacts();
	
};