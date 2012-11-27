Desription
=======

ObjectiveC runtime extensions which allows particular objects to have individual method implementations (instead of class-defined)

How to Use
=======

The main goal is to add to objects ability to have it's own implementations of some method. It's usage is super simple.
You create an objective-c object and add new method's (or replace existing's one) implementation like this:

```objc
[object setImplementationWithBlock: ^()
     {
         //individual method implementation goes here
     }
                            forSelector:@selector(methodName)
                         withReturnType:@encode(void)
		withParamsTypesEncoding:nil];
```


What's supported
=======

Individ takes care of supporting objective-c messaging mechanism and modifies `-respondsToSelector:` as well as calls to 
`-forwardingTargetForSelector:` and `-forwardInvocation:`. Basically, all usual messaging should be transparently adopted to
new method implementations.

Guarantees
=======

Individ comes with unit tests for covering all possible ways to use it: various types passing and returning, responding to
messaging mechanism, assertions. Since built-in unit tests cannot be run on device, and since we need these tests being 
run on all supported platforms, We choosed GHUnit for unit testing. 
If you want to ensure Individ works correctly on your platoform - go ahead and run these tests.

Support
=======

Currently Individ supports x86 (32bit) and armv7 armv7s, no armv6 support. Platoform restictions come from the assembly code using for 
forwarding variable number parameters.


Credits
=======

Individ was created by Sergey Gavrilyuk [@octogavrix](http://twitter.com/octogavrix). Assembly code inspired by one of the
Mike Ash's [friday Q&A](http://www.mikeash.com/pyblog/friday-qa-2012-11-16-lets-build-objc_msgsend.html)

License
=======

Individ is distributed under MIT license. See LICENSE for more info.


