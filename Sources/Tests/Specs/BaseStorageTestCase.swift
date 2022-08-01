//
//  BaseStorageTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 29.10.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage

@MainActor
class BaseStorageTestCase: XCTestCase {

    let storage = MemoryStorage()
    let updateObserver = StorageUpdatesObserver()
    
    override func setUp() {
        super.setUp()
        storage.delegate = updateObserver
    }
    
    func testTwoInsertions()
    {
        storage.performUpdates {
            storage.addItems([1])
            storage.addItems([2], toSection: 1)
        }
        updateObserver.applyUpdates()
        
        updateObserver.verifyObjectChanges([
            (.insert, [indexPath(0, 0)]),
            (.insert, [indexPath(0, 1)])
        ])
    }
    
}
