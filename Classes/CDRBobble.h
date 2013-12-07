//
//  CDRBobble.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/1/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Invader.h"
#import "GameSettings.h"

@interface CDRBobble : Invader {

}

- (void) shoot;
- (void) doDestroyedScore: (Ball *) ball;
- (void) promote: (int) level;
- (void) removeArmor;
@end
