//
//  GAISomeClass.h
//  IndividExample
//
//  Created by Sergey Gavrilyuk on 12-11-21.
//
//

#import <Foundation/Foundation.h>

@class  GAIForwardTargetClass;
extern NSString* kGAISomeConst1;


@interface GAISomeClass : NSObject

-(void) exisitngMethodReturningVoid;
-(NSString*) exisitngMethodReturningConst1;

-(void) setForwardTarget:(GAIForwardTargetClass*) forwardTarget;

@end
