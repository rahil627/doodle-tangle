//  GameManager.h
//  cake
//
//  Created by Rahil Patel on 5/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class ButtonGroup;

@interface GameManager : NSObject {
    
}

@property (nonatomic, readwrite) int score;
@property (nonatomic, readwrite) int highScore;

+ (GameManager*)sharedGameManager;

@end
