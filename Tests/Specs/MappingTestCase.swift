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

protocol MappingTestProtocol {}

class ProtocolTestableTableViewCell : UITableViewCell, ModelTransfer {
    var model : MappingTestProtocol?
    
    func update(with model: MappingTestProtocol) {
        self.model = model
    }
}

class ProtocolTestableTableViewCellSubclass : ProtocolTestableTableViewCell {
    
}

class ConformingClass : MappingTestProtocol {
    
}

class AncestorClass {}
class Subclass : AncestorClass {}

class SubclassTestableTableViewCell : UITableViewCell, ModelTransfer {
    func update(with model: AncestorClass) {
        
    }
}

class IntTableViewCell : UITableViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class OtherIntTableViewCell : UITableViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class MappingTestCase: XCTestCase {
    
    var mappings : [ViewModelMapping]!
    
    override func setUp() {
        super.setUp()
        mappings = []
    }
    
    func testProtocolModelIsFindable() {
        let mapping = ViewModelMapping(viewType: .cell, viewClass: ProtocolTestableTableViewCell.self, mappingBlock: nil)
        mappings.append(mapping)
        
        let candidates = mappings.mappingCandidates(for: .cell, withModel: ConformingClass(), at: indexPath(0, 0))
        
        XCTAssertEqual(candidates.count, 1)
        XCTAssert(candidates.first?.viewClass == ProtocolTestableTableViewCell.self)
    }
    
    func testOptionalModelOfProtocolIsFindable() {
        let mapping = ViewModelMapping(viewType: .cell, viewClass: ProtocolTestableTableViewCell.self, mappingBlock: nil)
        mappings.append(mapping)
        let optional: ConformingClass? = ConformingClass()
        let candidates = mappings.mappingCandidates(for: .cell, withModel: optional ?? 0, at: indexPath(0, 0))
        XCTAssertEqual(candidates.count, 1)
        XCTAssert(candidates.first?.viewClass == ProtocolTestableTableViewCell.self)
    }
    
    func testSubclassModelMappingIsFindable() {
        let mapping = ViewModelMapping(viewType: .cell, viewClass: SubclassTestableTableViewCell.self, mappingBlock: nil)
        mappings.append(mapping)
        let candidates = mappings.mappingCandidates(for: .cell, withModel: Subclass(), at: indexPath(0, 0))
        
        XCTAssertEqual(candidates.count, 1)
        XCTAssert(candidates.first?.viewClass == SubclassTestableTableViewCell.self)
    }
    
    func testNilModelDoesNotReturnMappingCandidates() {
        let mapping = ViewModelMapping(viewType: .cell, viewClass: SubclassTestableTableViewCell.self, mappingBlock: nil)
        mappings.append(mapping)
        let model : AncestorClass? = nil
        let candidates = mappings.mappingCandidates(for: .cell, withModel: model as Any, at: indexPath(0, 0))
        
        XCTAssertEqual(candidates.count, 0)
    }
    
    func testUpdateBlockCanBeSuccessfullyCalled() {
        let mapping = ViewModelMapping(viewType: .cell, viewClass: ProtocolTestableTableViewCell.self, mappingBlock: nil)
        mappings.append(mapping)
        
        let candidates = mappings.mappingCandidates(for: .cell, withModel: ConformingClass(), at: indexPath(0, 0))
        
        XCTAssertEqual(candidates.count, 1)
        XCTAssert(candidates.first?.viewClass == ProtocolTestableTableViewCell.self)
        
        let cell = ProtocolTestableTableViewCell()
        candidates.first?.updateBlock(cell, ConformingClass())
        
        XCTAssertTrue(cell.model is ConformingClass)
    }
    
    func testSectionConditionIsVeryfiable() {
        let firstMapping = ViewModelMapping(viewType: .cell, viewClass: ProtocolTestableTableViewCell.self) { mapping in
            mapping.condition = .section(0)
        }
        
        let secondMapping = ViewModelMapping(viewType: .cell, viewClass: ProtocolTestableTableViewCellSubclass.self) { mapping in
            mapping.condition = .section(1)
        }
        mappings.append(firstMapping)
        mappings.append(secondMapping)
        
        let firstCandidates = mappings.mappingCandidates(for: .cell, withModel: ConformingClass(), at: indexPath(0, 0))
        XCTAssertEqual(firstCandidates.count, 1)
        XCTAssert(firstCandidates.first?.viewClass === ProtocolTestableTableViewCell.self)
        
        let secondCandidates = mappings.mappingCandidates(for: .cell, withModel: ConformingClass(), at: indexPath(0, 1))
        XCTAssertEqual(secondCandidates.count, 1)
        XCTAssert(secondCandidates.first?.viewClass === ProtocolTestableTableViewCellSubclass.self)
    }
    
    func testCustomConditionIsVeryfiable() {
        let firstMapping = ViewModelMapping(viewType: .cell, viewClass: IntTableViewCell.self) { mapping in
            mapping.condition = .custom({ _, model  in
                return (model as? Int ?? 0) > 5
            })
        }
        
        let secondMapping = ViewModelMapping(viewType: .cell, viewClass: OtherIntTableViewCell.self) { mapping in
            mapping.condition = .custom({ _, model  in
                return (model as? Int ?? 0) <= 5
            })
        }
        mappings.append(firstMapping)
        mappings.append(secondMapping)
        
        let firstCandidates = mappings.mappingCandidates(for: .cell, withModel: 3, at: indexPath(0, 0))
        XCTAssertEqual(firstCandidates.count, 1)
        XCTAssert(firstCandidates.first?.viewClass === OtherIntTableViewCell.self)
        
        let secondCandidates = mappings.mappingCandidates(for: .cell, withModel: 6, at: indexPath(0, 1))
        XCTAssertEqual(secondCandidates.count, 1)
        XCTAssert(secondCandidates.first?.viewClass === IntTableViewCell.self)
    }
    
    func testModelMappingInferringModelType() {
        let firstMapping = ViewModelMapping(viewType: .cell, viewClass: IntTableViewCell.self) { mapping in
            mapping.condition = IntTableViewCell.modelCondition { _, model in model > 5 }
        }
        
        let secondMapping = ViewModelMapping(viewType: .cell, viewClass: OtherIntTableViewCell.self) { mapping in
            mapping.condition = OtherIntTableViewCell.modelCondition { _, model in model <= 5 }
        }
        mappings.append(firstMapping)
        mappings.append(secondMapping)
        
        let firstCandidates = mappings.mappingCandidates(for: .cell, withModel: 3, at: indexPath(0, 0))
        XCTAssertEqual(firstCandidates.count, 1)
        XCTAssert(firstCandidates.first?.viewClass === OtherIntTableViewCell.self)
        
        let secondCandidates = mappings.mappingCandidates(for: .cell, withModel: 6, at: indexPath(0, 1))
        XCTAssertEqual(secondCandidates.count, 1)
        XCTAssert(secondCandidates.first?.viewClass === IntTableViewCell.self)
    }
}

class Transferable : ModelTransfer {
    func update(with model: Int) {}
}

class ViewModelMappingTestCase: XCTestCase {
    
    func testComparisons() {
        let type = ViewType.cell
        
        XCTAssertNil(type.supplementaryKind())
        XCTAssertEqual(ViewType.supplementaryView(kind: "foo"), ViewType.supplementaryView(kind: "foo"))
    }
    
    func testSupplementaryKindEnum()
    {
        let type = ViewType.supplementaryView(kind: "foo")
        
        XCTAssertEqual(type.supplementaryKind(), "foo")
    }
    
    func testComparisonsOfDifferentViewTypes()
    {
        let cellType = ViewType.cell
        let supplementaryType = ViewType.supplementaryView(kind: "foo")
        
        XCTAssertFalse(cellType == supplementaryType)
    }
    
}
