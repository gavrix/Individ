//
//  NSObject+Individ.m
//  IndividExample
//
//  Created by Sergey Gavrilyuk on 12-11-13.
//
//

#import "NSObject+Individ.h"
#import <objc/runtime.h>

@interface NSObject (IndividInternal)
-(BOOL) respondsToSelectorOld:(SEL) selector;
@end


const char kGAIndividDispatchTableKey;
const char kGAIndividDefaultImpKey;

const NSString* kGAIndividImplementationKey = @"kGAIndividImplementationKey";
const NSString* kGAIndividSuperImplementationKey = @"kGAIndividSuperImplementationKey";
const NSString* kGAIndividTypeEncodingKey = @"kGAIndividTypeEncodingKey";
//const NSString* kGAIndividDefaultImpKey = @"kGAIndividDefaultImpKey";

extern id individMessageDispatch(id self, SEL cmd,...);
extern id individMessageDispatchStret(id self, SEL cmd,...);

//const NSString* kGAIndividSelectorKey = @"kGAIndividSelectorKey";

//id objc_msgSendStret(id self, SEL cmd,...);

id individForwardTarget(id self, SEL cmd)
{
    return [self forwardingTargetForSelector:cmd];
}

void individMessageDispatchDoesnotRecognize(id self, SEL cmd,...)
{
    NSMethodSignature* methodSignature = [self methodSignatureForSelector:cmd];
    if(methodSignature)
    {
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setSelector:cmd];
        va_list ap;
        va_start(ap, cmd);
        
        int offset = 0;
        for(int i=2;i<[methodSignature numberOfArguments];i++)
        {
            NSUInteger sizep = 0;
            NSUInteger alingp = 0;
            NSGetSizeAndAlignment([methodSignature getArgumentTypeAtIndex:i],
                                  &sizep, &alingp);
            
            [invocation setArgument:(void *)(ap+offset) atIndex:i];
            offset+=alingp;
        }
        va_end(ap);
        
        [self forwardInvocation:invocation];
    }
    else
        [self doesNotRecognizeSelector:cmd];
}

void* individMessageDispatchGetImp(id self, SEL _cmd, ...)
{
    void* forwardFunc = NULL;
    
    NSDictionary* individDispatchTable = objc_getAssociatedObject(self, &kGAIndividDispatchTableKey);
    if(!individDispatchTable)
    {
        NSDictionary* classDispatchTable = objc_getAssociatedObject([self class], &kGAIndividDefaultImpKey);
        NSAssert(classDispatchTable!=nil,
                 @"Individ inconsistency: no individual or class dispatch table for object %@",self);

        forwardFunc = [[classDispatchTable objectForKey:[NSString stringWithCString:(const char*)_cmd encoding:NSASCIIStringEncoding]]
                       pointerValue];
    }
    else
    {
        NSDictionary* dict = [individDispatchTable objectForKey:[NSString stringWithCString:(const char*)_cmd
                                                                                   encoding:NSASCIIStringEncoding]];
        id block =  [dict objectForKey:kGAIndividImplementationKey];
        
        if(block)
        {
            forwardFunc = imp_implementationWithBlock(block);
        }
        else
        {
            NSDictionary* classDispatchTable = objc_getAssociatedObject([self class], &kGAIndividDefaultImpKey);
            NSAssert(classDispatchTable!=nil,
                     @"Individ inconsistency: no implementation for %s and no class dispatch table for object %@",(const char*)_cmd,self);
            
            forwardFunc = [[classDispatchTable objectForKey:[NSString stringWithCString:(const char*)_cmd encoding:NSASCIIStringEncoding]]
                           pointerValue];

        }
    }
    
    return forwardFunc;
}

void* objc_msgSendAddr()
{
    return objc_msgSend;
}

void* objc_msgSendStretAddr()
{
    return objc_msgSend_stret;
}

void* individMessageDispatchDoesnotRecognizeAddr()
{
    return individMessageDispatchDoesnotRecognize;
}


BOOL respondsToSelectorImp(id self,SEL _cmd,SEL _sel)
{
    BOOL result = [self respondsToSelectorOld:_sel];
    if(result)
    {
        IMP selImp = method_getImplementation(class_getInstanceMethod([self class], _sel));
        if((void*)selImp == individMessageDispatch)
        {
            NSDictionary* individDispatchTable = objc_getAssociatedObject(self, &kGAIndividDispatchTableKey);
            NSDictionary* classDispatchTable = objc_getAssociatedObject([self class], &kGAIndividDefaultImpKey);
            
            result = ((individDispatchTable && [individDispatchTable objectForKey:
                       [NSString stringWithCString:(const char*)_sel encoding:NSASCIIStringEncoding]]) ||
            (classDispatchTable && [classDispatchTable objectForKey:
                                   [NSString stringWithCString:(const char*)_sel encoding:NSASCIIStringEncoding]]));
        }
    }
    
    return result;
}




@implementation NSObject (Individ)

-(void) setImplementationWithBlock:(id) block
              forSelector:(SEL) selector
        withTypesEncoding:(char*)typesEncoding
{
    Method existingMethod = class_getInstanceMethod([self class], selector);
    IMP existingImp = NULL;
    
    void * impPointer = individMessageDispatch;
    
#if !__i386__
    NSMethodSignature* signature = [NSMethodSignature signatureWithObjCTypes:typesEncoding];
    const char* type = [signature methodReturnType];
    
//    int sizep;
//    int alingp;
//    NSGetSizeAndAlignment([signature methodReturnType],
//                          &sizep,
//                          &alingp);
    
    if(strlen(type)>5)
    {
        impPointer = individMessageDispatchStret;
    }
#endif
    
    if(!existingMethod)
    {
        class_addMethod([self class],
                        selector,
                        (IMP)impPointer,
                        typesEncoding);
        
    }
    else
    {
        const char* encoding = method_getTypeEncoding(existingMethod);
        char* simplifiedEncoding = malloc(strlen(encoding)+1);
        memset(simplifiedEncoding, 0, strlen(encoding)+1);

        for(size_t i=0,offset = 0;i<strlen(encoding);i++)
        {
            if(encoding[i]>='0' && encoding[i]<='9')
                continue;
            
            simplifiedEncoding[offset] = encoding[i];
            offset++;
        }
        BOOL areEqual = (strcmp(typesEncoding, simplifiedEncoding)==0);
        free(simplifiedEncoding);
        NSAssert(areEqual,
                 @"attempt to modify method with different set of patameters");
        
        
        existingImp = class_replaceMethod([self class],
                                          selector,
                                          (IMP)impPointer,
                                          typesEncoding);
        
    }
    
    NSMutableDictionary* defaultImpTable = objc_getAssociatedObject([self class], &kGAIndividDefaultImpKey);
    if(!defaultImpTable)
    {
        defaultImpTable = [NSMutableDictionary dictionary];
        objc_setAssociatedObject([self class],
                                 &kGAIndividDefaultImpKey,
                                 defaultImpTable,
                                 OBJC_ASSOCIATION_RETAIN);
    }
    
    if(existingImp && existingImp!=impPointer &&
       ![defaultImpTable objectForKey:[NSString stringWithCString:(const char*)selector encoding:NSASCIIStringEncoding]])
        [defaultImpTable setObject:[NSValue valueWithPointer:existingImp]
                        forKey:[NSString stringWithCString:(const char*)selector encoding:NSASCIIStringEncoding]];
    
    
    NSMutableDictionary* individDispatchTable =
    objc_getAssociatedObject(self, &kGAIndividDispatchTableKey);
    
    if(!individDispatchTable)
    {
        individDispatchTable = [NSMutableDictionary dictionary];
        
        IMP oldImp = class_getMethodImplementation([self class], @selector(respondsToSelector:));
        class_replaceMethod([self class], @selector(respondsToSelector:),
                            (IMP)respondsToSelectorImp, "b@::");
        
        class_addMethod([self class],
                        @selector(respondsToSelectorOld:),
                        oldImp,
                        "b@::");
        
        
    }
    
    block = Block_copy(block);

    [individDispatchTable setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                     block, kGAIndividImplementationKey,
                                     [NSString stringWithCString:typesEncoding
                                                        encoding:NSASCIIStringEncoding],kGAIndividTypeEncodingKey,
                                     nil]
                             forKey:[NSString stringWithCString:(const char*)selector encoding:NSASCIIStringEncoding]];
        
    Block_release(block);
    
    objc_setAssociatedObject(self,
                             &kGAIndividDispatchTableKey,
                             individDispatchTable,
                             OBJC_ASSOCIATION_RETAIN);
    
    
}

@end
