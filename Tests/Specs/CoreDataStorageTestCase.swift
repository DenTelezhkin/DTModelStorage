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
import Nimble

class CoreDataStorageTestCase: XCTestCase {
    
    var storage : CoreDataStorage!
    var updateObserver : StorageUpdatesObserver!
    override func setUp() {
        super.setUp()
        
        let request = NSFetchRequest(entityName: "ListItem")
        let sortDescriptor = NSSortDescriptor(key: "value", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.sharedInstance.context, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsController.performFetch()
        storage = CoreDataStorage(fetchedResultsController: fetchedResultsController)
        
        updateObserver = StorageUpdatesObserver()
        storage.delegate = updateObserver
        CoreDataManager.sharedInstance.deleteAllObjects()
    }
    
    func testCoreDataStack()
    {
        expect(self.storage.sections.first?.numberOfItems) == 0
    }
    
    func testInsertion()
    {
        let _ = ListItem.createItemWithValue(5)
        
        expect(self.updateObserver.update?.insertedRowIndexPaths) == Set([indexPath(0, 0)])
    }
    
    func testDeletion()
    {
        let item = ListItem.createItemWithValue(5)
        item.managedObjectContext?.deleteObject(item)
        expect(self.updateObserver.update?.deletedRowIndexPaths).toEventually(equal(Set([indexPath(0, 0)])))
    }
    
    func testItemAtIndexPathGetter()
    {
        let _ = ListItem.createItemWithValue(3)
        
        expect((self.storage.itemAtIndexPath(indexPath(0, 0)) as? ListItem)?.value) == 3
    }
    
    func testMovingValues()
    {
        let item1 = ListItem.createItemWithValue(1)
        let _ = ListItem.createItemWithValue(2)
        item1.value = 3
        let _ = try? item1.managedObjectContext?.save()
        
        let expectedMovement = [[indexPath(0, 0),indexPath(1, 0)]]
        
        expect(self.updateObserver.update?.movedRowIndexPaths).toEventually(equal(expectedMovement))
    }
    
    func testUpdatingValues()
    {
        let item = ListItem.createItemWithValue(1)
        let _ = try? item.managedObjectContext?.save()
        item.value = 5
        let _ = try? item.managedObjectContext?.save()
        
        expect(self.updateObserver.update?.updatedRowIndexPaths).toEventually(equal(Set([indexPath(0, 0)])))
    }
    
    func testGettingAllObjects() {
        let _ = [1,2,3,4,5].map { ListItem.createItemWithValue($0) }
        
        let items = storage.sections.first?.items
        
        expect(items?.count) == 5
        expect((items?.first as? ListItem)?.value) == 1
        expect((items?.last as? ListItem)?.value) == 5
    }
    
    func testHeaderModel() {
        storage.configureForTableViewUsage()
        expect(self.storage.headerModelForSectionIndex(0) as? String) == ""
    }
    
    func testFooterModel()
    {
        storage.configureForTableViewUsage()
        expect(self.storage.footerModelForSectionIndex(0)).to(beNil())
    }
    
    func testSupplementaryModelOfKind() {
        expect(self.storage.supplementaryModelOfKind(DTTableViewElementSectionHeader, sectionIndex: 0)).to(beNil())
    }
}
