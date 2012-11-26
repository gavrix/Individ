//
//  IndividTests.m
//  IndividTests
//
//  Created by Sergey Gavrilyuk on 12-11-21.
//
//

#import "IndividTests.h"
#import "GAISomeClass.h"
#import "NSObject+Individ.h"
#import "GAIForwardTargetClass.h"



NSString* kGAISomeConst2 = @"kGAISomeConst2";
NSString* kGAISomeConst3 = @"kGAISomeConst3";

typedef struct
{
    unsigned char f1;
} StructChar;

typedef struct
{
    unsigned char f1;
} StructInt;

typedef struct
{
    unsigned char f1;
    unsigned char f2;
} StructCharChar;

typedef struct
{
    unsigned char f1;
    unsigned int f2;
} StructCharInt;

typedef struct
{
    unsigned int f1;
    unsigned char f2;
} StructIntChar;

typedef struct
{
    unsigned int f1;
    unsigned int f2;
} StructIntInt;



@interface GAISomeClass(RetStructs)
-(int) newMethodReturningInt;
-(StructChar) newMethodReturningSTChar;
-(StructInt) newMethodReturningSTInt;
-(StructCharChar) newMethodReturningSTCharChar;
-(StructCharInt) newMethodReturningSTCharInt;
-(StructIntChar) newMethodReturningSTIntChar;
-(StructIntInt) newMethodReturningSTIntInt;
@end

@implementation IndividTests
{

}
- (void)setUp
{
    [super setUp];
    

}

- (void)tearDown
{
    [super tearDown];
}

- (void)testRespondsToSelector
{
    NSObject* object1 = [[GAISomeClass alloc] init];
    NSObject* object2 = [[GAISomeClass alloc] init];
    
    [object1 setImplementationWithBlock: ^()
     {
         
     }
                            forSelector:@selector(nonExistingMethod)
                      withTypesEncoding:"v@:"];
    STAssertTrue([object1 respondsToSelector:@selector(nonExistingMethod)],
             @"respondsToSelector failed for object to which new method added");
    
    STAssertFalse([object2 respondsToSelector:@selector(nonExistingMethod)],
             @"respondsToSelector failed for object other than one new method added to");
    

    [object2 setImplementationWithBlock: ^()
     {
         
     }
                            forSelector:@selector(exisitngMethodReturningVoid)
                      withTypesEncoding:"v@:"];
    
    STAssertTrue([object1 respondsToSelector:@selector(exisitngMethodReturningVoid)],
             @"respondsToSelector failed for object existing method added to");
    
    STAssertTrue([object2 respondsToSelector:@selector(exisitngMethodReturningVoid)],
             @"respondsToSelector failed for object other than one exiting method added to");
    
    [object1 release];
    [object2 release];
    
}

-(void) testCorrectImplementation
{
    GAISomeClass* object1 = [[GAISomeClass alloc] init];
    GAISomeClass* object2 = [[GAISomeClass alloc] init];
    GAISomeClass* object3 = [[GAISomeClass alloc] init];
    
 
    [object1 setImplementationWithBlock:(NSString* (^)(void)) ^
     {
         return kGAISomeConst2;
     }
                            forSelector:@selector(exisitngMethodReturningConst1)
                      withTypesEncoding:"@@:"];
    
    [object2 setImplementationWithBlock:(NSString* (^)(void)) ^
     {
         return kGAISomeConst3;
     }
                            forSelector:@selector(exisitngMethodReturningConst1)
                      withTypesEncoding:"@@:"];
    
    
    [object1 exisitngMethodReturningConst1];
    
    
    
    
    
    STAssertTrue([[object1 exisitngMethodReturningConst1] isEqualToString:kGAISomeConst2],
                 @"overriden existing method failed to return overriden value");

    STAssertTrue([[object2 exisitngMethodReturningConst1] isEqualToString:kGAISomeConst3],
                 @"overriden existing method failed to return overriden value");

    STAssertTrue([[object3 exisitngMethodReturningConst1] isEqualToString:kGAISomeConst1],
             @"existing method failed to return original expected value");
    
    [object1 release];
    [object2 release];
    [object3 release];
}

-(void) testParametersPassing
{
    GAISomeClass* object1 = [[GAISomeClass alloc] init];
    NSInteger intParam = 12345;
    CGRect rectParam = CGRectMake(1, 2, 3, 4);
    unsigned char charParam1 = 123;
    unsigned char charParam2 = 124;
    unsigned char charParam3 = 125;
    
    
    const char* cc = @encode(CGRect);
    
    [object1 setImplementationWithBlock:^(id self, NSInteger i,CGRect rect)
     {
         STAssertEquals(intParam, i,
                        @"First integer param in overriden method is invalid");
         STAssertTrue(CGRectEqualToRect(rectParam, rect),
                      @"Second CGRect param in overriden method is invalid");
         
     }
                            forSelector:@selector(testInt:rect:)
                      withTypesEncoding:"v@:i{?={?=ff}{?=ff}}"];
    
    [object1 setImplementationWithBlock:^(id self, CGRect rect, NSInteger i)
     {
         STAssertEquals(intParam, i,
                        @"First CGRect param in overriden method is invalid");
         STAssertTrue(CGRectEqualToRect(rectParam, rect),
                      @"Second int param in overriden method is invalid");
         
     }
                            forSelector:@selector(testRect:int:)
                      withTypesEncoding:"v@:{?={?=ff}{?=ff}}i"];

    [object1 setImplementationWithBlock:^(id self, unsigned char char1, unsigned char char2, unsigned char char3)
     {
         STAssertEquals(charParam1, char1,
                        @"First char param in overriden method is invalid");

         STAssertEquals(charParam2, char2,
                        @"Second char param in overriden method is invalid");

         STAssertEquals(charParam3, char3,
                        @"Third char param in overriden method is invalid");
         
     }
                            forSelector:@selector(testChar1:char2:char3:)
                      withTypesEncoding:"v@:CCC"];


    
    [object1 testInt:intParam rect:rectParam];
    [object1 testRect:rectParam int:intParam];
    [object1 testChar1:charParam1 char2:charParam2 char3:charParam3];
    [object1 release];
}



-(void) testReturnParams
{
    GAISomeClass* object1 = [[GAISomeClass alloc] init];
    int kRetunedParam = 123;
    
    StructChar kSTChar; kSTChar.f1 = 113;
    StructCharChar kSTCharChar; kSTCharChar.f1 = 114;kSTCharChar.f1 = 115;
    StructCharInt kSTCharInt; kSTCharInt.f1 = 116; kSTCharInt.f2 = 117;
    StructIntChar kSTIntChar; kSTIntChar.f1 = 118; kSTIntChar.f2 = 119;
    StructIntInt kSTIntInt; kSTIntInt.f1 = 120; kSTIntInt.f2 = 121;
    
    
//    const char* ss = @encode(StructCharInt);
    
    [object1 setImplementationWithBlock:(int (^)(void)) ^
     {
         return kRetunedParam;
     }
                            forSelector:@selector(newMethodReturningInt)
                      withTypesEncoding:"i@:"];
    
    [object1 setImplementationWithBlock:(StructChar (^)(void)) ^
     {
         return kSTChar;
     }
                            forSelector:@selector(newMethodReturningSTChar)
                      withTypesEncoding:"{?=C}@:"];
    
    [object1 setImplementationWithBlock:(StructCharChar (^)(void)) ^
     {
         return kSTCharChar;
     }
                            forSelector:@selector(newMethodReturningSTCharChar)
                      withTypesEncoding:"{?=CC}@:"];

    [object1 setImplementationWithBlock:(StructCharInt (^)(void)) ^
     {
         return kSTCharInt;
     }
                            forSelector:@selector(newMethodReturningSTCharInt)
                      withTypesEncoding:"{?=CI}@:"];
    
    [object1 setImplementationWithBlock:(StructIntChar (^)(void)) ^
     {
         return kSTIntChar;
     }
                            forSelector:@selector(newMethodReturningSTIntChar)
                      withTypesEncoding:"{?=IC}@:"];
    
    [object1 setImplementationWithBlock:(StructIntInt (^)(void)) ^
     {
         return kSTIntInt;
     }
                            forSelector:@selector(newMethodReturningSTIntInt)
                      withTypesEncoding:"{?=II}@:"];
    
    
    STAssertTrue((int)[object1 newMethodReturningInt] == kRetunedParam,
                 @"Returning int param failed");

    STAssertTrue([object1 newMethodReturningSTChar].f1 == kSTChar.f1,
                 @"Returning {char} param failed");
    
//    [object1 newMethodReturningSTChar];
//    [object1 newMethodReturningSTInt];
//     StructCharChar c = [object1 newMethodReturningSTCharChar];
//    c.f1+=2;
    
    STAssertTrue([object1 newMethodReturningSTCharChar].f1 == kSTCharChar.f1 &&
                 [object1 newMethodReturningSTCharChar].f2 == kSTCharChar.f2,
                 @"Returning {char char} param failed");
//
//    STAssertTrue([object1 newMethodReturningSTCharInt].f1 == kSTCharInt.f1 &&
//                 [object1 newMethodReturningSTCharInt].f2 == kSTCharInt.f2,
//                 @"Returning {char int} param failed");
//
//    STAssertTrue([object1 newMethodReturningSTIntChar].f1 == kSTIntChar.f1 &&
//                 [object1 newMethodReturningSTIntChar].f2 == kSTIntChar.f2,
//                 @"Returning {int char} param failed");
//
//    STAssertTrue([object1 newMethodReturningSTIntInt].f1 == kSTIntInt.f1 &&
//                 [object1 newMethodReturningSTIntInt].f2 == kSTIntInt.f2,
//                 @"Returning {int char} param failed");

}


-(void) testAssertionWhileIsertingMethod
{

    NSObject* object1 = [[GAISomeClass alloc] init];
    STAssertThrows(
                   [object1 setImplementationWithBlock: ^()
                    {
                        
                    }
                                           forSelector:@selector(exisitngMethodReturningVoid)
                                     withTypesEncoding:"v@::"]

                   ,
                   @"Failed to throw exception because of invalid types encoding");

}

-(void) testForwardTarget
{
    __block BOOL forwardedHookWasCalled = NO;
    __block BOOL notForwardedHookWasCalled = NO;
    __block BOOL notForwardedHookWasCalled2 = NO;
    NSObject* object1 = [[GAISomeClass alloc] init];
    GAISomeClass* object2 = [[GAISomeClass alloc] init];
    GAIForwardTargetClass* targetObject = [[GAIForwardTargetClass alloc] initWithHookBlock:^
                                           {
                                               forwardedHookWasCalled = YES;
                                           }];
    [object1 setImplementationWithBlock:^
     {
         notForwardedHookWasCalled = YES;
     }
                           forSelector:@selector(forwardedMethod)
                     withTypesEncoding:"v@:"];
    

    GAISomeClass* object3 = [[GAISomeClass alloc] init];
    [object3 setImplementationWithBlock:^
     {
         notForwardedHookWasCalled2 = YES;
     }
                            forSelector:@selector(forwardedMethod)
                      withTypesEncoding:"v@:"];
    
    
    [object2 setForwardTarget:targetObject];
    
    [object2 forwardedMethod];
    [object1 forwardedMethod];
    [object3 forwardedMethod];

    STAssertTrue(forwardedHookWasCalled,
                 @"method was not forwared to desired target");
    STAssertTrue(notForwardedHookWasCalled,
                 @"overriden method was not called");
    STAssertTrue(notForwardedHookWasCalled2,
                 @"overriden method was not called");
    
    [object1 release];
    [object2 release];
    [object3 release];
    [targetObject release];

}
@end
