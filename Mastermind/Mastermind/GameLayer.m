//
//  GameLayer.m
//  Mastermind
//
//  Created by Der Olli on 16.03.13.
//
//

#import "GameLayer.h"
#import "MainMenuLayer.h"

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
        
        enterButton = [CCSprite spriteWithFile:@"enterButtonFrontCross.png"];
        enterButton.position = ccp(size.width-45,35);
        [self addChild:enterButton z:1];
        
        enterButtonLed = [CCSprite spriteWithFile:@"enterButtonRed.png"];
        enterButtonLed.scale = 0.60;
        enterButtonLed.position = ccp(size.width-45,35);
        [enterButtonLed setOpacity:0.5];
        id fadeIn = [CCFadeTo actionWithDuration:1 opacity:200];
        id fadeOut = [CCFadeTo actionWithDuration:1 opacity:100];
        CCSequence *pulseSequence = [CCSequence actionOne:fadeIn two:fadeOut];
        CCAction *repeat = [CCRepeatForever actionWithAction:pulseSequence];
        
        [enterButtonLed runAction:repeat];
        [self addChild:enterButtonLed z:0];
    
        
        
        
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
        currentFieldShape = [CCSprite spriteWithFile:@"currentField.png"];
        currentFieldShape.position = ccp((size.width /2)- 30, size.height);
        currentFieldShape.opacity = 1;
        [self addChild:currentFieldShape z:1];
        
        movableSprites = [[NSMutableArray alloc] init];
        
        [self createPins:1];
        [self createPins:2];
        [self createPins:3];
        [self createPins:4];
        
        currentField = 0;
        
        minYField = rowbackground[currentField].position.y + rowbackground[currentField].contentSize.height;
        maxYField = rowbackground[currentField].position.y;
        
        for (int i = 0; i < 4; i++) {
            rand = arc4random() % 4;
            searchedCode[i] = rand+1;
        }
        
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    }
    return self;
}

- (void) createPins:(NSInteger) color{
        //add pins
    switch (color) {
        case 1:
            pin = [CCSprite spriteWithFile:@"ball_blau.png"];
            pin.position = ccp(63, 35);
            pin.tag = 1;
            break;
        case 2:
            pin = [CCSprite spriteWithFile:@"ball_gelb.png"];
            pin.position = ccp(108, 35);
            pin.tag = 2;
            break;
        case 3:
            pin = [CCSprite spriteWithFile:@"ball_gruen.png"];
            pin.position = ccp(153, 35);
            pin.tag = 3;
            break;
        case 4:
            pin = [CCSprite spriteWithFile:@"ball_rot.png"];
            pin.position = ccp(198, 35);
            pin.tag = 4;
            break;    
    }
    [self addChild: pin];
    [movableSprites addObject:pin];
}

- (void) dealloc
{
    
    [super dealloc];
    [movableSprites release];
    movableSprites = nil;
}

- (void)selectSpriteForTouch:(CGPoint)touchLocation {
    CCSprite * newSprite = nil;
    if(CGRectContainsPoint(enterButton.boundingBox, touchLocation)) {
        NSInteger checkCode[4];
        if (codeField[0] != 0 && codeField[1] != 0 && codeField[2] != 0 && codeField[3] != 0) {
            for (int i = 0; i < 4; i++) {
                checkCode[i] = searchedCode[i];
            }
            NSInteger correctHoles = 0;
            NSInteger correctColors = 0;
            NSInteger wrongPins = 4;
            CGFloat currentFbLedX = feedbackled[currentField].position.x-13;
            CGFloat currentFbLedY = feedbackled[currentField].position.y+12;
            for(int i = 0; i < 4; i++) {
                if (codeField[i] == searchedCode[i]) {
                    switch (correctHoles) {
                        case 0:
                            currentFbLedX = feedbackled[currentField].position.x-13;
                            currentFbLedY = feedbackled[currentField].position.y+12;
                            break;
                        case 1:
                            currentFbLedX = currentFbLedX+26;
                            break;
                        case 2:
                            currentFbLedX = currentFbLedX-26;
                            currentFbLedY = currentFbLedY-24;
                            break;
                        case 3:
                            currentFbLedX = currentFbLedX+26;
                            break;
                    }
                    correctHoles++;
                    wrongPins--;
                    codeField[i] = 0;
                    checkCode[i] = 0;
                    feedbackPin = [CCSprite spriteWithFile:@"feedbackLedRed.png"];
                    feedbackPin.scale = 1.2;
                    feedbackPin.position = ccp(currentFbLedX, currentFbLedY);
                    [feedbackPin setOpacity:0];
                    id fade = [CCFadeIn actionWithDuration:0.3];
                    [feedbackPin runAction:fade];
                    [self addChild:feedbackPin];
                }
            }
            if(correctHoles < 4) {
                for(int i = 0; i < 4; i++) {
                    if(codeField[i] != 0) {
                        for(int j = 0; j < 4; j++) {
                            if(checkCode[j] != 0) {
                                if (codeField[i] == checkCode[j]) {
                                    switch (correctHoles+correctColors) {
                                        case 0:
                                            currentFbLedX = feedbackled[currentField].position.x-13;
                                            currentFbLedY = feedbackled[currentField].position.y+12;
                                            break;
                                        case 1:
                                            currentFbLedX = currentFbLedX+26;
                                            break;
                                        case 2:
                                            currentFbLedX = currentFbLedX-26;
                                            currentFbLedY = currentFbLedY-24;
                                            break;
                                        case 3:
                                            currentFbLedX = currentFbLedX+26;
                                            break;
                                    }
                                    correctColors++;
                                    wrongPins--;
                                    codeField[i] = 0;
                                    checkCode[j] = 0;
                                    feedbackPin = [CCSprite spriteWithFile:@"feedbackLedWhite.png"];
                                    feedbackPin.scale = 1.2;
                                    feedbackPin.position = ccp(currentFbLedX, currentFbLedY);
                                    [feedbackPin setOpacity:0];
                                    id fade = [CCFadeIn actionWithDuration:0.3];
                                    [feedbackPin runAction:fade];
                                    [self addChild:feedbackPin];
                                }
                            }
                        }
                    }
                } if (currentField == 7) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Verloren"
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"Hauptmenü", @"Neustart", nil];
                    [alert show];
                    [alert release];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gewonnen"
                                                                message:[NSString stringWithFormat:@"Versuche: %d",currentField+1]
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Hauptmenü", @"Neustart", nil];
                [alert show];
                [alert release];
            }
            
            if(correctHoles != 4) {
                correctHoles = 0;
                correctColors = 0;
                wrongPins = 4;
                for(int i = 0; i < 4; i++) {
                    codeField[i] = 0;
                }
                currentField++;
                minYField = rowbackground[currentField].position.y + rowbackground[currentField].contentSize.height;
                maxYField = rowbackground[currentField].position.y;
                
                id fadeIn = [CCFadeTo actionWithDuration:1 opacity:255];
                id fadeOut = [CCFadeTo actionWithDuration:1 opacity:100];
                CCSequence *pulseSequence = [CCSequence actionOne:fadeOut two:fadeIn];
                [rowbackground[currentField] runAction:pulseSequence];
            }
        }
    }
    for (CCSprite *sprite in movableSprites) {
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {
            oldPosY = 35;
            switch (sprite.tag) {
                case 1:
                    oldPosX = 65;
                    break;
                case 2:
                    oldPosX = 110;
                    break;
                case 3:
                    oldPosX = 155;
                    break;
                case 4:
                    oldPosX = 200;
                    break;
            }
            
            newSprite = sprite;
            break;
        }
    }
    
    newSprite.scale = 1.2;
    newSprite.zOrder = 1;
   if (newSprite != selSprite) {
       [selSprite stopAllActions];
       selSprite = newSprite;
       
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
    [self panForTranslation:translation];
    
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    selSprite.scale = 1.0;
    //CGSize size = [[CCDirector sharedDirector] winSize];
    
    //if(holeOne.position.x+holeOne.contentSize.width < 50) {
        //codeField[holeOne.tag-1] = 0;
        //[self removeChild:holeOne cleanup:YES];
    //}
    
    
    
    if(selSprite.position.y+selSprite.contentSize.height/2 > maxYField && selSprite.position.y+selSprite.contentSize.height/2 < minYField) {
        if(selSprite.position.x > 60 && selSprite.position.x < 84) {
            switch (selSprite.tag) {
                case 1:
                    holeOne = [CCSprite spriteWithFile:@"ball_blau.png"];
                    break;
                case 2:
                    holeOne = [CCSprite spriteWithFile:@"ball_gelb.png"];
                    break;
                case 3:
                    holeOne = [CCSprite spriteWithFile:@"ball_gruen.png"];
                    break;
                case 4:
                    holeOne = [CCSprite spriteWithFile:@"ball_rot.png"];
                    break;
            }
            
            holeOne.position = ccp(62.25, maxYField);
            holeOne.tag = selSprite.tag;
            holeOne.scale = 1.2;
            id scale = [CCScaleTo actionWithDuration:0.3 scale:1];
            [holeOne runAction:scale];
            [self addChild:holeOne];
            [movableSprites addObject:holeOne];
            codeField[0] = holeOne.tag;
            
        } else if(selSprite.position.x > 85 && selSprite.position.x < 129) {
            switch (selSprite.tag) {
                case 1:
                    holeTwo = [CCSprite spriteWithFile:@"ball_blau.png"];
                    break;
                case 2:
                    holeTwo = [CCSprite spriteWithFile:@"ball_gelb.png"];
                    break;
                case 3:
                    holeTwo = [CCSprite spriteWithFile:@"ball_gruen.png"];
                    break;
                case 4:
                    holeTwo = [CCSprite spriteWithFile:@"ball_rot.png"];
                    break;
            }
            
            holeTwo.position = ccp(107.25, maxYField);
            holeTwo.tag = selSprite.tag;
            holeTwo.scale = 1.2;
            id scale = [CCScaleTo actionWithDuration:0.3 scale:1];
            [holeTwo runAction:scale];
            [self addChild:holeTwo];
            [movableSprites addObject:holeTwo];
            codeField[1] = holeTwo.tag;
            
        } else if(selSprite.position.x > 130 && selSprite.position.x < 174) {
            switch (selSprite.tag) {
                case 1:
                    holeThree = [CCSprite spriteWithFile:@"ball_blau.png"];
                    break;
                case 2:
                    holeThree = [CCSprite spriteWithFile:@"ball_gelb.png"];
                    break;
                case 3:
                    holeThree = [CCSprite spriteWithFile:@"ball_gruen.png"];
                    break;
                case 4:
                    holeThree = [CCSprite spriteWithFile:@"ball_rot.png"];
                    break;
            }
            
            holeThree.position = ccp(152.25, maxYField);
            holeThree.tag = selSprite.tag;
            holeThree.scale = 1.2;
            id scale = [CCScaleTo actionWithDuration:0.3 scale:1];
            [holeThree runAction:scale];
            [self addChild:holeThree];
            [movableSprites addObject:holeThree];
            codeField[2] = holeThree.tag;
            
        } else if(selSprite.position.x > 175 && selSprite.position.x < 219) {
            switch (selSprite.tag) {
                case 1:
                    holeFour = [CCSprite spriteWithFile:@"ball_blau.png"];
                    break;
                case 2:
                    holeFour = [CCSprite spriteWithFile:@"ball_gelb.png"];
                    break;
                case 3:
                    holeFour = [CCSprite spriteWithFile:@"ball_gruen.png"];
                    break;
                case 4:
                    holeFour = [CCSprite spriteWithFile:@"ball_rot.png"];
                    break;
            }
            
            holeFour.position = ccp(197.25, maxYField);
            holeFour.tag = selSprite.tag;
            holeFour.scale = 1.2;
            id scale = [CCScaleTo actionWithDuration:0.3 scale:1];
            [holeFour runAction:scale];
            [self addChild:holeFour];
            [movableSprites addObject:holeFour];
            codeField[3] = holeFour.tag;
        } 
    }
    
    selSprite.position = ccp(oldPosX,oldPosY);
    
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    if (codeField[0] != 0 && codeField[1] != 0 && codeField[2] != 0 && codeField[3] != 0) {
        [self removeChild:enterButtonLed cleanup:YES];
        enterButtonLed = [CCSprite spriteWithFile:@"enterButtonGreen.png"];
    } else {
        [self removeChild:enterButtonLed cleanup:YES];
        enterButtonLed = [CCSprite spriteWithFile:@"enterButtonRed.png"];
    }
    enterButtonLed.scale = 0.60;
    enterButtonLed.position = ccp(size.width-45,35);
    [enterButtonLed setOpacity:0.5];
    id fadeIn = [CCFadeTo actionWithDuration:1 opacity:200];
    id fadeOut = [CCFadeTo actionWithDuration:1 opacity:100];
    CCSequence *pulseSequence = [CCSequence actionOne:fadeIn two:fadeOut];
    CCAction *repeat = [CCRepeatForever actionWithAction:pulseSequence];
    [enterButtonLed runAction:repeat];
    [self addChild:enterButtonLed z:0];
}

// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 0 index is "OK" button
    if(buttonIndex == 0)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[MainMenuLayer scene] withColor:ccWHITE]];
    }
    if(buttonIndex == 1)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameLayer scene] withColor:ccWHITE]];
    }
}



@end
