//
//  MemoryStorage+UpdateWithoutAnimations.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 11.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

extension MemoryStorage
{
    /// This method allows multiple simultaneous changes to memory storage without any notifications for delegate.
    ///
    /// You can think of this as a way of "manual" management for memory storage. Typical usage would be multiple insertions/deletions etc., if you don't need any animations. You can batch any changes in block, and call reloadData on your UI component after this method was call.
    /// - Note: You must call reloadData after calling this method, or you will get NSInternalInconsistencyException runtime, thrown by either UITableView or UICollectionView.
    public func updateWithoutAnimations(block: () -> Void)
    {
        let delegate = self.delegate
        self.delegate = nil
        block()
        self.delegate = delegate
    }
}