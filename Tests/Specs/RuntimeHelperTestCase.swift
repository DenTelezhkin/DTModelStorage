//
//  RuntimeHelperTestCase.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTModelStorage

class RuntimeHelperTestCase: XCTestCase {

    func testRuntimeHelperIsAbleToRecursivelyUnwrapButReturnNil()
    {
        let implicitlyUnwrapped : Int? = nil
        let unwrapped = RuntimeHelper.recursivelyUnwrapAnyValue(implicitlyUnwrapped as Any)
        XCTAssertNil(unwrapped)
    }
}
