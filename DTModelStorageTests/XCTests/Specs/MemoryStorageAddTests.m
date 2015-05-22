//
//  MemoryStorageAddTests.m
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 28.09.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "DTMemoryStorage.h"

@interface MemoryStorageAddTests : XCTestCase
{
    DTMemoryStorage *storage;
    OCMockObject * delegate;
}
@end

@implementation MemoryStorageAddTests

- (void)setUp {
    [super setUp];
    
    delegate = [OCMockObject niceMockForProtocol:@protocol(DTStorageUpdating)];
    storage = [DTMemoryStorage new];
    storage.delegate = (id <DTStorageUpdating>) delegate;
}

-(void)testShouldReceiveCorrectUpdateCallWhenAddingItem
{
    DTStorageUpdate * update = [DTStorageUpdate new];
    [update.insertedSectionIndexes addIndex:0];
    [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                               inSection:0]];
    
    [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id argument) {
        return [update isEqual:argument];
    }]];
    
    [storage addItem:@""];
    [delegate verify];
}

-(void)testShouldReceiveCorrectUpdateCallWhenAddingItems
{
    DTStorageUpdate * update = [DTStorageUpdate new];
    [update.insertedSectionIndexes addIndexesInRange:NSMakeRange(0, 2)];
    [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                               inSection:1]];
    [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                               inSection:1]];
    [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:2
                                                               inSection:1]];
    
    [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id argument) {
        return [update isEqual:argument];
    }]];
    
    [storage addItems:@[@"1",@"2",@"3"] toSection:1];
    [delegate verify];
}
@end
