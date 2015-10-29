//
//  BaseStorageTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 29.10.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage
import Nimble

class BaseStorageTestCase: XCTestCase {

    var storage : MemoryStorage!
    var updateObserver : StorageUpdatesObserver!
    
    override func setUp() {
        super.setUp()
        storage = MemoryStorage()
        updateObserver = StorageUpdatesObserver()
        storage.delegate = updateObserver
    }
    
    func testTwoInsertions()
    {
        storage.performUpdates {
            storage.addItems([1])
            storage.addItems([2], toSection: 1)
        }
        
        expect(self.updateObserver.update?.insertedRowIndexPaths) == Set([indexPath(0, 0), indexPath(0, 1)])
    }
    
}
