//
//  MemoryStorageRemovingItemsSpecs.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 12.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
@testable import DTModelStorage
import Nimble

class MemoryStorageRemovingItemsSpecs: XCTestCase {

    var storage : MemoryStorage!
    var storageUpdatesObserver : StorageUpdatesObserver!
    
    override func setUp() {
        super.setUp()
        self.storage = MemoryStorage()
        storageUpdatesObserver = StorageUpdatesObserver()
        storage.delegate = storageUpdatesObserver
    }

    func testRemovingTwoSubsequentItemsByIndexPathsWorksCorrectly() {
        storage.addItems([1,2,3], toSection: 0)
        storage.removeItems(at: [indexPath(0, 0),indexPath(1, 0)])
        expect(self.storage.item(at: indexPath(0, 0)) as? Int).to(equal(3))
    }
    
    func testRemovingSubsequentItemsWorksInDifferentSections()
    {
        storage.addItems([1,2,3], toSection: 0)
        storage.addItems([4,5,6], toSection: 1)
        
        self.storage.removeItems(at: [indexPath(1, 0), indexPath(2, 0),indexPath(0, 1),indexPath(2, 1)])
        
        expect(self.storage.item(at: indexPath(0, 0)) as? Int) == 1
        expect(self.storage.item(at: indexPath(0, 1)) as? Int) == 5
        
        expect(self.storage.section(atIndex: 0)?.items.count) == 1
        expect(self.storage.section(atIndex: 1)?.items.count) == 1
    }
    
    func testRemovingItemsWorksWithSubsequentItems()
    {
        self.storage.addItems([1,2,3], toSection: 0)
        self.storage.addItems([4,5,6], toSection: 1)
        
        self.storage.removeItems([2,3,4,5])
        
        expect(self.storage.item(at: indexPath(0, 0)) as? Int) == 1
        expect(self.storage.item(at: indexPath(0, 1)) as? Int) == 6
        
        expect(self.storage.section(atIndex: 0)?.items.count) == 1
        expect(self.storage.section(atIndex: 1)?.items.count) == 1
    }
    
    func testSortingOfIndexPathsInSingleSection()
    {
        let indexPaths = [indexPath(0, 0),indexPath(5, 0),indexPath(3, 0)]
        let sortedIndexPaths = MemoryStorage.sortedArrayOfIndexPaths(indexPaths, ascending: false)
        
        expect(sortedIndexPaths.first?.item) == 5
        expect(sortedIndexPaths.last?.item) == 0
        expect(sortedIndexPaths.count) == 3
    }
    
    func testSortingOfIndexPathsInDifferentSections()
    {
        let indexPaths = [indexPath(0, 0),indexPath(3, 0),indexPath(3,2),indexPath(2, 2),indexPath(1, 1)]
        let sortedIndexPaths = MemoryStorage.sortedArrayOfIndexPaths(indexPaths, ascending: false)
        
        let expectedIndexPaths = [indexPath(3, 2),indexPath(2, 2),indexPath(1, 1),indexPath(3, 0),indexPath(0, 0)]
        
        expect(sortedIndexPaths) == expectedIndexPaths
    }
    
    func testRemovingAndEnumerating()
    {
        storage.addItems([1,2,3,4,5])
        storage.removeItems([1,3,4,6])
        
        expect(self.storage.section(atIndex: 0)?.items.count) == 2
        expect(self.storage.item(at: indexPath(0, 0)) as? Int) == 2
        expect(self.storage.item(at: indexPath(1, 0)) as? Int) == 5
        
        expect(self.storageUpdatesObserver.update?.objectChanges.filter { $0.0 == .delete }.flatMap { $1 } ) == [indexPath(0, 0),indexPath(2, 0), indexPath(3, 0)]
    }
    
    func testRemoveItemsFromSection()
    {
        storage.addItems([1,2,3])
        storage.removeItems(fromSection: 0)
        
        expect(self.storage.section(atIndex: 0)?.items.count) == 0
        
        expect(self.storageUpdatesObserver.update?.objectChanges.filter { $0.0 == .delete}.flatMap { $1 }) == [indexPath(0, 0),indexPath(1, 0), indexPath(2, 0)]
    }
}
