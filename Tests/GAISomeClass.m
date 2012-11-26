//
//  GAISomeClass.m
//  IndividExample
//
//  Created by Sergey Gavrilyuk on 12-11-21.
//
//

#import "GAISomeClass.h"
#import "GAIForwardTargetClass.h"

NSString* kGAISomeConst1 = @"kGAISomeConst1";


@implementation GAISomeClass
{
    GAIForwardTargetClass* _forwardTarget;
}
-(void) exisitngMethodReturningVoid
{
    
}

-(NSString*) exisitngMethodReturningConst1
{
    return kGAISomeConst1;
}

-(void) setForwardTarget:(GAIForwardTargetClass*) forwardTarget
{
    [_forwardTarget autorelease];
    _forwardTarget = [forwardTarget retain];
}

-(id)forwardingTargetForSelector:(SEL)aSelector
{
    return _forwardTarget;
}

@end
