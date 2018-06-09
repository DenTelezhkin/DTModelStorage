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
        storage.defersDatasourceUpdates = false
    }
    
    func testShouldInsertItems()
    {
        storage.addItems([2, 4, 6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        
        try! storage.insertItem(1, to: storage.indexPath(forItem: 6)!)
        
        var update = StorageUpdate()
        update.objectChanges.append((.insert, [indexPath(2, 0)]))
        
        expect(self.delegate.update) == update
        
        
        try! storage.insertItem(3, to: storage.indexPath(forItem: 5)!)
        
        update = StorageUpdate()
        update.objectChanges.append((.insert, [indexPath(0, 1)]))
        
        expect(self.delegate.update) == update
    }
#if swift(>=4.1)
    func testBatchInsertionWithDifferentItemCountsTriggersAnomaly() {
        let exp = expectation(description: "Insert with different counts")
        let anomaly = MemoryStorageAnomaly.batchInsertionItemCountMismatch(itemsCount: 1, indexPathsCount: 2)
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        try? storage.insertItems([1], to: [indexPath(0, 0), indexPath(1, 0)])
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to insert batch of items, items count: 1, indexPaths count: 2")
    }
#endif
    
    func testSetItems() {
        storage.addItems([1, 2, 3])
        storage.setItems([4, 5, 6])
        
        expect(self.storage.section(atIndex: 0)?.items.map { $0 as! Int }) == [4, 5, 6]
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
        storage.addItems([2, 4, 6], toSection: 0)
        
        try! storage.insertItem(1, to: indexPath(0, 0))
        
        expect(self.storage.item(at: indexPath(0, 0)) as? Int) == 1
        expect(self.storage.item(at: indexPath(1, 0)) as? Int) == 2
    }
    
    func testInsertionThrows()
    {
        do {
          try storage.insertItem(1, to: indexPath(1, 0))
        } catch let error as MemoryStorageError  {
            guard case MemoryStorageError.insertionFailed(reason: _) = error else {
                XCTFail()
                return
            }
        } catch {
            XCTFail()
        }
    }
    
#if swift(>=4.1)
    func testInsertingIntoTooLargeIndexPathLeadsToAnomaly() {
        let exp = expectation(description: "Insert into not that large section")
        let anomaly = MemoryStorageAnomaly.insertionIndexPathTooBig(indexPath: indexPath(10, 1), countOfElementsInSection: 5)
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        storage.addItems([1,2,3])
        storage.addItems([4,5,6,7,8], toSection: 1)
        try? storage.insertItem(7, to: indexPath(10, 1))
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to insert item into IndexPath: [1, 10], count of elements in the section: 5")
    }
#endif

    func testShouldReloadRows()
    {
        storage.addItems([2, 4, 6])
        
        storage.reloadItem(4)
        
        let update = StorageUpdate()
        update.objectChanges.append((.update, [indexPath(1, 0)]))
        
        expect(self.delegate.update) == update
    }
    
    func testShouldReplaceRows()
    {
        storage.addItems([2, 4, 6])
        try! storage.replaceItem(4, with: 5)
        
        let update = StorageUpdate()
        update.objectChanges.append((.update, [indexPath(1, 0)]))
        
        expect(self.delegate.update) == update
    }
    
    func testShouldReplaceRowsThrows()
    {
        do {
            try storage.replaceItem(1, with: "foo")
        } catch let error as MemoryStorageError  {
            guard case MemoryStorageError.searchFailed(reason: _) = error else {
                XCTFail()
                return
            }
        } catch {
            XCTFail()
        }
    }
#if swift(>=4.1)
    func testReplacingItemLeadsToAnomalyWhenNotFound() {
        let exp = expectation(description: "Replacing unknown item")
        let anomaly = MemoryStorageAnomaly.replaceItemFailedItemNotFound(itemDescription: "3")
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        try? storage.replaceItem(3, with: "Foo")
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to find item for replacement: 3")
    }
#endif
    
    func testShouldRemoveItem()
    {
        storage.addItems([2, 4, 6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        try! storage.removeItem(2)
        
        let update = StorageUpdate()
        update.objectChanges.append((.delete, [indexPath(0, 0)]))
        
        expect(self.delegate.update) == update
        
        try! storage.removeItem(5)
        update.objectChanges = [(.delete, [indexPath(0, 1)])]
        
        expect(self.delegate.update) == update
    }
    
    func testShouldRemoveItemThrows()
    {
        do {
            try storage.removeItem(3)
        } catch let error as MemoryStorageError  {
            guard case MemoryStorageError.searchFailed(reason: _) = error else {
                XCTFail()
                return
            }
        } catch {
            XCTFail()
        }
    }
    
#if swift(>=4.1)
    func testRemovingItemLeadsToAnomalyWhenNotFound() {
        let exp = expectation(description: "Removing unknown item")
        let anomaly = MemoryStorageAnomaly.removeItemFailedItemNotFound(itemDescription: "3")
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        try? storage.removeItem(3)
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to find item for removal: 3")
    }
#endif
    
    
    func testShouldRemoveItemAtIndexPath()
    {
        storage.addItems([2, 4, 6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        storage.removeItems(at: [indexPath(0, 0)])
        
        let update = StorageUpdate()
        update.objectChanges.append((.delete, [indexPath(0, 0)]))
        
        expect(self.delegate.update) == update
        
        storage.removeItems(at: [indexPath(0, 1)])
        update.objectChanges = [(.delete, [indexPath(0, 1)])]
        
        expect(self.delegate.update) == update
    }
    
    func testShouldRemoveItemsAtIndexPaths()
    {
        storage.addItems([2, 4, 6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        storage.removeItems(at: [indexPath(0, 0), indexPath(0, 1)])
        
        let update = StorageUpdate()
        update.objectChanges.append((.delete, [indexPath(0, 1)]))
        update.objectChanges.append((.delete, [indexPath(0, 0)]))
        
        expect(self.delegate.update) == update
    }
    
    func testShouldNotCrashWhenRemovingNonExistingItem()
    {
        storage.addItems([2, 4, 6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        storage.removeItems(at: [indexPath(5, 0), indexPath(2, 1)])
    }
    
    func testShouldRemoveItems()
    {
        storage.addItems([1, 3], toSection: 0)
        storage.addItems([2, 4], toSection: 1)
        
        let update = StorageUpdate()
        update.objectChanges.append((.delete, [indexPath(0, 0)]))
        update.objectChanges.append((.delete, [indexPath(1, 1)]))
        update.objectChanges.append((.delete, [indexPath(1, 0)]))
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
        
        let update = StorageUpdate()
        update.sectionChanges.append((.delete, [1]))
        
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
        
        let update = StorageUpdate()
        update.sectionChanges.append((.delete, [1]))
        update.sectionChanges.append((.delete, [3]))
        
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
        storage.setSupplementaries([[0: 1], [0: 2], [0: 3]], forKind: kind)
        
        expect(self.storage.section(atIndex: 0)?.supplementaryModel(ofKind: kind, atIndex: 0) as? Int) == 1
        expect(self.storage.section(atIndex: 1)?.supplementaryModel(ofKind: kind, atIndex: 0) as? Int) == 2
        expect(self.storage.section(atIndex: 2)?.supplementaryModel(ofKind: kind, atIndex: 0) as? Int) == 3
    }
    
    func testShouldNilOutSupplementaries()
    {
        let kind = "foo"
        storage.setSupplementaries([[0: 1], [0: 2], [0: 3]], forKind: kind)
        
        storage.setSupplementaries([[Int:Int]]().compactMap { $0 }, forKind: kind)
        
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
        storage.addItems([1, 1], toSection: 1)
        storage.addItems([1, 1, 1], toSection: 2)
        
        storage.moveSection(0, toSection: 1)
        expect(self.storage.section(atIndex: 0)?.items.count) == 2
        expect(self.storage.section(atIndex: 1)?.items.count) == 1
        let moves = delegate.update?.sectionChanges.filter { $0.0 == .move }
        expect(moves?.first?.1) == [0, 1]
    }
    
    func testMovingItem()
    {
        storage.addItems([1])
        storage.addItems([2, 3], toSection: 1)
        storage.addItems([4, 5, 6], toSection: 2)
        
        storage.moveItem(at: indexPath(0, 0), to: indexPath(1, 1))
        
        expect(self.storage.item(at: indexPath(1, 1)) as? Int) == 1
        
        let moves = delegate.update?.objectChanges.filter { $0.0 == .move }
        expect(moves?.first?.1) == [indexPath(0, 0), indexPath(1, 1)]
    }
    
    func testMovingItemIntoNonExistingSection()
    {
        storage.addItems([1])
        
        storage.moveItem(at: indexPath(0, 0), to: indexPath(0, 1))
        
        expect(self.storage.item(at: indexPath(0, 1)) as? Int) == 1
        
        expect(self.delegate.update?.sectionChanges.filter { $0.0 == .insert }.flatMap { $0.1 }) == [1]
        let moves = delegate.update?.objectChanges.filter { $0.0 == .move }
        expect(moves?.first?.1) == [indexPath(0, 0), indexPath(0, 1)]
    }
    
    func testMovingNotExistingIndexPath()
    {
        storage.moveItem(at: indexPath(0, 0), to: indexPath(0, 1))
    }
    
#if swift(>=4.1)
    func testMovingItemThatIsUnfindableLeadsToAnomaly() {
        let exp = expectation(description: "Moving unknown item")
        let anomaly = MemoryStorageAnomaly.moveItemFailedItemNotFound(indexPath: indexPath(0, 0))
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        storage.moveItem(at: indexPath(0, 0), to: indexPath(1, 0))
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to find item for moving at indexPath: [0, 0]")
    }
    
    func testMovingItemToIndexPathThatIsTooBigLeadsToAnomaly() {
        let exp = expectation(description: "Moving unknown item")
        let anomaly = MemoryStorageAnomaly.moveItemFailedIndexPathTooBig(indexPath: indexPath(1, 0), countOfElementsInSection: 0)
        storage.addItem(1)
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        storage.moveItem(at: indexPath(0, 0), to: indexPath(1, 0))
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to move item, destination indexPath is too big: [0, 1], number of items in section after removing source item: 0")
    }
    
    func testMovingForInvalidIndexPathsLeadsToAnomaly() {
        let exp = expectation(description: "Moving item with invalid indexPaths")
        let anomaly = MemoryStorageAnomaly.moveItemFailedInvalidIndexPaths(sourceIndexPath: indexPath(0, 0), destinationIndexPath: indexPath(3, 1), sourceElementsInSection: 1, destinationElementsInSection: 1)
        storage.addItem(1)
        storage.addItem(2, toSection: 1)
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        storage.moveItemWithoutAnimation(from: indexPath(0, 0), to: indexPath(3, 1))
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to move item, sourceIndexPath: [0, 0], destination indexPath: [1, 3], number of items in source section: 1, number of items in destination section after removing source item: 1")
    }

#endif
    
    func testMovingItemWithoutAnimationsActuallyUnderstandsSectionBounds() {
        storage.addItem(1)
        storage.moveItemWithoutAnimation(from: indexPath(0, 0), to: indexPath(1, 0))
    }
    
    func testMovingItemIntoTooBigSection()
    {
        storage.addItem(1)
        
        storage.moveItem(at: indexPath(0, 0), to: indexPath(5, 0))
    }
    
    func testSettingAllItemsInStorage() {
        storage.setItemsForAllSections([[1], [2], [3]])
        
        expect(self.storage.totalNumberOfItems) == 3
        expect(self.storage.sections.count) == 3
        expect(self.storage.item(at: indexPath(0, 0)) as? Int) == 1
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
        storage.defersDatasourceUpdates = false
    }
    
    func testSectionHeaderModelsSetter()
    {
        storage.setSectionHeaderModels([1, 2, 3])
        
        expect(self.storage.sections.count) == 3
        expect(self.storage.headerModel(forSection: 0) as? Int) == 1
        expect(self.storage.headerModel(forSection: 1) as? Int) == 2
        expect(self.storage.headerModel(forSection: 2) as? Int) == 3
    }
    
    func testSectionFooterModelsSetter()
    {
        storage.setSectionFooterModels([1, 2, 3])
        
        expect(self.storage.sections.count) == 3
        expect(self.storage.footerModel(forSection: 0) as? Int) == 1
        expect(self.storage.footerModel(forSection: 1) as? Int) == 2
        expect(self.storage.footerModel(forSection: 2) as? Int) == 3
    }
    
    func testNillifySectionHeaders()
    {
        storage.setSectionHeaderModels([1, 2, 3])
        storage.setSectionHeaderModels([Int]())
        
        expect(self.storage.headerModel(forSection: 1) as? Int).to(beNil())
    }
    
    func testNillifySectionFooters()
    {
        storage.setSectionFooterModels([1, 2, 3])
        storage.setSectionFooterModels([Int]())
        
        expect(self.storage.footerModel(forSection: 1) as? Int).to(beNil())
    }
    
    func testInsertingSection()
    {
        let section = SectionModel()
        section.setSupplementaryModel("Foo", forKind: DTCollectionViewElementSectionHeader, atIndex: 0)
        section.setSupplementaryModel("Bar", forKind: DTCollectionViewElementSectionFooter, atIndex: 0)
        section.setItems([1, 2, 3])
        storage.insertSection(section, atIndex: 0)
        
        expect(self.updatesObserver.update?.sectionChanges.filter { $0.0 == .insert }.flatMap { $0.1 }) == [0]
        expect(self.updatesObserver.update?.objectChanges.filter { $0.0 == .insert }.flatMap { $0.1 }) == [indexPath(0, 0), indexPath(1, 0), indexPath(2, 0)]
        
        expect(self.storage.section(atIndex: 0)?.supplementaryModel(ofKind: DTCollectionViewElementSectionHeader, atIndex: 0) as? String) == "Foo"
        expect(self.storage.section(atIndex: 0)?.supplementaryModel(ofKind: DTCollectionViewElementSectionFooter, atIndex: 0) as? String) == "Bar"
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
        } catch _ {
            XCTFail()
        }
    }
    
    func testSetSectionMethod() {
        storage.addItems([1, 2, 3], toSection: 0)
        storage.addItems([4, 5, 6], toSection: 1)
        
        let section = SectionModel()
        section.setItems([7, 8, 9])
        storage.setSection(section, forSection: 1)
        
        expect(self.storage.section(atIndex: 1)?.items(ofType: Int.self)) == [7, 8, 9]
    }
    
    func testInsertItemsAtIndexPathsSuccessfullyInsertsItems() {
        try! storage.insertItems([1, 2, 3], to: [indexPath(0, 0), indexPath(1, 0), indexPath(2, 0)])
        
        expect(self.storage.items(inSection: 0)?.count) == 3
        expect(self.storage.section(atIndex: 0)?.items(ofType: Int.self)) == [1, 2, 3]
    }
    
    func testWrongCountsRaisesException() {
        do {
            try storage.insertItems([1, 2], to: [indexPath(0, 0)])
        } catch let error as MemoryStorageError  {
            guard case MemoryStorageError.batchInsertionFailed(reason: _) = error else {
                XCTFail()
                return
            }
        } catch {
            XCTFail()
        }
    }
    
    func testInsertItemsAtIndexPathsDoesNotTryToInsertItemsPastItemsCount() {
        try! storage.insertItems([1, 2, 3], to: [indexPath(0, 0), indexPath(1, 0), indexPath(3, 0)])
        
        expect(self.storage.items(inSection: 0)?.count) == 2
        expect(self.storage.section(atIndex: 0)?.items(ofType: Int.self)) == [1, 2]
    }
}
