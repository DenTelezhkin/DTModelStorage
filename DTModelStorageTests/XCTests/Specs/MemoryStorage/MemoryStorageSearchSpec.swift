//
//  MemoryStorageSearchSpec.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 11.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTModelStorage
import Nimble

class MemoryStorageSearchSpec: XCTestCase {

    var storage = MemoryStorage()

    override func setUp() {
        super.setUp()
        self.storage = MemoryStorage()
    }
    
    func testShouldCorrectlyReturnItemAtIndexPath() {
        storage.addItems(["1","2"])
        storage.addItems(["3","4"], toSection: 1)
        var model = storage.itemAtIndexPath(indexPath(1, 1))
     
        expect(model as? String) == "4"
        
        model = storage.itemAtIndexPath(indexPath(0, 0))
        
        expect(model as? String) == "1"
    }
    
    func testShouldReturnIndexPathOfItem()
    {
        storage.addItems([1,2], toSection: 0)
        storage.addItems([3,4], toSection: 1)
        
        let indexPath = storage.indexPathForItem(3)
        
        expect(indexPath) == NSIndexPath(forItem: 0, inSection: 1)
        
        expect(self.storage.indexPathForItem(5)).to(beNil())
    }
    
    func testShouldReturnItemsInSection()
    {
        storage.addItems([1,2], toSection: 0)
        storage.addItems([3,4], toSection: 1)
        
        let section0 = storage.itemsInSection(0)?.map{ $0 as! Int }
        let section1 = storage.itemsInSection(1)?.map{ $0 as! Int }
        
        expect(section0) == [1,2]
        expect(section1) == [3,4]
    }
    
    func testTableItemIndexPath()
    {
        
        // MARK: TODO Add test with testables and swift 2.0
//        it(@"should correctly map index paths to models", ^{
//
//            NSArray * testArray1 = @[ acc1, testModel, acc3 ];
//            [storage addItems:testArray1];
//
//            NSArray * testArray2 = @[ acc6, acc4, testModel ];
//            [storage addItems:testArray2 toSection:1];
//
//            NSArray * testArray3 = @[ testModel, acc5, acc2 ];
//            [storage addItems:testArray3 toSection:2];
//
//            NSIndexPath * ip1 = [storage indexPathForItem:acc1];
//            NSIndexPath * ip2 = [storage indexPathForItem:acc2];
//            NSIndexPath * ip3 = [storage indexPathForItem:acc3];
//            NSIndexPath * ip4 = [storage indexPathForItem:acc4];
//            NSIndexPath * ip5 = [storage indexPathForItem:acc5];
//            NSIndexPath * ip6 = [storage indexPathForItem:acc6];
//            NSIndexPath * testPath = [storage indexPathForItem:testModel];
//
//            NSArray * indexPaths = [storage indexPathArrayForItems:testArray1];
//
//            [indexPaths objectAtIndex:0] should equal(ip1);
//            [indexPaths objectAtIndex:1] should equal(testPath);
//            [indexPaths objectAtIndex:2] should equal(ip3);
//
//            indexPaths = [storage indexPathArrayForItems:testArray2];
//            [indexPaths objectAtIndex:0] should equal(ip6);
//            [indexPaths objectAtIndex:1] should equal(ip4);
//            [indexPaths objectAtIndex:2] should equal(testPath);
//
//            indexPaths = [storage indexPathArrayForItems:testArray3];
//            [indexPaths objectAtIndex:0] should equal(testPath);
//            [indexPaths objectAtIndex:1] should equal(ip5);
//            [indexPaths objectAtIndex:2] should equal(ip2);
//        });
    }
}
