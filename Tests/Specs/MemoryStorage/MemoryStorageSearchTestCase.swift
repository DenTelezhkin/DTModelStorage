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
import Nimble

#if swift(>=4.1)
#else
/// Extension for adding Swift 4.1 methods, to support Swift 4.0 and Swift 3.2/3.3 concurrently.
extension Sequence {
    func compactMap<ElementOfResult>(_ transform: (Self.Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        return try flatMap(transform)
    }
}
#endif

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
     
        expect(model as? String) == "4"
        
        model = storage.item(at: indexPath(0, 0))
        
        expect(model as? String) == "1"
    }
    
    func testShouldReturnIndexPathOfItem()
    {
        storage.addItems([1, 2], toSection: 0)
        storage.addItems([3, 4], toSection: 1)
        
        let indexPath = storage.indexPath(forItem: 3)
        
        expect(indexPath) == IndexPath(item: 0, section: 1)
        
        expect(self.storage.indexPath(forItem: 5)).to(beNil())
    }
    
    func testShouldReturnItemsInSection()
    {
        storage.addItems([1, 2], toSection: 0)
        storage.addItems([3, 4], toSection: 1)
        
        let section0 = storage.items(inSection: 0)?.map{ $0 as! Int }
        let section1 = storage.items(inSection: 1)?.map{ $0 as! Int }
        
        expect(section0) == [1, 2]
        expect(section1) == [3, 4]
    }
    
    func testTableItemIndexPath()
    {
        storage.addItems([1, 2, 3])
        storage.addItems([4, 5, 6], toSection: 1)
        storage.addItems([7, 8, 9], toSection: 2)
        
        let indexPathArray = storage.indexPathArray(forItems: [1, 5, 9])
        expect(indexPathArray) == [indexPath(0, 0), indexPath(1, 1), indexPath(2, 2)]
    }
    
    func testUpdateWithoutAnimations() {
        storage.defersDatasourceUpdates = true
        storage.updateWithoutAnimations {
            storage.addItems([1,2])
        }
        expect((self.storage.items(inSection: 0) ?? []).compactMap { $0 as? Int } ) == [1,2]
        
        storage.updateWithoutAnimations {
            storage.addItems([3,4])
            storage.addItems([5,6])
        }
        expect((self.storage.items(inSection: 0) ?? []).compactMap { $0 as? Int }) == [1,2,3,4,5,6]
    }
    
    func testEmptySection()
    {
        expect(self.storage.section(atIndex: 0)).to(beNil())
    }
    
    func testNilEmptySectionItems()
    {
        expect(self.storage.items(inSection: 0)).to(beNil())
    }
    
    func testRemoveAllItems()
    {
        let storageNeedsReloading = StorageUpdatingInstance()
        storage.delegate = storageNeedsReloading
        storage.addItems([12, 3, 5, 6])
        
        expect(storageNeedsReloading.storageNeedsReloadingCalled).to(beFalse())
        storage.removeAllItems()
        expect(storageNeedsReloading.storageNeedsReloadingCalled).to(beTrue())
        expect(self.storage.section(atIndex: 0)?.items.count) == 0
    }
    
    func testSectionModelIsAwareOfItsLocation() {
        storage.addItem(3)
        let section = storage.section(atIndex: 0)! as SectionModel
        expect(section.currentSectionIndex) == 0
    }
}
