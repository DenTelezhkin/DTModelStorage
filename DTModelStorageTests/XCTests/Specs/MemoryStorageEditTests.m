//
//  MemoryStorageEditTests.m
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 28.09.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DTMemoryStorage.h"
#import "OCMock.h"

@interface MemoryStorageEditTests : XCTestCase
{
    DTMemoryStorage *storage;
    OCMockObject * delegate;
    NSString * acc1;
    NSString * acc2;
    NSString * acc3;
    NSString * acc4;
    NSString * acc5;
    NSString * acc6;
}
@end

@implementation MemoryStorageEditTests

- (void)setUp {
    [super setUp];
    delegate = [OCMockObject niceMockForProtocol:@protocol(DTStorageUpdating)];
    storage = [DTMemoryStorage storage];
    storage.delegate = (id <DTStorageUpdating>) delegate;
    
    acc1 = @"1";
    acc2 = @"2";
    acc3 = @"3";
    acc4 = @"4";
    acc5 = @"5";
    acc6 = @"6";
}

- (void)testShouldInsertItems
{
    [storage addItems:@[acc2,acc4,acc6]];
    [storage addItem:acc5 toSection:1];
    
    DTStorageUpdate * update = [DTStorageUpdate new];
    [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:2
                                                               inSection:0]];
    
    [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [update isEqual:obj];
    }]];
    
    [storage insertItem:acc1 toIndexPath:[storage indexPathForItem:acc6]];
    
    [delegate verify];
    
    update = [DTStorageUpdate new];
    [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                               inSection:1]];
    
    [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [update isEqual:obj];
    }]];
    
    [storage insertItem:acc3 toIndexPath:[storage indexPathForItem:acc5]];
    
    [delegate verify];
}

-(void)testShouldReloadRows
{
    [storage addItems:@[acc2,acc4,acc6]];
    
    DTStorageUpdate * update = [DTStorageUpdate new];
    [update.updatedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                              inSection:0]];
    
    [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [update isEqual:obj];
    }]];
    
    [storage reloadItem:acc4];
    
    [delegate verify];
}

-(void)testShouldReplaceRows
{
    [storage addItems:@[acc2,acc4,acc6]];
    
    DTStorageUpdate * update = [DTStorageUpdate new];
    [update.updatedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                              inSection:0]];
    
    [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [update isEqual:obj];
    }]];
    
    [storage replaceItem:acc4 withItem:acc5];
    
    [delegate verify];
}

-(void)testShouldRemoveItem
{
    [storage addItems:@[acc2,acc4,acc6]];
    [storage addItem:acc5 toSection:1];
    
    DTStorageUpdate * update = [DTStorageUpdate new];
    [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                              inSection:0]];
    
    [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [update isEqual:obj];
    }]];
    [storage removeItem:acc2];
    [delegate verify];
    
    update = [DTStorageUpdate new];
    [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                              inSection:1]];
    
    [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [update isEqual:obj];
    }]];
    [storage removeItem:acc5];
    [delegate verify];
}

-(void)testShouldRemoveItemAtIndexPath
{
    [storage addItems:@[acc2,acc4,acc6]];
    [storage addItem:acc5 toSection:1];
    
    DTStorageUpdate * update = [DTStorageUpdate new];
    [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                              inSection:0]];
    
    [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [update isEqual:obj];
    }]];
    [storage removeItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0
                                                           inSection:0]]];
    [delegate verify];
    
    update = [DTStorageUpdate new];
    [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                              inSection:1]];
    
    [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [update isEqual:obj];
    }]];
    [storage removeItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0
                                                           inSection:1]]];
    [delegate verify];
}

-(void)testShouldRemoveItemsAtIndexPaths
{
    [storage addItems:@[acc2,acc4,acc6]];
    [storage addItem:acc5 toSection:1];
    
    DTStorageUpdate * update = [DTStorageUpdate new];
    [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                              inSection:0]];
    [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                              inSection:1]];
    
    [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [update isEqual:obj];
    }]];
    [storage removeItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0
                                                           inSection:0],
                                       [NSIndexPath indexPathForItem:0
                                                           inSection:1]]];
    [delegate verify];
}

-(void)testShouldNotCrashWhenRemovingNonExistingItem
{
    [storage addItems:@[acc2,acc4,acc6]];
    [storage addItem:acc5 toSection:1];
    
    expect(^{
        [storage removeItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:5
                                                               inSection:0]]];}).toNot.raiseAny();
    expect(^{
        [storage removeItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:2
                                                               inSection:1]]];
    }).toNot.raiseAny();
}

-(void)testShouldRemoveItems
{
    [storage addItems:@[acc1,acc3] toSection:0];
    [storage addItems:@[acc2,acc4] toSection:1];
    
    
    DTStorageUpdate * update = [DTStorageUpdate new];
    [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                              inSection:0]];
    [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                              inSection:1]];
    [update.deletedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                              inSection:0]];
    
    
    [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [update isEqual:obj];
    }]];
    [storage removeItems:@[acc1,acc4,acc3,acc5]];
    [delegate verify];
    
    expect([[storage itemsInSection:0] count]).to.equal(0);
    expect([[storage itemsInSection:1] count]).to.equal(1);
}

-(void)testShouldDeleteSections
{
    [storage addItem:acc1];
    [storage addItem:acc2 toSection:1];
    [storage addItem:acc3 toSection:2];
    
    DTStorageUpdate * update = [DTStorageUpdate new];
    [update.deletedSectionIndexes addIndex:1];
    
    [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [update isEqual:obj];
    }]];
    [storage deleteSections:[NSIndexSet indexSetWithIndex:1]];
    [delegate verify];
    
    expect([[storage sections] count]).to.equal(2);
}

-(void)testShouldSafelySetAndRetrieveSupplementaryModel
{
    DTSectionModel * section = [DTSectionModel new];
    
    [section setSupplementaryModel:@"foo" forKind:@"bar"];
    
    expect([section supplementaryModelOfKind:@"bar"]).to.equal(@"foo");
}

-(void)testShouldNotCallDelegateForOptionalMethod
{
    expect(^{
    [storage supplementaryModelOfKind:@"foo" forSectionIndex:1];
    }).toNot.raiseAny();
}

-(void)testShouldBeAbleToRetrieveSupplementaryModelViaStorageMethod
{
    DTSectionModel * section = [storage sectionAtIndex:0];
    
    [section setSupplementaryModel:@"foo" forKind:@"bar"];
    
    expect([storage supplementaryModelOfKind:@"bar" forSectionIndex:0]).to.equal(@"foo");
}

-(void)testShouldSetSupplementaries
{
    NSString * kind = @"foo";
    [storage setSupplementaries:@[@"1",@"2",@"3"] forKind:kind];
    
    expect([[storage sectionAtIndex:0] supplementaryModelOfKind:kind]).to.equal(@"1");
    expect([[storage sectionAtIndex:1] supplementaryModelOfKind:kind]).to.equal(@"2");
    expect([[storage sectionAtIndex:2] supplementaryModelOfKind:kind]).to.equal(@"3");
}

-(void)testShouldNilOutSupplementaries
{
    NSString * kind = @"foo";
    [storage setSupplementaries:@[@"1",@"2",@"3"] forKind:kind];
    
    [storage setSupplementaries:nil forKind:kind];
    
    expect([[storage sectionAtIndex:0] supplementaryModelOfKind:kind]).to.beNil();
    expect([[storage sectionAtIndex:1] supplementaryModelOfKind:kind]).to.beNil();
    expect([[storage sectionAtIndex:2] supplementaryModelOfKind:kind]).to.beNil();
}

-(void)testShouldNotCallDelegateIfItDoesNotImplementMethod
{
    storage.delegate = (id)storage;
    expect(^{
        [storage addItem:@"foo"];
    }).toNot.raiseAny();
}

-(void)testShouldGetItemCorrectly
{
    [storage addItem:acc1];
    [storage addItem:acc2 toSection:1];
    [storage addItem:acc3 toSection:2];
    
    id model = [storage objectAtIndexPath:[NSIndexPath indexPathForItem:0
                                                              inSection:1]];
    
    expect(model).to.equal(acc2);
    
    model = [storage objectAtIndexPath:[NSIndexPath indexPathForItem:0
                                                           inSection:2]];
    expect(model).to.equal(acc3);
}

-(void)testShouldReturnNilForNotExistingIndexPath
{
    expect(^{
        id model = [storage objectAtIndexPath:[NSIndexPath indexPathForItem:5 inSection:6]];
        expect(model).to.beNil();
    }).toNot.raiseAny();
}

-(void)testShouldReturnNilForNotExistingIndexPathInExistingSection
{
    expect(^{
        [storage addItem:acc1];
        id model = [storage objectAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
        expect(model).to.beNil();
    }).toNot.raiseAny();
}

@end
