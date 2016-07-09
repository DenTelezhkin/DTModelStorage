//
//  StorageProtocolTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 18.09.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage
import Nimble

class FooView : UIView, ModelTransfer {
    func updateWithModel(_ model: String) {
        
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
    
    func testHeaderClassItemGetter()
    {
        expect(self.storage.itemForHeaderClass(FooView.self, atSectionIndex: 0)) == "Foo"
    }

    func testFooterClassItemGetter()
    {
        expect(self.storage.itemForFooterClass(FooView.self, atSectionIndex: 0)) == "Bar"
    }
    
    
    func testCollectionViewFlowLayoutUsage() {
        storage.configureForCollectionViewFlowLayoutUsage()
        
        expect(self.storage.supplementaryHeaderKind) == UICollectionElementKindSectionHeader
        expect(self.storage.supplementaryFooterKind) == UICollectionElementKindSectionFooter
        
        storage.configureForTableViewUsage()
        
        expect(self.storage.supplementaryHeaderKind) == DTTableViewElementSectionHeader
        expect(self.storage.supplementaryFooterKind) == DTTableViewElementSectionFooter
    }
}
