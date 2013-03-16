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
        
        CCSprite *background;
        
        background = [CCSprite spriteWithFile:@"game_background.png"];
        background.position = ccp(size.width /2, size.height /2);
        [self addChild: background];
        
    }
    return self;
}

- (void) dealloc
{
    
    [super dealloc];
}
@end
