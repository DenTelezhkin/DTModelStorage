//
//  Storage.swift
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

/// `Storage` protocol is used to define common interface for storage classes.
public protocol Storage
{
    /// Array of sections, conforming to `Section` protocol.
    var sections : [Section] { get }
    
    /// Returns item at concrete indexPath.
    func item(at indexPath : IndexPath) -> Any?
    
    /// Delegate property used to notify about current data storage changes.
    weak var delegate  : StorageUpdating? {get set}
}

public protocol SupplementaryStorage
{
    /// Returns supplementary model of `kind` for section at `indexPath`.
    func supplementaryModel(ofKind kind: String, forSectionAt indexPath: IndexPath) -> Any?
}

public protocol HeaderFooterStorage
{
    /// Returns header model for section with section `index` or nil if not found.
    func headerModel(forSection index: Int) -> Any?
    
    /// Returns footer model for section with section `index` or nil if not found.
    func footerModel(forSection index: Int) -> Any?
    
    /// Supplementary kind for header in current storage
    var supplementaryHeaderKind : String? { get set }
    
    /// Supplementary kind for footer in current storage
    var supplementaryFooterKind : String?  { get set }
}

public protocol SectionLocationIdentifyable : class {
    /// Returns section index for section, or nil if section was not found.
    func sectionIndex(for: Section) -> Int?
}

public protocol SupplementaryAccessible : class {
    
    /// Section index for current section
    var currentSectionIndex: Int? { get }
    
    /// delegate, that knows about current section index in storage.
    weak var sectionLocationDelegate : SectionLocationIdentifyable? { get set }
    
    /// Supplementaries dictionary
    var supplementaries: [String: [Int:Any]] { get set }
    
    /// Returns supplementary model of `kind` at `index` or nil, if it was not found
    func supplementaryModel(ofKind kind: String, atIndex index: Int) -> Any?
    
    /// Sets supplementary `model` for `kind` at `index`
    func setSupplementaryModel(_ model : Any?, forKind kind: String, atIndex index: Int)
}

extension SupplementaryAccessible {
    /// Returns supplementary model of `kind` at `index` or nil, if it was not found
    public func supplementaryModel(ofKind kind: String, atIndex index: Int) -> Any?
    {
        return self.supplementaries[kind]?[index]
    }
    
    /// Sets supplementary `model` for `kind` at `index`
    public func setSupplementaryModel(_ model : Any?, forKind kind: String, atIndex index: Int)
    {
        var dictionary: [Int:Any] = supplementaries[kind] ?? [:]
        dictionary[index] = model
        self.supplementaries[kind] = dictionary
    }
}

/// `StorageUpdating` protocol is used to transfer data storage updates.
public protocol StorageUpdating : class
{
    /// Transfers data storage updates. 
    ///
    /// Object, that implements this method, may react to received update by updating UI for current storage.
    func storageDidPerformUpdate(_ update : StorageUpdate)
    
    /// Method is called when UI needs to be fully updated for data storage changes.
    func storageNeedsReloading()
}

// DEPRECATED

public extension Storage {
    @available(*,unavailable,renamed:"item(at:)")
    func itemAtIndexPath(_ : IndexPath) -> Any? {
        fatalError("UNAVAILABLE")
    }
}

public extension SupplementaryStorage {
    @available(*,unavailable,renamed:"supplementaryModel(ofKind:forSectionAt:)")
    func supplementaryModelOfKind(_ kind: String, sectionIndexPath : IndexPath) -> Any? {
        fatalError("UNAVAILABLE")
    }
}

public extension HeaderFooterStorage {
    @available(*,unavailable,renamed: "headerModel(forSection:)")
    func headerModelForSectionIndex(_ index: Int) -> Any? {
        fatalError("UNAVAILABLE")
    }
    @available(*,unavailable,renamed: "footerModel(forSection:)")
    func footerModelForSectionIndex(_ index: Int) -> Any? {
        fatalError("UNAVAILABLE")
    }
}

public extension SupplementaryAccessible {
    @available(*,unavailable,renamed:"supplementaryModel(ofKind:atIndex:)")
    public func supplementaryModelOfKind(_ kind: String, atIndex index: Int) -> Any?
    {
        fatalError("UNAVAILABLE")
    }
}

@available(*,unavailable,renamed:"Storage")
public protocol StorageProtocol {}

@available(*,unavailable,renamed:"SupplementaryStorage")
public protocol SupplementaryStorageProtocol {}

@available(*,unavailable,renamed:"HeaderFooterStorage")
public protocol HeaderFooterStorageProtocol {}
