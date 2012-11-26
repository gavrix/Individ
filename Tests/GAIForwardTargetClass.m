//
//  GAIForwardTargetClass.m
//  IndividExample
//
//  Created by Sergey Gavrilyuk on 12-11-21.
//
//

#import "GAIForwardTargetClass.h"

@implementation GAIForwardTargetClass
{
    void (^_hookBlock)(void);
}

-(id)initWithHookBlock:(void (^)(void)) block
{
    self = [super init];
    if(self)
    {
        _hookBlock = Block_copy(block);
    }
    return self;
}

-(void)dealloc
{
    Block_release(_hookBlock);
    
    [super dealloc];
}


-(void) forwardedMethod
{
    if(_hookBlock)
        _hookBlock();
}


@end
