//
//  MemoryStorage.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 10.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit

class MemoryStorage: BaseStorage, StorageProtocol
{
    var sections: [Section] = [SectionModel]()
    private var currentUpdate :StorageUpdate?
    
    func objectAtIndexPath(path: NSIndexPath) -> Any? {
        let sectionModel : SectionModel
        if path.section >= self.sections.count {
            return nil
        }
        else {
            sectionModel = self.sections[path.section] as! SectionModel
            if path.item >= sectionModel.numberOfObjects {
                return nil
            }
        }
        return sectionModel.objects[path.item]
    }
    
    func startUpdate()
    {
        self.currentUpdate = StorageUpdate()
    }
    
    func finishUpdate()
    {
        if self.currentUpdate != nil {
            self.delegate?.storageDidPerformUpdate(self.currentUpdate!)
        }
        self.currentUpdate = nil
    }
    
    func sectionAtIndex(sectionIndex : Int) -> SectionModel
    {
        self.startUpdate()
        let section = self.getValidSection(sectionIndex)
        self.finishUpdate()
        return section
    }
    
    private func getValidSection(sectionIndex : Int) -> SectionModel
    {
        if sectionIndex < self.sections.count
        {
            return self.sections[sectionIndex] as! SectionModel
        }
        else {
            for i in self.sections.count...sectionIndex {
                self.sections.append(SectionModel())
                self.currentUpdate?.insertedSectionIndexes.addIndex(i)
            }
        }
        return self.sections.last as! SectionModel
    }
    
    func setSectionHeaderModel(model: Any?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method")
        self.sectionAtIndex(sectionIndex).setSupplementaryModel(model, forKind: self.supplementaryHeaderKind!)
    }
    
    func setSectionFooterModel(model: Any?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method")
        self.sectionAtIndex(sectionIndex).setSupplementaryModel(model, forKind: self.supplementaryFooterKind!)
    }
    
    func setSupplementaries(models : [Any], forKind kind: String)
    {
        self.startUpdate()
        
        if models.count == 0 {
            for section in self.sections as! [SectionModel] {
                section.setSupplementaryModel(nil, forKind: kind)
            }
            return
        }
        
        self.getValidSection(models.count - 1)
        
        for index in 0..<models.count {
            let section = self.sections[index] as! SectionModel
            section.setSupplementaryModel(models[index], forKind: kind)
        }
        
        self.finishUpdate()
    }
    
    func setSectionHeaderModels(models : [Any])
    {
        assert(self.supplementaryHeaderKind != nil, "Please set supplementaryHeaderKind property before setting section header models")
        self.setSupplementaries(models, forKind: self.supplementaryHeaderKind!)
    }
    
    func setSectionFooterModels(models : [Any])
    {
        assert(self.supplementaryFooterKind != nil, "Please set supplementaryFooterKind property before setting section header models")
        self.setSupplementaries(models, forKind: self.supplementaryFooterKind!)
    }
    
    func setItems(items: [Any], forSectionIndex index: Int)
    {
        let section = self.sectionAtIndex(index)
        section.objects.removeAll(keepCapacity: false)
        section.objects.extend(items)
        self.delegate?.storageNeedsReloading()
    }
}

extension MemoryStorage : HeaderFooterStorageProtocol
{
    func headerModelForSectionIndex(index: Int) -> Any? {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling headerModelForSectionIndex: method")
        return self.supplementaryModelOfKind(self.supplementaryHeaderKind!, sectionIndex: index)
    }
    
    func footerModelForSectionIndex(index: Int) -> Any? {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling footerModelForSectionIndex: method")
        return self.supplementaryModelOfKind(self.supplementaryFooterKind!, sectionIndex: index)
    }
}

extension MemoryStorage : SupplementaryStorageProtocol
{
    func supplementaryModelOfKind(kind: String, sectionIndex: Int) -> Any? {
        let sectionModel : SectionModel
        if sectionIndex >= self.sections.count {
            return nil
        }
        else {
            sectionModel = self.sections[sectionIndex] as! SectionModel
        }
        return sectionModel.supplementaryModelOfKind(kind)
    }
}