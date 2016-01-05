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
import RealmSwift

/// Storage class, that handles multiple `RealmSection` instances with Realm.Results<T>. It is similar with CoreDataStorage, but for Realm database. 
/// When created, it automatically subscribes for Realm notifications and notifies delegate when it's sections change.
public class RealmStorage : BaseStorage
{
    /// Array of `RealmSection` objects
    public var sections = [Section]()
    
    /// NotificationToken, that allows to unsubscribe from Realm notifications.
    var notificationToken : NotificationToken?
    
    public override init() {
        super.init()
        notificationToken = try? Realm().addNotificationBlock({ [weak self] notification, realm in
            self?.handleRealmNotification(notification, realm: realm)
        })
    }
    
    func handleRealmNotification(notification: Notification, realm: Realm) {
        for section in sections {
            if (section as? RealmRetrievable)?.realm == realm {
                delegate?.storageNeedsReloading()
                return
            }
        }
    }
    
    deinit {
        if notificationToken != nil { _ = try? Realm().removeNotification(notificationToken!) }
    }
    
    /// Retrieve `RealmSection` at index
    /// - Parameter sectionIndex: index of section
    /// - Returns: `RealmSection` instance
    public func sectionAtIndex(sectionIndex: Int) -> Section? {
        guard sectionIndex < sections.count else { return nil }
        
        return sections[sectionIndex]
    }
    
    /// Add `RealmSection`, containing `Results<T>` objects.
    /// - Parameter results: results of Realm objects query.
    public func addSectionWithResults<T:Object>(results: Results<T>) {
        let section = RealmSection(results: results)
        sections.append(section)
        delegate?.storageNeedsReloading()
    }
    
    /// Delete sections at indexes. Delegate will be automatically notified of changes
    /// - Parameter sections: index set with sections to delete
    public func deleteSections(sections: NSIndexSet) {
        startUpdate()
        defer { self.finishUpdate() }
        
        for var i = sections.lastIndex; i != NSNotFound; i = sections.indexLessThanIndex(i) {
            self.sections.removeAtIndex(i)
            currentUpdate?.deletedSectionIndexes.insert(i)
        }
    }
    
    /// Set section header model at index. `supplementaryHeaderKind` should be set prior to calling this method.
    /// - Parameter model: model for section header
    /// - Parameter sectionIndex: index of section
    /// - SeeAlso: `configureForTableViewUsage`
    /// - SeeAlso: `configureForCollectionViewUsage`
    public func setSectionHeaderModel<T>(model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method")
        let section = (sectionAtIndex(sectionIndex) as? SupplementaryAccessible)
        section?.setSupplementaryModel(model, forKind: self.supplementaryHeaderKind!)
    }
    
    /// Set section footer model at index. `supplementaryFooterKind` should be set prior to calling this method.
    /// - Parameter model: model for section footer
    /// - Parameter sectionIndex: index of section
    /// - SeeAlso: `configureForTableViewUsage`
    /// - SeeAlso: `configureForCollectionViewUsage`
    public func setSectionFooterModel<T>(model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method")
        let section = (sectionAtIndex(sectionIndex) as? SupplementaryAccessible)
        section?.setSupplementaryModel(model, forKind: self.supplementaryFooterKind!)
    }
    
    /// Set array of supplementaries for specific kind. Number of models should not exceed number of sections.
    /// - Parameter model: models for sections supplementaries
    /// - Parameter kind: supplementaryKind
    /// - Note: This method can be used to clear all supplementaries of specific kind, just pass an empty array as models.
    public func setSupplementaries<T>(models : [T], forKind kind: String)
    {
        if models.count == 0 {
            for index in 0..<self.sections.count {
                let section = self.sections[index] as? SupplementaryAccessible
                section?.setSupplementaryModel(nil, forKind: kind)
            }
            return
        }
        
        assert(sections.count >= models.count, "The section should be set before setting supplementaries")
        
        for index in 0..<models.count {
            let section = self.sections[index] as? SupplementaryAccessible
            section?.setSupplementaryModel(models[index], forKind: kind)
        }
    }
    
    /// Set section header models.
    /// - Note: `supplementaryHeaderKind` property should be set before calling this method.
    /// - Parameter models: section header models
    public func setSectionHeaderModels<T>(models : [T])
    {
        assert(self.supplementaryHeaderKind != nil, "Please set supplementaryHeaderKind property before setting section header models")
        self.setSupplementaries(models, forKind: self.supplementaryHeaderKind!)
    }
    
    /// Set section footer models.
    /// - Note: `supplementaryFooterKind` property should be set before calling this method.
    /// - Parameter models: section footer models
    public func setSectionFooterModels<T>(models : [T])
    {
        assert(self.supplementaryFooterKind != nil, "Please set supplementaryFooterKind property before setting section header models")
        self.setSupplementaries(models, forKind: self.supplementaryFooterKind!)
    }
}

extension RealmStorage : StorageProtocol {
    public func itemAtIndexPath(path: NSIndexPath) -> Any? {
        guard path.section < self.sections.count else {
            return nil
        }
        return (sections[path.section] as? ItemAtIndexPathRetrievable)?.itemAtIndexPath(path)
    }
}

extension RealmStorage : SupplementaryStorageProtocol
{
    public func supplementaryModelOfKind(kind: String, sectionIndex: Int) -> Any? {
        guard sectionIndex < sections.count else {
            return nil
        }
        
        return (sections[sectionIndex] as? SupplementaryAccessible)?.supplementaryModelOfKind(kind)
    }
}