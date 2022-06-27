//
//  RealmStorageTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 02.01.16.
//  Copyright © 2016 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
#if canImport(RealmSwift)
import RealmSwift
import RealmStorage
import DTModelStorage

func delay(_ delay:Double, _ closure:@escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

class RealmStorageTestCase: XCTestCase {
    
    let realm = { Void -> Realm in
        let configuration = Realm.Configuration(fileURL: nil, inMemoryIdentifier: "foo")
        return try! Realm(configuration: configuration)
    }(())
    var storage: RealmStorage!
    var observer: StorageUpdatesObserver!
    
    override func setUp() {
        super.setUp()
        storage = RealmStorage()
        try! realm.write {
            realm.deleteAll()
        }
        observer = StorageUpdatesObserver()
        storage.delegate = observer
    }
    
    override func tearDown() {
        super.tearDown()
        observer = nil
        storage = nil
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func addDogNamed(_ name: String) {
        try! realm.write {
            let dog = Dog()
            dog.name = name
            realm.add(dog)
        }
    }
    
    func giveDogs(names: [String], to personName: String) -> Person {
        let person = Person()
        try! realm.write {
            person.name = personName
            realm.add(person)

            let dogs = names.map{(name: String) -> Dog in
                let dog = Dog()
                dog.name = name
                realm.add(dog)
                return dog
            }
            
            person.dogs.append(objectsIn: dogs)
        }
        
        return person
    }
    
    func createSwarm(size: Int) {
        try! realm.write {
            for id in 0...size {
                let swarmer = Swarmer()
                swarmer.id = id
            }
        }
    }
        
    func testRealmStorageAddList() {
        let person = giveDogs(names: ["Rex", "Spot"], to: "Joe")
        
        storage.addSection(with: person.dogs)
        
        XCTAssertEqual((storage.item(at: indexPath(1, 0)) as? Dog)?.name, "Spot")
    }
    
    func testRealmStorageHandlesSectionAddition() {
        addDogNamed("Rex")
        
        let results = realm.objects(Dog.self)
        storage.addSection(with: results)
        
        XCTAssertEqual((storage.item(at: indexPath(0, 0)) as? Dog)?.name, "Rex")
    }
    
    func testRealmStorageIsAbleToHandleRealmNotification() {
        let results = realm.objects( Dog.self)
        storage.addSection(with: results)
        
        addDogNamed("Rex")
        
        XCTAssertEqual((self.storage.item(at: indexPath(0, 0)) as? Dog)?.name, "Rex")
        XCTAssert(observer.storageNeedsReloadingCalled)
    }
    
    func testInsertNotificationIsHandled() {
        let results = realm.objects(Dog.self)
        storage.addSection(with: results)
        
        addDogNamed("Rex")
        
        XCTAssertEqual((self.storage.item(at: indexPath(0, 0)) as? Dog)?.name, "Rex")
        
        let exp = expectation(description: "Insert notification expectation")
        observer.onUpdate = { observer, lastUpdate in
            if lastUpdate.objectChanges.first?.1.first == indexPath(0, 0) { return } // skip first update
            observer.verifyObjectChanges([
                (.insert, [indexPath(1, 0)])
            ])
            exp.fulfill()
        }
        delay(0.1) {
            try! self.realm.write {
                let dog = Dog()
                dog.name = "Rexxar"
                self.realm.add(dog)
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDeleteNotificationIsHandled() {
        let results = realm.objects(Dog.self)
        storage.addSection(with: results)
        
        var dog: Dog!
        try! realm.write {
            dog = Dog()
            dog.name = "Rexxar"
            realm.add(dog)
        }
        let exp = expectation(description: "Delete notification expectation")
        observer.onUpdate = { observer, lastUpdate in
            if lastUpdate.objectChanges.first?.1.first == indexPath(0, 0), lastUpdate.objectChanges.first?.0 == .insert { return } // skip first update
            observer.verifyObjectChanges([
                (.delete, [indexPath(0, 0)])
                ])
            exp.fulfill()
        }
        delay(0.1) {
            try! self.realm.write {
                self.realm.delete(dog)
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUpdateNotificationIsHandled() {
        let results = realm.objects(Dog.self)
        storage.addSection(with: results)
        
        var dog: Dog!
        try! realm.write {
            dog = Dog()
            dog.name = "Rexxar"
            realm.add(dog)
        }
        let exp = expectation(description: "Update notification expectation")
        observer.onUpdate = { observer, lastUpdate in
            if lastUpdate.objectChanges.first?.1.first == indexPath(0, 0), lastUpdate.objectChanges.first?.0 == .insert { return } // skip first update
            observer.verifyObjectChanges([
                (.update, [indexPath(0, 0)])
                ])
            exp.fulfill()
        }
        delay(0.1) {
            try! self.realm.write {
                dog.name = "Rex"
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testStorageHasSingleSection() {
        addDogNamed("Rex")
        
        storage.addSection(with: realm.objects(Dog.self))
        
        let section = storage.section(at: 0)
        
        XCTAssertEqual(section?.numberOfItems, 1)
        XCTAssertEqual((section?.item(at: 0) as? Dog)?.name, "Rex")
        XCTAssertNil(section?.item(at: 1))
    }
    
    func testItemAtIndexPathIsSafe() {
        let item = storage.item(at: indexPath(0, 0))
        XCTAssertNil(item)
        let section = storage.section(at: 0)
        XCTAssertNil(section)
    }
    
    func testDeletingSectionsTriggersUpdates() {
        addDogNamed("Rex")
        addDogNamed("Barnie")
        
        storage.addSection(with: realm.objects(Dog.self))
        storage.addSection(with: realm.objects(Dog.self))
        
        let observer = StorageUpdatesObserver()
        storage.delegate = observer
        
        storage.deleteSections(IndexSet(integer: 0))
        observer.verifySectionChanges([(.delete, [0])])
        XCTAssertEqual(storage.sections.count, 1)
    }
    
    func testShouldDeleteSectionsEvenIfThereAreNone()
    {
        storage.deleteSections(IndexSet(integer: 0))
    }
    
    func testSetSectionShouldAddWhenThereAreNoSections() {
        addDogNamed("Rex")
        addDogNamed("Barnie")
        
        storage.setSection(with: realm.objects(Dog.self), forSection: 0)
        
        XCTAssertEqual(storage.sections.count, 1)
        XCTAssertEqual(storage.section(at: 0)?.numberOfItems, 2)
        XCTAssertEqual(storage.numberOfItems(inSection: 0), 2)
        XCTAssertEqual(storage.numberOfItems(inSection: 1), 0)
    }
    
    func testSectionShouldBeReplaced() {
        addDogNamed("Rex")
        addDogNamed("Barnie")
        
        storage.addSection(with: realm.objects(Dog.self))
        storage.setSection(with: realm.objects(Dog.self), forSection: 0)
        
        XCTAssertEqual(storage.sections.count, 1)
        XCTAssertEqual(storage.section(at: 0)?.numberOfItems, 2)
    }
    
    func testShouldDisallowSettingWrongSection() {
        storage.setSection(with: realm.objects(Dog.self), forSection: 5)
        
        XCTAssertEqual(storage.sections.count, 0)
    }
    
    func testSupplementaryHeadersWork() {
        storage.configureForTableViewUsage()
        storage.addSection(with: realm.objects(Dog.self))
        storage.addSection(with: realm.objects(Dog.self))
        storage.addSection(with: realm.objects(Dog.self))
        storage.setSectionHeaderModels([1, 2, 3])
        XCTAssertEqual(storage.numberOfSections(), 3)
        
        XCTAssertEqual(storage.headerModel(forSection: 2) as? Int, 3)
        XCTAssertNil(storage.supplementaryModel(ofKind: DTTableViewElementSectionHeader, forSectionAt: indexPath(0, 3)))
    }
    
    func testSupplementaryFootersWork() {
        storage.configureForTableViewUsage()
        storage.addSection(with: realm.objects(Dog.self))
        storage.addSection(with: realm.objects(Dog.self))
        storage.addSection(with: realm.objects(Dog.self))
        storage.setSectionFooterModels([1, 2, 3])
        
        XCTAssertEqual(storage.footerModel(forSection: 2) as? Int, 3)
        XCTAssertNil(storage.supplementaryModel(ofKind: DTTableViewElementSectionFooter, forSectionAt: indexPath(0, 3)))
    }
    
    func testSectionModelIsAwareOfItsLocation() {
        addDogNamed("Rex")
        
        let results = realm.objects(Dog.self)
        storage.addSection(with: results)
        
        let section = storage.section(at: 0) as? RealmSection<Dog>
        XCTAssertEqual(section?.currentSectionIndex, 0)
    }
    
    func testItemAtIndexPathPerfomance() {
        createSwarm(size: 10000)
        storage = RealmStorage()
        storage.addSection(with: realm.objects(Swarmer.self))
        
        measure {
            _ = storage.item(at: indexPath(5000, 0))
        }
    }
}

#endif
