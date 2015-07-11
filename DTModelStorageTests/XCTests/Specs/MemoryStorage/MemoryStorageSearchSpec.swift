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

}
