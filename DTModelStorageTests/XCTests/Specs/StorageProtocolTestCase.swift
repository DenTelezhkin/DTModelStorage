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
    func updateWithModel(model: String) {
        
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
    
    func testHeaderClassObjectGetter()
    {
        expect(self.storage.objectForHeaderClass(FooView.self, atSectionIndex: 0)) == "Foo"
    }

    func testFooterClassObjectGetter()
    {
        expect(self.storage.objectForFooterClass(FooView.self, atSectionIndex: 0)) == "Bar"
    }
    
}
