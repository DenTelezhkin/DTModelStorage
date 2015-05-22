//
//  TestMemoryStorage.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 22.05.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import DTModelStorage

class TestMemoryStorage: DTMemoryStorage {
    override init()
    {
        super.init()
    }
}

class TestCoreDataStorage : DTCoreDataStorage
{
    var foo: String
    
    init(controller : NSFetchedResultsController)
    {
        foo = ""
        super.init(fetchResultsController: controller)
    }
}
