//
//  StorageUpdatesObserver.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 11.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import ModelStorage

func indexPath(item:Int,_ section:Int) -> NSIndexPath
{
    return NSIndexPath(forItem: item, inSection: section)
}

class StorageUpdatesObserver : StorageUpdating
{
    var update : StorageUpdate?
    var storageNeedsReloadingFlag = false
    
    init(){}
    
    func storageNeedsReloading() {
        storageNeedsReloadingFlag = true
    }
    
    func storageDidPerformUpdate(update: StorageUpdate) {
        self.update = update
    }
}