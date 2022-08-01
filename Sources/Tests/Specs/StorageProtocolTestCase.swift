//
//  StorageTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 18.09.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage
import UIKit

class FooView : UIView, ModelTransfer {
    func update(with model: String) {
        
    }
}

@MainActor
class StorageProtocolTestCase: XCTestCase {
    
    let storage = MemoryStorage()
    override func setUp() {
        super.setUp()
        storage.configureForTableViewUsage()
    }
    
    func testCollectionViewFlowLayoutUsage() {
        storage.configureForCollectionViewFlowLayoutUsage()
        
        XCTAssertEqual(self.storage.supplementaryHeaderKind, UICollectionView.elementKindSectionHeader)
        XCTAssertEqual(self.storage.supplementaryFooterKind, UICollectionView.elementKindSectionFooter)
        
        storage.configureForTableViewUsage()
        
        XCTAssertEqual(self.storage.supplementaryHeaderKind, DTTableViewElementSectionHeader)
        XCTAssertEqual(self.storage.supplementaryFooterKind, DTTableViewElementSectionFooter)
    }
}
