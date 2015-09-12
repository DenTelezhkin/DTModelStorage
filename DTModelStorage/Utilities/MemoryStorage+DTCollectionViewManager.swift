//
//  MemoryStorage+DTCollectionViewManager.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 24.08.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

/// This protocol is used to determine, whether our delegate deals with UICollectionView
public protocol CollectionViewStorageUpdating
{
    /// Perform animated update on UICollectionView. This is useful, when animation consists of several actions.
    func performAnimatedUpdate(block : (UICollectionView) -> Void)
}

extension MemoryStorage
{
    /// Remove all items from UICollectionView.
    /// - Note: method will call .reloadData() when finishes.
    public func removeAllCollectionItems()
    {
        guard let collectionViewDelegate = delegate as? CollectionViewStorageUpdating else { return }
        
        for section in self.sections {
            (section as! SectionModel).objects.removeAll(keepCapacity: false)
        }
        
        collectionViewDelegate.performAnimatedUpdate { collectionView in
            collectionView.reloadData()
        }
    }
    
    /// Move collection item from `sourceIndexPath` to `destinationIndexPath`.
    /// - Parameter sourceIndexPath: indexPath from which we need to move
    /// - Parameter toIndexPath: destination index path for table item
    public func moveCollectionItemAtIndexPath(sourceIndexPath: NSIndexPath, toIndexPath: NSIndexPath)
    {
        guard self.delegate is CollectionViewStorageUpdating else { return }
        
        self.startUpdate()
        defer { self.currentUpdate = nil }
        
        guard let item = self.objectAtIndexPath(sourceIndexPath) else {
            print("DTCollectionViewManager: source indexPath should not be nil when moving collection item")
            return
        }
        let sourceSection = self.getValidSection(sourceIndexPath.section)
        let destinationSection = self.getValidSection(toIndexPath.section)
        
        guard destinationSection.objects.count >= toIndexPath.item else {
            print("DTCollectionViewManager: failed moving item to indexPath: \(toIndexPath), only \(destinationSection.objects.count) items in section")
            return
        }
        
        (self.delegate as! CollectionViewStorageUpdating).performAnimatedUpdate { collectionView in
            let sectionsToInsert = NSMutableIndexSet()
            for index in 0..<self.currentUpdate!.insertedSectionIndexes.count {
                if collectionView.numberOfSections() <= index {
                    sectionsToInsert.addIndex(index)
                }
            }
            
            collectionView.performBatchUpdates({
                collectionView.insertSections(sectionsToInsert)
                }, completion: nil)
            
            sourceSection.objects.removeAtIndex(sourceIndexPath.item)
            destinationSection.objects.insert(item, atIndex: toIndexPath.item)
            
            if sourceIndexPath.item == 0 && sourceSection.objects.count == 0 {
                collectionView.reloadData()
            }
            else {
                collectionView.performBatchUpdates({
                    collectionView.moveItemAtIndexPath(sourceIndexPath, toIndexPath: toIndexPath)
                    }, completion: nil)
            }
        }
    }
    
    /// Move collection view section
    /// - Parameter sourceSection: index of section, from which we'll be moving
    /// - Parameter destinationSection: index of section, where we'll be moving
    public func moveCollectionViewSection(sourceSectionIndex: Int, toSection: Int)
    {
        guard self.delegate is CollectionViewStorageUpdating else { return }
        
        self.startUpdate()
        defer { self.currentUpdate = nil }
        
        let sectionFrom = self.getValidSection(sourceSectionIndex)
        let _ = self.getValidSection(toSection)
        
        self.currentUpdate?.insertedSectionIndexes.removeIndex(toSection)
        
        (self.delegate as! CollectionViewStorageUpdating).performAnimatedUpdate { collectionView in
            if self.sections.count > collectionView.numberOfSections() {
                collectionView.reloadData()
            }
            else {
                collectionView.performBatchUpdates({
                    collectionView.insertSections(self.currentUpdate!.insertedSectionIndexes)
                    self.sections.removeAtIndex(sourceSectionIndex)
                    self.sections.insert(sectionFrom, atIndex: toSection)
                    collectionView.moveSection(sourceSectionIndex, toSection: toSection)
                    }, completion: nil)
            }
        }
    }
}