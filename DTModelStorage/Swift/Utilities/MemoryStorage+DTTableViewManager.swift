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
    public func removeAllTableItems()
    {
        guard let tableViewDelegate = delegate as? TableViewStorageUpdating else { return }
        
        for section in self.sections {
            (section as! SectionModel).objects.removeAll(keepCapacity: false)
        }
        tableViewDelegate.performAnimatedUpdate { tableView in
            tableView.reloadData()
        }
    }
   
    /// Move table item from `sourceIndexPath` to `destinationIndexPath`.
    /// - Parameter sourceIndexPath: indexPath from which we need to move
    /// - Parameter toIndexPath: destination index path for table item
    public func moveTableItemAtIndexPath(sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    {
        guard delegate is TableViewStorageUpdating else { return }
        
        self.startUpdate()
        defer { self.currentUpdate = nil }
        
        guard let item = self.objectAtIndexPath(sourceIndexPath) else {
            print("MemoryStorage: source indexPath should not be nil when moving table item")
            return
        }
        
        let sourceSection = self.getValidSection(sourceIndexPath.section)
        let destinationSection = self.getValidSection(destinationIndexPath.section)
        
        
        if destinationSection.objects.count < destinationIndexPath.row {
            print("MemoryStorage: failed moving item to indexPath: %@, only %@ items in section")
            return
        }
        (self.delegate as! TableViewStorageUpdating).performAnimatedUpdate { (tableView) in
            tableView.insertSections(self.currentUpdate!.insertedSectionIndexes,
                withRowAnimation: UITableViewRowAnimation.Automatic)
            sourceSection.objects.removeAtIndex(sourceIndexPath.row)
            destinationSection.objects.insert(item, atIndex: destinationIndexPath.row)
            tableView.moveRowAtIndexPath(sourceIndexPath, toIndexPath: destinationIndexPath)
        }
    }
    
    /// Move table view section
    /// - Parameter sourceSection: index of section, from which we'll be moving
    /// - Parameter destinationSection: index of section, where we'll be moving
    public func moveTableViewSection(sourceSection: Int, toSection destinationSection: Int)
    {
        guard delegate is TableViewStorageUpdating else { return }
    
        let validSectionFrom = self.getValidSection(sourceSection)
        let _ = self.getValidSection(destinationSection)
        self.sections.removeAtIndex(sourceSection)
        self.sections.insert(validSectionFrom, atIndex: destinationSection)
        
        (delegate as! TableViewStorageUpdating).performAnimatedUpdate { (tableView) in
            tableView.moveSection(sourceSection, toSection: destinationSection)
        }
    }
}