//
//  NamedParticleSystem.m
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/5/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "NamedParticleSystem.h"


@implementation NamedParticleSystem

@synthesize pFile = _pFile;

- (id) initWithFile: (NSString *) f {
	if ((self = [super initWithFile:f])) {
		self.pFile = [NSString stringWithString:f];
	}
	return self;
}

+ (id) particleWithFile: (NSString *) f {
	return [[[NamedParticleSystem alloc] initWithFile:f] autorelease];
}

-(void) dealloc {
	[_pFile release];
	[super dealloc];
}
@end
