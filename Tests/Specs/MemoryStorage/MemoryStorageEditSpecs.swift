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
        
        
        try! storage.insertItem(1, to: storage.indexPath(forItem: 6)!)
        
        var update = StorageUpdate()
        update.insertedRowIndexPaths = [indexPath(2,0)]
        
        expect(self.delegate.update) == update
        
        
        try! storage.insertItem(3, to: storage.indexPath(forItem: 5)!)
        
        update = StorageUpdate()
        update.insertedRowIndexPaths = [indexPath(0, 1)]
        
        expect(self.delegate.update) == update
    }
    
    func testSetItems() {
        storage.addItems([1,2,3])
        storage.setItems([4,5,6])
        
        expect(self.storage.section(atIndex: 0)?.items.map { $0 as! Int} ) == [4,5,6]
    }
    
    func testSetSectionSupplementariesModel()
    {
        storage.configureForTableViewUsage()
        storage.setSectionHeaderModel(1, forSection: 0)
        storage.setSectionFooterModel(2, forSection: 1)
        expect(self.storage.headerModel(forSection: 0) as? Int) == 1
        expect(self.storage.footerModel(forSection: 1) as? Int) == 2
    }
    
    func testInsertionOfStructs()
    {
        storage.addItems([2,4,6], toSection: 0)
        
        try! storage.insertItem(1, to: indexPath(0, 0))
        
        expect(self.storage.item(at: indexPath(0, 0)) as? Int) == 1
        expect(self.storage.item(at: indexPath(1, 0)) as? Int) == 2
    }
    
    func testInsertionThrows()
    {
        do {
          try storage.insertItem(1, to: indexPath(1, 0))
        }
        catch MemoryStorageErrors.Insertion.indexPathTooBig {
            
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
        try! storage.replaceItem(4, with: 5)
        
        var update = StorageUpdate()
        update.updatedRowIndexPaths = [indexPath(1, 0)]
        
        expect(self.delegate.update) == update
    }
    
    func testShouldReplaceRowsThrows()
    {
        do {
            try storage.replaceItem(1, with: "foo")
        }
        catch MemoryStorageErrors.Replacement.itemNotFound
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
        catch MemoryStorageErrors.Removal.itemNotFound
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
        
        storage.removeItems(at: [indexPath(0, 0)])
        
        var update = StorageUpdate()
        update.deletedRowIndexPaths = [indexPath(0, 0)]
        
        expect(self.delegate.update) == update
        
        storage.removeItems(at: [indexPath(0, 1)])
        
        update.deletedRowIndexPaths = [indexPath(0, 1)]
        
        expect(self.delegate.update) == update
    }
    
    func testShouldRemoveItemsAtIndexPaths()
    {
        storage.addItems([2,4,6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        storage.removeItems(at: [indexPath(0, 0),indexPath(0, 1)])
        
        var update = StorageUpdate()
        update.deletedRowIndexPaths = [indexPath(0, 1),indexPath(0, 0)]
        
        expect(self.delegate.update) == update
    }
    
    func testShouldNotCrashWhenRemovingNonExistingItem()
    {
        storage.addItems([2,4,6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        storage.removeItems(at: [indexPath(5, 0), indexPath(2, 1)])
    }
    
    func testShouldRemoveItems()
    {
        storage.addItems([1,3], toSection: 0)
        storage.addItems([2,4], toSection: 1)
        
        var update = StorageUpdate()
        update.deletedRowIndexPaths = [indexPath(0, 0),indexPath(1, 1),indexPath(1, 0)]
    }
    
    func testShouldDeleteSectionsEvenIfThereAreNone()
    {
        storage.deleteSections(IndexSet(integer: 0))
    }
    
    func testShouldDeleteSections()
    {
        storage.addItem(1, toSection: 0)
        storage.addItem(2, toSection: 1)
        storage.addItem(3, toSection: 2)
        
        storage.deleteSections(IndexSet(integer: 1))
        
        var update = StorageUpdate()
        update.deletedSectionIndexes.insert(1)
        
        expect(self.delegate.update) == update
    }
    
    func testShouldDeleteMultipleSections() {
        storage.addItem(1, toSection: 0)
        storage.addItem(2, toSection: 1)
        storage.addItem(3, toSection: 2)
        storage.addItem(4, toSection: 3)
        
        let set = NSMutableIndexSet(index: 1)
        set.add(3)
        storage.deleteSections(set as IndexSet)
        
        var update = StorageUpdate()
        update.deletedSectionIndexes.insert(1)
        update.deletedSectionIndexes.insert(3)
        
        expect(self.delegate.update) == update
        expect(self.storage.sections.count) == 2
    }
    
    func testShouldSafelySetAndRetrieveSupplementaryModel()
    {
        let section = SectionModel()
        section.setSupplementaryModel("foo", forKind: "bar", atIndex: 0)
        
        expect(section.supplementaryModel(ofKind: "bar", atIndex: 0) as? String).to(equal("foo"))
    }
    
    func testShouldNotCallDelegateForOptionalMethod()
    {
        _ = storage.supplementaryModel(ofKind: "foo", forSectionAt: indexPath(0, 1))
    }
    
    func testShouldBeAbleToRetrieveSupplementaryModelViaStorageMethod()
    {
        storage.addItem(1)
        storage.section(atIndex: 0)?.setSupplementaryModel("foo", forKind: "bar", atIndex: 0)
        expect(self.storage.supplementaryModel(ofKind: "bar", forSectionAt: indexPath(0, 0)) as? String).to(equal("foo"))
    }
    
    func testShouldSetSupplementaries()
    {
        let kind = "foo"
        storage.setSupplementaries([[0: 1], [0: 2],[0: 3]], forKind: kind)
        
        expect(self.storage.section(atIndex: 0)?.supplementaryModel(ofKind: kind, atIndex: 0) as? Int) == 1
        expect(self.storage.section(atIndex: 1)?.supplementaryModel(ofKind: kind, atIndex: 0) as? Int) == 2
        expect(self.storage.section(atIndex: 2)?.supplementaryModel(ofKind: kind, atIndex: 0) as? Int) == 3
    }
    
    func testShouldNilOutSupplementaries()
    {
        let kind = "foo"
        storage.setSupplementaries([[0: 1], [0: 2],[0: 3]], forKind: kind)
        
        storage.setSupplementaries([[Int:Int]]().flatMap { $0 }, forKind: kind)
        
        expect(self.storage.section(atIndex: 0)?.supplementaryModel(ofKind: kind, atIndex: 0) as? Int).to(beNil())
        expect(self.storage.section(atIndex: 1)?.supplementaryModel(ofKind: kind, atIndex: 0) as? Int).to(beNil())
        expect(self.storage.section(atIndex: 2)?.supplementaryModel(ofKind: kind, atIndex: 0) as? Int).to(beNil())
    }
    
    func testShouldGetItemCorrectly()
    {
        storage.addItem(1, toSection: 0)
        storage.addItem(2, toSection: 1)
        storage.addItem(3, toSection: 2)
        
        var model = storage.item(at: indexPath(0, 1))
        
        expect(model as? Int) == 2
        
        model = storage.item(at: indexPath(0, 2))
        
        expect(model as? Int) == 3
    }
    
    func testShouldReturnNilForNotExistingIndexPath()
    {
        let model = storage.item(at: indexPath(5, 6))
        expect(model as? Int).to(beNil())
    }
    
    func testShouldReturnNilForNotExistingIndexPathInExistingSection()
    {
        storage.addItem(1, toSection: 0)
        let model = storage.item(at: indexPath(1, 0))
        
        expect(model as? Int).to(beNil())
    }
    
    func testMovingSections()
    {
        storage.addItems([1])
        storage.addItems([1,1], toSection: 1)
        storage.addItems([1,1,1], toSection: 2)
        
        storage.moveSection(0, toSection: 1)
        expect(self.storage.section(atIndex: 0)?.items.count) == 2
        expect(self.storage.section(atIndex: 1)?.items.count) == 1
        expect(self.delegate.update?.movedSectionIndexes.elementsEqual([[0,1]], by: { $0 == $1 })).to(beTrue())
    }
    
    func testMovingItem()
    {
        storage.addItems([1])
        storage.addItems([2,3], toSection: 1)
        storage.addItems([4,5,6], toSection: 2)
        
        storage.moveItem(at: indexPath(0, 0), to: indexPath(1, 1))
        
        expect(self.storage.item(at: indexPath(1, 1)) as? Int) == 1
        
        expect(self.delegate.update?.movedRowIndexPaths.elementsEqual([[indexPath(0, 0), indexPath(1,1)]], by: { $0 == $1 })).to(beTrue())
    }
    
    func testMovingItemIntoNonExistingSection()
    {
        storage.addItems([1])
        
        storage.moveItem(at: indexPath(0, 0), to: indexPath(0, 1))
        
        expect(self.storage.item(at: indexPath(0, 1)) as? Int) == 1
        
        expect(self.delegate.update?.insertedSectionIndexes) == Set(arrayLiteral: 1)
        expect(self.delegate.update?.movedRowIndexPaths.elementsEqual([[indexPath(0, 0), indexPath(0,1)]], by: { $0 == $1 })).to(beTrue())
    }
    
    func testMovingNotExistingIndexPath()
    {
        storage.moveItem(at: indexPath(0, 0), to: indexPath(0, 1))
    }
    
    func testMovingItemIntoTooBigSection()
    {
        storage.addItem(1)
        
        storage.moveItem(at: indexPath(0, 0), to: indexPath(5, 0))
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
        expect(self.storage.headerModel(forSection: 0) as? Int) == 1
        expect(self.storage.headerModel(forSection: 1) as? Int) == 2
        expect(self.storage.headerModel(forSection: 2) as? Int) == 3
    }
    
    func testSectionFooterModelsSetter()
    {
        storage.setSectionFooterModels([1,2,3])
        
        expect(self.storage.sections.count) == 3
        expect(self.storage.footerModel(forSection: 0) as? Int) == 1
        expect(self.storage.footerModel(forSection: 1) as? Int) == 2
        expect(self.storage.footerModel(forSection: 2) as? Int) == 3
    }
    
    func testNillifySectionHeaders()
    {
        storage.setSectionHeaderModels([1,2,3])
        storage.setSectionHeaderModels([Int]())
        
        expect(self.storage.headerModel(forSection: 1) as? Int).to(beNil())
    }
    
    func testNillifySectionFooters()
    {
        storage.setSectionFooterModels([1,2,3])
        storage.setSectionFooterModels([Int]())
        
        expect(self.storage.footerModel(forSection: 1) as? Int).to(beNil())
    }
    
    func testInsertingSection()
    {
        let section = SectionModel()
        section.setSupplementaryModel("Foo", forKind: UICollectionElementKindSectionHeader, atIndex: 0)
        section.setSupplementaryModel("Bar", forKind: UICollectionElementKindSectionFooter, atIndex: 0)
        section.setItems([1,2,3])
        storage.insertSection(section, atIndex: 0)
        
        expect(self.updatesObserver.update?.insertedSectionIndexes) == Set([0])
        expect(self.updatesObserver.update?.insertedRowIndexPaths) == Set([indexPath(0, 0),indexPath(1, 0),indexPath(2, 0)])
        
        expect(self.storage.section(atIndex: 0)?.supplementaryModel(ofKind: UICollectionElementKindSectionHeader, atIndex: 0) as? String) == "Foo"
        expect(self.storage.section(atIndex: 0)?.supplementaryModel(ofKind: UICollectionElementKindSectionFooter, atIndex: 0) as? String) == "Bar"
        expect(self.storage.section(atIndex: 0)?.items.first as? Int) == 1
        expect(self.storage.section(atIndex: 0)?.items.last as? Int) == 3
    }
    
    func testInsertingSectionAtWrongIndexPathDoesNotWork()
    {
        let section = SectionModel()
        
        storage.insertSection(section, atIndex: 1)
    }
    
    func testInsertionAtFirstIndexPath()
    {
        do {
            try storage.insertItem(1, to: indexPath(0, 0))
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
        storage.setSection(section, forSection: 1)
        
        expect(self.storage.section(atIndex: 1)?.items(ofType: Int.self)) == [7,8,9]
    }
    
    func testInsertItemsAtIndexPathsSuccessfullyInsertsItems() {
        try! storage.insertItems([1,2,3], to: [indexPath(0, 0), indexPath(1, 0), indexPath(2, 0)])
        
        expect(self.storage.items(inSection: 0)?.count) == 3
        expect(self.storage.section(atIndex: 0)?.items(ofType: Int.self)) == [1,2,3]
    }
    
    func testWrongCountsRaisesException() {
        do {
            try storage.insertItems([1,2], to: [indexPath(0, 0)])
        }
        catch MemoryStorageErrors.BatchInsertion.itemsCountMismatch {
            return
        }
        catch {
            XCTFail()
        }
        XCTFail()
    }
    
    func testInsertItemsAtIndexPathsDoesNotTryToInsertItemsPastItemsCount() {
        try! storage.insertItems([1,2,3], to: [indexPath(0, 0), indexPath(1, 0),indexPath(3, 0)])
        
        expect(self.storage.items(inSection: 0)?.count) == 2
        expect(self.storage.section(atIndex: 0)?.items(ofType: Int.self)) == [1,2]
    }
}
