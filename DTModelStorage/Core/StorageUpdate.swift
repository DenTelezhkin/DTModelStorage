//
//  StorageUpdate.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

struct StorageUpdate : Equatable
{
    var deletedSectionIndexes = NSMutableIndexSet()
    var insertedSectionIndexes = NSMutableIndexSet()
    var updatedSectionIndexes = NSMutableIndexSet()
    
    var deletedRowIndexPaths = [NSIndexPath]()
    var insertedRowIndexPaths = [NSIndexPath]()
    var updatedRowIndexPaths = [NSIndexPath]()
}

func ==(left : StorageUpdate, right: StorageUpdate) -> Bool
{
    if !left.deletedSectionIndexes.isEqualToIndexSet(right.deletedSectionIndexes) { return false }
    if !left.insertedSectionIndexes.isEqualToIndexSet(right.insertedSectionIndexes) { return false }
    if !left.updatedSectionIndexes.isEqualToIndexSet(right.updatedSectionIndexes) { return false }
    if !(left.deletedRowIndexPaths == right.deletedRowIndexPaths) { return false }
    if !(left.insertedRowIndexPaths == right.insertedRowIndexPaths) { return false }
    if !(left.updatedRowIndexPaths == right.updatedRowIndexPaths) { return false }
    return true
}