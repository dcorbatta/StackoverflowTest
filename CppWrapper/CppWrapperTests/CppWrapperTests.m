//
//  CppWrapperTests.m
//  CppWrapperTests
//
//  Created by Daniel Nestor Corbatta Barreto on 02/12/13.
//  Copyright (c) 2013 Daniel Nestor Corbatta Barreto. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PersonWrapper.h"
@interface CppWrapperTests : XCTestCase

@end

@implementation CppWrapperTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    PersonWrapper * p = [[PersonWrapper alloc] initWithName:@"Daniel" andAge:[NSNumber numberWithInt:25]];
    [p talk];
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
