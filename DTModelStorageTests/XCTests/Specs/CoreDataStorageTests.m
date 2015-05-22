//
//  CoreDataStorageTests.m
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 28.09.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DTCoreDataStorage.h"

@interface DTCoreDataStorage()
-(void)startUpdate;
-(void)finishUpdate;

@property (nonatomic, strong) DTStorageUpdate * currentUpdate;

@end

@interface CoreDataStorageTests : XCTestCase
{
    DTCoreDataStorage *storage;
}
@end

@implementation CoreDataStorageTests

- (void)setUp
{
    [super setUp];
    
    storage = [[DTCoreDataStorage alloc] initWithFetchResultsController:[NSFetchedResultsController new]];
    storage.delegate = (id)storage;
}

-(void)testThatDelegateShouldRespondToSelector
{
    [storage startUpdate];
    [[storage.currentUpdate insertedSectionIndexes] addIndex:5];
    
    expect(^{
        [storage finishUpdate];
    }).toNot.raiseAny();
}

@end
