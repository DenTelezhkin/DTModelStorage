//
//  StorageUpdateTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 18.09.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage
import Nimble

class StorageUpdateTestCase: XCTestCase {
    
    let emptyStorage = StorageUpdate()
    var storage : StorageUpdate!
    
    override func setUp() {
        super.setUp()
        storage = StorageUpdate()
    }
    
    func testInsertedSectionIndexesStorageUpdateEqual()
    {
        storage.sectionChanges.append((.insert,[3]))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testDeletedSectionIndexesStorageUpdateEqual()
    {
        storage.sectionChanges.append((.delete,[2]))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testUpdatedSectionIndexesStorageUpdateEqual()
    {
        storage.sectionChanges.append((.update,[2]))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testInsertedRowsStorageUpdateEqual()
    {
        storage.objectChanges.append((.insert,[indexPath(0,0)]))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testDeletedRowsStorageUpdateEqual()
    {
        storage.objectChanges.append((.delete,[indexPath(0,0)]))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testUpdatedRowsStorageUpdateEqual()
    {
        storage.objectChanges.append((.update,[indexPath(0,0)]))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testMovedRowsStorageUpdateEqual()
    {
        storage.objectChanges.append((.move,[indexPath(0,0),indexPath(1,1)]))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testMovedSectionsStorageUpdateEqual()
    {
        storage.sectionChanges.append((.move,[0,1]))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
}
