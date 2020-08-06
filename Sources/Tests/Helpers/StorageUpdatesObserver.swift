//
//  StorageUpdatesObserver.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 11.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import DTModelStorage
import XCTest

func indexPath(_ item:Int, _ section:Int) -> IndexPath
{
    return IndexPath(item: item, section: section)
}

class StorageUpdatesObserver : StorageUpdating
{
    var updates: [StorageUpdate] = []
    var lastUpdate : StorageUpdate?
    var storageNeedsReloadingCalled = false
    var onUpdate: ((StorageUpdatesObserver, StorageUpdate) -> Void)?
    
    init(){}
    
    func storageNeedsReloading() {
        storageNeedsReloadingCalled = true
    }
    
    func storageDidPerformUpdate(_ update: StorageUpdate) {
        self.lastUpdate = update
        updates.append(update)
        onUpdate?(self, update)
    }
    
    func applyUpdates() {
        updates.forEach {
            $0.applyDeferredDatasourceUpdates()
        }
        updates = []
    }
    
    func flushUpdates() {
        updates = []
    }
    
    func verifyObjectChanges(_ changes: [(ChangeType, [IndexPath])]) {
        XCTAssertEqual(lastUpdate?.objectChanges.count, changes.count)
        for (index, change) in changes.enumerated() {
            guard (lastUpdate?.objectChanges.count ?? 0) > index else {
                XCTFail("object change not found!")
                continue
            }
            XCTAssertEqual(lastUpdate?.objectChanges[index].0, change.0)
            XCTAssertEqual(lastUpdate?.objectChanges[index].1, change.1)
        }
    }
    
    func verifySectionChanges(_ changes: [(ChangeType, [Int])]) {
        XCTAssertEqual(lastUpdate?.sectionChanges.count, changes.count)
        for (index, change) in changes.enumerated() {
            guard (lastUpdate?.sectionChanges.count ?? 0) > index else {
                XCTFail("section not found!")
                continue
            }
            XCTAssertEqual(lastUpdate?.sectionChanges[index].0, change.0)
            XCTAssertEqual(lastUpdate?.sectionChanges[index].1, change.1)
        }
    }
}
