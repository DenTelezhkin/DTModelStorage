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

class MemoryStorageEditSpecs: XCTestCase {

    var storage = MemoryStorage()
    var delegate = StorageUpdatesObserver()
    
    override func setUp() {
        super.setUp()
        storage.delegate = delegate
    }
    
    func testShouldInsertItems()
    {
        storage.addItems([2, 4, 6], toSection: 0)
        storage.addItem(5, toSection: 1)
        delegate.applyUpdates()
        
        try! storage.insertItem(1, to: storage.indexPath(forItem: 6)!)
        delegate.applyUpdates()
        delegate.verifyObjectChanges([
            (.insert, [indexPath(2, 0)])
        ])
        
        try! storage.insertItem(3, to: storage.indexPath(forItem: 5)!)
        delegate.applyUpdates()
        delegate.verifyObjectChanges([
            (.insert, [indexPath(0, 1)])
        ])
    }
    func testBatchInsertionWithDifferentItemCountsTriggersAnomaly() {
        let exp = expectation(description: "Insert with different counts")
        let anomaly = MemoryStorageAnomaly.batchInsertionItemCountMismatch(itemsCount: 1, indexPathsCount: 2)
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        storage.insertItems([1], to: [indexPath(0, 0), indexPath(1, 0)])
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to insert batch of items, items count: 1, indexPaths count: 2")
    }
    
    func testSetItems() {
        storage.addItems([1, 2, 3])
        delegate.applyUpdates()
        storage.setItems([4, 5, 6])
        delegate.applyUpdates()
        
        XCTAssertEqual(storage.section(atIndex: 0)?.items(ofType: Int.self), [4, 5, 6])
    }
    
    func testSetSectionSupplementariesModel()
    {
        storage.configureForTableViewUsage()
        storage.setSectionHeaderModels([1])
        storage.setSectionFooterModels([nil, 2])
        XCTAssertEqual(storage.headerModel(forSection: 0) as? Int, 1)
        XCTAssertEqual(storage.footerModel(forSection: 1) as? Int, 2)
    }
    
    func testInsertionOfStructs()
    {
        storage.addItems([2, 4, 6], toSection: 0)
        delegate.applyUpdates()
        try! storage.insertItem(1, to: indexPath(0, 0))
        delegate.applyUpdates()
        XCTAssertEqual(storage.item(at: indexPath(0, 0)) as? Int, 1)
        XCTAssertEqual(storage.item(at: indexPath(1, 0)) as? Int, 2)
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
    
    func testInsertingIntoTooLargeIndexPathLeadsToAnomaly() {
        let exp = expectation(description: "Insert into not that large section")
        let anomaly = MemoryStorageAnomaly.insertionIndexPathTooBig(indexPath: indexPath(10, 1), countOfElementsInSection: 5)
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        storage.addItems([1, 2, 3])
        storage.addItems([4, 5, 6, 7, 8], toSection: 1)
        delegate.applyUpdates()
        try? storage.insertItem(7, to: indexPath(10, 1))
        delegate.applyUpdates()
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to insert item into IndexPath: [1, 10], count of elements in the section: 5")
    }

    func testShouldReloadRows()
    {
        storage.addItems([2, 4, 6])
        delegate.applyUpdates()
        storage.reloadItem(4)
        delegate.applyUpdates()
        delegate.verifyObjectChanges([
            (.update, [indexPath(1, 0)])
        ])
    }
    
    func testShouldReplaceRows()
    {
        storage.addItems([2, 4, 6])
        delegate.applyUpdates()
        try! storage.replaceItem(4, with: 5)
        delegate.applyUpdates()
        delegate.verifyObjectChanges([
            (.update, [indexPath(1, 0)])
        ])
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
    
    func testReplacingItemLeadsToAnomalyWhenNotFound() {
        let exp = expectation(description: "Replacing unknown item")
        let anomaly = MemoryStorageAnomaly.replaceItemFailedItemNotFound(itemDescription: "3")
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        try? storage.replaceItem(3, with: "Foo")
        delegate.applyUpdates()
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to find item for replacement: 3")
    }
    
    func testShouldRemoveItem()
    {
        storage.addItems([2, 4, 6], toSection: 0)
        
        storage.addItem(5, toSection: 1)
        delegate.applyUpdates()
        try! storage.removeItem(2)
        delegate.applyUpdates()
        delegate.verifyObjectChanges([
            (.delete, [indexPath(0, 0)])
        ])
        try! storage.removeItem(5)
        delegate.applyUpdates()
        delegate.verifyObjectChanges([
            (.delete, [indexPath(0, 1)])
        ])
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
    
    func testRemovingItemLeadsToAnomalyWhenNotFound() {
        let exp = expectation(description: "Removing unknown item")
        let anomaly = MemoryStorageAnomaly.removeItemFailedItemNotFound(itemDescription: "3")
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        try? storage.removeItem(3)
        delegate.applyUpdates()
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to find item for removal: 3")
    }
    
    func testShouldRemoveItemAtIndexPath()
    {
        storage.addItems([2, 4, 6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        storage.removeItems(at: [indexPath(0, 0)])
        delegate.applyUpdates()
        delegate.verifyObjectChanges([
            (.delete, [indexPath(0, 0)])
        ])
        storage.removeItems(at: [indexPath(0, 1)])
        delegate.applyUpdates()
        delegate.verifyObjectChanges([
            (.delete, [indexPath(0, 1)])
        ])
    }
    
    func testShouldRemoveItemsAtIndexPaths()
    {
        storage.addItems([2, 4, 6], toSection: 0)
        storage.addItem(5, toSection: 1)
        
        storage.removeItems(at: [indexPath(0, 0), indexPath(0, 1)])
        delegate.applyUpdates()
        delegate.verifyObjectChanges([
            (.delete, [indexPath(0, 1)]),
            (.delete, [indexPath(0, 0)])
        ])
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
        
        storage.removeItems([2, 4, 1])
        delegate.applyUpdates()
        delegate.verifyObjectChanges([
            (.delete, [indexPath(0, 1)]),
            (.delete, [indexPath(1, 1)]),
            (.delete, [indexPath(0, 0)])
        ])
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
        delegate.applyUpdates()
        storage.deleteSections(IndexSet(integer: 1))
        delegate.applyUpdates()
        delegate.verifySectionChanges([(.delete, [1])])
    }
    
    func testShouldDeleteMultipleSections() {
        storage.addItem(1, toSection: 0)
        storage.addItem(2, toSection: 1)
        storage.addItem(3, toSection: 2)
        storage.addItem(4, toSection: 3)
        delegate.applyUpdates()
        let set = NSMutableIndexSet(index: 1)
        set.add(3)
        storage.deleteSections(set as IndexSet)
        delegate.applyUpdates()
        delegate.verifySectionChanges([
            (.delete, [1]),
            (.delete, [3])
        ])
        XCTAssertEqual(storage.sections.count, 2)
    }
    
    func testShouldNotCallDelegateForOptionalMethod()
    {
        _ = storage.supplementaryModel(ofKind: "foo", forSectionAt: indexPath(0, 1))
    }
    
    func testShouldBeAbleToRetrieveSupplementaryModelViaStorageMethod()
    {
        storage.addItem(1)
        storage.supplementaryModelProvider = { kind, indexPath in
            guard kind == "bar" else { return nil }
            guard indexPath.section == 0, indexPath.item == 0 else { return nil }
            return "foo"
        }
        XCTAssertEqual(storage.supplementaryModel(ofKind: "bar", forSectionAt: indexPath(0, 0)) as? String, "foo")
    }
    
    func testShouldGetItemCorrectly()
    {
        storage.addItem(1, toSection: 0)
        storage.addItem(2, toSection: 1)
        storage.addItem(3, toSection: 2)
        delegate.applyUpdates()
        var model = storage.item(at: indexPath(0, 1))
        
        XCTAssertEqual(model as? Int, 2)
        
        model = storage.item(at: indexPath(0, 2))
        
        XCTAssertEqual(model as? Int, 3)
    }
    
    func testShouldReturnNilForNotExistingIndexPath()
    {
        let model = storage.item(at: indexPath(5, 6))
        XCTAssertNil(model)
    }
    
    func testShouldReturnNilForNotExistingIndexPathInExistingSection()
    {
        storage.addItem(1, toSection: 0)
        let model = storage.item(at: indexPath(1, 0))
        XCTAssertNil(model)
    }
    
    func testMovingSections()
    {
        storage.addItems([1])
        storage.addItems([1, 1], toSection: 1)
        storage.addItems([1, 1, 1], toSection: 2)
        delegate.applyUpdates()
        storage.moveSection(0, toSection: 1)
        delegate.applyUpdates()
        XCTAssertEqual(storage.section(atIndex: 0)?.items.count, 2)
        XCTAssertEqual(storage.section(atIndex: 1)?.items.count, 1)
        let moves = delegate.lastUpdate?.sectionChanges.filter { $0.0 == .move }
        XCTAssertEqual(moves?.first?.1, [0, 1])
    }
    
    func testMovingItem()
    {
        storage.addItems([1])
        storage.addItems([2, 3], toSection: 1)
        storage.addItems([4, 5, 6], toSection: 2)
        delegate.applyUpdates()
        storage.moveItem(at: indexPath(0, 0), to: indexPath(1, 1))
        delegate.applyUpdates()
        XCTAssertEqual(storage.item(at: indexPath(1, 1)) as? Int, 1)
        
        delegate.verifyObjectChanges([(.move, [indexPath(0, 0), indexPath(1, 1)])])
    }
    
    func testMovingItemIntoNonExistingSection()
    {
        storage.addItems([1])
        delegate.applyUpdates()
        storage.moveItem(at: indexPath(0, 0), to: indexPath(0, 1))
        delegate.applyUpdates()
        XCTAssertEqual(storage.item(at: indexPath(0, 1)) as? Int, 1)
        
        delegate.verifySectionChanges([(.insert, [1])])
        delegate.verifyObjectChanges([
            (.move, [indexPath(0, 0), indexPath(0, 1)])
        ])
    }
    
    func testMovingNotExistingIndexPath()
    {
        storage.moveItem(at: indexPath(0, 0), to: indexPath(0, 1))
    }
    
    func testMovingItemThatIsUnfindableLeadsToAnomaly() {
        let exp = expectation(description: "Moving unknown item")
        let anomaly = MemoryStorageAnomaly.moveItemFailedItemNotFound(indexPath: indexPath(0, 0))
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        storage.moveItem(at: indexPath(0, 0), to: indexPath(1, 0))
        delegate.applyUpdates()
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to find item for moving at indexPath: [0, 0]")
    }
    
    func testMovingItemToIndexPathThatIsTooBigLeadsToAnomaly() {
        let exp = expectation(description: "Moving unknown item")
        let anomaly = MemoryStorageAnomaly.moveItemFailedIndexPathTooBig(indexPath: indexPath(1, 0), countOfElementsInSection: 0)
        storage.addItem(1)
        delegate.applyUpdates()
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        storage.moveItem(at: indexPath(0, 0), to: indexPath(1, 0))
        delegate.applyUpdates()
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to move item, destination indexPath is too big: [0, 1], number of items in section after removing source item: 0")
    }
    
    func testMovingForInvalidIndexPathsLeadsToAnomaly() {
        let exp = expectation(description: "Moving item with invalid indexPaths")
        let anomaly = MemoryStorageAnomaly.moveItemFailedInvalidIndexPaths(sourceIndexPath: indexPath(0, 0), destinationIndexPath: indexPath(3, 1), sourceElementsInSection: 1, destinationElementsInSection: 1)
        storage.addItem(1)
        storage.addItem(2, toSection: 1)
        delegate.applyUpdates()
        storage.anomalyHandler.anomalyAction = exp.expect(anomaly: anomaly)
        storage.moveItemWithoutAnimation(from: indexPath(0, 0), to: indexPath(3, 1))
        delegate.applyUpdates()
        waitForExpectations(timeout: 0.1)
        
        XCTAssertEqual(anomaly.debugDescription, "⚠️ [MemoryStorage] Failed to move item, sourceIndexPath: [0, 0], destination indexPath: [1, 3], number of items in source section: 1, number of items in destination section after removing source item: 1")
    }
    
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
        
        XCTAssertEqual(storage.totalNumberOfItems, 3)
        XCTAssertEqual(storage.sections.count, 3)
        XCTAssertEqual(storage.item(at: indexPath(0, 0)) as? Int, 1)
    }
    
    func testSetItemsForAllSectionsResetsPreviousSections() {
        storage.setItemsForAllSections([[1],[2]])
        
        storage.setItemsForAllSections([[3,4,5]])
        
        XCTAssertEqual(storage.totalNumberOfItems, 3)
        XCTAssertEqual(storage.sections.count, 1)
        XCTAssertEqual(storage.item(at: indexPath(1, 0)) as? Int, 4)
    }
}

class SectionSupplementariesTestCase : XCTestCase
{
    var storage = MemoryStorage()
    var delegate = StorageUpdatesObserver()
    override func setUp() {
        super.setUp()
        self.storage.configureForTableViewUsage()
        storage.delegate = delegate
    }
    
    func testSectionHeaderModelsSetter()
    {
        storage.setSectionHeaderModels([1, 2, 3])
        
        XCTAssertEqual(storage.sections.count, 0)
        XCTAssertEqual(storage.headerModel(forSection: 0) as? Int, 1)
        XCTAssertEqual(storage.headerModel(forSection: 1) as? Int, 2)
        XCTAssertEqual(storage.headerModel(forSection: 2) as? Int, 3)
    }
    
    func testSectionFooterModelsSetter()
    {
        storage.setSectionFooterModels([1,2,3])
        
        XCTAssertEqual(storage.sections.count, 0)
        XCTAssertEqual(storage.footerModel(forSection: 0) as? Int, 1)
        XCTAssertEqual(storage.footerModel(forSection: 1) as? Int, 2)
        XCTAssertEqual(storage.footerModel(forSection: 2) as? Int, 3)
    }
    
    func testNillifySectionHeaders()
    {
        storage.headerModelProvider = { [1,2,3][$0] }
        storage.headerModelProvider = { _ in nil }
        
        XCTAssertNil(storage.headerModel(forSection: 1))
    }
    
    func testNillifySectionFooters()
    {
        storage.footerModelProvider = { [1,2,3][$0] }
        storage.footerModelProvider = { _ in nil }
        
        XCTAssertNil(storage.footerModel(forSection: 1))
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
        section.items = [7, 8, 9]
        storage.setSection(section, forSection: 1)
        
        XCTAssertEqual(self.storage.section(atIndex: 1)?.items(ofType: Int.self), [7, 8, 9])
    }
    
    func testInsertItemsAtIndexPathsSuccessfullyInsertsItems() throws {
        storage.insertItems([1, 2, 3], to: [indexPath(0, 0), indexPath(1, 0), indexPath(2, 0)])
        delegate.applyUpdates()
        XCTAssertEqual(self.storage.items(inSection: 0)?.count, 3)
        XCTAssertEqual(self.storage.section(atIndex: 0)?.items(ofType: Int.self), [1, 2, 3])
    }
    
    func testInsertingSeveralItemsAtIndexPathDeliversCorrectUpdates() {
        storage.setItems([1,2,3])
        delegate.applyUpdates()
        
        try? storage.insertItems([4,5], at: IndexPath(item: 2, section: 0))
        delegate.applyUpdates()
        delegate.verifyObjectChanges([
            (.insert, [indexPath(2, 0)]),
            (.insert, [indexPath(3, 0)])
        ])
        delegate.applyUpdates()
        XCTAssertEqual(storage.section(atIndex: 0)?.items.compactMap { $0 as? Int}, [1,2,4,5,3])
    }
    
    func testInsertingSeveralItemsAtTheEndWorks() {
        storage.setItems([1,2,3])
        delegate.applyUpdates()
        
        try? storage.insertItems([4,5], at: IndexPath(item: 3, section: 0))
        delegate.applyUpdates()
        delegate.verifyObjectChanges([
            (.insert, [indexPath(3, 0)]),
            (.insert, [indexPath(4, 0)])
        ])
        delegate.applyUpdates()
        XCTAssertEqual(storage.section(atIndex: 0)?.items.compactMap { $0 as? Int}, [1,2,3,4,5])
    }
    
    func testInsertingItemsBeyondSectionThrowsError() {
        do {
            try storage.insertItems([1,2], at: indexPath(1, 0))
        } catch MemoryStorageError.insertionFailed(reason: let reason) {
            XCTAssertEqual(reason, .indexPathTooBig(indexPath(1,0)))
        } catch {
            XCTFail()
        }
    }
    
    func testInsertItemsAtIndexPathsDoesNotTryToInsertItemsPastItemsCount()  {
        storage.insertItems([1, 2, 3], to: [indexPath(0, 0), indexPath(1, 0), indexPath(3, 0)])
        delegate.applyUpdates()
        XCTAssertEqual(self.storage.items(inSection: 0)?.count, 2)
        XCTAssertEqual(self.storage.section(atIndex: 0)?.items(ofType: Int.self), [1, 2])
    }
}
