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
public class RealmStorage : BaseStorage, StorageProtocol, SupplementaryStorageProtocol, SectionLocationIdentifyable
{
    /// Array of `RealmSection` objects
    public var sections = [Section]() {
        didSet {
            sections.forEach {
                ($0 as? SupplementaryAccessible)?.sectionLocationDelegate = self
            }
        }
    }
    
    public func sectionIndex(for section: Section) -> Int? {
        return sections.index(where: {
            return ($0 as? RealmSection) === (section as? RealmSection)
        })
    }
    
    @nonobjc private var notificationTokens: [Int:RealmSwift.NotificationToken] = [:]
    
    deinit {
        notificationTokens.values.forEach { token in
            token.stop()
        }
    }
    
    /// Retrieve `RealmSection` at index
    /// - Parameter sectionIndex: index of section
    /// - Returns: `RealmSection` instance
    public func sectionAtIndex(_ sectionIndex: Int) -> Section? {
        guard sectionIndex < sections.count else { return nil }
        
        return sections[sectionIndex]
    }
    
    /// Add `RealmSection`, containing `Results<T>` objects.
    /// - Parameter results: results of Realm objects query.
    public func addSectionWithResults<T:Object>(_ results: Results<T>) {
        setSectionWithResults(results, forSectionIndex: sections.count)
    }
    
    /// Set `RealmSection`, containing `Results<T>` objects, for section at index. Calls `delegate.storageNeedsReloading()` after section is set.
    /// - Parameter results: results of Realm objects query.
    /// - Parameter forSectionIndex: index for section.
    /// - Note: if index is less than number of section, this method won't do anything.
    public func setSectionWithResults<T:Object>(_ results: Results<T>, forSectionIndex index: Int) {
        guard index <= sections.count else { return }
        
        let section = RealmSection(results: results)
        notificationTokens[index]?.stop()
        notificationTokens[index] = nil
        if index == sections.count {
            sections.append(section)
        } else {
            sections[index] = section
        }
        let sectionIndex = sections.count - 1
        notificationTokens[index] = results.addNotificationBlock(block: { [weak self] change in
            self?.handleChange(change, inSection: sectionIndex)
        })
        delegate?.storageNeedsReloading()
    }
    
    internal func handleChange<T>(_ change: RealmCollectionChange<T>, inSection: Int)
    {
        if case RealmCollectionChange.Initial(_) = change {
            delegate?.storageNeedsReloading()
            return
        }
        guard case let RealmCollectionChange.Update(_, deletions, insertions, modifications) = change else {
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
    
    /// Delete sections at indexes. Delegate will be automatically notified of changes
    /// - Parameter sections: index set with sections to delete
    public func deleteSections(_ sections: IndexSet) {
        startUpdate()
        defer { self.finishUpdate() }
        
        var i = sections.last
        while i != NSNotFound && i < self.sections.count {
            self.sections.remove(at: i!)
            notificationTokens[i!]?.stop()
            notificationTokens[i!] = nil
            self.currentUpdate?.deletedSectionIndexes.insert(i!)
            i = sections.integerLessThan(i!)
        }
    }
    
    /// Set section header model at index. `supplementaryHeaderKind` should be set prior to calling this method.
    /// - Parameter model: model for section header
    /// - Parameter sectionIndex: index of section
    /// - SeeAlso: `configureForTableViewUsage`
    /// - SeeAlso: `configureForCollectionViewUsage`
    public func setSectionHeaderModel<T>(_ model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method")
        let section = (sectionAtIndex(sectionIndex) as? SupplementaryAccessible)
        section?.setSupplementaryModel(model, forKind: self.supplementaryHeaderKind!, atIndex: 0)
    }
    
    /// Set section footer model at index. `supplementaryFooterKind` should be set prior to calling this method.
    /// - Parameter model: model for section footer
    /// - Parameter sectionIndex: index of section
    /// - SeeAlso: `configureForTableViewUsage`
    /// - SeeAlso: `configureForCollectionViewUsage`
    public func setSectionFooterModel<T>(_ model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method")
        let section = (sectionAtIndex(sectionIndex) as? SupplementaryAccessible)
        section?.setSupplementaryModel(model, forKind: self.supplementaryFooterKind!, atIndex: 0)
    }
    
    /// Set array of supplementaries for specific kind. Number of models should not exceed number of sections.
    /// - Parameter model: models for sections supplementaries
    /// - Parameter kind: supplementaryKind
    /// - Note: This method can be used to clear all supplementaries of specific kind, just pass an empty array as models.
    public func setSupplementaries(_ models : [[Int: Any]], forKind kind: String)
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
    
    /// Set section header models.
    /// - Note: `supplementaryHeaderKind` property should be set before calling this method.
    /// - Parameter models: section header models
    public func setSectionHeaderModels<T>(_ models : [T])
    {
        assert(self.supplementaryHeaderKind != nil, "Please set supplementaryHeaderKind property before setting section header models")
        var supplementaries = [[Int:Any]]()
        for model in models {
            supplementaries.append([0:model])
        }
        self.setSupplementaries(supplementaries, forKind: self.supplementaryHeaderKind!)
    }
    
    /// Set section footer models.
    /// - Note: `supplementaryFooterKind` property should be set before calling this method.
    /// - Parameter models: section footer models
    public func setSectionFooterModels<T>(_ models : [T])
    {
        assert(self.supplementaryFooterKind != nil, "Please set supplementaryFooterKind property before setting section header models")
        var supplementaries = [[Int:Any]]()
        for model in models {
            supplementaries.append([0:model])
        }
        self.setSupplementaries(supplementaries, forKind: self.supplementaryFooterKind!)
    }
    
    // MARK: - StorageProtocol
    
    public func itemAtIndexPath(_ path: IndexPath) -> Any? {
        guard path.section < self.sections.count else {
            return nil
        }
        return (sections[path.section] as? ItemAtIndexPathRetrievable)?.itemAtIndexPath(path)
    }
    
    // MARK: - SupplementaryStorageProtocol
    
    public func supplementaryModelOfKind(_ kind: String, sectionIndexPath: IndexPath) -> Any? {
        guard sectionIndexPath.section < sections.count else { return nil }
        
        return (sections[sectionIndexPath.section] as? SupplementaryAccessible)?.supplementaryModelOfKind(kind, atIndex: sectionIndexPath.item)
    }
}
