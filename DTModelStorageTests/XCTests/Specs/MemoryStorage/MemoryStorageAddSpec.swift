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
import Nimble

class MemoryStorageAddSpec: XCTestCase {

    var storage : MemoryStorage!
    var delegate : StorageUpdatesObserver!
    
    override func setUp() {
        super.setUp()
        delegate = StorageUpdatesObserver()
        storage = MemoryStorage()
        storage.delegate = delegate
    }

    func testShouldReceiveCorrectUpdateCallWhenAddingItem() {
        var update = StorageUpdate()
        update.insertedSectionIndexes.addIndex(0)
        update.insertedRowIndexPaths.append(indexPath(0, 0))
        
        storage.addItem("")
        
        expect(self.delegate.update) == update
    }
    
    func testShouldReceiveCorrectUpdateCallWhenAddingItems()
    {
        let foo = [1,2,3]
        storage.addItems(foo, toSection: 1)
        
        var update = StorageUpdate()
        update.insertedSectionIndexes.addIndexesInRange(NSMakeRange(0, 2))
        update.insertedRowIndexPaths.append(indexPath(0, 1))
        update.insertedRowIndexPaths.append(indexPath(1, 1))
        update.insertedRowIndexPaths.append(indexPath(2, 1))
        
        expect(self.delegate.update) == update
    }

}
