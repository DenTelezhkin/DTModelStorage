//
//  StorageTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 18.09.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage
import Nimble

class FooView : UIView, ModelTransfer {
    func update(with model: String) {
        
    }
}

class StorageProtocolTestCase: XCTestCase {
    
    let storage = MemoryStorage()
    override func setUp() {
        super.setUp()
        storage.configureForTableViewUsage()
        storage.setSectionHeaderModels(["Foo"])
        storage.setSectionFooterModels(["Bar"])
    }
    
    func testCollectionViewFlowLayoutUsage() {
        storage.configureForCollectionViewFlowLayoutUsage()
        
        expect(self.storage.supplementaryHeaderKind) == DTCollectionViewElementSectionHeader
        expect(self.storage.supplementaryFooterKind) == DTCollectionViewElementSectionFooter
        
        storage.configureForTableViewUsage()
        
        expect(self.storage.supplementaryHeaderKind) == DTTableViewElementSectionHeader
        expect(self.storage.supplementaryFooterKind) == DTTableViewElementSectionFooter
    }
}
