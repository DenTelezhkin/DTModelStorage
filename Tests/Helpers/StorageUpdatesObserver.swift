//
//  StorageUpdatesObserver.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 11.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import DTModelStorage

func indexPath(_ item:Int, _ section:Int) -> IndexPath
{
    return IndexPath(item: item, section: section)
}

class StorageUpdatesObserver : StorageUpdating
{
    var update : StorageUpdate?
    var storageNeedsReloadingFlag = false
    
    init(){}
    
    func storageNeedsReloading() {
        storageNeedsReloadingFlag = true
    }
    
    func storageDidPerformUpdate(_ update: StorageUpdate) {
        self.update = update
    }
}
