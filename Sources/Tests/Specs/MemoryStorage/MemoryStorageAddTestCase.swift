//
//  MemoryStorageAddSpec.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 11.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTModelStorage

class MemoryStorageAddSpec: XCTestCase {

    var storage : MemoryStorage!
    var observer : StorageUpdatesObserver!
    
    override func setUp() {
        super.setUp()
        observer = StorageUpdatesObserver()
        storage = MemoryStorage()
        storage.delegate = observer
        storage.defersDatasourceUpdates = false
    }

    func testShouldReceiveCorrectUpdateCallWhenAddingItem() {
        let update = StorageUpdate()
        update.sectionChanges.append((.insert, [0]))
        update.objectChanges.append((.insert, [indexPath(0, 0)]))
        
        storage.addItem("")
        
        XCTAssertEqual(observer.update, update)
    }
    
    func testShouldReceiveCorrectUpdateCallWhenAddingItems()
    {
        let foo = [1, 2, 3]
        storage.addItems(foo, toSection: 1)
        
        observer.verifyObjectChanges([
            (.insert, [indexPath(0, 1)]),
            (.insert, [indexPath(1, 1)]),
            (.insert, [indexPath(2, 1)])
        ])
        observer.verifySectionChanges([
            (.insert, [0]),
            (.insert, [1])
        ])
    }
}
