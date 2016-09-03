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
        storage.insertedSectionIndexes.insert(3)
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testDeletedSectionIndexesStorageUpdateEqual()
    {
        storage.deletedSectionIndexes.insert(2)
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testUpdatedSectionIndexesStorageUpdateEqual()
    {
        storage.updatedSectionIndexes.insert(2)
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testInsertedRowsStorageUpdateEqual()
    {
        storage.insertedRowIndexPaths.insert(indexPath(0, 0))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testDeletedRowsStorageUpdateEqual()
    {
        storage.deletedRowIndexPaths.insert(indexPath(0, 0))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testUpdatedRowsStorageUpdateEqual()
    {
        storage.updatedRowIndexPaths.insert(indexPath(0, 0))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testMovedRowsStorageUpdateEqual()
    {
        storage.movedRowIndexPaths.append([indexPath(0, 0),indexPath(1, 1)])
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testMovedSectionsStorageUpdateEqual()
    {
        storage.movedSectionIndexes.append([0,1])
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
}
