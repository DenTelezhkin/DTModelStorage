//
//  BaseStorage.swift
//  DTModelStorageTests
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
import UIKit

/// Suggested supplementary kind for UITableView header
public let DTTableViewElementSectionHeader = "DTTableViewElementSectionHeader"
/// Suggested supplementary kind for UITableView footer
public let DTTableViewElementSectionFooter = "DTTableViewElementSectionFooter"

/// Base class for MemoryStorage and CoreDataStorage
public class BaseStorage : NSObject, HeaderFooterStorageProtocol
{
    /// Supplementary kind for header in current storage
    public var supplementaryHeaderKind : String?
    
    /// Supplementary kind for footer in current storage
    public var supplementaryFooterKind : String?
    
    /// Current update
    public var currentUpdate: StorageUpdate?
    
    /// Batch updates are in progress. If true, update will not be finished.
    public var batchUpdatesInProgress = false
    
    /// Delegate for storage updates
    public weak var delegate : StorageUpdating?
    
    /// Perform update in storage. After update is finished, delegate will be notified.
    /// Parameter block: Block to execute
    /// - Note: This method allows to execute several updates in a single batch. It is similar to UICollectionView method `performBatchUpdates:`.
    /// - Warning: Performing mutual exclusive updates inside block can cause application crash.
    public func performUpdates(@noescape block: () -> Void) {
        batchUpdatesInProgress = true
        startUpdate()
        block()
        batchUpdatesInProgress = false
        finishUpdate()
    }
    
    /// Start update in storage. This creates StorageUpdate instance and stores it into `currentUpdate` property.
    public func startUpdate(){
        if self.currentUpdate == nil {
            self.currentUpdate = StorageUpdate()
        }
    }
    
    /// Finished update. Method verifies, that update is not empty, and sends updates to the delegate. After this method finishes, `currentUpdate` property is nilled out.
    public func finishUpdate()
    {
        guard batchUpdatesInProgress == false else { return }
        
        defer { self.currentUpdate = nil }
        
        if self.currentUpdate != nil
        {
            if self.currentUpdate!.isEmpty() {
                return
            }
            self.delegate?.storageDidPerformUpdate(self.currentUpdate!)
        }
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
    
    // MARK - HeaderFooterStorageProtocol
    
    /// Header model for section.
    /// - Requires: supplementaryHeaderKind to be set prior to calling this method
    /// - Parameter index: index of section
    /// - Returns: header model for section, or nil if there are no model
    public func headerModelForSectionIndex(index: Int) -> Any? {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling headerModelForSectionIndex: method")
        return (self as? SupplementaryStorageProtocol)?.supplementaryModelOfKind(self.supplementaryHeaderKind!, sectionIndex: index)
    }
    
    /// Footer model for section.
    /// - Requires: supplementaryFooterKind to be set prior to calling this method
    /// - Parameter index: index of section
    /// - Returns: footer model for section, or nil if there are no model
    public func footerModelForSectionIndex(index: Int) -> Any? {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling footerModelForSectionIndex: method")
        return (self as? SupplementaryStorageProtocol)?.supplementaryModelOfKind(self.supplementaryFooterKind!, sectionIndex: index)
    }
}