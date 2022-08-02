//
//  CoreDataStorageTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 29.10.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage
import CoreData

@MainActor
class CoreDataStorageTestCase: XCTestCase {
    
    var storage : CoreDataStorage<ListItem>!
    var updateObserver : StorageUpdatesObserver!
    @MainActor override func setUp() {
        super.setUp()
        
        configureStorage()
        
        updateObserver = StorageUpdatesObserver()
        storage.delegate = updateObserver
        CoreDataManager.sharedInstance.deleteAllObjects()
    }
    
    func configureStorage() {
        let request = NSFetchRequest<ListItem>()
        request.entity = NSEntityDescription.entity(forEntityName: "ListItem", in: CoreDataManager.sharedInstance.context)
        let sortDescriptor = NSSortDescriptor(key: "value", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController<ListItem>(fetchRequest: request, managedObjectContext: CoreDataManager.sharedInstance.context, sectionNameKeyPath: nil, cacheName: nil)
        _ = try? fetchedResultsController.performFetch()
        storage = CoreDataStorage(fetchedResultsController: fetchedResultsController)
    }
    
    @MainActor override func tearDown() {
        super.tearDown()
        updateObserver = nil
        storage = nil
        CoreDataManager.sharedInstance.deleteAllObjects()
    }
    
    func testCoreDataStack()
    {
        XCTAssertEqual(storage.numberOfItems(inSection: 0), 0)
    }
    
    func testInsertion()
    {
        _ = ListItem.createItemWithValue(5)
        updateObserver.verifyObjectChanges([(.insert, [indexPath(0, 0)])])
    }
    
    func testDeletion()
    {
        let item = ListItem.createItemWithValue(5)
        let exp = expectation(description: "Delete update")
        updateObserver.onUpdate = { observer, update in
            observer.verifyObjectChanges([
                (.delete, [indexPath(0, 0)])
            ])
            exp.fulfill()
        }
        item.managedObjectContext?.delete(item)
        waitForExpectations(timeout: 1)
    }
    
    func testItemAtIndexPathGetter()
    {
        _ = ListItem.createItemWithValue(3)
        
        XCTAssertEqual((storage.item(at: indexPath(0, 0)) as? ListItem)?.value, 3)
    }
    
    func testMovingValues()
    {
        let item1 = ListItem.createItemWithValue(1)
        _ = ListItem.createItemWithValue(2)
        item1.value = 3
        let exp = expectation(description: "Move expectation")
        updateObserver.onUpdate = { observer, update in
            observer.verifyObjectChanges([
                (.delete, [indexPath(0, 0)]),
                (.insert, [indexPath(1, 0)])
            ])
            exp.fulfill()
        }
        _ = try? item1.managedObjectContext?.save()
        waitForExpectations(timeout: 1)
    }
    
    func testUpdatingValues()
    {
        let item = ListItem.createItemWithValue(1)
        _ = try? item.managedObjectContext?.save()
        item.value = 5
        let exp = expectation(description: "Update expectation")
        updateObserver.onUpdate = { observer, update in
            observer.verifyObjectChanges([
                (.update, [indexPath(0, 0)])
            ])
            exp.fulfill()
        }
        _ = try? item.managedObjectContext?.save()
        
        waitForExpectations(timeout: 1)
    }
    
    func testGettingAllObjects() {
        _ = [1, 2, 3, 4, 5].map { ListItem.createItemWithValue($0) }
        
        XCTAssertEqual(storage.numberOfItems(inSection: 0), 5)
        XCTAssertEqual((storage.item(at: indexPath(0, 0)) as? ListItem)?.value, 1)
        XCTAssertEqual((storage.item(at: indexPath(4, 0)) as? ListItem)?.value, 5)
        
        XCTAssertEqual(storage.numberOfSections(), 1)
        XCTAssertEqual(storage.numberOfItems(inSection: 0), 5)
        XCTAssertEqual(storage.numberOfItems(inSection: 1), 0)
    }
    
    func testHeaderModel() {
        storage.configureForTableViewUsage()
        XCTAssertEqual(storage.headerModel(forSection: 0) as? String, "")
    }
    
    func testFooterModel()
    {
        storage.configureForTableViewUsage()
        XCTAssertNil(storage.footerModel(forSection: 0))
    }
    
    func createSwarm(size: Int) {
        CoreDataManager.sharedInstance.context.performAndWait {
            let context = CoreDataManager.sharedInstance.context
            for id in 0...size {
                //swiftlint:disable:next force_cast
                let item = NSEntityDescription.insertNewObject(forEntityName: "ListItem", into:context) as! ListItem
                item.value = id as NSNumber
            }
            try! context.save()
        }
        
    }
    
    func testItemAtIndexPathPerfomance() {
        createSwarm(size: 500)
        configureStorage()
        
        measure {
            _ = storage.item(at: indexPath(250, 0))
        }
    }
}
