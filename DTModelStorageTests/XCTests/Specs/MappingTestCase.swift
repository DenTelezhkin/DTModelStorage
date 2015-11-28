//
//  MappingTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 27.11.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import XCTest
import UIKit
import DTModelStorage
import Nimble

protocol MappingTestProtocol {}

class ProtocolTestableTableViewCell : UITableViewCell, ModelTransfer {
    var model : MappingTestProtocol?
    
    func updateWithModel(model: MappingTestProtocol) {
        self.model = model
    }
}

class ConformingClass : MappingTestProtocol {
    
}

class AncestorClass {}
class Subclass : AncestorClass {}

class SubclassTestableTableViewCell : UITableViewCell, ModelTransfer {
    func updateWithModel(model: AncestorClass) {
        
    }
}

class MappingTestCase: XCTestCase {
    
    var mappings : [ViewModelMapping]!
    
    override func setUp() {
        super.setUp()
        mappings = []
    }
    
    func testProtocolModelIsFindable() {
        mappings.addMappingForViewType(.Cell, viewClass: ProtocolTestableTableViewCell.self)
        
        let candidates = mappings.mappingCandidatesForViewType(.Cell, model: ConformingClass())
        
        expect(candidates.count) == 1
        expect(candidates.first?.viewClass == ProtocolTestableTableViewCell.self).to(beTrue())
    }
    
    func testOptionalModelOfProtocolIsFindable() {
        mappings.addMappingForViewType(.Cell, viewClass: ProtocolTestableTableViewCell.self)
        let optional: ConformingClass? = ConformingClass()
        let candidates = mappings.mappingCandidatesForViewType(.Cell, model: optional)
        expect(candidates.count) == 1
        expect(candidates.first?.viewClass == ProtocolTestableTableViewCell.self).to(beTrue())
    }
    
    func testSubclassModelMappingIsFindable() {
        mappings.addMappingForViewType(.Cell, viewClass: SubclassTestableTableViewCell.self)
        let candidates = mappings.mappingCandidatesForViewType(.Cell, model: Subclass())
        
        expect(candidates.count) == 1
        expect(candidates.first?.viewClass == SubclassTestableTableViewCell.self).to(beTrue())
    }
    
    func testNilModelDoesNotReturnMappingCandidates() {
        mappings.addMappingForViewType(.Cell, viewClass: SubclassTestableTableViewCell.self)
        let model : AncestorClass? = nil
        let candidates = mappings.mappingCandidatesForViewType(.Cell, model: model)
        
        expect(candidates.count) == 0
    }
    
    func testUpdateBlockCanBeSuccessfullyCalled() {
        mappings.addMappingForViewType(.Cell, viewClass: ProtocolTestableTableViewCell.self)
        
        let candidates = mappings.mappingCandidatesForViewType(.Cell, model: ConformingClass())
        
        expect(candidates.count) == 1
        expect(candidates.first?.viewClass == ProtocolTestableTableViewCell.self).to(beTrue())
        
        let cell = ProtocolTestableTableViewCell()
        candidates.first?.updateBlock(cell, ConformingClass())
        
        expect(cell.model is ConformingClass).to(beTrue())
    }
}

class ViewModelMappingTestCase: XCTestCase {
    
    func testComparisons() {
        let type = ViewType.Cell
        
        expect(type.supplementaryKind()).to(beNil())
    }
    
    func testSupplementaryKindEnum()
    {
        let type = ViewType.SupplementaryView(kind: "foo")
        
        expect(type.supplementaryKind()) == "foo"
    }
    
    func testComparisonsOfDifferentViewTypes()
    {
        let cellType = ViewType.Cell
        let supplementaryType = ViewType.SupplementaryView(kind: "foo")
        
        expect(cellType == supplementaryType).to(beFalse())
    }
    
}
