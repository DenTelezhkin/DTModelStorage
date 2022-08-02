//
//  StorageUpdateTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 18.09.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage

@MainActor
class StorageUpdateTestCase: XCTestCase {
    
    let emptyStorage = StorageUpdate()
    var storage : StorageUpdate!
    
    @MainActor override func setUp() {
        super.setUp()
        storage = StorageUpdate()
    }
    
    func testInsertedSectionIndexesStorageUpdateEqual()
    {
        storage.sectionChanges.append((.insert, [3]))
        
        XCTAssertNotEqual(emptyStorage, storage)
    }
    
    func testDeletedSectionIndexesStorageUpdateEqual()
    {
        storage.sectionChanges.append((.delete, [2]))
        
        XCTAssertNotEqual(emptyStorage, storage)
    }
    
    func testUpdatedSectionIndexesStorageUpdateEqual()
    {
        storage.sectionChanges.append((.update, [2]))
        
        XCTAssertNotEqual(emptyStorage, storage)
    }
    
    func testInsertedRowsStorageUpdateEqual()
    {
        storage.objectChanges.append((.insert, [indexPath(0, 0)]))
        
        XCTAssertNotEqual(emptyStorage, storage)
    }
    
    func testDeletedRowsStorageUpdateEqual()
    {
        storage.objectChanges.append((.delete, [indexPath(0, 0)]))
        
        XCTAssertNotEqual(emptyStorage, storage)
    }
    
    func testUpdatedRowsStorageUpdateEqual()
    {
        storage.objectChanges.append((.update, [indexPath(0, 0)]))
        
        XCTAssertNotEqual(emptyStorage, storage)
    }
    
    func testMovedRowsStorageUpdateEqual()
    {
        storage.objectChanges.append((.move, [indexPath(0, 0), indexPath(1, 1)]))
        
        XCTAssertNotEqual(emptyStorage, storage)
    }
    
    func testMovedSectionsStorageUpdateEqual()
    {
        storage.sectionChanges.append((.move, [0, 1]))
        
        XCTAssertNotEqual(emptyStorage, storage)
    }
}
