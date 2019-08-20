//
//  MemoryStorageSearchSpec.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 11.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
@testable import DTModelStorage

class TableCell: UITableViewCell, ModelTransfer
{
    func update(with model: Int) {
    }
}

class CollectionCell : UICollectionViewCell, ModelTransfer
{
    func update(with model: Int) {
    }
}

class MemoryStorageSearchSpec: XCTestCase {

    var storage = MemoryStorage()

    class StorageUpdatingInstance : StorageUpdating {
        var storageNeedsReloadingCalled = false
        
        func storageDidPerformUpdate(_ update: StorageUpdate) {
            
        }
        
        func storageNeedsReloading() {
            storageNeedsReloadingCalled = true
        }
    }
    
    override func setUp() {
        super.setUp()
        self.storage = MemoryStorage()
        storage.defersDatasourceUpdates = false
    }
    
    func testShouldCorrectlyReturnItemAtIndexPath() {
        storage.addItems(["1", "2"])
        storage.addItems(["3", "4"], toSection: 1)
        var model = storage.item(at: indexPath(1, 1))
     
        XCTAssertEqual(model as? String, "4")
        
        model = storage.item(at: indexPath(0, 0))
        
        XCTAssertEqual(model as? String, "1")
        XCTAssertEqual(storage.numberOfSections(), 2)
        XCTAssertEqual(storage.numberOfItems(inSection: 0), 2)
        XCTAssertEqual(storage.numberOfItems(inSection: 2), 0)
    }
    
    func testShouldReturnIndexPathOfItem()
    {
        storage.addItems([1, 2], toSection: 0)
        storage.addItems([3, 4], toSection: 1)
        
        let indexPath = storage.indexPath(forItem: 3)
        
        XCTAssertEqual(indexPath, IndexPath(item: 0, section: 1))
        
        XCTAssertNil(storage.indexPath(forItem: 5))
    }
    
    func testShouldReturnItemsInSection()
    {
        storage.addItems([1, 2], toSection: 0)
        storage.addItems([3, 4], toSection: 1)
        
        let section0 = storage.items(inSection: 0)?.map{ $0 as! Int }
        let section1 = storage.items(inSection: 1)?.map{ $0 as! Int }
        
        XCTAssertEqual(section0, [1, 2])
        XCTAssertEqual(section1, [3, 4])
    }
    
    func testTableItemIndexPath()
    {
        storage.addItems([1, 2, 3])
        storage.addItems([4, 5, 6], toSection: 1)
        storage.addItems([7, 8, 9], toSection: 2)
        
        let indexPathArray = storage.indexPathArray(forItems: [1, 5, 9])
        XCTAssertEqual(indexPathArray, [indexPath(0, 0), indexPath(1, 1), indexPath(2, 2)])
    }
    
    func testUpdateWithoutAnimations() {
        storage.defersDatasourceUpdates = true
        storage.updateWithoutAnimations {
            storage.addItems([1, 2])
        }
        XCTAssertEqual(storage.items(inSection: 0)?.compactMap { $0 as? Int }, [1, 2])
        
        storage.updateWithoutAnimations {
            storage.addItems([3, 4])
            storage.addItems([5, 6])
        }
        XCTAssertEqual(storage.items(inSection: 0)?.compactMap { $0 as? Int }, [1, 2, 3, 4, 5, 6])
    }
    
    func testEmptySection()
    {
        XCTAssertNil(storage.section(atIndex: 0))
    }
    
    func testNilEmptySectionItems()
    {
        XCTAssertNil(storage.items(inSection: 0))
    }
    
    func testRemoveAllItems()
    {
        let storageNeedsReloading = StorageUpdatingInstance()
        storage.delegate = storageNeedsReloading
        storage.addItems([12, 3, 5, 6])
        
        XCTAssertFalse(storageNeedsReloading.storageNeedsReloadingCalled)
        storage.removeAllItems()
        XCTAssert(storageNeedsReloading.storageNeedsReloadingCalled)
        XCTAssertEqual(storage.section(atIndex: 0)?.items.count, 0)
    }
    
    func testSectionModelIsAwareOfItsLocation() {
        storage.addItem(3)
        let section = storage.section(atIndex: 0)! as SectionModel
        XCTAssertEqual(section.currentSectionIndex, 0)
    }
}
