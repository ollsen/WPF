//
//  GameLayer.m
//  Mastermind
//
//  Created by Der Olli on 16.03.13.
//
//

#import "GameLayer.h"

@implementation GameLayer

+(id) scene
{
    CCScene *scene = [CCScene node];
    
    GameLayer *layer = [GameLayer node];
    
    [scene addChild: layer];
    
    return scene;
}

-(id) init
{
    
    if( (self=[super init] )) {
        
        CCLabelTTF *message = [CCLabelTTF labelWithString:@"Greetings" fontName:@"Courier" fontSize:32];
        
        // ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        message.position = ccp(size.width /2 , size.height /2);
        [self addChild: message];
        
        //[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(size.width /2, size.height /2);
        [self addChild: background];
        
    
        
        CCSprite *rowbackground[8];
        CCSprite *feedbackled[8];
        
        int j = 50;
        for (int i = 0; i < 8; i++) {
            rowbackground[i] = [CCSprite spriteWithFile:@"presentRowBackround.png"];
            rowbackground[i].scale = 0.24;
            rowbackground[i].position = ccp((size.width /2)- 30, size.height-j);
            feedbackled[i] = [CCSprite spriteWithFile:@"feedbackLedOff.png"];
            feedbackled[i].scale = 1.25;
            feedbackled[i].position = ccp(size.width - 50, size.height-j);
            j += 48;
            [self addChild: rowbackground[i]];
            [self addChild: feedbackled[i]];
        }
        
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        movableSprites = [[NSMutableArray alloc] init];
        
        [self createPins:1];
        [self createPins:2];
        [self createPins:3];
        [self createPins:4];
        
        currentField = 0;
        
        minYField = rowbackground[currentField].position.y + rowbackground[currentField].contentSize.height;
        maxYField = rowbackground[currentField].position.y;
        
        NSLog(@"%f", minYField);
        NSLog(@"%f", maxYField);
        
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    return self;
}

- (void) createPins:(NSInteger) color{
        //add pins
    switch (color) {
        case 1:
            blueball = [CCSprite spriteWithFile:@"ball_blau.png"];
            blueball.position = ccp(65, 35);
            blueball.tag = 1;
            [self addChild: blueball];
            [movableSprites addObject:blueball];
            break;
        case 2:
            yellowball = [CCSprite spriteWithFile:@"ball_gelb.png"];
            yellowball.position = ccp(110, 35);
            y
            [self addChild: yellowball];
            [movableSprites addObject:yellowball];
            break;
        case 3:
            greenball = [CCSprite spriteWithFile:@"ball_gruen.png"];
            greenball.position = ccp(155, 35);
            [self addChild: greenball];
            [movableSprites addObject:greenball];
            break;
        case 4:
            redball = [CCSprite spriteWithFile:@"ball_rot.png"];
            redball.position = ccp(200, 35);
            [self addChild: redball];
            [movableSprites addObject:redball];
            break;    
    }
    
}

- (void) dealloc
{
    
    [super dealloc];
    [movableSprites release];
    movableSprites = nil;
}

- (void)selectSpriteForTouch:(CGPoint)touchLocation {
    CCSprite * newSprite = nil;
    for (CCSprite *sprite in movableSprites) {
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
            if(CGRectContainsPoint(sprite.boundingBox, blueball.position)) {
                NSLog(@"blue");
                selPin = 1;
            }
            if(CGRectContainsPoint(sprite.boundingBox, yellowball.position)) {
                NSLog(@"yellow");
                selPin = 2;
            }
            if(CGRectContainsPoint(sprite.boundingBox, greenball.position)) {
                NSLog(@"green");
                selPin = 3;
            }
            if(CGRectContainsPoint(sprite.boundingBox, redball.position)) {
                NSLog(@"red");
                selPin = 4;
            }
            if(CGRectContainsPoint(sprite.boundingBox, holeOne.position)) {
                NSLog(@"selSprite");
            }
                
            NSLog(@"%f", sprite.position.x);
            newSprite = sprite;
            break;
        }
    }
   if (newSprite != selSprite) {
       [selSprite stopAllActions];
       selSprite = newSprite;
       selSprite.scale = 1.2;
       oldPosX = selSprite.position.x;
       oldPosY = selSprite.position.y;
    }
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self selectSpriteForTouch:touchLocation];
    return TRUE;
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    //CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x,0);
    retval.y = self.position.y;
    return retval;
}

- (void)panForTranslation:(CGPoint)translation {
    if (selSprite) {
        CGPoint newPos = ccpAdd(selSprite.position, translation);
        selSprite.position = newPos;
    } else {
        CGPoint newPos = ccpAdd(self.position, translation);
        self.position = [self boundLayerPos:newPos];
    }
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    NSLog(@"%f", selSprite.position.x+selSprite.contentSize.width);
    [self panForTranslation:translation];
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    selSprite.scale = 1.0;
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    if(holeOne.position.x+holeFour.contentSize.width < 50) {
        holeOne = nil;
    }
    
    if(selSprite.position.y+selSprite.contentSize.height/2 > maxYField && selSprite.position.y+selSprite.contentSize.height/2 < minYField) {
        if(selSprite.position.x > 60 && selSprite.position.x < 84) {
            NSLog(@"%f", selSprite.position.x);
            holeOne = selSprite;
            holeOne.position = ccp(62.25, size.height-50);
            if(selSprite.position.y != oldPosY) {
                NSLog(@"worked %f",oldPosY);
                [self createPins:selPin];
            }
            
        } else if(selSprite.position.x > 85 && selSprite.position.x < 129) {
            NSLog(@"%f", selSprite.position.x);
            holeTwo = selSprite;
            holeTwo.position = ccp(107.25, size.height-50);
            if(selSprite.position.y != oldPosY) {
                NSLog(@"worked %f",oldPosY);
                [self createPins:selPin];
            }
        } else if(selSprite.position.x > 130 && selSprite.position.x < 174) {
            NSLog(@"%f", selSprite.position.x);
            holeThree = selSprite;
            holeThree.position = ccp(152.25, size.height-50);
            if(selSprite.position.y != oldPosY) {
                NSLog(@"worked %f",oldPosY);
                [self createPins:selPin];
            }
        } else if(selSprite.position.x > 175 && selSprite.position.x < 219) {
            NSLog(@"%f", selSprite.position.x);
            holeFour = selSprite;
            holeFour.position = ccp(197.25, size.height-50);
            if(selSprite.position.y != oldPosY) {
                NSLog(@"worked %f",oldPosY);
                [self createPins:selPin];
            }
        } else {
            selSprite.position = ccp(oldPosX,oldPosY);
        }
    } else {
        selSprite.position = ccp(oldPosX,oldPosY);
    }
    NSLog(@"%f", blueball.position.y);
    selSprite = Nil;
    
    
}





@end
