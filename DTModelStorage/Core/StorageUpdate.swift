//
//  StorageUpdate.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

public struct StorageUpdate : Equatable
{
    public var deletedSectionIndexes = NSMutableIndexSet()
    public var insertedSectionIndexes = NSMutableIndexSet()
    public var updatedSectionIndexes = NSMutableIndexSet()
    
    public var deletedRowIndexPaths = [NSIndexPath]()
    public var insertedRowIndexPaths = [NSIndexPath]()
    public var updatedRowIndexPaths = [NSIndexPath]()
    
    public init(){}
}

public func ==(left : StorageUpdate, right: StorageUpdate) -> Bool
{
    if !left.deletedSectionIndexes.isEqualToIndexSet(right.deletedSectionIndexes) { return false }
    if !left.insertedSectionIndexes.isEqualToIndexSet(right.insertedSectionIndexes) { return false }
    if !left.updatedSectionIndexes.isEqualToIndexSet(right.updatedSectionIndexes) { return false }
    if !(left.deletedRowIndexPaths == right.deletedRowIndexPaths) { return false }
    if !(left.insertedRowIndexPaths == right.insertedRowIndexPaths) { return false }
    if !(left.updatedRowIndexPaths == right.updatedRowIndexPaths) { return false }
    return true
}