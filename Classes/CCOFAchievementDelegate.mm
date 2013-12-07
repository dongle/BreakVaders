//
//  CCOFAchievementDelegate.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/8/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "CCOFAchievementDelegate.h"


@implementation CCOFAchievementDelegate

- (void)didSubmitDeferredAchievements {
	
}


- (void)didFailSubmittingDeferredAchievements {
	
}


- (void)didUnlockOFAchievement:(OFAchievement*)achievement {
	printf("unlocked achievement\n");
}


- (void)didFailUnlockOFAchievement:(OFAchievement*)achievement {
	printf("failed to unlock achievement\n");
}


- (void)didGetIcon:(UIImage*)image OFAchievement:(OFAchievement*)achievement {
	
}


- (void)didFailGetIconOFAchievement:(OFAchievement*)achievement {
	
}
@end
