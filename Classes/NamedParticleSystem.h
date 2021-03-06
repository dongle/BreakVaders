//
//  NamedParticleSystem.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/5/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCParticleSystemQuad.h"

@interface NamedParticleSystem : CCParticleSystemQuad {
	NSString *_pFile;
}

@property (nonatomic, retain) NSString *pFile;

+ (id) particleWithFile: (NSString *) f;
- (id) initWithFile: (NSString *) f;
@end
