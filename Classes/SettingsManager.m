//
//  SettingsManager.m
//  Comet3DGame
//
//  Created by Cole Krumbholz on 6/27/10.
//  Copyright 2010 Koduco. All rights reserved.
//

#import "SettingsManager.h"

#define kSOSTR 0
#define kSONUM 1
#define kSOOPT 2

@implementation SettingsManager

- (id) init {
	if ((self = [super init])) {
		_settings = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc {
	[_settings release];
	[super dealloc];
}

- (void) addStringFor: (NSString *) key init: (NSString *) value {
	SettingsObject *so = [[[SettingsObject alloc]init]autorelease];
	so.sval = value;
	so.type = kSOSTR;
	[_settings setObject:so forKey: key];
}

- (void) addIntFor: (NSString *) key init: (int) value {
	SettingsObject *so = [[[SettingsObject alloc]init]autorelease];
	so.nval = [NSNumber numberWithInt:value];
	so.type = kSONUM;
	[_settings setObject:so forKey: key];
}

- (void) addFloatFor: (NSString *) key init: (float) value {
	SettingsObject *so = [[[SettingsObject alloc]init]autorelease];
	so.nval = [NSNumber numberWithFloat:value];
	so.type = kSONUM;
	[_settings setObject:so forKey: key];
}

- (void) addOptionsFor: (NSString *) key with: (NSArray *) options init: (int) value {
	SettingsObject *so = [[[SettingsObject alloc]init]autorelease];
	so.options = options;
	so.curopt = value;
	so.type = kSOOPT;
	[_settings setObject:so forKey: key];
}

- (void) remove: (NSString *) key {
	[_settings removeObjectForKey:key];
}


- (BOOL) exists: (NSString *) key {
	return [_settings objectForKey:key] != nil;
}

- (NSString *) get: (NSString *) key {
	SettingsObject *so = [_settings objectForKey:key];
	NSString *ret = nil;
	switch (so.type) {
		case kSOSTR: ret = so.sval; break;
		case kSONUM: ret = [NSString stringWithFormat:@"%@", so.nval]; break;
		case kSOOPT: ret = [so.options objectAtIndex:so.curopt]; break;
	}
	return ret;
}

- (int) getInt: (NSString *) key {
	SettingsObject *so = [_settings objectForKey:key];
	int ret = 0;
	switch (so.type) {
		case kSOSTR: ret = 0; break;
		case kSONUM: ret = [so.nval intValue]; break;
		case kSOOPT: ret = so.curopt; break;
	}
	return ret;
}

- (float) getFloat: (NSString *) key {
	SettingsObject *so = [_settings objectForKey:key];
	float ret = 0;
	switch (so.type) {
		case kSOSTR: ret = 0; break;
		case kSONUM: ret = [so.nval floatValue]; break;
		case kSOOPT: ret = so.curopt; break;
	}
	return ret;
}

- (void) set: (NSString *) key to: (NSString *) value {
	SettingsObject *so = [_settings objectForKey:key];
	switch (so.type) {
		case kSOSTR: so.sval = value; break;
		case kSONUM: so.nval = [NSNumber numberWithFloat:[value floatValue]]; break;
		case kSOOPT: 
			so.curopt = -1;
			for (int i=0; i<[so.options count]; i++) {
				if ([(NSString *)[so.options objectAtIndex:i] isEqualToString:value]) {
					so.curopt = i;
					break;
				}
			}
			if (so.curopt < 0) so.curopt = [value intValue];
			break;
	}
	[_settings setObject:so forKey:key];
}

- (void) set: (NSString *) key toInt: (int) value
{
	SettingsObject *so = [_settings objectForKey:key];
	switch (so.type) {
		case kSOSTR: so.sval = [NSString stringWithFormat:@"%d", value]; break;
		case kSONUM: so.nval = [NSNumber numberWithInt: value]; break;
		case kSOOPT: so.curopt = value; break;
	}
	[_settings setObject:so forKey:key];
}

- (void) set: (NSString *) key toFloat: (float) value
{
	SettingsObject *so = [_settings objectForKey:key];
	switch (so.type) {
		case kSOSTR: so.sval = [NSString stringWithFormat:@"%.5f", value]; break;
		case kSONUM: so.nval = [NSNumber numberWithFloat: value]; break;
		case kSOOPT: so.curopt = (int) value; break;
	}
	[_settings setObject:so forKey:key];
}

- (void) inc: (NSString *) key 
{
	SettingsObject *so = [_settings objectForKey:key];
	switch (so.type) {
		case kSONUM: so.nval = [NSNumber numberWithFloat: [so.nval floatValue] + 1.0]; break;
		case kSOOPT: 
			so.curopt++;
			if (so.curopt >= [so.options count]) so.curopt = 0;
			break;
	}
	[_settings setObject:so forKey:key];
}

- (void) dec: (NSString *) key 
{
	SettingsObject *so = [_settings objectForKey:key];
	switch (so.type) {
		case kSONUM: so.nval = [NSNumber numberWithFloat: [so.nval floatValue] - 1.0]; break;
		case kSOOPT: 
			so.curopt--;
			if (so.curopt < 0) so.curopt = [so.options count]-1;
			break;
	}
	[_settings setObject:so forKey:key];
}

- (void) inc: (NSString *) key by: (float) num
{
	SettingsObject *so = [_settings objectForKey:key];
	switch (so.type) {
		case kSONUM: so.nval = [NSNumber numberWithFloat: [so.nval floatValue] + num]; break;
		case kSOOPT: 
			so.curopt += num;
			if (so.curopt >= [so.options count]) so.curopt = 0;
			if (so.curopt < 0) so.curopt = [so.options count]-1;
			break;
	}
	[_settings setObject:so forKey:key];
}

- (void) dec: (NSString *) key by: (float) num
{
	SettingsObject *so = [_settings objectForKey:key];
	switch (so.type) {
		case kSONUM: so.nval = [NSNumber numberWithFloat: [so.nval floatValue] - num]; break;
		case kSOOPT: 
			so.curopt -= num;
			if (so.curopt >= [so.options count]) so.curopt = 0;
			if (so.curopt < 0) so.curopt = [so.options count]-1;
			break;
	}
	[_settings setObject:so forKey:key];
}

- (void) setMetaFor: (NSString *) key to: (NSDictionary *) value
{
	SettingsObject *so = [_settings objectForKey:key];
	so.meta = value;
	[_settings setObject:so forKey:key];
}

- (id) get: (NSString *) key meta: (NSString *) metakey
{
	SettingsObject *so = [_settings objectForKey:key];
	return [so.meta objectForKey:metakey];
}

- (id) get: (NSString *) key metaLookup: (NSString *) format
{
	SettingsObject *so = [_settings objectForKey:key];
	id metaobj = [so.meta objectForKey:[NSString stringWithFormat:format, [self get: key]]];
	if (!metaobj && (so.type == kSOOPT)) metaobj = [so.meta objectForKey:[NSString stringWithFormat:format, [NSNumber numberWithInt:so.curopt]]];
	if (!metaobj) metaobj = [so.meta objectForKey:[NSString stringWithFormat:format, @"*"]];
	return metaobj;
}

- (NSString *) get: (NSString *) key metaReplace: (NSString *) metakey
{
	SettingsObject *so = [_settings objectForKey:key];
	return [NSString stringWithFormat:[so.meta valueForKey:metakey], [self get: key]];
}

- (NSString *) get: (NSString *) key metaLookupAndReplace: (NSString *) format
{
	return [NSString stringWithFormat:[self get: key metaLookup: format], [self get: key]];
}

- (void) addSettingsFromPlistDict: (NSDictionary *) pdict 
{
	for (NSString *k in [pdict keyEnumerator]) {
		SettingsObject *so = [[[SettingsObject alloc] initWithPlistArray:[pdict objectForKey:k]] autorelease];
		[_settings setObject:so forKey:k];
	}	
}

- (NSDictionary *) toPlistDict {
	NSMutableDictionary *retd = [NSMutableDictionary dictionary];
	for (NSString *k in [_settings keyEnumerator]) {
		NSArray *obj = [[_settings objectForKey:k] toPlistArray];
		[retd setObject: obj forKey:k];
	}
	return retd;
}

@end

@implementation SettingsObject 
@synthesize sval = _sval;
@synthesize nval = _nval;
@synthesize options = _options;
@synthesize curopt = _curopt;
@synthesize type = _type;
@synthesize meta = _meta;

- (id) init {
	if ((self = [super init])) {
		_sval = [[NSString string] retain];
		_nval = [[NSNumber numberWithInt:0] retain];
		_options = [[NSArray array] retain];
		_curopt = 0;
		_type = 0;
		_meta = [[NSDictionary dictionary] retain];
	}
	return self;
}

- (id) initWithPlistArray: (NSArray *) parray {
	if ((self = [super init])) {
		self.sval = [parray objectAtIndex:0];
		self.nval = [parray objectAtIndex:1];
		self.options = [parray objectAtIndex:2];
		self.curopt = [(NSNumber *)[parray objectAtIndex:3] intValue];
		self.type = [(NSNumber *) [parray objectAtIndex:4] intValue];
		self.meta = [parray objectAtIndex:5];
	}
	return self;
}

- (void) dealloc {
	[_sval release];
	[_nval release];
	[_options release];
	[_meta release];
	[super dealloc];
}

- (NSArray *) toPlistArray {
	NSMutableArray *ret = [NSMutableArray array];
	[ret addObject:_sval];
	[ret addObject:_nval];
	[ret addObject:_options];
	[ret addObject:[NSNumber numberWithInt:_curopt]];
	[ret addObject:[NSNumber numberWithInt:_type]];
	[ret addObject:_meta];
	return ret;
}

@end
