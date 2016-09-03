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
        let bundle = Bundle(for: type(of: self))
        expect(UINib.nibExists(withNibName: "Foo", inBundle: bundle)) == false
        expect(UINib.nibExists(withNibName: "EmptyNib", inBundle: bundle)) == true
    }
}
