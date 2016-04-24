//
//  StorageProtocol.swift
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

/// `StorageProtocol` protocol is used to define common interface for storage classes.
public protocol StorageProtocol
{
    /// Array of sections, conforming to `Section` protocol.
    var sections : [Section] { get }
    
    /// Returns item at concrete indexPath.
    func itemAtIndexPath(path : NSIndexPath) -> Any?
    
    /// Delegate property used to notify about current data storage changes.
    weak var delegate  : StorageUpdating? {get set}
}

public protocol HeaderFooterStorageProtocol
{
    /// Getter method for header model for current section.
    /// - Parameter index: Number of section.
    /// - Returns: Header model for section at index.
    func headerModelForSectionIndex(index: Int) -> Any?
    
    /// Getter method for footer model for current section.
    /// - Parameter index: Number of section.
    /// - Returns: Footer model for section at index.
    func footerModelForSectionIndex(index: Int) -> Any?
    
    /// Supplementary kind for header in current storage
    var supplementaryHeaderKind : String? { get set }
    
    /// Supplementary kind for footer in current storage
    var supplementaryFooterKind : String?  { get set }
}

public protocol SupplementaryStorageProtocol
{
    /// Storage class may implement this method to return supplementary models for section.
    /// - Parameter kind: supplementary kind
    /// - Parameter sectionIndex: index of section
    /// - Returns supplementary model for given kind for given section
    func supplementaryModelOfKind(kind: String, sectionIndex : Int) -> Any?
}

public protocol SupplementaryAccessible : class {
    
    var supplementaries: [String:Any] { get set }
    
    /// Retrieve supplementaryModel of specific kind
    /// - Parameter: kind - kind of supplementary
    /// - Returns: supplementary model or nil, if there are no model
    func supplementaryModelOfKind(kind: String) -> Any?
    
    /// Set supplementary model of specific kind
    /// - Parameter model: model to set
    /// - Parameter forKind: kind of supplementary
    func setSupplementaryModel(model : Any?, forKind kind: String)
}

extension SupplementaryAccessible {
    /// Retrieve supplementaryModel of specific kind
    /// - Parameter: kind - kind of supplementary
    /// - Returns: supplementary model or nil, if there are no model
    public func supplementaryModelOfKind(kind: String) -> Any?
    {
        return self.supplementaries[kind]
    }
    
    /// Set supplementary model of specific kind
    /// - Parameter model: model to set
    /// - Parameter forKind: kind of supplementary
    public func setSupplementaryModel(model : Any?, forKind kind: String)
    {
        self.supplementaries[kind] = model
    }
}

/// `StorageUpdating` protocol is used to transfer data storage updates.
public protocol StorageUpdating : class
{
    /// Transfers data storage updates. Object, that implements this method, may react to received update by updating it's UI.
    func storageDidPerformUpdate(update : StorageUpdate)
    
    /// Method is called when UI needs to be fully updated for data storage changes.
    func storageNeedsReloading()
}

public extension StorageProtocol
{
    /// Retrieve model of specific type at index path.
    /// - Parameter cell: UITableViewCell type
    /// - Parameter indexPath: NSIndexPath of the data model
    /// - Returns: data model that belongs to this index path.
    /// - Note: Method does not require cell to be visible, however it requires that storage really contains object of `ModelType` at specified index path, otherwise it will return nil.
    public func itemForCellClass<T:ModelTransfer where T: UITableViewCell>(cellClass: T.Type, atIndexPath indexPath: NSIndexPath)-> T.ModelType?
    {
        return self.itemAtIndexPath(indexPath) as? T.ModelType
    }
    
    /// Retrieve model of specific type at index path.
    /// - Parameter cell: UICollectionViewCell type.
    /// - Parameter indexPath: NSIndexPath of the data model.
    /// - Returns: data model that belongs to this index path.
    /// - Note: Method does not require cell to be visible, however it requires that storage really contains object of `ModelType` at specified index path, otherwise it will return nil.
    public func itemForCellClass<T:ModelTransfer where T: UICollectionViewCell>(cellClass: T.Type, atIndexPath indexPath: NSIndexPath)-> T.ModelType?
    {
        return self.itemAtIndexPath(indexPath) as? T.ModelType
    }
    
    /// Retrieve model of specific type for section index.
    /// - Parameter headerView: UIView type
    /// - Parameter indexPath: NSIndexPath of the view
    /// - Returns: data model that belongs to this view
    /// - Note: Method does not require header to be visible, however it requires that storage really contains object of `ModelType` at specified section index, and storage to comply to `HeaderFooterStorageProtocol`, otherwise it will return nil.
    public func itemForHeaderClass<T:ModelTransfer where T:UIView>(headerClass: T.Type, atSectionIndex sectionIndex: Int) -> T.ModelType?
    {
        return (self as? HeaderFooterStorageProtocol)?.headerModelForSectionIndex(sectionIndex) as? T.ModelType
    }
    
    /// Retrieve model of specific type for section index.
    /// - Parameter footerView: UIView type
    /// - Parameter indexPath: NSIndexPath of the view
    /// - Returns: data model that belongs to this view
    /// - Note: Method does not require footer to be visible, however it requires that storage really contains object of `ModelType` at specified section index, and storage to comply to `HeaderFooterStorageProtocol`, otherwise it will return nil.
    public func itemForFooterClass<T:ModelTransfer where T:UIView>(footerClass: T.Type, atSectionIndex sectionIndex: Int) -> T.ModelType?
    {
        return (self as? HeaderFooterStorageProtocol)?.footerModelForSectionIndex(sectionIndex) as? T.ModelType
    }
}