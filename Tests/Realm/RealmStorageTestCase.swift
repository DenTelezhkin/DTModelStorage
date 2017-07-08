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

func delay(_ delay:Double, _ closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

class RealmStorageTestCase: XCTestCase {
    
    let realm = { Void -> Realm in
        let configuration = Realm.Configuration(fileURL: nil, inMemoryIdentifier: "foo")
        return try! Realm(configuration: configuration)
    }(())
    var storage: RealmStorage!
    
    override func setUp() {
        super.setUp()
        storage = RealmStorage()
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
        
    func testRealmStorageAddList() {
        let person = giveDogs(names: ["Rex", "Spot"], to: "Joe")
        
        storage.addSection(with: person.dogs)
        
        expect((self.storage.item(at: indexPath(1, 0)) as? Dog)?.name) == "Spot"
    }
    
    func testRealmStorageHandlesSectionAddition() {
        addDogNamed("Rex")
        
        let results = realm.objects(Dog.self)
        storage.addSection(with: results)
        
        expect((self.storage.item(at: indexPath(0, 0)) as? Dog)?.name) == "Rex"
    }
    
    func testRealmStorageIsAbleToHandleRealmNotification() {
        let storageObserver = StorageUpdatesObserver()
        storage.delegate = storageObserver
        let results = realm.objects( Dog.self)
        storage.addSection(with: results)
        
        addDogNamed("Rex")
        
        expect((self.storage.item(at: indexPath(0, 0)) as? Dog)?.name) == "Rex"
        expect(storageObserver.storageNeedsReloadingFlag) == true
    }
    
    func testInsertNotificationIsHandled() {
        let updateObserver = StorageUpdatesObserver()
        storage.delegate = updateObserver
        let results = realm.objects(Dog.self)
        storage.addSection(with: results)
        
        addDogNamed("Rex")
        
        expect((self.storage.item(at: indexPath(0, 0)) as? Dog)?.name) == "Rex"
        
        delay(0.1) {
            try! self.realm.write {
                let dog = Dog()
                dog.name = "Rexxar"
                self.realm.add(dog)
            }
        }
        expect(updateObserver.update?.objectChanges.filter { $0.0 == .insert }.flatMap { arg in arg.1 }).toEventually(equal([indexPath(1, 0)]))
    }
    
    func testDeleteNotificationIsHandled() {
        let updateObserver = StorageUpdatesObserver()
        storage.delegate = updateObserver
        let results = realm.objects(Dog.self)
        storage.addSection(with: results)
        
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
        expect(updateObserver.update?.objectChanges.filter { $0.0 == .delete }.flatMap { arg in arg.1 }).toEventually(equal([indexPath(0, 0)]))
    }
    
    func testUpdateNotificationIsHandled() {
        let updateObserver = StorageUpdatesObserver()
        storage.delegate = updateObserver
        let results = realm.objects(Dog.self)
        storage.addSection(with: results)
        
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
        expect(updateObserver.update?.objectChanges.filter { $0.0 == .update }.flatMap { arg in arg.1 }).toEventually(equal([indexPath(0, 0)]))
    }
    
    func testStorageHasSingleSection() {
        addDogNamed("Rex")
        
        storage.addSection(with: realm.objects(Dog.self))
        
        let section = storage.section(at: 0)
        
        expect(section?.numberOfItems) == 1
        expect((section?.items.first as? Dog)?.name) == "Rex"
    }
    
    func testItemAtIndexPathIsSafe() {
        let item = storage.item(at: indexPath(0, 0))
        expect(item).to(beNil())
        let section = storage.section(at: 0)
        expect(section).to(beNil())
    }
    
    func testDeletingSectionsTriggersUpdates() {
        addDogNamed("Rex")
        addDogNamed("Barnie")
        
        storage.addSection(with: realm.objects(Dog.self))
        storage.addSection(with: realm.objects(Dog.self))
        
        let observer = StorageUpdatesObserver()
        storage.delegate = observer
        
        storage.deleteSections(IndexSet(integer: 0))
        expect(observer.update?.sectionChanges.filter { $0.0 == .delete }.flatMap { arg in arg.1 }) == [0]
        expect(self.storage.sections.count) == 1
    }
    
    func testShouldDeleteSectionsEvenIfThereAreNone()
    {
        storage.deleteSections(IndexSet(integer: 0))
    }
    
    func testSetSectionShouldAddWhenThereAreNoSections() {
        addDogNamed("Rex")
        addDogNamed("Barnie")
        
        storage.setSection(with: realm.objects(Dog.self), forSection: 0)
        
        expect(self.storage.sections.count) == 1
        expect(self.storage.section(at: 0)?.items.count) == 2
    }
    
    func testSectionShouldBeReplaced() {
        addDogNamed("Rex")
        addDogNamed("Barnie")
        
        storage.addSection(with: realm.objects(Dog.self))
        storage.setSection(with: realm.objects(Dog.self), forSection: 0)
        
        expect(self.storage.sections.count) == 1
        expect(self.storage.section(at: 0)?.items.count) == 2
    }
    
    func testShouldDisallowSettingWrongSection() {
        storage.setSection(with: realm.objects(Dog.self), forSection: 5)
        
        expect(self.storage.sections.count) == 0
    }
    
    func testSupplementaryHeadersWork() {
        storage.configureForTableViewUsage()
        storage.addSection(with: realm.objects(Dog.self))
        storage.addSection(with: realm.objects(Dog.self))
        storage.addSection(with: realm.objects(Dog.self))
        storage.setSectionHeaderModels([1,2,3])
        
        expect(self.storage.headerModel(forSection: 2) as? Int) == 3
        expect(self.storage.supplementaryModel(ofKind: DTTableViewElementSectionHeader, forSectionAt: IndexPath(item:0, section: 3))).to(beNil())
    }
    
    func testSupplementaryFootersWork() {
        storage.configureForTableViewUsage()
        storage.addSection(with: realm.objects(Dog.self))
        storage.addSection(with: realm.objects(Dog.self))
        storage.addSection(with: realm.objects(Dog.self))
        storage.setSectionFooterModels([1,2,3])
        
        expect(self.storage.footerModel(forSection: 2) as? Int) == 3
        expect(self.storage.supplementaryModel(ofKind: DTTableViewElementSectionFooter, forSectionAt: IndexPath(item:0, section: 3))).to(beNil())
    }
    
    func testSupplementariesCanBeClearedOut() {
        storage.configureForTableViewUsage()
        storage.addSection(with: realm.objects(Dog.self))
        storage.addSection(with: realm.objects(Dog.self))
        storage.addSection(with: realm.objects(Dog.self))
        storage.setSectionFooterModels([1,2,3])
        
        storage.setSupplementaries([[Int:Int]]().flatMap { $0 }, forKind: DTTableViewElementSectionFooter)
        expect(self.storage.supplementaryModel(ofKind: DTTableViewElementSectionFooter, forSectionAt: IndexPath(item:0, section: 0))).to(beNil())
    }
    
    func testSettingSupplementaryModelForSectionIndex() {
        storage.configureForTableViewUsage()
        storage.addSection(with: realm.objects(Dog.self))
        storage.setSectionHeaderModel(1, forSectionIndex: 0)
    
        expect(self.storage.headerModel(forSection: 0) as? Int) == 1
        
        storage.setSectionFooterModel(2, forSectionIndex: 0)
        
        expect(self.storage.footerModel(forSection: 0) as? Int) == 2
    }
    
    func testSectionModelIsAwareOfItsLocation() {
        addDogNamed("Rex")
        
        let results = realm.objects(Dog.self)
        storage.addSection(with: results)
        
        let section = storage.section(at: 0)! as? RealmSection<Dog>
        expect(section?.currentSectionIndex) == 0
    }
}
