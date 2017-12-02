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
import Nimble

class SectionModelTestCase: XCTestCase {

    var section: SectionModel!
    
    override func setUp() {
        super.setUp()
        section = SectionModel()
    }
    
    func testSectionModelSupplementaryModelChange()
    {
        section.setSupplementaryModel("bar", forKind: "foo", atIndex: 0)
        
        XCTAssertEqual(section.supplementaryModel(ofKind: "foo", atIndex: 0) as? String ?? "", "bar")
        
        section.setSupplementaryModel(nil, forKind: "foo", atIndex: 0)
        XCTAssert(section.supplementaryModel(ofKind: "foo", atIndex: 0) == nil)
    }

//    func testAnyArrayWorks()
//    {
//        let arrayOfInts = [1,2,3]
//        section.setItems(arrayOfInts)
//        
//        expect(section.items as? [Int]) == [1,2,3]
//    }
    
    func testItemsOfTypeWorks()
    {
        let section = SectionModel()
        section.setItems([1, 2, 3])
        
        expect(section.items(ofType: Int.self)) == [1, 2, 3]
    }
}
