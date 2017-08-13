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
public protocol Storage : class
{
    /// Array of sections, conforming to `Section` protocol.
    var sections: [Section] { get }
    
    /// Returns item at concrete indexPath.
    func item(at indexPath: IndexPath) -> Any?
    
    /// Delegate property used to notify about current data storage changes.
    weak var delegate: StorageUpdating? {get set}
}

public protocol SupplementaryStorage : class
{
    /// Returns supplementary model of `kind` for section at `indexPath`.
    func supplementaryModel(ofKind kind: String, forSectionAt indexPath: IndexPath) -> Any?
}

public protocol HeaderFooterStorage : class
{
    /// Returns header model for section with section `index` or nil if not found.
    func headerModel(forSection index: Int) -> Any?
    
    /// Returns footer model for section with section `index` or nil if not found.
    func footerModel(forSection index: Int) -> Any?
    
    /// Supplementary kind for header in current storage
    var supplementaryHeaderKind: String? { get set }
    
    /// Supplementary kind for footer in current storage
    var supplementaryFooterKind: String?  { get set }
}


/// Allows setting supplementaries for kind for various storage subclasses. Currently `MemoryStorage` and `RealmStorage` implement this protocol.
public protocol HeaderFooterSettable : class, HeaderFooterStorage {
    func setSupplementaries(_ models: [[Int: Any]], forKind kind: String)
}

extension HeaderFooterSettable {
    /// Sets section header `models`, using `supplementaryHeaderKind`.
    ///
    /// - Note: `supplementaryHeaderKind` property should be set before calling this method.
    public func setSectionHeaderModels<T>(_ models: [T])
    {
        assert(supplementaryHeaderKind != nil, "Please set supplementaryHeaderKind property before setting section header models")
        var supplementaries = [[Int: Any]]()
        for model in models {
            supplementaries.append([0: model])
        }
        setSupplementaries(supplementaries, forKind: supplementaryHeaderKind!)
    }
    
    /// Sets section footer `models`, using `supplementaryFooterKind`.
    ///
    /// - Note: `supplementaryFooterKind` property should be set before calling this method.
    public func setSectionFooterModels<T>(_ models: [T])
    {
        assert(supplementaryFooterKind != nil, "Please set supplementaryFooterKind property before setting section header models")
        var supplementaries = [[Int: Any]]()
        for model in models {
            supplementaries.append([0: model])
        }
        setSupplementaries(supplementaries, forKind: supplementaryFooterKind!)
    }
}

/// `StorageUpdating` protocol is used to transfer data storage updates.
public protocol StorageUpdating : class
{
    /// Transfers data storage updates. 
    ///
    /// Object, that implements this method, may react to received update by updating UI for current storage.
    func storageDidPerformUpdate(_ update: StorageUpdate)
    
    /// Method is called when UI needs to be fully updated for data storage changes.
    func storageNeedsReloading()
}
