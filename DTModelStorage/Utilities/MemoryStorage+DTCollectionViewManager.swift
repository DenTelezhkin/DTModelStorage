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
    @available(*,unavailable, renamed="removeAllItems")
    public func removeAllCollectionItems() {}
    
    /// Move collection item from `sourceIndexPath` to `destinationIndexPath`.
    /// - Parameter sourceIndexPath: indexPath from which we need to move
    /// - Parameter toIndexPath: destination index path for table item
    @available(*, unavailable, renamed="moveItemAtIndexPath(_:toIndexPath:)")
    public func moveCollectionItemAtIndexPath(sourceIndexPath: NSIndexPath, toIndexPath: NSIndexPath){}
    
    /// Move collection view section
    /// - Parameter sourceSection: index of section, from which we'll be moving
    /// - Parameter destinationSection: index of section, where we'll be moving
    @available(*, unavailable, renamed="moveSection(_:toSection:)")
    public func moveCollectionViewSection(sourceSectionIndex: Int, toSection: Int){}
}