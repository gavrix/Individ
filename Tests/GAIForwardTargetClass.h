//
//  GAIForwardTargetClass.h
//  IndividExample
//
//  Created by Sergey Gavrilyuk on 12-11-21.
//
//

#import <Foundation/Foundation.h>

@interface GAIForwardTargetClass : NSObject

-(id)initWithHookBlock:(void (^)(void)) block;

@end
