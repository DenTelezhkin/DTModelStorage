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

class MemoryStorageDeferredUpdatesTestCase: XCTestCase {
    
    var storage : MemoryStorage!
    var delegate : StorageUpdatesObserver!
    
    override func setUp() {
        super.setUp()
        delegate = StorageUpdatesObserver()
        storage = MemoryStorage()
        storage.delegate = delegate
        storage.defersDatasourceUpdates = true
    }
    
    func testSeveralUpdatesAreDeferrable() {
        storage.addItems([2, 4, 6], toSection: 0)
        XCTAssertEqual(self.delegate.update?.objectChanges.count, 0)
        XCTAssertEqual(self.delegate.update?.enqueuedDatasourceUpdates.count, 1)
        XCTAssertEqual(storage.totalNumberOfItems, 0)
        XCTAssert(self.delegate.update?.containsDeferredDatasourceUpdates ?? false)
        self.delegate.update?.applyDeferredDatasourceUpdates()
        XCTAssertFalse(self.delegate.update?.containsDeferredDatasourceUpdates ?? true)
        XCTAssertEqual(self.delegate.update?.objectChanges.count, 3)
        XCTAssertEqual(storage.totalNumberOfItems, 3)
    }
    
    func testSeveralUpdatesAreDeferrableInPerformUpdatesBlock() {
        storage.performUpdates {
            storage.addItems([2, 4, 6])
            try? storage.insertItem(3, to: indexPath(1, 0))
        }
        XCTAssertEqual(self.delegate.update?.objectChanges.count, 0)
        XCTAssertEqual(self.delegate.update?.enqueuedDatasourceUpdates.count, 2)
        XCTAssertEqual(storage.totalNumberOfItems, 0)
        self.delegate.update?.applyDeferredDatasourceUpdates()
        XCTAssertEqual(self.delegate.update?.objectChanges.count, 4)
        XCTAssertEqual(storage.totalNumberOfItems, 4)
        XCTAssertEqual(storage.items(inSection: 0) as? [Int] ?? [], [2,3,4,6])
    }
}
