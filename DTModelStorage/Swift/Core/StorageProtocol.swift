//
//  StorageProtocol.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation
import UIKit

public protocol StorageProtocol
{
    var sections : [Section] { get }
    
    func objectAtIndexPath(path : NSIndexPath) -> Any?
    
    weak var delegate  : StorageUpdating? {get set}
}

public protocol HeaderFooterStorageProtocol
{
    func headerModelForSectionIndex(index: Int) -> Any?
    func footerModelForSectionIndex(index: Int) -> Any?
    
    var supplementaryHeaderKind : String? { get set }
    var supplementaryFooterKind : String?  { get set }
}

public protocol SupplementaryStorageProtocol
{
    func supplementaryModelOfKind(kind: String, sectionIndex : Int) -> Any?
}

public protocol StorageUpdating : class
{
    func storageDidPerformUpdate(update : StorageUpdate)
    func storageNeedsReloading()
}

public extension StorageProtocol
{
    public func objectForCell<T:ModelTransfer where T: UITableViewCell>(cell: T?, atIndexPath indexPath: NSIndexPath)-> T.CellModel?
    {
        return self.objectAtIndexPath(indexPath) as? T.CellModel
    }
    
    public func objectForCell<T:ModelTransfer where T: UICollectionViewCell>(cell: T?, atIndexPath indexPath: NSIndexPath)-> T.CellModel?
    {
        return self.objectAtIndexPath(indexPath) as? T.CellModel
    }
    
    public func objectForTableHeader<T:ModelTransfer where T:UIView>(headerView: T?, atSectionIndex sectionIndex: Int) -> T.CellModel?
    {
        return (self as? HeaderFooterStorageProtocol)?.headerModelForSectionIndex(sectionIndex) as? T.CellModel
    }
    
    public func objectForTableFooter<T:ModelTransfer where T:UIView>(footerView: T?, atSectionIndex sectionIndex: Int) -> T.CellModel?
    {
        return (self as? HeaderFooterStorageProtocol)?.footerModelForSectionIndex(sectionIndex) as? T.CellModel
    }
    
    public func objectForCollectionHeader<T:ModelTransfer where T:UICollectionReusableView>(headerView: T?, atSectionIndex sectionIndex: Int) -> T.CellModel?
    {
        return (self as? HeaderFooterStorageProtocol)?.headerModelForSectionIndex(sectionIndex) as? T.CellModel
    }
    
    public func objectForCollectionFooter<T:ModelTransfer where T:UICollectionReusableView>(footerView: T?, atSectionIndex sectionIndex: Int) -> T.CellModel?
    {
        return (self as? HeaderFooterStorageProtocol)?.footerModelForSectionIndex(sectionIndex) as? T.CellModel
    }
}