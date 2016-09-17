//
//  StorageUpdate.swift
//  DTModelStorage
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
public struct StorageUpdate : Equatable, CustomStringConvertible
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
    public var deletedRowIndexPaths = Set<IndexPath>()
    
    /// Index paths of rows that need to be inserted in current update.
    public var insertedRowIndexPaths = Set<IndexPath>()
    
    /// Index paths of rows that need to be updated in current update.
    public var updatedRowIndexPaths = Set<IndexPath>()
    
    /// Array if index paths to be moved in current update.
    public var movedRowIndexPaths = [[IndexPath]]()
    
    /// Create an empty update.
    public init(){}
    
    /// Returns true, if update is empty.
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
    
    /// Compare StorageUpdates
    static public func ==(left : StorageUpdate, right: StorageUpdate) -> Bool
    {
        guard left.deletedSectionIndexes == right.deletedSectionIndexes else { return false }
        guard left.insertedSectionIndexes == right.insertedSectionIndexes else { return false }
        guard left.updatedSectionIndexes == right.updatedSectionIndexes else { return false }
        guard left.movedSectionIndexes.elementsEqual(right.movedSectionIndexes, by: { $0 == $1 }) else {
            return false
        }
        guard left.deletedRowIndexPaths == right.deletedRowIndexPaths else { return false }
        guard left.insertedRowIndexPaths == right.insertedRowIndexPaths else { return false }
        guard left.updatedRowIndexPaths == right.updatedRowIndexPaths else { return false }
        guard left.movedRowIndexPaths.elementsEqual(right.movedRowIndexPaths, by: { $0 == $1 }) else {
            return false
        }
        return true
    }
    
    public var description : String {
        return "Deleted section indexes: \(deletedSectionIndexes)\n" +
            "Inserted section indexes : \(insertedSectionIndexes)\n" +
            "Updated section indexes : \(updatedSectionIndexes)\n" +
            "Deleted row indexPaths: \(deletedRowIndexPaths)\n" +
            "Inserted row indexPaths: \(insertedRowIndexPaths)\n" +
            "Updated row indexPaths: \(updatedRowIndexPaths)\n"
    }
}

