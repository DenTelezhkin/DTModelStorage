//
//  BaseStorage.swift
//  DTModelStorage
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

/// Base class for storage classes
open class BaseStorage: NSObject, HeaderFooterStorage
{
    /// Supplementary kind for header in current storage
    open var supplementaryHeaderKind: String?
    
    /// Supplementary kind for footer in current storage
    open var supplementaryFooterKind: String?
    
    /// Current update
    open var currentUpdate: StorageUpdate?
    
    /// Batch updates are in progress. If true, update will not be finished.
    open var batchUpdatesInProgress = false
    
    /// Delegate for storage updates
    open weak var delegate: StorageUpdating?
    
    /// Performs update `block` in storage. After update is finished, delegate will be notified.
    /// Parameter block: Block to execute
    /// - Note: This method allows to execute several updates in a single batch. It is similar to UICollectionView method `performBatchUpdates:`.
    /// - Warning: Performing mutually exclusive updates inside block can cause application crash.
    open func performUpdates( _ block: () -> Void) {
        batchUpdatesInProgress = true
        startUpdate()
        block()
        batchUpdatesInProgress = false
        finishUpdate()
    }
    
    /// Starts update in storage. 
    ///
    /// This creates StorageUpdate instance and stores it into `currentUpdate` property.
    open func startUpdate(){
        if self.currentUpdate == nil {
            self.currentUpdate = StorageUpdate()
        }
    }
    
    /// Finishes update. 
    ///
    /// Method verifies, that update is not empty, and sends updates to the delegate. After this method finishes, `currentUpdate` property is nilled out.
    open func finishUpdate()
    {
        guard batchUpdatesInProgress == false else { return }
        
        defer { currentUpdate = nil }
        
        if let update = currentUpdate {
            if update.isEmpty {
                return
            }
            delegate?.storageDidPerformUpdate(update)
        }
    }
    
    /// Configures storage for using with UITableView
    open func configureForTableViewUsage()
    {
        self.supplementaryHeaderKind = DTTableViewElementSectionHeader
        self.supplementaryFooterKind = DTTableViewElementSectionFooter
    }
    
    /// Configures storage for using with UICollectionViewFlowLayout
    open func configureForCollectionViewFlowLayoutUsage()
    {
        self.supplementaryHeaderKind = UICollectionElementKindSectionHeader
        self.supplementaryFooterKind = UICollectionElementKindSectionFooter
    }
    
    // MARK - HeaderFooterStorage
    
    /// Returns header model from section with section `index` or nil, if it was not set.
    /// - Requires: supplementaryHeaderKind to be set prior to calling this method
    open func headerModel(forSection index: Int) -> Any? {
        guard let kind = supplementaryHeaderKind else {
            assertionFailure("supplementaryHeaderKind property was not set before calling headerModelForSectionIndex: method")
            return nil
        }
        return (self as? SupplementaryStorage)?.supplementaryModel(ofKind:kind, forSectionAt: IndexPath(item: 0, section: index))
    }
    
    /// Returns footer model from section with section `index` or nil, if it was not set.
    /// - Requires: supplementaryFooterKind to be set prior to calling this method
    open func footerModel(forSection index: Int) -> Any? {
        guard let kind = supplementaryFooterKind else {
            assertionFailure("supplementaryFooterKind property was not set before calling footerModelForSectionIndex: method")
            return nil
        }
        return (self as? SupplementaryStorage)?.supplementaryModel(ofKind:kind, forSectionAt: IndexPath(item: 0, section: index))
    }
}
