//
//  StorageUpdate.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/// Object representing update in storage.
public struct StorageUpdate : Equatable
{
    /// Indexes of section to be deleted in current update
    public var deletedSectionIndexes = Set<Int>()
    
    /// Indexes of sections to be inserted in current update
    public var insertedSectionIndexes = Set<Int>()
    
    /// Indexes of sections to be updated in current update.
    public var updatedSectionIndexes = Set<Int>()
    
    /// Array of section indexes to be moved in current update
    public var movedSectionIndexes = [[Int]]()

    /// Index paths of rows that need to be deleted in current update.
    public var deletedRowIndexPaths = Set<NSIndexPath>()
    
    /// Index paths of rows that need to be inserted in current update.
    public var insertedRowIndexPaths = Set<NSIndexPath>()
    
    /// Index paths of rows that need to be updated in current update.
    public var updatedRowIndexPaths = Set<NSIndexPath>()
    
    /// Array if index paths to be moved in current update.
    public var movedRowIndexPaths = [[NSIndexPath]]()
    
    /// Create an empty update.
    public init(){}
    
    /// Check whether update is empty.
    /// Returns: Returns true, if update does not contain any data.
    public func isEmpty() -> Bool {
        return deletedSectionIndexes.count == 0 &&
            insertedSectionIndexes.count == 0 &&
            updatedSectionIndexes.count == 0 &&
            movedSectionIndexes.count == 0 &&
            deletedRowIndexPaths.count == 0 &&
            insertedRowIndexPaths.count == 0 &&
            updatedRowIndexPaths.count == 0 &&
            movedRowIndexPaths.count == 0
    }
}

/// Compare StorageUpdates
public func ==(left : StorageUpdate, right: StorageUpdate) -> Bool
{
    if !(left.deletedSectionIndexes == right.deletedSectionIndexes) { return false }
    if !(left.insertedSectionIndexes == right.insertedSectionIndexes) { return false }
    if !(left.updatedSectionIndexes == right.updatedSectionIndexes) { return false }
    if !(left.movedSectionIndexes == right.movedSectionIndexes) { return false }
    if !(left.deletedRowIndexPaths == right.deletedRowIndexPaths) { return false }
    if !(left.insertedRowIndexPaths == right.insertedRowIndexPaths) { return false }
    if !(left.updatedRowIndexPaths == right.updatedRowIndexPaths) { return false }
    if !(left.movedRowIndexPaths == right.movedRowIndexPaths) { return false }
    return true
}

extension StorageUpdate : CustomStringConvertible
{
    public var description : String {
        return "Deleted section indexes: \(deletedSectionIndexes)\n" +
            "Inserted section indexes : \(insertedSectionIndexes)\n" +
            "Updated section indexes : \(updatedSectionIndexes)\n" +
            "Deleted row indexPaths: \(deletedRowIndexPaths)\n" +
            "Inserted row indexPaths: \(insertedRowIndexPaths)\n" +
            "Updated row indexPaths: \(updatedRowIndexPaths)\n"
    }
}

/// Workaround that allows Set<Int> to be converted to NSIndexSet
public protocol NSIndexSetConvertible {}
extension Int: NSIndexSetConvertible {}

public extension Set where Element : NSIndexSetConvertible
{
    /// Make NSIndexSet instance out of Set<Int>
    /// Returns: NSIndexSet with Ints inside
    func makeNSIndexSet() -> NSIndexSet {
        let indexSet = NSMutableIndexSet()
        for element in self {
            indexSet.addIndex(element as! Int)
        }
        return NSIndexSet(indexSet: indexSet)
    }
}