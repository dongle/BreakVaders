//
//  NamedParticleSystem.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/5/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCQuadParticleSystem.h"

@interface NamedParticleSystem : CCQuadParticleSystem {
	NSString *pFile;
}

@property (nonatomic, retain) NSString *pFile;

+ (id) particleWithFile: (NSString *) f;
- (id) initWithFile: (NSString *) f;
@end
