//
//  Utils.h
//  Toe2Toe
//
//  Created by Cole Krumbholz on 10/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

#define RADIANS( degrees ) ( degrees * M_PI / 180 )
#define CGDotProduct(v1, v2) ((v1.x*v2.x) + (v1.y*v2.y))
#define CGNormalize(v1) ccp(v1.x/sqrt(v1.x*v1.x+v1.y*v1.y), v1.y/sqrt(v1.x*v1.x+v1.y*v1.y))
#define CGPointAdd(v1, v2) (CGPointMake(v1.x+v2.x, v1.y+v2.y))
#define CGPointSub(v1, v2) (CGPointMake(v1.x-v2.x, v1.y-v2.y))

@interface CCLabelBMFont (GetRect)
- (CGRect) getRect;
@end

@interface Utils : NSObject 

+ (BOOL)writeApplicationPlist:(id)plist toFile:(NSString *)fileName;
+ (id)applicationPlistFromFile:(NSString *)fileName;
+ (BOOL) dictionary: (NSDictionary *) dictionary hasKey: (NSString *) key;
+ (void) checkPrefsWithKnownKey: (NSString *) knownKey;
+ (CCNode *)multilineNodeWithText:(NSString *)text font:(NSString *)fnt color:(ccColor3B) col rowlength:(int)length rowheight:(int) height;
+ (CGFloat) distanceFrom: (CGPoint) first to: (CGPoint) second;
+ (CGFloat) angleFrom:(CGPoint) first to: (CGPoint) second;
+ (CGFloat) angleFrom:(CGPoint) line1Start and: (CGPoint) line1End to: (CGPoint) line2Start and: (CGPoint) line2End;
	
@end
