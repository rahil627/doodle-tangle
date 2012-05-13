//
//  HelloWorldLayer.m
//  MultiAvoider
//
//  Created by Rahil Patel on 5/12/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "GameLayer.h"
#import "Player.h"

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
        
    self.isTouchEnabled = YES;
    state = 0;
    timer = 0;
    levelState = 0;
    moveSpeed = 2;
    
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
    fileNames = [[NSArray alloc] initWithObjects:@"Curve.png", @"Trap.png", @"OneOpening.png", @"TwoOpenings.png", nil];
    
    [self schedule:@selector(update:)];
    
    return self;
}

- (void) update :(ccTime)dt {
    // tap to create a player
    // drag player to move
    // create enemies
    
    // ready state
    if (state == 0) {
        // if number of players >= 3, allow to start game
        if ([self getPlayerCount] >= 3)
            startButton.isEnabled = YES;
    }
    
    // game state
    if (state == 1) {
        timer -= dt;
        //CCLOG(@"timer: %f", timer);
        
        [self moveDoodles];
        [self checkCollisions];
        
        // if number of players < total, restart
        if ([self getPlayerCount] < /*totalPlayerCount*/ 3) {
            [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
        }
        
        if (timer <= 0) {
            // level stuff
            switch (levelState) {
                case 0:
                    // do stuff
                    label.string = @"avoid the doodles"; //[NSString stringWithFormat:@"%@\r%@\r%@", @"avoid the doodles", @"work together", @"good luck"];
                    timer = 1; // todo: 5
                    break;
                case 1:
                    //label.visible = NO;
                    [self removeChild:label cleanup:YES];
                    timer = 1; // todo: 5
                    break;
                    /*
                case 2:
                    [self addDoodle:@"Blob.png"];
                    timer = 20;
                    break;
                case 3:
                    [self addDoodle:@"TwoOpenings.png"];
                    timer = 20;
                    break;
                     */
                default:
                    [self addDoodle:[self getRandomImageString]];
                    timer = 20; //todo: spawn speed
                    // randomly go through all doodles
                    // increase speed over time
                    // add timer
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
    timer = 1; // todo: 5
    
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
                            [self removeChild:child cleanup:YES]; // todo: add this back in!
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

- (NSString*) getRandomImageString {
    NSUInteger randomIndex = arc4random() % [fileNames count];
    return [fileNames objectAtIndex:randomIndex];
}


#pragma mark - overridden functions
- (void) dealloc {
    [super dealloc];
}

// touches

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { // Began/Moved/Ended/Cancelled
	/*
     //iteration method
     for ( UITouch* touch in touches ) {
     CGPoint location = [touch locationInView:[touch view]];
     location = [[CCDirector sharedDirector] convertToGL:location];
     
     //code
	 */
	/*
     CGRect spriteRect = [sprite boundingBox];
     
     UITouch *touch = [touches anyObject];
     
     CGPoint location = [touch previousLocationInView:[touch view]];
     location = [[CCDirector sharedDirector] convertToGL:location];
     
     if (CGRectContainsPoint(spriteRect, location))
     {
     id move = [CCMoveBy actionWithDuration:0.05 position:10];
     [sprite runAction:[CCRepeatForever actionWithAction:move]];
     }
     */
	
	/*
	 //index-array method
	 
	 NSArray *touchArray = [touches allObjects];
	 
	 UITouch *touchOne = [touchArray objectAtIndex:0];
	 CGPoint locationOne = [touchOne locationInView:[touchOne location]];
	 
	 //CODE
	 
	 if ( [touchArray count] > 1 ) {
	 UITouch *touchTwo = [touchArray objectAtIndex:1];
	 //Location, CODE
	 }
	 
	 //And so forth...
	 */
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // iteration method
    for (UITouch* touch in touches) {
        CGPoint touchPoint = [touch locationInView:[touch view]];
        touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
        
        Player* player = [Player init :touchPoint];
        [self addChild:player];
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
