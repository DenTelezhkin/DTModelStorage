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
        
        storage.insertItem(1, toIndexPath: storage.indexPathForItem(6)!)
        
        var update = StorageUpdate()
        update.insertedRowIndexPaths = [indexPath(2,0)]
        
        expect(self.delegate.update) == update
        
        
        storage.insertItem(3, toIndexPath: storage.indexPathForItem(5)!)
        
        update = StorageUpdate()
        update.insertedRowIndexPaths = [indexPath(0, 1)]
        
        expect(self.delegate.update) == update
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
        storage.replaceItem(4, replacingItem: 5)
        
        var update = StorageUpdate()
        update.updatedRowIndexPaths = [indexPath(1, 0)]
        
        expect(self.delegate.update) == update
    }
    
    func testShouldRemoveItem()
    {
        storage.addItems([2,4,6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        storage.removeItem(2)
        
        var update = StorageUpdate()
        update.deletedRowIndexPaths = [indexPath(0, 0)]
        
        expect(self.delegate.update) == update
        
        storage.removeItem(5)
        update.deletedRowIndexPaths = [indexPath(0, 1)]
        
        expect(self.delegate.update) == update
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
        
        // MARK : TODO - check for error in Swift 2
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
        update.deletedSectionIndexes.addIndex(1)
        
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
        let section = storage.sectionAtIndex(0)
        section.setSupplementaryModel("foo", forKind: "bar")
        expect(self.storage.supplementaryModelOfKind("bar", sectionIndex: 0) as? String).to(equal("foo"))
    }
    
    func testShouldSetSupplementaries()
    {
        let kind = "foo"
        storage.setSupplementaries([1,2,3], forKind: kind)
        
        expect(self.storage.sectionAtIndex(0).supplementaryModelOfKind(kind) as? Int) == 1
        expect(self.storage.sectionAtIndex(1).supplementaryModelOfKind(kind) as? Int) == 2
        expect(self.storage.sectionAtIndex(2).supplementaryModelOfKind(kind) as? Int) == 3
    }
    
    func testShouldNilOutSupplementaries()
    {
        let kind = "foo"
        storage.setSupplementaries([1,2,3], forKind: kind)
        
        storage.setSupplementaries([], forKind: kind)
        
        expect(self.storage.sectionAtIndex(0).supplementaryModelOfKind(kind) as? Int).to(beNil())
        expect(self.storage.sectionAtIndex(1).supplementaryModelOfKind(kind) as? Int).to(beNil())
        expect(self.storage.sectionAtIndex(2).supplementaryModelOfKind(kind) as? Int).to(beNil())
    }
    
    func testShouldGetItemCorrectly()
    {
        storage.addItem(1, toSection: 0)
        storage.addItem(2, toSection: 1)
        storage.addItem(3, toSection: 2)
        
        var model = storage.objectAtIndexPath(indexPath(0, 1))
        
        expect(model as? Int) == 2
        
        model = storage.objectAtIndexPath(indexPath(0, 2))
        
        expect(model as? Int) == 3
    }
    
    func testShouldReturnNilForNotExistingIndexPath()
    {
        let model = storage.objectAtIndexPath(indexPath(5, 6))
        expect(model as? Int).to(beNil())
    }
    
    func testShouldReturnNilForNotExistingIndexPathInExistingSection()
    {
        storage.addItem(1, toSection: 0)
        let model = storage.objectAtIndexPath(indexPath(1, 0))
        
        expect(model as? Int).to(beNil())
    }
    
}

class SectionSupplementariesTestCase : XCTestCase
{
    var storage : MemoryStorage!
    
    override func setUp() {
        super.setUp()
        self.storage = MemoryStorage()
        self.storage.supplementaryHeaderKind = DTModelStorage.DTTableViewElementSectionHeader
        self.storage.supplementaryFooterKind = DTModelStorage.DTTableViewElementSectionFooter
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
        storage.setSectionHeaderModels([])
        
        expect(self.storage.headerModelForSectionIndex(1) as? Int).to(beNil())
    }
    
    func testNillifySectionFooters()
    {
        storage.setSectionFooterModels([1,2,3])
        storage.setSectionFooterModels([])
        
        expect(self.storage.footerModelForSectionIndex(1) as? Int).to(beNil())
    }
}
