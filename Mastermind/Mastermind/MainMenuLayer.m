//
//  MainMenuLayer.m
//  Mastermind
//
//  Created by Der Olli on 16.03.13.
//
//

#import "MainMenuLayer.h"
#import "GameLayer.h"

@implementation MainMenuLayer


+(id) scene
{
    CCScene *scene = [CCScene node];
    
    MainMenuLayer *layer = [MainMenuLayer node];
    
    [scene addChild: layer];
    
    return scene;
}

-(id) init
{
    
    if( (self=[super init] )) {
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"Mastermind" fontName:@"Courier" fontSize:32];
        
        // ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        title.position = ccp(size.width /2 , size.height - 100);
        [self addChild: title];
        
        // new menu layer
        CCLayer *menuLayer = [[CCLayer alloc] init];
        [self addChild:menuLayer];
        
        CCMenuItemImage *startButton = [CCMenuItemImage
                                        itemFromNormalImage:@"startButton.png"
                                        selectedImage:@"startButtonSelected.png"
                                        target:self
                                        selector:@selector(startGame:)];
        
        CCMenu *menu = [CCMenu menuWithItems: startButton, nil];
        [menuLayer addChild: menu];
    }
    return self;
}

- (void) startGame: (id) sender
{
    [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
}

- (void) dealloc
{
    
    [super dealloc];
}
@end
