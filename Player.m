//
//  Player.m
//  MultiAvoider
//
//  Created by Rahil Patel on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Player.h"

@implementation Player

#pragma mark - overridden functions
+ (id)init :(CGPoint)position {
    return [[[self alloc] init: position] autorelease];
}

- (id)init :(CGPoint)position {
	if (!(self = [super initWithFile:@"square.png"])) // todo: might need WithFile
		return nil;
    
    //[[self texture] setAliasTexParameters];
    
    //self.isTouchEnabled = YES;
    
    self.position = position;
    
    // random color circle
    //[self setTextureRect:CGRectMake(-10, -10, 20, 20)];
    [self setColor:ccc3(CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255)];
    
    //self.position = position;
    
    return self;
}

- (void)onEnter {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
    [super onEnter];
}

- (void)onExit {
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	//CGPoint location = [touch locationInView:[touch view]];
    //location = [[CCDirector sharedDirector] convertToGL:location];
	
    if (![self containsTouchLocation:touch])
        return NO;
    
	//if (![Library IsPointInPolygon:4 :vertices :location.x :location.y])
		//return NO;
    return YES;
}
 - (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
     // If it weren't for the TouchDispatcher, you would need to keep a reference
     // to the touch from touchBegan and check that the current touch is the same
     // as that one.
     // Actually, it would be even more complicated since in the Cocos dispatcher
     // you get NSSets instead of 1 UITouch, so you'd need to loop through the set
     // in each touchXXX method.
     
     CGPoint touchPoint = [touch locationInView:[touch view]];
     touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
     
     self.position = touchPoint;
 }

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

}
        
#pragma mark - private functions
- (BOOL)containsTouchLocation:(UITouch *)touch {
    return CGRectContainsPoint(self.textureRect, [self convertTouchToNodeSpaceAR:touch]);
}

@end
