//
//  RuntimeHelperObjectiveCTests.m
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 29.09.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "XCTests-Swift.h"
#import "DTRuntimeHelper.h"

@interface RuntimeHelperObjectiveCTests : XCTestCase

@end

@implementation RuntimeHelperObjectiveCTests

-(void)testSwiftClassIsAcceptable
{
    id object = [SwiftProvider swiftObject];
    expect([DTRuntimeHelper modelStringForClass:[object class]]).to.equal(@"SwiftClass");
}

-(void)testRenamedSwiftClassIsAcceptable
{
    id object = [SwiftProvider renamedClassObject];
    expect([DTRuntimeHelper modelStringForClass:[object class]]).to.equal(@"RenamedFooClass");
}

-(void)testSwiftStringClass
{
    id string = [SwiftProvider swiftString];
    expect([DTRuntimeHelper modelStringForClass:[string class]]).to.equal(@"NSString");
}

-(void)testSwiftNumbers
{
    id number = [[SwiftProvider swiftNumberArray] firstObject];
    expect([DTRuntimeHelper modelStringForClass:[number class]]).to.equal(@"NSNumber");
}

-(void)testSwiftNumberArray
{
    id array = [SwiftProvider swiftNumberArray];
    expect([DTRuntimeHelper modelStringForClass:[array class]]).to.equal(@"NSArray");
}

-(void)testSwiftArray
{
    id array = [SwiftProvider swiftArray];
    expect([DTRuntimeHelper modelStringForClass:[array class]]).to.equal(@"NSArray");
}

-(void)testBoolArray
{
    id bar = [[SwiftProvider boolArray] firstObject];
    expect([DTRuntimeHelper modelStringForClass:[bar class]]).to.equal(@"NSNumber");
}

-(void)testSwiftDictionary
{
    id dictionary = [SwiftProvider swiftDictionary];
    expect([DTRuntimeHelper modelStringForClass:[dictionary class]]).to.equal(@"NSDictionary");
}

-(void)testNSStringClass
{
    expect([DTRuntimeHelper modelStringForClass:[NSString class]]).to.equal(@"NSString");
    expect([DTRuntimeHelper modelStringForClass:[NSMutableString class]]).to.equal(@"NSString");
}

-(void)testNSArrayClass {
    expect([DTRuntimeHelper modelStringForClass:[NSArray class]]).to.equal(@"NSArray");
    expect([DTRuntimeHelper modelStringForClass:[NSMutableArray class]]).to.equal(@"NSArray");
}

-(void)testNSDictionaryClass
{
    expect([DTRuntimeHelper modelStringForClass:[NSDictionary class]]).to.equal(@"NSDictionary");
    expect([DTRuntimeHelper modelStringForClass:[NSMutableDictionary class]]).to.equal(@"NSDictionary");
}

-(void)testNSDateClass
{
    expect([DTRuntimeHelper modelStringForClass:[NSDate class]]).to.equal(@"NSDate");
}

-(void)testNSNumberClass
{
    expect([DTRuntimeHelper modelStringForClass:[NSNumber class]]).to.equal(@"NSNumber");
    expect([DTRuntimeHelper modelStringForClass:[@(YES) class]]).to.equal(@"NSNumber");
}

@end
