//
//  UFO.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DynamicInvader.h"
//#import "cocos2d.h"

@interface UFO : CCSprite {
	CCAnimation *enterAnim, *leaveAnim, *releaseAnim;
	DynamicInvader *mynuke;
}

@property (nonatomic, retain) CCAnimation* enterAnim;
@property (nonatomic, retain) CCAnimation* leaveAnim;
@property (nonatomic, retain) CCAnimation* releaseAnim;
@property (nonatomic, retain) DynamicInvader *mynuke;

- (id) initUFO;
- (void) flyTo: (CGPoint) pos with: (DynamicInvader *) nuke;

@end
