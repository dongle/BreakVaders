//
//  Utils.m
//  Toe2Toe
//
//  Created by Cole Krumbholz on 10/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "GameSettings.h"

@implementation CCLabelTTF (GetRect) 

-(CGRect) getRect {
	return CGRectMake(self.position.x - ((self.anchorPoint.x*self.contentSize.width*self.scale) ),
					  self.position.y - ((self.anchorPoint.y*self.contentSize.height*self.scale)),
					  self.contentSize.width*self.scale ,
					  self.contentSize.height*self.scale );
}

@end

@implementation Utils

+ (BOOL)writeApplicationData:(NSData *)data toFile:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    if (!docDir) {
        NSLog(@"Doc directory not found!");
        return NO;
    }
    NSString *appFile = [docDir stringByAppendingPathComponent:fileName];
    return ([data writeToFile:appFile atomically:YES]);
}

+ (NSData *)applicationDataFromFile:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *appFile = [docDir stringByAppendingPathComponent:fileName];
    NSData *myData = [[[NSData alloc] initWithContentsOfFile:appFile] autorelease];
    return myData;
}

+ (BOOL)writeApplicationPlist:(id)plist toFile:(NSString *)fileName {
    NSString *error;
    NSData *pData = [NSPropertyListSerialization dataFromPropertyList:plist format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
    if (!pData) {
        NSLog(@"%@", error);
        return NO;
    }
    return ([Utils writeApplicationData:pData toFile:(NSString *)fileName]);
}

+ (id)applicationPlistFromFile:(NSString *)fileName {
    NSData *retData;
    NSString *error;
    id retPlist;
    NSPropertyListFormat format;
	
    retData = [Utils applicationDataFromFile:fileName];
    if (!retData) {
        NSLog(@"Data file not returned.");
        return nil;
    }
    retPlist = [NSPropertyListSerialization propertyListFromData:retData  mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
    if (!retPlist){
        NSLog(@"Plist not returned, error: %@", error);
    }
    return retPlist;
}

+ (BOOL) dictionary: (NSDictionary *) dictionary hasKey: (NSString *) key
{
	NSEnumerator *enumerator = [dictionary keyEnumerator];
	NSString * nextkey;

	while ((nextkey = [enumerator nextObject])) {
		if ([key isEqualToString: nextkey]) return TRUE;
	}
	return FALSE;
}

+ (void) checkPrefsWithKnownKey: (NSString *) knownKey 
{
	NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:knownKey];
	if (testValue == nil)
	{
		// no default values have been set, create them here based on what's in our Settings bundle info
		//
		NSString *pathStr = [[NSBundle mainBundle] bundlePath];
		NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
		
		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
		NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
		
		// since no default values have been set (i.e. no preferences file created), create it here		
		NSMutableDictionary *appDefaults = [NSMutableDictionary dictionary];
		
		NSDictionary *prefItem;
		for (prefItem in prefSpecifierArray)
		{
			NSString *keyValueStr = [prefItem objectForKey:@"Key"];
			id defaultValue = [prefItem objectForKey:@"DefaultValue"];
			[appDefaults setObject: defaultValue forKey: keyValueStr];
		}
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
}


/*
 * adapted from http://www.cocos2d-iphone.org/forum/topic/207
 *
 * Returns a CCNode with the string. It splits on new lines and returns the length of the final node.
 * The length parameter sets the max length in characters, and is will return the final length of the node.
 * 
 * 
 * call it this way:
 *
 *   int length;
 *   CCNode *credits = [self multilineNodeWithText:creditsText length:&length];
 * 
 */
+ (CCNode *)multilineNodeWithText:(NSString *)text fontSize:(CGFloat)fnt color:(ccColor3B) col rowlength:(int)length rowheight:(int) height {
	NSInteger lineChars = 0;
	BOOL isSpace = NO, isNewLine = NO;
	NSInteger index = 0;
	NSInteger numLines = 0;
	NSInteger maxWidth = 0;
	
	NSMutableString *line = [NSMutableString stringWithCapacity:length];
	
	CCNode *container = [CCNode node];
	while (index <= [text length]) {

		if (index == [text length]) {
			CCLabelTTF *tip = [CCLabelTTF labelWithString:[NSString stringWithString:line]
																		   fontName:@"pvaders.ttf" fontSize:fnt];
			[container addChild:tip];
			if ([tip getRect].size.width > maxWidth) maxWidth = [tip getRect].size.width;
			numLines++;
			break;
		}
		
		NSString *tmp = [text substringWithRange:NSMakeRange(index, 1)];
		[line appendString:tmp];
		
		if ([tmp isEqual:@" "])
			isSpace = YES;
		else
			isSpace = NO;
		if ([tmp isEqual:@"\n"])
			isNewLine = YES;
		else
			isNewLine = NO;
		
		if ((lineChars >= length && isSpace) || isNewLine) {
			CCLabelTTF *tip = [CCLabelTTF labelWithString:[NSString stringWithString:line]
																		  fontName:@"pvaders.ttf" fontSize:fnt];
			[container addChild:tip];
			if ([tip getRect].size.width > maxWidth) maxWidth = [tip getRect].size.width;
			
			lineChars = -1;
			[line setString:@""];
			numLines++;
		}
		lineChars++;
		index++;
	}

	for (int i=0; i<[[container children] count]; i++) {
		CCLabelTTF *line = [[container children] objectAtIndex:i];
		line.color = col;
		CGSize sz = [line getRect].size;
		line.position = ccp((sz.width - maxWidth)/2.0, -i*height + height*(numLines-1)/2.0);
	}

	return container;
}

+ (CGFloat) distanceFrom: (CGPoint) first to: (CGPoint) second {
	CGFloat deltaX = second.x - first.x;
	CGFloat deltaY = second.y - first.y;
	return sqrt(deltaX*deltaX + deltaY*deltaY );
}

+ (CGFloat) angleFrom:(CGPoint) first to: (CGPoint) second {
	CGFloat height = second.y - first.y;
	CGFloat width = first.x - second.x;
	CGFloat rads = atan(height/width);
	return rads;
	//degs = degrees(atan((top - bottom)/(right - left)))
}

+ (CGFloat) angleFrom:(CGPoint) line1Start and: (CGPoint) line1End to: (CGPoint) line2Start and: (CGPoint) line2End {	
	CGFloat a = line1End.x - line1Start.x;
	CGFloat b = line1End.y - line1Start.y;
	CGFloat c = line2End.x - line2Start.x;
	CGFloat d = line2End.y - line2Start.y;
	
	CGFloat rads = acos(((a*c) + (b*d)) / ((sqrt(a*a + b*b)) * (sqrt(c*c + d*d))));
	
	return rads;
}

@end
