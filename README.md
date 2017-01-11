GoogleMock - Xcode
==================

[![Build Status](https://img.shields.io/travis/macmade/gmock-xcode.svg?branch=master&style=flat)](https://travis-ci.org/macmade/gmock-xcode)
[![Issues](http://img.shields.io/github/issues/macmade/gmock-xcode.svg?style=flat)](https://github.com/macmade/gmock-xcode/issues)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg?style=flat)
![License](https://img.shields.io/badge/license-boost-brightgreen.svg?style=flat)
[![Contact](https://img.shields.io/badge/contact-@macmade-blue.svg?style=flat)](https://twitter.com/macmade)  
[![Donate-Patreon](https://img.shields.io/badge/donate-patreon-yellow.svg?style=flat)](https://patreon.com/macmade)
[![Donate-Gratipay](https://img.shields.io/badge/donate-gratipay-yellow.svg?style=flat)](https://www.gratipay.com/macmade)
[![Donate-Paypal](https://img.shields.io/badge/donate-paypal-yellow.svg?style=flat)](https://paypal.me/xslabs)

About
-----

This project consists of an integration of the GoogleMock library to Apple's Xcode IDE.

Since version 5, Xcode provides a nice way to write unit tests with the `XCTest` framework.  
The cool thing is that unit tests written with `XCTest` are nicely integrated to the IDE, providing visual feedback when running tests. Obviously they are also nicely integrated with the different build toolchains, like `xcodebuild` or Facebook's `xctool`.

While this is perfect for Objective-C, writing unit tests for other languages (like C++) is not so great with `XCTest`.  
Of course, this is possible using Objective-C++, but writing an Objective-C class for each C++ test case leads to some undesired overhead.

GoogleMock is nice unit testing library for C++. The only issue is that it does not integrate well with Xcode, as does `XCTest`.  
This mean the IDE won't provide visual feedback for the unit tests written with GoogleMock, and you'll have to look at the console output to inspect any failed test.

So this project fixes this issue by bridging GoogleMock to `XCTest`.

### Implementation details

`XCTest` works by analysing test classes at runtime, thanks to Objective-C dynamic nature.  
Basically, when the test bundle is loaded, it will look for all classes extending `XCTestCase`, and look for methods beginning with the `test` prefix.

If such a class is available, it will then create an instance, and launch each test method, reporting the result to the IDE.

This project consists of a framework which has to be linked to the unit test bundle. The framework includes GoogleMock, so you don't have to build it by yourself.

It works by querying each GoogleMock test case. For each one, a specific subclass of `XCTestCase` will be dynamically created at runtime.  
For each test in a test case, an Objective-C method will be created and added to the `XCTestCase` subclass.

The GoogleMock test cases are then run, reporting the usual output to the console.

Then, as we created new classes compatible with `XCTest`, it will find them, and run them as usual.  
Each method will simply look at the GoogleMock test result, and report the status using `XCTest` assertions, so we got visual feedback, as if we had written our test cases using `XCTest`.


Project Configuration
---------------------

In order to use these features, your unit test bundle needs to be linked to the provided frameworks.

The easiest way to do this is to include the provided Xcode project (`GoogleMock.xcodeproj`) as a subproject of your own Xcode project, so all targets are available.

Then, from the `Build Phases` screen of your unit test's target, add the following frameworks to the `Target Dependancies` step:

 * GoogleMock

Adds the same frameworks to the `Link Binary With Libraries` step, and you're done.  
Your unit test bundle is now ready to use GoogleMock.


Writing tests
-------------

Writing GoogleMock tests is also straightforward.  
Simply include `<GoogleMock/GoogleMock.h>` to your `.cpp` file, and write your tests as usual.

For instance:

    #include <GoogleMock/GoogleMock.h>
    
    using namespace testing;
    
    TEST( MyTestCase, MyTest )
    {
        ASSERT_TRUE( true );
    }

In the above example, a subclass of `XCTestCase` named `MyTestCase` will be created at runtime, with a test method called `testMyTest`, so you can easily inspect the results of your GoogleMock tests directly from the Xcode tests tab.

License
-------

The GoogleMock Xcode integration library is released under the terms of the Boost Software License - Version 1.0.

Repository Infos
----------------

    Owner:			Jean-David Gadina - XS-Labs
    Web:			www.xs-labs.com
    Blog:			www.noxeos.com
    Twitter:		@macmade
    GitHub:			github.com/macmade
    LinkedIn:		ch.linkedin.com/in/macmade/
    StackOverflow:	stackoverflow.com/users/182676/macmade
