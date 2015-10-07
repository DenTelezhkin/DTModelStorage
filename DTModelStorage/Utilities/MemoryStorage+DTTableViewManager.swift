//
//  MemoryStorage+AnimatedUpdates.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 18.07.15.
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
import UIKit

/// This protocol is used to determine, whether our delegate deals with UITableView
public protocol TableViewStorageUpdating
{
    /// Perform animated update on UITableView. This is useful, when animation consists of several actions.
    func performAnimatedUpdate(block : (UITableView) -> Void)
}

public extension MemoryStorage
{
    /// Remove all items from UITableView.
    /// - Note: method will call .reloadData() when finishes.
    @available(*,unavailable, renamed="removeAllItems")
    public func removeAllTableItems(){}
   
    /// Move table item from `sourceIndexPath` to `destinationIndexPath`.
    /// - Parameter sourceIndexPath: indexPath from which we need to move
    /// - Parameter toIndexPath: destination index path for table item
    @available(*, unavailable, renamed="moveItemFromIndexPath(_:toIndexPath:)")
    public func moveTableItemAtIndexPath(sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath){}
    
    /// Move table view section
    /// - Parameter sourceSection: index of section, from which we'll be moving
    /// - Parameter destinationSection: index of section, where we'll be moving
    @available(*, unavailable, renamed="moveSection(_:toSection:)")
    public func moveTableViewSection(sourceSection: Int, toSection destinationSection: Int) {}
}