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
    
    func update(with model: MappingTestProtocol) {
        self.model = model
    }
}

class ConformingClass : MappingTestProtocol {
    
}

class AncestorClass {}
class Subclass : AncestorClass {}

class SubclassTestableTableViewCell : UITableViewCell, ModelTransfer {
    func update(with model: AncestorClass) {
        
    }
}

class MappingTestCase: XCTestCase {
    
    var mappings : [ViewModelMapping]!
    
    override func setUp() {
        super.setUp()
        mappings = []
    }
    
    func testProtocolModelIsFindable() {
        mappings.addMapping(for: .cell, viewClass: ProtocolTestableTableViewCell.self)
        
        let candidates = mappings.mappingCandidates(forViewType: .cell, withModel: ConformingClass())
        
        expect(candidates.count) == 1
        expect(candidates.first?.viewClass == ProtocolTestableTableViewCell.self).to(beTrue())
    }
    
    func testOptionalModelOfProtocolIsFindable() {
        mappings.addMapping(for: .cell, viewClass: ProtocolTestableTableViewCell.self)
        let optional: ConformingClass? = ConformingClass()
        let candidates = mappings.mappingCandidates(forViewType: .cell, withModel: optional)
        expect(candidates.count) == 1
        expect(candidates.first?.viewClass == ProtocolTestableTableViewCell.self).to(beTrue())
    }
    
    func testSubclassModelMappingIsFindable() {
        mappings.addMapping(for: .cell, viewClass: SubclassTestableTableViewCell.self)
        let candidates = mappings.mappingCandidates(forViewType: .cell, withModel: Subclass())
        
        expect(candidates.count) == 1
        expect(candidates.first?.viewClass == SubclassTestableTableViewCell.self).to(beTrue())
    }
    
    func testNilModelDoesNotReturnMappingCandidates() {
        mappings.addMapping(for: .cell, viewClass: SubclassTestableTableViewCell.self)
        let model : AncestorClass? = nil
        let candidates = mappings.mappingCandidates(forViewType: .cell, withModel: model)
        
        expect(candidates.count) == 0
    }
    
    func testUpdateBlockCanBeSuccessfullyCalled() {
        mappings.addMapping(for: .cell, viewClass: ProtocolTestableTableViewCell.self)
        
        let candidates = mappings.mappingCandidates(forViewType: .cell, withModel: ConformingClass())
        
        expect(candidates.count) == 1
        expect(candidates.first?.viewClass == ProtocolTestableTableViewCell.self).to(beTrue())
        
        let cell = ProtocolTestableTableViewCell()
        candidates.first?.updateBlock(cell, ConformingClass())
        
        expect(cell.model is ConformingClass).to(beTrue())
    }
}

class Transferable : ModelTransfer {
    func update(with model: Int) {}
}

class ViewModelMappingTestCase: XCTestCase {
    
    func testComparisons() {
        let type = ViewType.cell
        
        expect(type.supplementaryKind()).to(beNil())
        expect(ViewType.supplementaryView(kind: "foo")) == ViewType.supplementaryView(kind: "foo")
    }
    
    func testSupplementaryKindEnum()
    {
        let type = ViewType.supplementaryView(kind: "foo")
        
        expect(type.supplementaryKind()) == "foo"
    }
    
    func testComparisonsOfDifferentViewTypes()
    {
        let cellType = ViewType.cell
        let supplementaryType = ViewType.supplementaryView(kind: "foo")
        
        expect(cellType == supplementaryType).to(beFalse())
    }
    
}
