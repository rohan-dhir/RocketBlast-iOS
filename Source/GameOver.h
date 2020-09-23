//
//  GameOver.h
//  Rocket Blast!
//
//  Created by Rohan Dhir on 2015-09-19.
//
//

#import "CCNode.h"
#import "GameData.h"
#import "Advertisements.h"

@interface GameOver : CCNode
{
    CCLabelTTF  *hiScore, *score;
    CCButton *_back;
}
@end
