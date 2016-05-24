//
//  RealmStorageTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 02.01.16.
//  Copyright © 2016 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
@testable import DTModelStorage
import Nimble
import RealmSwift

func delay(delay:Double, _ closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

class RealmStorageTestCase: XCTestCase {
    
    let realm = { Void -> Realm in
        let configuration = Realm.Configuration(fileURL: nil, inMemoryIdentifier: "foo")
        return try! Realm(configuration: configuration)
    }()
    var storage: RealmStorage!
    
    override func setUp() {
        super.setUp()
        storage = RealmStorage()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func addDogNamed(name: String) {
        try! realm.write {
            let dog = Dog()
            dog.name = name
            realm.add(dog)
        }
    }
    
    func testRealmStorageHandlesSectionAddition() {
        addDogNamed("Rex")
        
        let results = realm.objects(Dog)
        storage.addSectionWithResults(results)
        
        expect((self.storage.itemAtIndexPath(indexPath(0, 0)) as? Dog)?.name) == "Rex"
    }
    
    func testRealmStorageIsAbleToHandleRealmNotification() {
        let storageObserver = StorageUpdatesObserver()
        storage.delegate = storageObserver
        let results = realm.objects(Dog)
        storage.addSectionWithResults(results)
        
        addDogNamed("Rex")
        
        expect((self.storage.itemAtIndexPath(indexPath(0, 0)) as? Dog)?.name) == "Rex"
        expect(storageObserver.storageNeedsReloadingFlag) == true
    }
    
    func testInsertNotificationIsHandled() {
        let updateObserver = StorageUpdatesObserver()
        storage.delegate = updateObserver
        let results = realm.objects(Dog)
        storage.addSectionWithResults(results)
        
        addDogNamed("Rex")
        
        expect((self.storage.itemAtIndexPath(indexPath(0, 0)) as? Dog)?.name) == "Rex"
        
        delay(0.1) {
            try! self.realm.write {
                let dog = Dog()
                dog.name = "Rexxar"
                self.realm.add(dog)
            }
        }
        expect(updateObserver.update?.insertedRowIndexPaths).toEventually(equal(Set([indexPath(1, 0)])))
    }
    
    func testDeleteNotificationIsHandled() {
        let updateObserver = StorageUpdatesObserver()
        storage.delegate = updateObserver
        let results = realm.objects(Dog)
        storage.addSectionWithResults(results)
        
        var dog: Dog!
        try! realm.write {
            dog = Dog()
            dog.name = "Rexxar"
            realm.add(dog)
        }
        
        delay(0.1) {
            try! self.realm.write {
                self.realm.delete(dog)
            }
        }
        expect(updateObserver.update?.deletedRowIndexPaths).toEventually(equal(Set([indexPath(0, 0)])))
    }
    
    func testUpdateNotificationIsHandled() {
        let updateObserver = StorageUpdatesObserver()
        storage.delegate = updateObserver
        let results = realm.objects(Dog)
        storage.addSectionWithResults(results)
        
        var dog: Dog!
        try! realm.write {
            dog = Dog()
            dog.name = "Rexxar"
            realm.add(dog)
        }
        delay(0.1) {
            try! self.realm.write {
                dog.name = "Rex"
            }
        }
        expect(updateObserver.update?.updatedRowIndexPaths).toEventually(equal(Set([indexPath(0, 0)])))
    }
    
    func testStorageHasSingleSection() {
        addDogNamed("Rex")
        
        storage.addSectionWithResults(realm.objects(Dog))
        
        let section = storage.sectionAtIndex(0)
        
        expect(section?.numberOfItems) == 1
        expect((section?.items.first as? Dog)?.name) == "Rex"
    }
    
    func testItemAtIndexPathIsSafe() {
        let item = storage.itemAtIndexPath(indexPath(0, 0))
        expect(item).to(beNil())
        let section = storage.sectionAtIndex(0)
        expect(section).to(beNil())
    }
    
    func testDeletingSectionsTriggersUpdates() {
        addDogNamed("Rex")
        addDogNamed("Barnie")
        
        storage.addSectionWithResults(realm.objects(Dog))
        storage.addSectionWithResults(realm.objects(Dog))
        
        let observer = StorageUpdatesObserver()
        storage.delegate = observer
        
        storage.deleteSections(NSIndexSet(index: 0))
        expect(observer.update?.deletedSectionIndexes) == Set<Int>([0])
        expect(self.storage.sections.count) == 1
    }
    
    func testSupplementaryHeadersWork() {
        storage.configureForTableViewUsage()
        storage.addSectionWithResults(realm.objects(Dog))
        storage.addSectionWithResults(realm.objects(Dog))
        storage.addSectionWithResults(realm.objects(Dog))
        storage.setSectionHeaderModels([1,2,3])
        
        expect(self.storage.headerModelForSectionIndex(2) as? Int) == 3
        expect(self.storage.supplementaryModelOfKind(DTTableViewElementSectionHeader, sectionIndex: 3)).to(beNil())
    }
    
    func testSupplementaryFootersWork() {
        storage.configureForTableViewUsage()
        storage.addSectionWithResults(realm.objects(Dog))
        storage.addSectionWithResults(realm.objects(Dog))
        storage.addSectionWithResults(realm.objects(Dog))
        storage.setSectionFooterModels([1,2,3])
        
        expect(self.storage.footerModelForSectionIndex(2) as? Int) == 3
        expect(self.storage.supplementaryModelOfKind(DTTableViewElementSectionFooter, sectionIndex: 3)).to(beNil())
    }
    
    func testSupplementariesCanBeClearedOut() {
        storage.configureForTableViewUsage()
        storage.addSectionWithResults(realm.objects(Dog))
        storage.addSectionWithResults(realm.objects(Dog))
        storage.addSectionWithResults(realm.objects(Dog))
        storage.setSectionFooterModels([1,2,3])
        
        storage.setSupplementaries([Int](), forKind: DTTableViewElementSectionFooter)
        expect(self.storage.supplementaryModelOfKind(DTTableViewElementSectionFooter, sectionIndex: 0)).to(beNil())
    }
    
    func testSettingSupplementaryModelForSectionIndex() {
        storage.configureForTableViewUsage()
        storage.addSectionWithResults(realm.objects(Dog))
        storage.setSectionHeaderModel(1, forSectionIndex: 0)
    
        expect(self.storage.headerModelForSectionIndex(0) as? Int) == 1
        
        storage.setSectionFooterModel(2, forSectionIndex: 0)
        
        expect(self.storage.footerModelForSectionIndex(0) as? Int) == 2
    }
}