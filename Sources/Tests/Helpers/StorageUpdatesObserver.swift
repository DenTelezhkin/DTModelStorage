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
    var update : StorageUpdate?
    var storageNeedsReloadingFlag = false
    var onUpdate: ((StorageUpdatesObserver, StorageUpdate) -> Void)?
    
    init(){}
    
    func storageNeedsReloading() {
        storageNeedsReloadingFlag = true
    }
    
    func storageDidPerformUpdate(_ update: StorageUpdate) {
        self.update = update
        onUpdate?(self, update)
    }
    
    func verifyObjectChanges(_ changes: [(ChangeType, [IndexPath])]) {
        XCTAssertEqual(update?.objectChanges.count, changes.count)
        for (index, change) in changes.enumerated() {
            XCTAssertEqual(update?.objectChanges[index].0, change.0)
            XCTAssertEqual(update?.objectChanges[index].1, change.1)
        }
    }
    
    func verifySectionChanges(_ changes: [(ChangeType, [Int])]) {
        XCTAssertEqual(update?.sectionChanges.count, changes.count)
        for (index, change) in changes.enumerated() {
            XCTAssertEqual(update?.sectionChanges[index].0, change.0)
            XCTAssertEqual(update?.sectionChanges[index].1, change.1)
        }
    }
}
