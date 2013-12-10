//
//  ADMBrainSeg.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 9/22/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Invader.h"
#import "GameSettings.h"
#import "ADMBrain.h"

@interface ADMBrainSeg : Invader {
@public 
	ADMBrain *_head;
}
@end

@interface ADMBrainSegSmall : ADMBrainSeg {
}
@end
