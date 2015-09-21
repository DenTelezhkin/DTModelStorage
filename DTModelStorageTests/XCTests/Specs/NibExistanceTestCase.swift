//
//  NibExistanceTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 18.09.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import Nimble
import DTModelStorage

class NibExistanceTestCase: XCTestCase {
    
    func testNibDoesNotExist()
    {
        let bundle = NSBundle(forClass: self.dynamicType)
        expect(UINib.nibExistsWithNibName("Foo", inBundle: bundle)) == false
        expect(UINib.nibExistsWithNibName("EmptyNib", inBundle: bundle)) == true
    }
}
