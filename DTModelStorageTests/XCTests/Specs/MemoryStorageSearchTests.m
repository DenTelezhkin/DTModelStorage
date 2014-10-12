//
//  MemoryStorageTests.m
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 28.09.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

#import "DTMemoryStorage.h"
#import "OCMock.h"
#import "DTSectionModel.h"
#import "DTBaseStorage.h"

@interface MemoryStorageTests : XCTestCase
{
    DTMemoryStorage *storage;
}
@end

@implementation MemoryStorageTests

- (void)setUp {
    [super setUp];
    
    storage = [DTMemoryStorage storage];
    storage.delegate = [OCMockObject niceMockForProtocol:@protocol(DTStorageUpdating)];
}

- (void)testShouldCorrectlyReturnItemAtIndexPath
{
    [storage addItems:@[@"1",@"2"] toSection:0];
    [storage addItems:@[@"3",@"4"] toSection:1];
    
    id model = [storage itemAtIndexPath:[NSIndexPath indexPathForRow:1
                                                           inSection:1]];
    
    expect(model).to.equal(@"4");
    
    model = [storage itemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    expect(model).to.equal(@"1");
}

-(void)testShouldReturnIndexPathOfItem
{
    [storage addItems:@[@"1",@"2"] toSection:0];
    [storage addItems:@[@"3",@"4"] toSection:1];
    
    NSIndexPath * indexPath = [storage indexPathForItem:@"3"];
    
    expect(indexPath).to.equal([NSIndexPath indexPathForRow:0 inSection:1]);
}

-(void)testShouldReturnItemsInSection
{
    [storage addItems:@[@"1",@"2"] toSection:0];
    [storage addItems:@[@"3",@"4"] toSection:1];
    
    NSArray * section0 = [storage itemsInSection:0];
    NSArray * section1 = [storage itemsInSection:1];
    
    expect(section0).to.equal(@[@"1",@"2"]);
    expect(section1).to.equal(@[@"3",@"4"]);
}

@end
