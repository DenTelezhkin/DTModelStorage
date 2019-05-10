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
    
    var storage : CoreDataStorage<ListItem>!
    var updateObserver : StorageUpdatesObserver!
    override func setUp() {
        super.setUp()
        
        let request = NSFetchRequest<ListItem>()
        request.entity = NSEntityDescription.entity(forEntityName: "ListItem", in: CoreDataManager.sharedInstance.context)
        let sortDescriptor = NSSortDescriptor(key: "value", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController<ListItem>(fetchRequest: request, managedObjectContext: CoreDataManager.sharedInstance.context, sectionNameKeyPath: nil, cacheName: nil)
        _ = try? fetchedResultsController.performFetch()
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
        _ = ListItem.createItemWithValue(5)
        
        expect(self.updateObserver.update?.objectChanges.filter { $0.0 == .insert }.flatMap { $0.1 }) == [indexPath(0, 0)]
    }
    
    func testDeletion()
    {
        let item = ListItem.createItemWithValue(5)
        item.managedObjectContext?.delete(item)
        expect(self.updateObserver.update?.objectChanges.filter { $0.0 == .delete }.flatMap { $0.1 }).toEventually(equal([indexPath(0, 0)]))
    }
    
    func testItemAtIndexPathGetter()
    {
        _ = ListItem.createItemWithValue(3)
        
        expect((self.storage.item(at: indexPath(0, 0)) as? ListItem)?.value) == 3
    }
    
    func testMovingValues()
    {
        let item1 = ListItem.createItemWithValue(1)
        _ = ListItem.createItemWithValue(2)
        item1.value = 3
        _ = try? item1.managedObjectContext?.save()
        
        expect(self.updateObserver.update?.objectChanges.filter { $0.0 == .insert }.flatMap { $0.1 }).toEventually(equal([indexPath(1, 0)]))
        expect(self.updateObserver.update?.objectChanges.filter { $0.0 == .delete }.flatMap { $0.1 }).toEventually(equal([indexPath(0, 0)]))
    }
    
    func testUpdatingValues()
    {
        let item = ListItem.createItemWithValue(1)
        _ = try? item.managedObjectContext?.save()
        item.value = 5
        _ = try? item.managedObjectContext?.save()
        
        expect(self.updateObserver.update?.objectChanges.filter { $0.0 == .update }.flatMap { $0.1 }).toEventually(equal([indexPath(0, 0)]))
    }
    
    func testGettingAllObjects() {
        _ = [1, 2, 3, 4, 5].map { ListItem.createItemWithValue($0) }
        
        let items = storage.sections.first?.items
        
        expect(items?.count) == 5
        expect((items?.first as? ListItem)?.value) == 1
        expect((items?.last as? ListItem)?.value) == 5
    }
    
    func testHeaderModel() {
        storage.configureForTableViewUsage()
        expect(self.storage.headerModel(forSection: 0) as? String) == ""
    }
    
    func testFooterModel()
    {
        storage.configureForTableViewUsage()
        expect(self.storage.footerModel(forSection: 0)).to(beNil())
    }
    
    func testSettingDifferentSupplementaryKindAllowsUsingSectionName() {
        storage.displaySectionNameForSupplementaryKinds = ["Foo"]
        expect(self.storage.supplementaryModel(ofKind: "Foo", forSectionAt: indexPath(0, 0)) as? String) == ""
    }
}
