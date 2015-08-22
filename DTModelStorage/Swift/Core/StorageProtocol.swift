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
    func objectAtIndexPath(path : NSIndexPath) -> Any?
    
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
    /// Retrieve model of specific type for specific cell.
    /// - Parameter cell: UITableViewCell instance
    /// - Parameter indexPath: NSIndexPath of the cell
    /// - Returns: data model that belongs to this cell
    public func objectForCell<T:ModelTransfer where T: UITableViewCell>(cell: T?, atIndexPath indexPath: NSIndexPath)-> T.CellModel?
    {
        return self.objectAtIndexPath(indexPath) as? T.CellModel
    }
    
    /// Retrieve model of specific type for specific cell.
    /// - Parameter cell: UICollectionViewCell instance
    /// - Parameter indexPath: NSIndexPath of the cell
    /// - Returns: data model that belongs to this cell
    public func objectForCell<T:ModelTransfer where T: UICollectionViewCell>(cell: T?, atIndexPath indexPath: NSIndexPath)-> T.CellModel?
    {
        return self.objectAtIndexPath(indexPath) as? T.CellModel
    }
    
    /// Retrieve model of specific type for specific view.
    /// - Parameter headerView: UIView instance
    /// - Parameter indexPath: NSIndexPath of the view
    /// - Returns: data model that belongs to this view
    public func objectForTableHeader<T:ModelTransfer where T:UIView>(headerView: T?, atSectionIndex sectionIndex: Int) -> T.CellModel?
    {
        return (self as? HeaderFooterStorageProtocol)?.headerModelForSectionIndex(sectionIndex) as? T.CellModel
    }
    
    /// Retrieve model of specific type for specific view.
    /// - Parameter footerView: UIView instance
    /// - Parameter indexPath: NSIndexPath of the view
    /// - Returns: data model that belongs to this view
    public func objectForTableFooter<T:ModelTransfer where T:UIView>(footerView: T?, atSectionIndex sectionIndex: Int) -> T.CellModel?
    {
        return (self as? HeaderFooterStorageProtocol)?.footerModelForSectionIndex(sectionIndex) as? T.CellModel
    }
    
    /// Retrieve model of specific type for specific view.
    /// - Parameter headerView: UICollectionReusableView instance
    /// - Parameter indexPath: NSIndexPath of the view
    /// - Returns: data model that belongs to this view
    public func objectForCollectionHeader<T:ModelTransfer where T:UICollectionReusableView>(headerView: T?, atSectionIndex sectionIndex: Int) -> T.CellModel?
    {
        return (self as? HeaderFooterStorageProtocol)?.headerModelForSectionIndex(sectionIndex) as? T.CellModel
    }
    
    /// Retrieve model of specific type for specific view.
    /// - Parameter footerView: UICollectionReusableView instance
    /// - Parameter indexPath: NSIndexPath of the view
    /// - Returns: data model that belongs to this view
    public func objectForCollectionFooter<T:ModelTransfer where T:UICollectionReusableView>(footerView: T?, atSectionIndex sectionIndex: Int) -> T.CellModel?
    {
        return (self as? HeaderFooterStorageProtocol)?.footerModelForSectionIndex(sectionIndex) as? T.CellModel
    }
}