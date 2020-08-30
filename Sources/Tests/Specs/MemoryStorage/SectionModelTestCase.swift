//
//  SectionModelTestCase.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 10.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTModelStorage

class SectionModelTestCase: XCTestCase {

    var section: SectionModel!
    
    override func setUp() {
        super.setUp()
        section = SectionModel()
    }
    
    func testItemsOfTypeWorks()
    {
        section.items = [1, 2, 3]
        
        XCTAssertEqual(section.items(ofType: Int.self), [1, 2, 3])
        XCTAssertEqual(section.item(at: 2) as? Int, 3)
        XCTAssertNil(section.item(at: 3))
    }
}
