//
//  AABBQueryCallback.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/4/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import <vector>

class AABBQueryCallback : public b2QueryCallback {
public:
	std::vector<b2Body*> contacts;
	
	AABBQueryCallback();
	~AABBQueryCallback();
	
	bool ReportFixture(b2Fixture *fixture);
};