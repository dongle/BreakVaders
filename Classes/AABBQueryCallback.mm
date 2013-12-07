//
//  AABBQueryCallback.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/4/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "AABBQueryCallback.h"

AABBQueryCallback::AABBQueryCallback() : contacts() {

}

AABBQueryCallback::~AABBQueryCallback() {

}

bool AABBQueryCallback::ReportFixture(b2Fixture *fixture) {
	b2Body* body = fixture->GetBody();
	
	contacts.push_back(body);
	
	// Return true to continue the query.
	return true;
}