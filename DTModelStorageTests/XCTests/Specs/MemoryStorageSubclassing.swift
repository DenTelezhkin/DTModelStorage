//
//  MemoryStorageSubclassing.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 22.05.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest

class MemoryStorageSubclassing: XCTestCase {

    func testMemoryStorageConstructor()
    {
        let storage = TestMemoryStorage()
        
        XCTAssertNotNil(storage.sections)
    }

}
