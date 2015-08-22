//
//  MemoryStorage+AnimatedUpdates.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 18.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

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
        guard delegate is TableViewStorageUpdating else { return }
        
        for section in self.sections {
            (section as! SectionModel).objects.removeAll(keepCapacity: false)
        }
        if let delegate = self.delegate as? TableViewStorageUpdating {
            delegate.performAnimatedUpdate({ (tableView) -> Void in
                tableView.reloadData()
            })
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
    /// - Parameter destionationSection: index of section, where we'll be moving
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