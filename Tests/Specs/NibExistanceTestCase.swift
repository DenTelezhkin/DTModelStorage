//
//  NibExistanceTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 18.09.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage

class NibExistanceTestCase: XCTestCase {
    
    func testNibDoesNotExist()
    {
        let bundle = Bundle(for: type(of: self))
        XCTAssertFalse(UINib.nibExists(withNibName: "Foo", inBundle: bundle))
        #if os(iOS)
        XCTAssert(UINib.nibExists(withNibName: "iOSEmptyNib", inBundle: bundle))
        #elseif os(tvOS)
        XCTAssertTrue(UINib.nibExists(withNibName: "tvOSEmptyNib", inBundle: bundle))
        #endif
    }
}
