//
//  HelloWorldLayer.h
//  MultiAvoider
//
//  Created by Rahil Patel on 5/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

@interface GameLayer : CCLayer {
    int state;
    CCLabelTTF *label;
    CCMenu *menu;
    CCMenuItemLabel *startButton;
    float timer;
    CCRenderTexture* _rt;
    int totalPlayerCount;
    int levelState;
    int moveSpeed;
    NSArray* fileNames;
}

+(CCScene *) scene;

//@property (nonatomic, readwrite) b2World *world;

// private
- (void) checkCollisions;
- (BOOL) isCollisionBetweenSpriteA:(CCSprite*)spr1 spriteB:(CCSprite*)spr2 pixelPerfect:(BOOL)pp;
- (int) getPlayerCount;
- (void) addDoodle :(NSString*)fileName;
- (void) moveDoodles;
- (NSString*) getRandomImageString;

@end
