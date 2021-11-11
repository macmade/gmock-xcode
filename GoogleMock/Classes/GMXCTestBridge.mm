/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2014 Jean-David Gadina - www.xs-labs.com / www.digidna.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

/*!
 * @file        GMXCTestBridge.mm
 * @copyright   (c) 2015 - Jean-David Gadina - www.xs-labs.com
 * @abstract    GoogleMock XCTest bridge
 */

#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wvariadic-macros"
#pragma clang diagnostic ignored "-Wgnu-statement-expression"
#pragma clang diagnostic ignored "-Wgnu-zero-variadic-macro-arguments"
#if __clang_major__ > 8
#pragma clang diagnostic ignored "-Wunguarded-availability"
#endif
#endif

#import <gmock/gmock.h>
#import <XCTest/XCTest.h>
#import <objc/runtime.h>

using namespace testing;

static bool                              __inited = false;
static std::vector< const TestCase * > * __t      = nullptr;

static void __f( id self, SEL _cmd );
static void __f( id self, SEL _cmd )
{
    std::string        testCaseName;
    std::string        testInfoName;
    int                i;
    int                n;
    const TestInfo   * testInfo;
    const TestResult * testResult;
    
    /* Name of the GMock test case to analyze */
    testCaseName = std::string( [ NSStringFromClass( [ self class ] ) UTF8String ] );
    
    /* Name of the GMock test to analyze */
    testInfoName = std::string( [ [ NSStringFromSelector( _cmd ) substringFromIndex: 4 ] UTF8String ] );
    
    /* Process each stored GMock test case */
    for( const TestCase * testCase: *( __t ) )
    {
        if( std::string( testCase->name() ) != testCaseName )
        {
            /* Not the current test case */
            continue;
        }
        
        /* Number of tests in the test case */
        n = testCase->total_test_count();
        
        /* Process each test in the test case */
        for( i = 0; i < n; i++ )
        {
            testInfo = testCase->GetTestInfo( i );
            
            if( testInfo == nullptr )
            {
                continue;
            }
            
            if( std::string( testInfo->name() ) != testInfoName )
            {
                /* Not the current test */
                continue;
            }
            
            if( testInfo->should_run() == false )
            {
                /* Test is disabled */
                return;
            }
            
            testResult = testInfo->result();
            
            if( testResult == nullptr )
            {
                XCTAssertNotEqual( testResult, nullptr, "Invalid GMock test result" );
                
                return;
            }
            
            if( testResult->Passed() )
            {
                /* Test has passed */
                XCTAssertTrue( true );
                
                return;
            }
            
            /* Test has failed */
            {
                int              testPartResultCount;
                int              j;
                NSString       * message;
                NSString       * part;
                NSMutableArray * parts;
                NSString       * file;
                NSUInteger       line;
                
                /* Number of test part results */
                testPartResultCount = testResult->total_part_count();
                
                /* Process each test part result */
                for( j = 0; j < testPartResultCount; j++ )
                {
                    const TestPartResult & testPartResult = testResult->GetTestPartResult( j );
                    
                    if( testPartResult.type() != TestPartResult::kFatalFailure )
                    {
                        /* Successfull part */
                        continue;
                    }
                    
                    /* Test message */
                    message = [ NSString stringWithCString: testPartResult.message() encoding: NSUTF8StringEncoding ];
                    parts   = [ NSMutableArray new ];
                    
                    for( part in [ message componentsSeparatedByString: @"\n" ] )
                    {
                        [ parts addObject: [ part stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceCharacterSet ] ] ];
                    }
                    
                    message = [ parts componentsJoinedByString: @" | " ];
                    
                    /* Test file and line */
                    if( testPartResult.file_name() == nullptr )
                    {
                        file = @"";
                        line = 0;
                    }
                    else
                    {
                        file = [ NSString stringWithCString: testPartResult.file_name() encoding: NSUTF8StringEncoding ];
                        line = ( NSUInteger )( testPartResult.line_number() );
                    }
                    
                    /* Fails the test */
                    [ self recordFailureWithDescription: message inFile: file atLine: line expected: YES ];
                }
            }
            
            return;
        }
    }
    
    XCTAssertTrue( false, "Cannot determine GMock test from current selector" );
}

static void __dtor( void ) __attribute__( ( destructor ) );
static void __dtor( void )
{
    delete __t;
}

@interface GoogleMockXCTestBridge: XCTestCase
{}

@end

@implementation GoogleMockXCTestBridge

+ ( void )initialize
{
    if( self != [ GoogleMockXCTestBridge self ] )
    {
        return;
    }
    
    /* Initializes GMock */
    {
        int          argc;
        const char * argv[ 1 ];
        
        argc      = 1;
        argv[ 0 ] = "GoogleMockXCTestBridge";
        
        testing::InitGoogleMock( &argc, const_cast< char ** >( argv ) );
    }
    
    /*
     * Support for xctool
     * 
     * The xctool helper will use otest-query-osx to query all tests in
     * the bundle, expecting JSON output in stdout.
     * As the GMock output is not JSON, we don't run the tests in such a case.
     * The Objective-C classes for each GMock test cases will still be
     * created, and the tests correctly run when necessary.
     */
    if( [ [ [ NSProcessInfo processInfo ] processName ] isEqualToString: @"otest-query-osx" ] == NO )
    {
        /* Runs all GMock tests */
        {
            int res;
            
            res = RUN_ALL_TESTS();
            
            /* warn_unused_result */
            ( void )res;
        }
    }
    
    /* Stores all GMock test cases and creates XCTest methods for each one */
    {
        const TestCase * testCase;
        const TestInfo * testInfo;
        int              testCaseCount;
        int              testInfoCount;
        int              i;
        int              j;
        Class            cls;
        IMP              imp;
        SEL              sel;
        NSString       * testName;
        
        /* Storage for the GMock test cases */
        __t = new std::vector< const TestCase * >;
        
        /* Number of available GMock test cases */
        testCaseCount = UnitTest::GetInstance()->total_test_case_count();
        
        /* Process each test case */
        for( i = 0; i < testCaseCount; i++ )
        {
            testCase = UnitTest::GetInstance()->GetTestCase( i );
            
            if( testCase == nullptr )
            {
                continue;
            }
            
            /* Stores the test case */
            __t->push_back( testCase );
            
            /* Creates a new Objective-C class for the test case */
            cls = objc_allocateClassPair( objc_getClass( "XCTestCase" ), testCase->name(), 0 );
            
            /* Number of tests in the test case */
            testInfoCount = testCase->total_test_count();
            
            /* Process each test in the test case */
            for( j = 0; j < testInfoCount; j++ )
            {
                testInfo = testCase->GetTestInfo( j );
                
                if( testInfo == nullptr )
                {
                    continue;
                }
                
                /* XCTest method name and selector */
                testName = [ NSString stringWithFormat: @"test%s", testInfo->name() ];
                sel      = sel_registerName( testName.UTF8String );
                
                /* IMP for the generic XCTest method */
                imp = reinterpret_cast< IMP >( __f );
                
                /* Adds the XCTest method to the class, so Xcode will run it */
                class_addMethod( cls, sel, imp, "v@:" );
                
                /* We have tests from GMock */
                __inited = true;
            }
            
            /* Registers the new class with the Objective-C runtime */
            objc_registerClassPair( cls );
        }
    }
}

- ( void )testHasGoogleMockTests
{
    XCTAssertTrue( __inited, "No GMock test" );
}

@end
