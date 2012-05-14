//
//  HelloWorldLayer.m
//  MultiAvoider
//
//  Created by Rahil Patel on 5/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "GameLayer.h"
#import "Player.h"
#import "GameManager.h"

@implementation GameLayer

+ (CCScene *) scene {
	CCScene *scene = [CCScene node];
	GameLayer *layer = [GameLayer node];
	[scene addChild: layer];
	
	return scene;
}

#pragma mark - main functions
- (id) init {
	if(!(self=[super init]))
        return nil;
    
    [CCDirector sharedDirector].displayFPS = NO; //todo: = debugValue
    self.isTouchEnabled = YES;
    state = 0;
    timer = 0;
    levelState = 0;
    moveSpeed = 2;
    spawnTime = 15;
    allTimer = 0;
    
    CGSize s = [CCDirector sharedDirector].winSize;
    
    label = [CCLabelTTF labelWithString:@"tap anywhere once to join" fontName:@"Marker Felt" fontSize:32];
    label.position = ccp(s.width / 2 , s.height - label.contentSize.height / 2);
    [self addChild: label z:0];
    
	// add start button
	CCLabelTTF *startLabel = [CCLabelTTF labelWithString:@"tap to start" fontName:@"Marker Felt" fontSize:32];
    startButton = [CCMenuItemLabel itemWithLabel:startLabel target:self selector:@selector(beginGame)];
    startButton.position = ccp(s.width / 2, s.height - label.contentSize.height * 2);
    startButton.isEnabled = NO;
    menu = [CCMenu menuWithItems:startButton, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    // create render texture and make it visible for testing purposes
    _rt = [CCRenderTexture renderTextureWithWidth:s.width height:s.height];
    _rt.position = ccp(s.width*0.5f,s.height*0.1f);
    [self addChild:_rt];
    _rt.visible = NO; // turn on to test
    
    // create file name string array
    levelFileNames1 = [[NSArray alloc] initWithObjects:@"Blob.png", @"TwoOpenings.png", @"TwoOpenings2.png", nil];
    levelFileNames2 = [[NSArray alloc] initWithObjects:@"OneOpening.png", @"OneOpening2.png", @"TwoToOne.png", nil];
    levelFileNames3 = [[NSArray alloc] initWithObjects:@"Curve.png", @"Curve2.png", @"Trap.png", @"SafeSpaces.png",
                       @"Backward.png", @"Staircase.png", @"Converge.png", nil];
    
    // scores
    NSString* scoreString = [NSString stringWithFormat:@"last score: %i", [[GameManager sharedGameManager] score]];
    scoreLabel = [CCLabelTTF labelWithString:scoreString fontName:@"Marker Felt" fontSize:32];
    scoreLabel.position = ccp(s.width / 2 , (scoreLabel.contentSize.height / 2) * 4);
    [self addChild: scoreLabel z:0];
    
    NSString* highScoreString = [NSString stringWithFormat:@"high score: %i", [[GameManager sharedGameManager] score]];
    highScoreLabel = [CCLabelTTF labelWithString:highScoreString fontName:@"Marker Felt" fontSize:32];
    highScoreLabel.position = ccp(s.width / 2 , highScoreLabel.contentSize.height / 2);
    [self addChild: highScoreLabel z:0];
    
    // clear button
	CCLabelTTF *clearLabel = [CCLabelTTF labelWithString:@"clear" fontName:@"Marker Felt" fontSize:32];
    CCMenuItemLabel* clearButton = [CCMenuItemLabel itemWithLabel:clearLabel target:self selector:@selector(clearPlayers)];
    clearButton.position = ccp(s.width - 100, clearLabel.contentSize.height / 2);
    //clearButton.isEnabled = YES;
    menu2 = [CCMenu menuWithItems:clearButton, nil];
    menu2.position = CGPointZero;
    [self addChild:menu2];
        
    [self schedule:@selector(update:)];
    
    return self;
}

- (void) update :(ccTime)dt {
    // tap to create a player
    // drag player to move
    // create enemies
    
    // TESTING Xcode source control
    
    // ready state
    if (state == 0) {
        // if number of players >= 3, allow to start game
        startButton.isEnabled = ([self getPlayerCount] >= 1);
    }
    
    // game state
    if (state == 1) {
        timer -= dt;
        allTimer += dt;
        //CCLOG(@"timer: %f", timer);
        
        [self moveDoodles];
        [self checkCollisions];
        
        // update score
        int allTimerInt = allTimer;
        currentScoreLabel.string = [NSString stringWithFormat:@"score: %i", allTimerInt];
        
        // if number of players < total, restart
        if ([self getPlayerCount] < /*totalPlayerCount*/ 1) {
            
            // set high score
            [GameManager sharedGameManager].score = allTimer;
            if ([GameManager sharedGameManager].highScore < [GameManager sharedGameManager].score) {
                [GameManager sharedGameManager].highScore = [GameManager sharedGameManager].score;
            }
            
            // restart
            [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
        }
        
        if (timer <= 0) {
            // level stuff
            switch (levelState) {
                case 0:
                    // do stuff
                    label.string = @"avoid the doodles"; //[NSString stringWithFormat:@"%@\r%@\r%@", @"avoid the doodles", @"work together", @"good luck"];
                    timer += 5;
                    break;
                case 1:
                    //label.visible = NO;
                    [self removeChild:label cleanup:YES];
                    timer += 1;
                    break;
                case 2:
                    //[self addDoodle:@"Trap.png"]; // test doodle here
                    [self addDoodle:[self getRandomIndex:levelFileNames1]];
                    timer += spawnTime;
                    break;
                case 3:
                    [self addDoodle:[self getRandomIndex:levelFileNames2]];
                    timer += spawnTime;
                    break;
                default:
                    [self addDoodle:[self getRandomIndex:levelFileNames3]];
                    timer = spawnTime;
                    break;
            }
            levelState++;
        }
    }
}

- (void) addDoodle :(NSString*)fileName {
    CGSize s = [CCDirector sharedDirector].winSize;
    
    CCSprite* doodle = [CCSprite spriteWithFile:fileName];
    doodle.position = ccp(s.width / 2, s.height + doodle.contentSize.height / 2);
    [self addChild:doodle z:0 tag:1];
}

- (void) moveDoodles {
    for(id child in self.children) {
        if([child isKindOfClass:[CCSprite class]]) {
            CCSprite* sprite = child;
            if (sprite.tag == 1)
                sprite.position = ccp(sprite.position.x, sprite.position.y - moveSpeed);
        }
    }
}

#pragma mark - private functions
- (void) beginGame {
    // clean up
    label.string = @"drag your sprite to move";
    //label.visible = NO;
    //[self removeChild:label cleanup:YES];
    [self removeChild:menu cleanup:YES];
    self.isTouchEnabled = false;
    totalPlayerCount = [self getPlayerCount];
    timer = 5;
    
    [self removeChild:scoreLabel cleanup:YES];
    [self removeChild:highScoreLabel cleanup:YES];
    [self removeChild:menu2 cleanup:YES];
    
    
    CGSize s = [CCDirector sharedDirector].winSize;
    
    NSString* currentScoreString = [NSString stringWithFormat:@"high score: %i", [[GameManager sharedGameManager] score]];
    currentScoreLabel = [CCLabelTTF labelWithString:currentScoreString fontName:@"Marker Felt" fontSize:32];
    currentScoreLabel.position = ccp(s.width / 2 , currentScoreLabel.contentSize.height / 2);
    [self addChild: currentScoreLabel z:0];
    
    state = 1;
}

- (void) checkCollisions {
    for(id child in self.children) {
        if([child isKindOfClass:[Player class]]) {
            
            
            for(id child2 in self.children) {
                if([child2 isKindOfClass:[CCSprite class]]) {
                    CCSprite* sprite = child2;
                    if (sprite.tag == 1) {
                        if ([self isCollisionBetweenSpriteA:child spriteB:sprite pixelPerfect:YES]) {
                            [self removeChild:child cleanup:YES];
                            //CCLOG(@"collision detected");
                        }
                    }
                }
            }
            
            //Player* player = child;
            //if ([self isCollisionBetweenSpriteA:child spriteB:lava pixelPerfect:YES])
            //    [self removeChild:child cleanup:YES];
            
        }
    }
}

- (int) getPlayerCount {
    int count = 0;
    for(id child in self.children) {
        if([child isKindOfClass:[Player class]]) {
            count++;
        }
    }
    return count;
}

- (NSString*) getRandomIndex :(NSArray *)fileNameArray {
    NSUInteger randomIndex = arc4random() % [fileNameArray count];
    return [fileNameArray objectAtIndex:randomIndex];
}

- (void) clearPlayers {
    for(id child in self.children) {
        if([child isKindOfClass:[Player class]]) {
            [self removeChild:child cleanup:YES];
        }
    }
}


#pragma mark - overridden functions
- (void) dealloc {
    [super dealloc];
}

// touches

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { // Began/Moved/Ended/Cancelled

}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // iteration method
    for (UITouch* touch in touches) {
        CGPoint touchPoint = [touch locationInView:[touch view]];
        touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
        
        if ([self getPlayerCount] < 11) {
            Player* player = [Player init :touchPoint];
            [self addChild:player];
        }
    }
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

# pragma mark - library functions
// http://www.cocos2d-iphone.org/forum/topic/18522
// _rt is a CCRenderTexture, created a variable for it in the header file
- (BOOL) isCollisionBetweenSpriteA:(CCSprite*)spr1 spriteB:(CCSprite*)spr2 pixelPerfect:(BOOL)pp
{
    BOOL isCollision = NO; 
    CGRect intersection = CGRectIntersection([spr1 boundingBox], [spr2 boundingBox]);
    
    // Look for simple bounding box collision
    if (!CGRectIsEmpty(intersection))
    {
        // If we're not checking for pixel perfect collisions, return true
        if (!pp) {return YES;}
        
        // Get intersection info
        unsigned int x = intersection.origin.x;
        unsigned int y = intersection.origin.y;
        unsigned int w = intersection.size.width;
        unsigned int h = intersection.size.height;
        unsigned int numPixels = w * h;
        
        //NSLog(@"\nintersection = (%u,%u,%u,%u), area = %u",x,y,w,h,numPixels);
        
        // Draw into the RenderTexture
        [_rt beginWithClear:0 g:0 b:0 a:0];
        
        // Render both sprites: first one in RED and second one in GREEN
        glColorMask(1, 0, 0, 1);
        [spr1 visit];
        glColorMask(0, 1, 0, 1);
        [spr2 visit];
        glColorMask(1, 1, 1, 1);
        
        // Get color values of intersection area
        ccColor4B *buffer = malloc( sizeof(ccColor4B) * numPixels );
        glReadPixels(x, y, w, h, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
        
        /******* All this is for testing purposes *********/
        
        // Draw the first sprite bounding box
        CGRect r1 = [spr1 boundingBox];
        glColor4f(1, 0, 0, 1);
        glLineWidth(0.5f);
        ccDrawLine(ccp(r1.origin.x,r1.origin.y), ccp(r1.origin.x+r1.size.width,r1.origin.y));
        ccDrawLine(ccp(r1.origin.x,r1.origin.y), ccp(r1.origin.x,r1.origin.y+r1.size.height));
        ccDrawLine(ccp(r1.origin.x+r1.size.width,r1.origin.y), ccp(r1.origin.x+r1.size.width,r1.origin.y+r1.size.height));
        ccDrawLine(ccp(r1.origin.x,r1.origin.y+r1.size.height), ccp(r1.origin.x+r1.size.width,r1.origin.y+r1.size.height));
        
        // Draw the second sprite bounding box
        CGRect r2 = [spr2 boundingBox];
        glColor4f(0, 1, 0, 1);
        glLineWidth(0.5f);
        ccDrawLine(ccp(r2.origin.x,r2.origin.y), ccp(r2.origin.x+r2.size.width,r2.origin.y));
        ccDrawLine(ccp(r2.origin.x,r2.origin.y), ccp(r2.origin.x,r2.origin.y+r2.size.height));
        ccDrawLine(ccp(r2.origin.x+r2.size.width,r2.origin.y), ccp(r2.origin.x+r2.size.width,r2.origin.y+r2.size.height));
        ccDrawLine(ccp(r2.origin.x,r2.origin.y+r2.size.height), ccp(r2.origin.x+r2.size.width,r2.origin.y+r2.size.height));
        
        // Draw the intersection rectangle in BLUE (testing purposes)
        glColor4f(0, 0, 1, 1);
        glLineWidth(0.5f);
        ccDrawLine(ccp(x,y), ccp(x+w,y));
        ccDrawLine(ccp(x,y), ccp(x,y+h));
        ccDrawLine(ccp(x+w,y), ccp(x+w,y+h));
        ccDrawLine(ccp(x,y+h), ccp(x+w,y+h));
        
        /**************************************************/
        
        [_rt end];
        
        // Read buffer
        unsigned int step = 1;
        for(unsigned int i=0; i<numPixels; i+=step)
        {
            ccColor4B color = buffer[i];
            
            if (color.r > 0 && color.g > 0)
            {
                isCollision = YES;
                break;
            }
        }
        
        // Free buffer memory
        free(buffer);
    }
    
    return isCollision;
}


@end
