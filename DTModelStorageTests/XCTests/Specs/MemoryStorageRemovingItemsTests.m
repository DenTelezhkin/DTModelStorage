//
//  MemoryStorageRemovingItemsTests.m
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 22.01.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DTMemoryStorage.h"

@interface MemoryStorageRemovingItemsTests : XCTestCase
@property (nonatomic, strong) DTMemoryStorage * storage;
@end

@interface DTMemoryStorage(UnitTests)
+(NSArray *)sortedArrayOfIndexPaths:(NSArray *)indexPaths ascending:(BOOL)ascending;
@end

@implementation MemoryStorageRemovingItemsTests

-(void)setUp
{
    self.storage = [DTMemoryStorage new];
}

-(void)testRemovingTwoSubsequentItemsByIndexPathsWorksCorrectly
{
    [self.storage addItems:@[@1,@2,@3]];
    
    [self.storage removeItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],
                                            [NSIndexPath indexPathForRow:1 inSection:0]]];
    expect([self.storage objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).to.equal(@3);
}

-(void)testRemovingSubsequentItemsWorksInDifferentSections
{
    [self.storage addItems:@[@1,@2,@3]];
    [self.storage addItems:@[@4,@5,@6] toSection:1];
    
    NSArray * indexPathsToRemove = @[[NSIndexPath indexPathForRow:1 inSection:0],
                                     [NSIndexPath indexPathForRow:2 inSection:0],
                                     [NSIndexPath indexPathForRow:0 inSection:1],
                                     [NSIndexPath indexPathForRow:2 inSection:1]];
    [self.storage removeItemsAtIndexPaths:indexPathsToRemove];
    
    expect([self.storage objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).to.equal(@1);
    expect([self.storage objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).to.equal(@5);
    expect([[[self.storage sectionAtIndex:0] objects] count]).to.equal(1);
    expect([[[self.storage sectionAtIndex:1] objects] count]).to.equal(1);
}

-(void)testRemovingItemsWorksWithSubsequentItems
{
    [self.storage addItems:@[@1,@2,@3]];
    [self.storage addItems:@[@4,@5,@6] toSection:1];
    [self.storage removeItems:@[@2,@3,@4,@5]];
    
    expect([self.storage objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).to.equal(@1);
    expect([self.storage objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).to.equal(@6);
    
    expect([[[self.storage sectionAtIndex:0] objects] count]).to.equal(1);
    expect([[[self.storage sectionAtIndex:1] objects] count]).to.equal(1);
}

-(void)testSortingOfIndexPathsInSingleSection
{
    NSArray * indexPaths = @[[NSIndexPath indexPathForRow:0 inSection:0],
                             [NSIndexPath indexPathForRow:5 inSection:0],
                             [NSIndexPath indexPathForRow:3 inSection:0]];
    NSArray * sortedIndexPaths = [DTMemoryStorage sortedArrayOfIndexPaths:indexPaths ascending:NO];
    
    expect([sortedIndexPaths.firstObject row]).to.equal(5);
    expect([sortedIndexPaths.lastObject row]).to.equal(0);
    expect(sortedIndexPaths.count).to.equal(3);
}

-(void)testSortingOfIndexPathsInDifferentSections {
    NSArray * indexPaths = @[[NSIndexPath indexPathForRow:0 inSection:0],
                             [NSIndexPath indexPathForRow:3 inSection:0],
                             [NSIndexPath indexPathForRow:3 inSection:2],
                             [NSIndexPath indexPathForRow:2 inSection:2],
                             [NSIndexPath indexPathForRow:1 inSection:1]];
    NSArray * sortedIndexPaths = [DTMemoryStorage sortedArrayOfIndexPaths:indexPaths ascending:NO];
    
    NSArray * expectedIndexPaths = @[
                                     [NSIndexPath indexPathForRow:3 inSection:2],
                                     [NSIndexPath indexPathForRow:2 inSection:2],
                                     [NSIndexPath indexPathForRow:1 inSection:1],
                                     [NSIndexPath indexPathForRow:3 inSection:0],
                                     [NSIndexPath indexPathForRow:0 inSection:0]
                                     ];
    expect(sortedIndexPaths).to.equal(expectedIndexPaths);
}

@end
