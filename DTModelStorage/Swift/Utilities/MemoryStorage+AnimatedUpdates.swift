//
//  MemoryStorage+AnimatedUpdates.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 18.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

//MARK: TODO - Refactor with protocol extensions on Swift 2

public protocol TableViewStorageUpdating
{
    func performAnimatedUpdate(block : (UITableView) -> Void)
}

public extension MemoryStorage
{
    public func removeAllTableItems()
    {
        for section in self.sections {
            (section as! SectionModel).objects.removeAll(keepCapacity: false)
        }
        if let delegate = self.delegate as? TableViewStorageUpdating {
            delegate.performAnimatedUpdate({ (tableView) -> Void in
                tableView.reloadData()
            })
        }
    }
    
    public func moveTableItemAtIndexPath(sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    {
        if !(self.delegate is TableViewStorageUpdating) {
            return
        }
        
        self.startUpdate()
        
        // MARK: - Replace with guard on Swift 2
        let item = self.objectAtIndexPath(sourceIndexPath)
        if item == nil {
            print("DTTableViewManager: source indexPath should not be nil when moving table item")
            return
        }
        
        let sourceSection = self.getValidSection(sourceIndexPath.section)
        let destinationSection = self.getValidSection(destinationIndexPath.section)
        if destinationSection.objects.count < destinationIndexPath.row {
            print("DTTableViewManager: failed moving item to indexPath: %@, only %@ items in section")
            self.currentUpdate = nil
            return
        }
        (self.delegate as! TableViewStorageUpdating).performAnimatedUpdate { (tableView) in
            tableView.insertSections(self.currentUpdate!.insertedSectionIndexes,
                withRowAnimation: UITableViewRowAnimation.Automatic)
            sourceSection.objects.removeAtIndex(sourceIndexPath.row)
            destinationSection.objects.insert(item, atIndex: destinationIndexPath.row)
            tableView.moveRowAtIndexPath(sourceIndexPath, toIndexPath: destinationIndexPath)
        }
        self.currentUpdate = nil
    }
    
    public func moveTableViewSection(sourceSection: Int, toSection destinationSection: Int)
    {
        if !(self.delegate is TableViewStorageUpdating) {
            return
        }
    
        let validSectionFrom = self.getValidSection(sourceSection)
        let _ = self.getValidSection(destinationSection)
        self.sections.removeAtIndex(sourceSection)
        self.sections.insert(validSectionFrom, atIndex: destinationSection)
        
        (self.delegate as! TableViewStorageUpdating).performAnimatedUpdate { (tableView) in
            tableView.moveSection(sourceSection, toSection: destinationSection)
        }
    }
}