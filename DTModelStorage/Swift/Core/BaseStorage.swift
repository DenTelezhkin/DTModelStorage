//
//  BaseStorage.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

public let DTTableViewElementSectionHeader = "DTTableViewElementSectionHeader"
public let DTTableViewElementSectionFooter = "DTTableViewElementSectionFooter"

public class BaseStorage : NSObject
{
    public var supplementaryHeaderKind : String?
    public var supplementaryFooterKind : String?
    internal var currentUpdate: StorageUpdate?
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
    
    public func configureForTableViewUsage()
    {
        self.supplementaryHeaderKind = DTTableViewElementSectionHeader
        self.supplementaryFooterKind = DTTableViewElementSectionFooter
    }
    
    public func configureForCollectionViewFlowLayoutUsage()
    {
        self.supplementaryHeaderKind = UICollectionElementKindSectionHeader
        self.supplementaryFooterKind = UICollectionElementKindSectionFooter
    }
}