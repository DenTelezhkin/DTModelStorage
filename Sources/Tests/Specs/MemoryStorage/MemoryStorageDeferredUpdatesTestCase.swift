//
//  MemoryStorageDeferredUpdatesTestCase.swift
//  Tests
//
//  Created by Denys Telezhkin on 02.12.17.
//  Copyright © 2017 Denys Telezhkin. All rights reserved.
//

import XCTest
import XCTest
@testable import DTModelStorage

@MainActor
class MemoryStorageDeferredUpdatesTestCase: XCTestCase {
    
    var storage : MemoryStorage!
    var delegate : StorageUpdatesObserver!
    
    @MainActor override func setUp() {
        super.setUp()
        delegate = StorageUpdatesObserver()
        storage = MemoryStorage()
        storage.delegate = delegate
    }
    
    func testSeveralUpdatesAreDeferrable() {
        storage.addItems([2, 4, 6], toSection: 0)
        XCTAssertEqual(self.delegate.lastUpdate?.objectChanges.count, 0)
        XCTAssertEqual(self.delegate.lastUpdate?.enqueuedDatasourceUpdates.count, 1)
        XCTAssertEqual(storage.totalNumberOfItems, 0)
        XCTAssert(self.delegate.lastUpdate?.containsDeferredDatasourceUpdates ?? false)
        self.delegate.lastUpdate?.applyDeferredDatasourceUpdates()
        XCTAssertFalse(self.delegate.lastUpdate?.containsDeferredDatasourceUpdates ?? true)
        XCTAssertEqual(self.delegate.lastUpdate?.objectChanges.count, 3)
        XCTAssertEqual(storage.totalNumberOfItems, 3)
    }
    
    func testSeveralUpdatesAreDeferrableInPerformUpdatesBlock() {
        storage.performUpdates {
            storage.addItems([2, 4, 6])
            try? storage.insertItem(3, to: indexPath(1, 0))
        }
        XCTAssertEqual(self.delegate.lastUpdate?.objectChanges.count, 0)
        XCTAssertEqual(self.delegate.lastUpdate?.enqueuedDatasourceUpdates.count, 2)
        XCTAssertEqual(storage.totalNumberOfItems, 0)
        self.delegate.lastUpdate?.applyDeferredDatasourceUpdates()
        XCTAssertEqual(self.delegate.lastUpdate?.objectChanges.count, 4)
        XCTAssertEqual(storage.totalNumberOfItems, 4)
        XCTAssertEqual(storage.items(inSection: 0) as? [Int] ?? [], [2, 3, 4, 6])
    }
}
