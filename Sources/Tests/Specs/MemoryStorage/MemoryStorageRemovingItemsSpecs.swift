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

@MainActor
class MemoryStorageRemovingItemsSpecs: XCTestCase {

    var storage = MemoryStorage()
    var delegate = StorageUpdatesObserver()
    
    @MainActor override func setUp() {
        super.setUp()
        storage.delegate = delegate
    }

    func testRemovingTwoSubsequentItemsByIndexPathsWorksCorrectly() {
        storage.addItems([1, 2, 3], toSection: 0)
        storage.removeItems(at: [indexPath(0, 0), indexPath(1, 0)])
        delegate.applyUpdates()
        XCTAssertEqual(storage.item(at: indexPath(0, 0)) as? Int, 3)
    }
    
    func testRemovingSubsequentItemsWorksInDifferentSections()
    {
        storage.addItems([1, 2, 3], toSection: 0)
        storage.addItems([4, 5, 6], toSection: 1)
        
        self.storage.removeItems(at: [indexPath(1, 0), indexPath(2, 0), indexPath(0, 1), indexPath(2, 1)])
        delegate.applyUpdates()
        XCTAssertEqual(storage.item(at: indexPath(0, 0)) as? Int, 1)
        XCTAssertEqual(storage.item(at: indexPath(0, 1)) as? Int, 5)
        
        XCTAssertEqual(storage.section(atIndex: 0)?.items.count, 1)
        XCTAssertEqual(storage.section(atIndex: 1)?.items.count, 1)
    }
    
    func testRemovingItemsWorksWithSubsequentItems()
    {
        self.storage.addItems([1, 2, 3], toSection: 0)
        self.storage.addItems([4, 5, 6], toSection: 1)
        
        self.storage.removeItems([2, 3, 4, 5])
        delegate.applyUpdates()
        XCTAssertEqual(storage.item(at: indexPath(0, 0)) as? Int, 1)
        XCTAssertEqual(storage.item(at: indexPath(0, 1)) as? Int, 6)
        
        XCTAssertEqual(storage.section(atIndex: 0)?.items.count, 1)
        XCTAssertEqual(storage.section(atIndex: 1)?.items.count, 1)
    }
    
    func testSortingOfIndexPathsInSingleSection()
    {
        let indexPaths = [indexPath(0, 0), indexPath(5, 0), indexPath(3, 0)]
        let sortedIndexPaths = MemoryStorage.sortedArrayOfIndexPaths(indexPaths, ascending: false)
        
        XCTAssertEqual(sortedIndexPaths.first?.item, 5)
        XCTAssertEqual(sortedIndexPaths.last?.item, 0)
        XCTAssertEqual(sortedIndexPaths.count, 3)
    }
    
    func testSortingOfIndexPathsInDifferentSections()
    {
        let indexPaths = [indexPath(0, 0), indexPath(3, 0), indexPath(3, 2), indexPath(2, 2), indexPath(1, 1)]
        let sortedIndexPaths = MemoryStorage.sortedArrayOfIndexPaths(indexPaths, ascending: false)
        
        let expectedIndexPaths = [indexPath(3, 2), indexPath(2, 2), indexPath(1, 1), indexPath(3, 0), indexPath(0, 0)]
        
        XCTAssertEqual(sortedIndexPaths, expectedIndexPaths)
    }
    
    func testRemovingAndEnumerating()
    {
        storage.addItems([1, 2, 3, 4, 5])
        storage.removeItems([1, 3, 4, 6])
        delegate.applyUpdates()
        XCTAssertEqual(storage.section(atIndex: 0)?.items.count, 2)
        XCTAssertEqual(storage.item(at: indexPath(0, 0)) as? Int, 2)
        XCTAssertEqual(storage.item(at: indexPath(1, 0)) as? Int, 5)
        
        delegate.verifyObjectChanges([
            (.delete, [indexPath(0, 0)]),
            (.delete, [indexPath(2, 0)]),
            (.delete, [indexPath(3, 0)])
        ])
    }
    
    func testRemoveItemsFromSection()
    {
        storage.addItems([1, 2, 3])
        storage.removeItems(fromSection: 0)
        delegate.applyUpdates()
        XCTAssertEqual(storage.section(atIndex: 0)?.items.count, 0)
        
        delegate.verifyObjectChanges([
            (.delete, [indexPath(0, 0)]),
            (.delete, [indexPath(1, 0)]),
            (.delete, [indexPath(2, 0)])
        ])
    }
}
