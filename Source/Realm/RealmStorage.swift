//
//  RealmStorage.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 13.12.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//
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
import Realm.RLMResults
import RealmSwift

/// Storage class, that handles multiple `RealmSection` instances with Realm.Results<T>. It is similar with CoreDataStorage, but for Realm database. 
/// When created, it automatically subscribes for Realm notifications and notifies delegate when it's sections change.
open class RealmStorage : BaseStorage, Storage, SupplementaryStorage, SectionLocationIdentifyable
{
    /// Array of `RealmSection` objects
    open var sections = [Section]() {
        didSet {
            sections.forEach {
                ($0 as? SupplementaryAccessible)?.sectionLocationDelegate = self
            }
        }
    }
    
    /// Returns index of `section` or nil, if section is now found
    open func sectionIndex(for section: Section) -> Int? {
        return sections.index(where: {
            return ($0 as? RealmSection) === (section as? RealmSection)
        })
    }
    
    /// Storage for notification tokens of `Realm`
    fileprivate var notificationTokens: [Int:RealmSwift.NotificationToken] = [:]
    
    deinit {
        notificationTokens.values.forEach { token in
            token.stop()
        }
    }
    
    /// Returns section at `sectionIndex` or nil, if it does not exist
    ///
    /// - Returns: `RealmSection` instance
    open func section(at sectionIndex: Int) -> Section? {
        guard sectionIndex < sections.count else { return nil }
        
        return sections[sectionIndex]
    }
    
    /// Adds `RealmSection`, containing `results`.
    open func addSection<T:Object>(with results: Results<T>) {
        setSection(with: results, forSection: sections.count)
    }
    
    /// Sets `RealmSection`, containing `results` objects, for section at `index`. 
    ///
    ///  Calls `delegate.storageNeedsReloading()` after section is set. Subscribes for Realm notifications to automatically update section when update occurs.
    /// - Note: if index is less than number of section, this method won't do anything.
    open func setSection<T:Object>(with results: Results<T>, forSection index: Int) {
        guard index <= sections.count else { return }
        
        let section = RealmSection(results: results)
        notificationTokens[index]?.stop()
        notificationTokens[index] = nil
        if index == sections.count {
            sections.append(section)
        } else {
            sections[index] = section
        }
        if results.realm?.configuration.readOnly == false {
            let sectionIndex = sections.count - 1
            notificationTokens[index] = results.addNotificationBlock({ [weak self] change in
                self?.handleChange(change, inSection: sectionIndex)
                })
        }
        delegate?.storageNeedsReloading()
    }
    
    /// Handles `change` in `section`, automatically notifying delegate.
    internal final func handleChange<T>(_ change: RealmCollectionChange<T>, inSection: Int)
    {
        if case RealmCollectionChange.initial(_) = change {
            delegate?.storageNeedsReloading()
            return
        }
        guard case let RealmCollectionChange.update(_, deletions, insertions, modifications) = change else {
            return
        }
        startUpdate()
        deletions.forEach{ [weak self] in
            self?.currentUpdate?.deletedRowIndexPaths.insert(IndexPath(item: $0, section: inSection))
        }
        insertions.forEach{ [weak self] in
            self?.currentUpdate?.insertedRowIndexPaths.insert(IndexPath(item: $0, section: inSection))
        }
        modifications.forEach{ [weak self] in
            self?.currentUpdate?.updatedRowIndexPaths.insert(IndexPath(item: $0, section: inSection))
        }
        finishUpdate()
    }
    
    /// Delete sections at `indexes`. 
    ///
    /// Delegate will be automatically notified of changes.
    open func deleteSections(_ indexes: IndexSet) {
        startUpdate()
        defer { self.finishUpdate() }
        
        var i = indexes.last ?? NSNotFound
        while i != NSNotFound && i < self.sections.count {
            self.sections.remove(at: i)
            notificationTokens[i]?.stop()
            notificationTokens[i] = nil
            self.currentUpdate?.deletedSectionIndexes.insert(i)
            i = indexes.integerLessThan(i) ?? NSNotFound
        }
    }
    
    /// Sets section header `model` for section at `sectionIndex`
    ///
    /// This method calls delegate?.storageNeedsReloading() method at the end, causing UI to be updated.
    /// - SeeAlso: `configureForTableViewUsage`
    /// - SeeAlso: `configureForCollectionViewUsage`
    open func setSectionHeaderModel<T>(_ model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method")
        let section = (self.section(at: sectionIndex) as? SupplementaryAccessible)
        section?.setSupplementaryModel(model, forKind: self.supplementaryHeaderKind!, atIndex: 0)
    }
    
    /// Sets section footer `model` for section at `sectionIndex`
    ///
    /// This method calls delegate?.storageNeedsReloading() method at the end, causing UI to be updated.
    /// - SeeAlso: `configureForTableViewUsage`
    /// - SeeAlso: `configureForCollectionViewUsage`
    open func setSectionFooterModel<T>(_ model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method")
        let section = (self.section(at: sectionIndex) as? SupplementaryAccessible)
        section?.setSupplementaryModel(model, forKind: self.supplementaryFooterKind!, atIndex: 0)
    }
    
    /// Sets supplementary `models` for supplementary of `kind`.
    ///
    /// - Note: This method can be used to clear all supplementaries of specific kind, just pass an empty array as models.
    open func setSupplementaries(_ models : [[Int: Any]], forKind kind: String)
    {
        if models.count == 0 {
            for index in 0 ..< self.sections.count {
                let section = self.sections[index] as? SupplementaryAccessible
                section?.supplementaries[kind] = nil
            }
            return
        }
        
        assert(sections.count >= models.count, "The section should be set before setting supplementaries")
        
        for index in 0 ..< models.count {
            let section = self.sections[index] as? SupplementaryAccessible
            section?.supplementaries[kind] = models[index]
        }
    }
    
    /// Sets section header `models`, using `supplementaryHeaderKind`.
    ///
    /// - Note: `supplementaryHeaderKind` property should be set before calling this method.
    open func setSectionHeaderModels<T>(_ models : [T])
    {
        assert(self.supplementaryHeaderKind != nil, "Please set supplementaryHeaderKind property before setting section header models")
        var supplementaries = [[Int:Any]]()
        for model in models {
            supplementaries.append([0:model])
        }
        self.setSupplementaries(supplementaries, forKind: self.supplementaryHeaderKind!)
    }
    
    /// Sets section footer `models`, using `supplementaryFooterKind`.
    ///
    /// - Note: `supplementaryFooterKind` property should be set before calling this method.
    open func setSectionFooterModels<T>(_ models : [T])
    {
        assert(self.supplementaryFooterKind != nil, "Please set supplementaryFooterKind property before setting section header models")
        var supplementaries = [[Int:Any]]()
        for model in models {
            supplementaries.append([0:model])
        }
        self.setSupplementaries(supplementaries, forKind: self.supplementaryFooterKind!)
    }
    
    // MARK: - Storage
    
    /// Returns item at `indexPath` or nil, if it is not found.
    open func item(at indexPath: IndexPath) -> Any? {
        guard indexPath.section < self.sections.count else {
            return nil
        }
        return (sections[indexPath.section] as? ItemAtIndexPathRetrievable)?.itemAt(indexPath)
    }
    
    // MARK: - SupplementaryStorage
    
    /// Returns supplementary model of supplementary `kind` for section at `sectionIndexPath`. Returns nil if not found.
    ///
    /// - SeeAlso: `headerModelForSectionIndex`
    /// - SeeAlso: `footerModelForSectionIndex`
    open func supplementaryModel(ofKind kind: String, forSectionAt sectionIndexPath: IndexPath) -> Any? {
        guard sectionIndexPath.section < sections.count else { return nil }
        
        return (sections[sectionIndexPath.section] as? SupplementaryAccessible)?.supplementaryModel(ofKind:kind, atIndex: sectionIndexPath.item)
    }
    
    // DEPRECATED
    
    @available(*, unavailable, renamed: "section(at:)")
    open func sectionAtIndex(_ sectionIndex: Int) -> Section? {
        fatalError("UNAVAILABLE")
    }
    
    @available(*, unavailable, renamed: "addSection(with:)")
    open func addSectionWithResults<T:Object>(_ results: Results<T>) {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"setSection(with:forSection:)")
    open func setSectionWithResults<T:Object>(_ results: Results<T>, forSectionIndex index: Int) {
        fatalError("UNAVAILABLE")
    }
}
