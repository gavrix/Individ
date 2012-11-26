//
//  NSObject+Individ.h
//  IndividExample
//
//  Created by Sergey Gavrilyuk on 12-11-13.
//
//

#import <Foundation/Foundation.h>



@interface NSObject (Individ)

-(void) setImplementationWithBlock:(id) block
                       forSelector:(SEL) selector
                 withTypesEncoding:(char*)typesEncoding;

@end
