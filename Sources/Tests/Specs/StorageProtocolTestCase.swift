//
//  StorageTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 18.09.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage

class FooView : UIView, ModelTransfer {
    func update(with model: String) {
        
    }
}

class StorageProtocolTestCase: XCTestCase {
    
    let storage = MemoryStorage()
    override func setUp() {
        super.setUp()
        storage.configureForTableViewUsage()
    }
    
    func testCollectionViewFlowLayoutUsage() {
        storage.configureForCollectionViewFlowLayoutUsage()
        
        XCTAssertEqual(self.storage.supplementaryHeaderKind, DTCollectionViewElementSectionHeader)
        XCTAssertEqual(self.storage.supplementaryFooterKind, DTCollectionViewElementSectionFooter)
        
        storage.configureForTableViewUsage()
        
        XCTAssertEqual(self.storage.supplementaryHeaderKind, DTTableViewElementSectionHeader)
        XCTAssertEqual(self.storage.supplementaryFooterKind, DTTableViewElementSectionFooter)
    }
}
