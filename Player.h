//
//  Player.h
//  MultiAvoider
//
//  Created by Rahil Patel on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface Player : CCSprite <CCTargetedTouchDelegate> {

}

+ (id)init :(CGPoint)position;
//- (id)init;

// private
- (BOOL)containsTouchLocation:(UITouch *)touch;

@end
