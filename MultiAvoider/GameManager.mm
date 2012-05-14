//  GameManager.m
//  cake
//
//  Created by Rahil Patel on 5/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.

#import "GameManager.h"

@implementation GameManager

static GameManager* _sharedGameManager = nil;

@synthesize score, highScore;

+(GameManager*)sharedGameManager 
{
    @synchronized([GameManager class])                             
    {
        if(!_sharedGameManager)                                    
            [[self alloc] init]; 
		
        return _sharedGameManager;                                
    }
    return nil; 
}

+(id)alloc 
{
    @synchronized ([GameManager class])                          
    {
        NSAssert(_sharedGameManager == nil, @"Attempted to allocated a second instance of the Game Manager singleton");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;                                
    }
    return nil;  
}

-(id)init {
	if(!(self=[super init]))
        return nil;
    
    // Game Manager initialized
    CCLOG(@"Game Manager Singleton, init");
    
    score = 0;
    highScore = 0;
    
    return self;
}

@end
