//
//  BaseStorage.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

/// Suggested supplementary kind for UITableView header
public let DTTableViewElementSectionHeader = "DTTableViewElementSectionHeader"
/// Suggested supplementary kind for UITableView footer
public let DTTableViewElementSectionFooter = "DTTableViewElementSectionFooter"

/// Base class for MemoryStorage and CoreDataStorage
public class BaseStorage : NSObject
{
    /// Supplementary kind for header in current storage
    public var supplementaryHeaderKind : String?
    
    /// Supplementary kind for footer in current storage
    public var supplementaryFooterKind : String?
    
    /// Current update
    internal var currentUpdate: StorageUpdate?
    
    /// Delegate for storage updates
    public weak var delegate : StorageUpdating?
}

extension BaseStorage
{
    func startUpdate(){
        self.currentUpdate = StorageUpdate()
    }
    
    func finishUpdate()
    {
        if self.currentUpdate != nil
        {
            if self.currentUpdate!.insertedRowIndexPaths.isEmpty &&
                self.currentUpdate!.updatedRowIndexPaths.isEmpty &&
                self.currentUpdate!.deletedRowIndexPaths.isEmpty &&
                self.currentUpdate!.insertedSectionIndexes.count == 0 &&
                self.currentUpdate!.updatedSectionIndexes.count == 0 &&
                self.currentUpdate!.deletedSectionIndexes.count == 0
            {
                self.currentUpdate = nil
                return
            }
            self.delegate?.storageDidPerformUpdate(self.currentUpdate!)
        }
        self.currentUpdate = nil
    }
    
    /// This method will configure storage for using with UITableView
    public func configureForTableViewUsage()
    {
        self.supplementaryHeaderKind = DTTableViewElementSectionHeader
        self.supplementaryFooterKind = DTTableViewElementSectionFooter
    }
    
    /// This method will configure storage for using with UICollectionViewFlowLayout
    public func configureForCollectionViewFlowLayoutUsage()
    {
        self.supplementaryHeaderKind = UICollectionElementKindSectionHeader
        self.supplementaryFooterKind = UICollectionElementKindSectionFooter
    }
}