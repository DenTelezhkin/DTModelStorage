//
//  StorageProtocol.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

protocol StorageProtocol
{
    var sections : [Section] { get }
    
    func objectAtIndexPath(path : NSIndexPath) -> Any?
}

protocol HeaderFooterStorageProtocol
{
    func headerModelForSectionIndex(index: Int) -> Any?
    func footerModelForSectionIndex(index: Int) -> Any?
    
    var supplementaryHeaderKind : String? { get set }
    var supplementaryFooterKind : String?  { get set }
}

protocol SupplementaryStorageProtocol
{
    func supplementaryModelOfKind(kind: String, sectionIndex : Int) -> Any?
}

protocol StorageUpdating : class
{
    func storageDidPerformUpdate(update : StorageUpdate)
    func storageNeedsReloading()
}