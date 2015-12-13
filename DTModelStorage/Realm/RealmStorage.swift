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

public class RealmStorage : BaseStorage
{
    public var sections = [Section]()
    var notificationToken : NotificationToken?
    
    public override init() {
        super.init()
        notificationToken = try? Realm().addNotificationBlock({ [weak self] notification, realm in
            self?.handleRealmNotification(notification, realm: realm)
        })
    }
    
    internal func handleRealmNotification(notification: Notification, realm: Realm) {
        for section in sections {
            if (section as? RealmSection)?.results.realm == realm {
                delegate?.storageNeedsReloading()
                return
            }
        }
    }
    
    deinit {
        if notificationToken != nil { _ = try? Realm().removeNotification(notificationToken!) }
    }
    
    public func sectionAtIndex(sectionIndex: Int) -> Section? {
        guard sectionIndex < sections.count else { return nil }
        
        return sections[sectionIndex]
    }
    
    public func addSectionWithResults<T:Object>(results: Results<T>) {
        let section = RealmSection(results: results)
        sections.append(section)
        delegate?.storageNeedsReloading()
    }
    
    public func deleteSections(sections: NSIndexSet) {
        startUpdate()
        defer { self.finishUpdate() }
        
        for var i = sections.lastIndex; i != NSNotFound; i = sections.indexLessThanIndex(i) {
            self.sections.removeAtIndex(i)
            self.currentUpdate?.deletedSectionIndexes.insert(i)
        }
    }
    
    public func setSectionHeaderModel<T>(model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method")
        let section = (sectionAtIndex(sectionIndex) as? SupplementaryAccessable)
        section?.setSupplementaryModel(model, forKind: self.supplementaryHeaderKind!)
    }
    
    public func setSectionFooterModel<T>(model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method")
        let section = (sectionAtIndex(sectionIndex) as? SupplementaryAccessable)
        section?.setSupplementaryModel(model, forKind: self.supplementaryFooterKind!)
    }
    
    public func setSupplementaries<T>(models : [T], forKind kind: String)
    {
        if models.count == 0 {
            for index in 0..<self.sections.count {
                let section = self.sections[index] as? SupplementaryAccessable
                section?.setSupplementaryModel(nil, forKind: kind)
            }
            return
        }
        
        assert(sections.count < models.count - 1, "The section should be set before setting supplementaries")
        
        for index in 0..<models.count {
            let section = self.sections[index] as? SupplementaryAccessable
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
        return (self.sections[path.section] as? RealmSection)?.results[path.item]
    }
}

extension RealmStorage : SupplementaryStorageProtocol
{
    public func supplementaryModelOfKind(kind: String, sectionIndex: Int) -> Any? {
        guard sectionIndex < sections.count else {
            return nil
        }
        
        return (sections[sectionIndex] as? SupplementaryAccessable)?.supplementaryModelOfKind(kind)
    }
}