//
//  MemoryStorageEditSpecs.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 11.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTModelStorage
import Nimble

class MemoryStorageEditSpecs: XCTestCase {

    var storage : MemoryStorage!
    var delegate : StorageUpdatesObserver!
    
    override func setUp() {
        super.setUp()
        delegate = StorageUpdatesObserver()
        storage = MemoryStorage()
        storage.delegate = delegate
    }
    
    func testShouldInsertItems()
    {
        storage.addItems([2,4,6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        storage.insertItem(1, toIndexPath: storage.indexPathForItem(6)!)
        
        var update = StorageUpdate()
        update.insertedRowIndexPaths = [indexPath(2,0)]
        
        expect(self.delegate.update) == update
        
        
        storage.insertItem(3, toIndexPath: storage.indexPathForItem(5)!)
        
        update = StorageUpdate()
        update.insertedRowIndexPaths = [indexPath(0, 1)]
        
        expect(self.delegate.update) == update
    }

    func testShouldReloadRows()
    {
        storage.addItems([2,4,6])
        
        storage.reloadItem(4)
        
        var update = StorageUpdate()
        update.updatedRowIndexPaths = [indexPath(1, 0)]
        
        expect(self.delegate.update) == update
    }
    
    func testShouldReplaceRows()
    {
        storage.addItems([2,4,6])
        storage.replaceItem(4, replacingItem: 5)
        
        var update = StorageUpdate()
        update.updatedRowIndexPaths = [indexPath(1, 0)]
        
        expect(self.delegate.update) == update
    }
}
