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

// Possible change types for objects and sections
public enum ChangeType: String {
    case delete
    case move
    case insert
    case update
}

/// Object representing update in storage.
public struct StorageUpdate: Equatable, CustomStringConvertible
{
    /// Object changes in update, in order of occurence
    public var objectChanges = [(ChangeType, [IndexPath])]()
    
    /// Section changes in update, in order of occurence
    public var sectionChanges = [(ChangeType, [Int])]()
    
    /// Objects that were updated, with initial index paths
    /// Discussion: This is done because UITableView and UICollectionView defer updating of items after all insertions and deletions are made. Therefore, resulting indexPaths are shifted, and update may be called on wrong indexPath. By storing objects from initial update call, we ensure, that objects used in update are correct.
    public var updatedObjects = [IndexPath: Any]()
    
    /// Create an empty update.
    public init(){}
    
    /// Returns true, if update is empty.
    public var isEmpty: Bool {
        return objectChanges.isEmpty && sectionChanges.isEmpty
    }
    
    /// Compare StorageUpdates
    static public func ==(left: StorageUpdate, right: StorageUpdate) -> Bool
    {
        if left.objectChanges.count != right.objectChanges.count ||
            left.sectionChanges.count != right.sectionChanges.count {
            return false
        }
        
        for (index, _) in left.objectChanges.enumerated() {
            if left.objectChanges[index].0 != right.objectChanges[index].0 ||
                left.objectChanges[index].1 != right.objectChanges[index].1
            {
                return false
            }
        }
        for (index, _) in left.sectionChanges.enumerated() {
            if left.sectionChanges[index].0 != right.sectionChanges[index].0 ||
                left.sectionChanges[index].1 != right.sectionChanges[index].1
            {
                return false
            }
        }
        return true
    }
    
    public var description: String {
        let objectChangesString = "Object changes: \n" + objectChanges.flatMap({ change, indexPaths in
            return change.rawValue.capitalized + " \(indexPaths)"
        }).reduce("", +)
        let sectionChangesString = "Section changes:" + objectChanges.flatMap({ change, index in
            return change.rawValue.capitalized + " \(index))"
        }).reduce("", +)
        return objectChangesString + "\n" + sectionChangesString
    }
}
