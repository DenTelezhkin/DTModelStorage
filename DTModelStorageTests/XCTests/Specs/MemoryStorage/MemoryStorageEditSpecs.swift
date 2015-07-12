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
    
    func testShouldRemoveItem()
    {
        storage.addItems([2,4,6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        storage.removeItem(2)
        
        var update = StorageUpdate()
        update.deletedRowIndexPaths = [indexPath(0, 0)]
        
        expect(self.delegate.update) == update
        
        storage.removeItem(5)
        update.deletedRowIndexPaths = [indexPath(0, 1)]
        
        expect(self.delegate.update) == update
    }
    
    func testShouldRemoveItemAtIndexPath()
    {
        storage.addItems([2,4,6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        storage.removeItemsAtIndexPaths([indexPath(0, 0)])
        
        var update = StorageUpdate()
        update.deletedRowIndexPaths = [indexPath(0, 0)]
        
        expect(self.delegate.update) == update
        
        storage.removeItemsAtIndexPaths([indexPath(0, 1)])
        
        update.deletedRowIndexPaths = [indexPath(0, 1)]
        
        expect(self.delegate.update) == update
    }
    
    func testShouldRemoveItemsAtIndexPaths()
    {
        storage.addItems([2,4,6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        storage.removeItemsAtIndexPaths([indexPath(0, 0),indexPath(0, 1)])
        
        var update = StorageUpdate()
        update.deletedRowIndexPaths = [indexPath(0, 1),indexPath(0, 0)]
        
        expect(self.delegate.update) == update
    }
    
    func testShouldNotCrashWhenRemovingNonExistingItem()
    {
        storage.addItems([2,4,6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        // MARK : TODO - check for error in Swift 2
        storage.removeItemsAtIndexPaths([indexPath(5, 0), indexPath(2, 1)])
    }
    
    func testShouldRemoveItems()
    {
        storage.addItems([1,3], toSection: 0)
        storage.addItems([2,4], toSection: 1)
        
        var update = StorageUpdate()
        update.deletedRowIndexPaths = [indexPath(0, 0),indexPath(1, 1),indexPath(1, 0)]
    }
}
