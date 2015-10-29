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
        
        
        try! storage.insertItem(1, toIndexPath: storage.indexPathForItem(6)!)
        
        var update = StorageUpdate()
        update.insertedRowIndexPaths = [indexPath(2,0)]
        
        expect(self.delegate.update) == update
        
        
        try! storage.insertItem(3, toIndexPath: storage.indexPathForItem(5)!)
        
        update = StorageUpdate()
        update.insertedRowIndexPaths = [indexPath(0, 1)]
        
        expect(self.delegate.update) == update
    }
    
    func testSetItems() {
        storage.addItems([1,2,3])
        storage.setItems([4,5,6])
        
        expect(self.storage.sectionAtIndex(0)?.items.map { $0 as! Int} ) == [4,5,6]
    }
    
    func testSetSectionSupplementariesModel()
    {
        storage.configureForTableViewUsage()
        storage.setSectionHeaderModel(1, forSectionIndex: 0)
        storage.setSectionFooterModel(2, forSectionIndex: 1)
        expect(self.storage.headerModelForSectionIndex(0) as? Int) == 1
        expect(self.storage.footerModelForSectionIndex(1) as? Int) == 2
    }
    
    func testInsertionOfStructs()
    {
        storage.addItems([2,4,6], toSection: 0)
        
        try! storage.insertItem(1, toIndexPath: indexPath(0, 0))
        
        expect(self.storage.itemAtIndexPath(indexPath(0, 0)) as? Int) == 1
        expect(self.storage.itemAtIndexPath(indexPath(1, 0)) as? Int) == 2
    }
    
    func testInsertionThrows()
    {
        do {
          try storage.insertItem(1, toIndexPath: indexPath(1, 0))
        }
        catch MemoryStorageErrors.Insertion.IndexPathTooBig {
            
        }
        catch {
            XCTFail()
        }
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
        try! storage.replaceItem(4, replacingItem: 5)
        
        var update = StorageUpdate()
        update.updatedRowIndexPaths = [indexPath(1, 0)]
        
        expect(self.delegate.update) == update
    }
    
    func testShouldReplaceRowsThrows()
    {
        do {
            try storage.replaceItem(1, replacingItem: "foo")
        }
        catch MemoryStorageErrors.Replacement.ItemNotFound
        {
            
        }
        catch {
            XCTFail()
        }
    }
    
    func testShouldRemoveItem()
    {
        storage.addItems([2,4,6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        try! storage.removeItem(2)
        
        var update = StorageUpdate()
        update.deletedRowIndexPaths = [indexPath(0, 0)]
        
        expect(self.delegate.update) == update
        
        try! storage.removeItem(5)
        update.deletedRowIndexPaths = [indexPath(0, 1)]
        
        expect(self.delegate.update) == update
    }
    
    func testShouldRemoveItemThrows()
    {
        do {
            try storage.removeItem(3)
        }
        catch MemoryStorageErrors.Removal.ItemNotFound
        {
            
        }
        catch {
            XCTFail()
        }
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
        
        storage.removeItemsAtIndexPaths([indexPath(5, 0), indexPath(2, 1)])
    }
    
    func testShouldRemoveItems()
    {
        storage.addItems([1,3], toSection: 0)
        storage.addItems([2,4], toSection: 1)
        
        var update = StorageUpdate()
        update.deletedRowIndexPaths = [indexPath(0, 0),indexPath(1, 1),indexPath(1, 0)]
    }
    
    func testShouldDeleteSections()
    {
        storage.addItem(1, toSection: 0)
        storage.addItem(2, toSection: 1)
        storage.addItem(3, toSection: 2)
        
        storage.deleteSections(NSIndexSet(index: 1))
        
        var update = StorageUpdate()
        update.deletedSectionIndexes.insert(1)
        
        expect(self.delegate.update) == update
    }
    
    func testShouldSafelySetAndRetrieveSupplementaryModel()
    {
        let section = SectionModel()
        section.setSupplementaryModel("foo", forKind: "bar")
        
        expect(section.supplementaryModelOfKind("bar") as? String).to(equal("foo"))
    }
    
    func testShouldNotCallDelegateForOptionalMethod()
    {
        storage.supplementaryModelOfKind("foo", sectionIndex: 1)
    }
    
    func testShouldBeAbleToRetrieveSupplementaryModelViaStorageMethod()
    {
        storage.addItem(1)
        storage.sectionAtIndex(0)?.setSupplementaryModel("foo", forKind: "bar")
        expect(self.storage.supplementaryModelOfKind("bar", sectionIndex: 0) as? String).to(equal("foo"))
    }
    
    func testShouldSetSupplementaries()
    {
        let kind = "foo"
        storage.setSupplementaries([1,2,3], forKind: kind)
        
        expect(self.storage.sectionAtIndex(0)?.supplementaryModelOfKind(kind) as? Int) == 1
        expect(self.storage.sectionAtIndex(1)?.supplementaryModelOfKind(kind) as? Int) == 2
        expect(self.storage.sectionAtIndex(2)?.supplementaryModelOfKind(kind) as? Int) == 3
    }
    
    func testShouldNilOutSupplementaries()
    {
        let kind = "foo"
        storage.setSupplementaries([1,2,3], forKind: kind)
        
        storage.setSupplementaries([Int](), forKind: kind)
        
        expect(self.storage.sectionAtIndex(0)?.supplementaryModelOfKind(kind) as? Int).to(beNil())
        expect(self.storage.sectionAtIndex(1)?.supplementaryModelOfKind(kind) as? Int).to(beNil())
        expect(self.storage.sectionAtIndex(2)?.supplementaryModelOfKind(kind) as? Int).to(beNil())
    }
    
    func testShouldGetItemCorrectly()
    {
        storage.addItem(1, toSection: 0)
        storage.addItem(2, toSection: 1)
        storage.addItem(3, toSection: 2)
        
        var model = storage.itemAtIndexPath(indexPath(0, 1))
        
        expect(model as? Int) == 2
        
        model = storage.itemAtIndexPath(indexPath(0, 2))
        
        expect(model as? Int) == 3
    }
    
    func testShouldReturnNilForNotExistingIndexPath()
    {
        let model = storage.itemAtIndexPath(indexPath(5, 6))
        expect(model as? Int).to(beNil())
    }
    
    func testShouldReturnNilForNotExistingIndexPathInExistingSection()
    {
        storage.addItem(1, toSection: 0)
        let model = storage.itemAtIndexPath(indexPath(1, 0))
        
        expect(model as? Int).to(beNil())
    }
    
    func testMovingSections()
    {
        storage.addItems([1])
        storage.addItems([1,1], toSection: 1)
        storage.addItems([1,1,1], toSection: 2)
        
        storage.moveSection(0, toSection: 1)
        expect(self.storage.sectionAtIndex(0)?.items.count) == 2
        expect(self.storage.sectionAtIndex(1)?.items.count) == 1
        expect(self.delegate.update?.movedSectionIndexes) == [[0,1]]
    }
    
    func testMovingItem()
    {
        storage.addItems([1])
        storage.addItems([2,3], toSection: 1)
        storage.addItems([4,5,6], toSection: 2)
        
        storage.moveItemAtIndexPath(indexPath(0, 0), toIndexPath: indexPath(1, 1))
        
        expect(self.storage.itemAtIndexPath(indexPath(1, 1)) as? Int) == 1
        
        expect(self.delegate.update?.movedRowIndexPaths) == [[indexPath(0, 0), indexPath(1,1)]]
    }
    
    func testMovingItemIntoNonExistingSection()
    {
        storage.addItems([1])
        
        storage.moveItemAtIndexPath(indexPath(0, 0), toIndexPath: indexPath(0, 1))
        
        expect(self.storage.itemAtIndexPath(indexPath(0, 1)) as? Int) == 1
        
        expect(self.delegate.update?.insertedSectionIndexes) == Set(arrayLiteral: 1)
        expect(self.delegate.update?.movedRowIndexPaths) == [[indexPath(0, 0), indexPath(0,1)]]
    }
    
    func testMovingNotExistingIndexPath()
    {
        storage.moveItemAtIndexPath(indexPath(0, 0), toIndexPath: indexPath(0, 1))
    }
    
    func testMovingItemIntoTooBigSection()
    {
        storage.addItem(1)
        
        storage.moveItemAtIndexPath(indexPath(0, 0), toIndexPath: indexPath(5, 0))
    }
}

class SectionSupplementariesTestCase : XCTestCase
{
    var storage : MemoryStorage!
    var updatesObserver : StorageUpdatesObserver!
    override func setUp() {
        super.setUp()
        self.storage = MemoryStorage()
        self.storage.configureForTableViewUsage()
        updatesObserver = StorageUpdatesObserver()
        storage.delegate = updatesObserver
    }
    
    func testSectionHeaderModelsSetter()
    {
        storage.setSectionHeaderModels([1,2,3])
        
        expect(self.storage.sections.count) == 3
        expect(self.storage.headerModelForSectionIndex(0) as? Int) == 1
        expect(self.storage.headerModelForSectionIndex(1) as? Int) == 2
        expect(self.storage.headerModelForSectionIndex(2) as? Int) == 3
    }
    
    func testSectionFooterModelsSetter()
    {
        storage.setSectionFooterModels([1,2,3])
        
        expect(self.storage.sections.count) == 3
        expect(self.storage.footerModelForSectionIndex(0) as? Int) == 1
        expect(self.storage.footerModelForSectionIndex(1) as? Int) == 2
        expect(self.storage.footerModelForSectionIndex(2) as? Int) == 3
    }
    
    func testNillifySectionHeaders()
    {
        storage.setSectionHeaderModels([1,2,3])
        storage.setSectionHeaderModels([Int]())
        
        expect(self.storage.headerModelForSectionIndex(1) as? Int).to(beNil())
    }
    
    func testNillifySectionFooters()
    {
        storage.setSectionFooterModels([1,2,3])
        storage.setSectionFooterModels([Int]())
        
        expect(self.storage.footerModelForSectionIndex(1) as? Int).to(beNil())
    }
    
    func testInsertingSection()
    {
        let section = SectionModel()
        section.setSupplementaryModel("Foo", forKind: UICollectionElementKindSectionHeader)
        section.setSupplementaryModel("Bar", forKind: UICollectionElementKindSectionFooter)
        section.setItems([1,2,3])
        storage.insertSection(section, atIndex: 0)
        
        expect(self.updatesObserver.update?.insertedSectionIndexes) == Set([0])
        expect(self.updatesObserver.update?.insertedRowIndexPaths) == Set([indexPath(0, 0),indexPath(1, 0),indexPath(2, 0)])
        
        expect(self.storage.sectionAtIndex(0)?.supplementaryModelOfKind(UICollectionElementKindSectionHeader) as? String) == "Foo"
        expect(self.storage.sectionAtIndex(0)?.supplementaryModelOfKind(UICollectionElementKindSectionFooter) as? String) == "Bar"
        expect(self.storage.sectionAtIndex(0)?.items.first as? Int) == 1
        expect(self.storage.sectionAtIndex(0)?.items.last as? Int) == 3
    }
    
    func testInsertingSectionAtWrongIndexPathDoesNotWork()
    {
        let section = SectionModel()
        
        storage.insertSection(section, atIndex: 1)
    }
    
    func testInsertionAtFirstIndexPath()
    {
        do {
            try storage.insertItem(1, toIndexPath: indexPath(0, 0))
        }
        catch _ {
            XCTFail()
        }
    }
    
    func testSetSectionMethod() {
        storage.addItems([1,2,3], toSection: 0)
        storage.addItems([4,5,6], toSection: 1)
        
        let section = SectionModel()
        section.setItems([7,8,9])
        storage.setSection(section, forSectionIndex: 1)
        
        expect(self.storage.sectionAtIndex(1)?.itemsOfType(Int)) == [7,8,9]
    }
}
