//
//  GameLayer.h
//  Mastermind
//
//  Created by Der Olli on 16.03.13.
//
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@interface GameLayer : CCLayer {
    
    NSInteger searchedCode[4];
    NSInteger codeField[4];
    NSInteger selPin;
    
    CCSprite * background;
    CCSprite * selSprite;
    
    CCSprite * blueball;
    CCSprite * yellowball;
    CCSprite * greenball;
    CCSprite * redball;
    
    CCSprite *holeOne;
    CCSprite *holeTwo;
    CCSprite *holeThree;
    CCSprite *holeFour;
    
    CGFloat minYField;
    CGFloat maxYField;
    
    CGFloat Field;
    
    NSInteger currentField;
    
    CGFloat oldPosX;
    CGFloat oldPosY;
    NSMutableArray * movableSprites;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(id) scene;


@end
