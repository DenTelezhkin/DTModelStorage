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
        storage.insertedSectionIndexes.addIndex(3)
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testDeletedSectionIndexesStorageUpdateEqual()
    {
        storage.deletedSectionIndexes.addIndex(2)
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testUpdatedSectionIndexesStorageUpdateEqual()
    {
        storage.updatedSectionIndexes.addIndex(2)
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testInsertedRowsStorageUpdateEqual()
    {
        storage.insertedRowIndexPaths.append(indexPath(0, 0))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testDeletedRowsStorageUpdateEqual()
    {
        storage.deletedRowIndexPaths.append(indexPath(0, 0))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
    
    func testUpdatedRowsStorageUpdateEqual()
    {
        storage.updatedRowIndexPaths.append(indexPath(0, 0))
        
        expect(self.emptyStorage == self.storage).to(beFalse())
    }
}
