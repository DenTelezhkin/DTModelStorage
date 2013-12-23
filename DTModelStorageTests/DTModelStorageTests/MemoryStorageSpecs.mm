#import "DTMemoryStorage.h"
#import "OCMock.h"
#import "DTSectionModel.h"
#import "DTStorage.h"

#import <Cedar-iOS/Cedar-iOS.h>
#import <Cedar-iOS/SpecHelper.h>

using namespace Cedar::Matchers;

SPEC_BEGIN(MemoryStorageSpecs)

describe(@"Storage search specs", ^{
    __block DTMemoryStorage *storage;
    
    beforeEach(^{
        storage = [DTMemoryStorage storage];
        storage.delegate = [OCMockObject niceMockForProtocol:@protocol(DTStorageUpdating)];
    });
    
    it(@"should correctly return item at indexPath", ^{
        [storage addItems:@[@"1",@"2"] toSection:0];
        [storage addItems:@[@"3",@"4"] toSection:1];
        
        id model = [storage itemAtIndexPath:[NSIndexPath indexPathForRow:1
                                                               inSection:1]];
        
        model should equal(@"4");
        
        model = [storage itemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        model should equal(@"1");
    });
    
    it(@"should return indexPath of Item", ^{
        [storage addItems:@[@"1",@"2"] toSection:0];
        [storage addItems:@[@"3",@"4"] toSection:1];
        
        NSIndexPath * indexPath = [storage indexPathForItem:@"3"];
        
        indexPath should equal([NSIndexPath indexPathForRow:0 inSection:1]);
    });
    
    it(@"should return items in section",^{
        [storage addItems:@[@"1",@"2"] toSection:0];
        [storage addItems:@[@"3",@"4"] toSection:1];
        
        NSArray * section0 = [storage itemsInSection:0];
        NSArray * section1 = [storage itemsInSection:1];
        
        section0 should equal(@[@"1",@"2"]);
        section1 should equal(@[@"3",@"4"]);
    });
    
});

describe(@"Storage Add specs", ^{
    __block DTMemoryStorage *storage;
    __block OCMockObject * delegate;

    beforeEach(^{
        delegate = [OCMockObject niceMockForProtocol:@protocol(DTStorageUpdating)];
        storage = [DTMemoryStorage storage];
        storage.delegate = (id <DTStorageUpdating>) delegate;
    });
    
    it(@"should receive correct update call when adding table item",
    ^{
        DTStorageUpdate * update = [DTStorageUpdate new];
        [update.insertedSectionIndexes addIndex:0];
        [update.insertedRowIndexPaths addObject:[NSIndexPath indexPathForRow:0
                                                                   inSection:0]];
        
        [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id argument) {
            return [update isEqual:argument];
        }]];
        
        [storage addItem:@""];
        [delegate verify];
    });
    
    it(@"should receive correct update call when adding table items",
    ^{
        DTStorageUpdate * update = [DTStorageUpdate new];
        [update.insertedSectionIndexes addIndexesInRange:{0,2}];
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
    });
});

describe(@"Storage edit specs", ^{
    __block DTMemoryStorage *storage;
    __block OCMockObject * delegate;
    __block NSString * acc1;
    __block NSString * acc2;
    __block NSString * acc3;
    __block NSString * acc4;
    __block NSString * acc5;
    __block NSString * acc6;
    
    beforeEach(^{
        delegate = [OCMockObject niceMockForProtocol:@protocol(DTStorageUpdating)];
        storage = [DTMemoryStorage storage];
        storage.delegate = (id <DTStorageUpdating>) delegate;
        
        acc1 = @"1";
        acc2 = @"2";
        acc3 = @"3";
        acc4 = @"4";
        acc5 = @"5";
        acc6 = @"6";
    });
    
    it(@"should insert items", ^{
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
    });
   
    it(@"should reload rows", ^{
        
        [storage addItems:@[acc2,acc4,acc6]];
        
        DTStorageUpdate * update = [DTStorageUpdate new];
        [update.updatedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:0]];
        
        [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        
        [storage reloadItem:acc4];
        
        [delegate verify];
    });
    
    it(@"should reload rows", ^{
        
        [storage addItems:@[acc2,acc4,acc6]];
        
        DTStorageUpdate * update = [DTStorageUpdate new];
        [update.updatedRowIndexPaths addObject:[NSIndexPath indexPathForRow:1
                                                                  inSection:0]];
        
        [[delegate expect] storageDidPerformUpdate:[OCMArg checkWithBlock:^BOOL(id obj) {
            return [update isEqual:obj];
        }]];
        
        [storage replaceItem:acc4 withItem:acc5];
        
        [delegate verify];
    });
    
    it(@"should remove table item", ^{
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
    });
    
    it(@"should remove table items", ^{
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
        
        [[storage itemsInSection:0] count] should equal(0);
        [[storage itemsInSection:1] count] should equal(1);
    });
    
    it(@"should delete sections", ^{
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
        
        [[storage sections] count] should equal(2);
    });
    
    it(@"should have ability to safely set and retrieve supplementary model", ^{
        DTSectionModel * section = [DTSectionModel new];
        
        [section setSupplementaryModel:@"foo" forKind:@"bar"];
        
        [section supplementaryModelOfKind:@"bar"] should equal(@"foo");
    });
    
    it(@"should not call delegate for optional supplementary method", ^{
        ^{
            [storage supplementaryModelOfKind:@"foo" forSectionIndex:1];
        } should_not raise_exception();
    });
    
    it(@"should be able to retrieve supplementary model via storage method", ^{
        
        DTSectionModel * section = [storage sectionAtIndex:0];
        
        [section setSupplementaryModel:@"foo" forKind:@"bar"];
        
        [storage supplementaryModelOfKind:@"bar" forSectionIndex:0] should equal(@"foo");
    });
    
    it(@"should not call delegate if it doesn't respond to selector", ^{
       storage.delegate = (id)storage;
        
        ^{
            [storage addItem:@"foo"];
        } should_not raise_exception();
        
    });
});


SPEC_END
