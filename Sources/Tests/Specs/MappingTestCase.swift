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

class ProtocolTestableCollectionViewCell: UICollectionViewCell, ModelTransfer {
    var model : MappingTestProtocol?
    
    func update(with model: MappingTestProtocol) {
        self.model = model
    }
}

class ProtocolTestableTableViewCellSubclass : ProtocolTestableTableViewCell {
    
}

class ProtocolTestableCollectionViewCellSubclass : ProtocolTestableCollectionViewCell {
    
}

class ConformingClass : MappingTestProtocol {
    
}

class AncestorClass {}
class Subclass : AncestorClass {}

class SubclassTestableTableViewCell : UITableViewCell, ModelTransfer {
    func update(with model: AncestorClass) {
        
    }
}

class SubclassTestableCollectionViewCell : UICollectionViewCell, ModelTransfer {
    func update(with model: AncestorClass) {
        
    }
}

class IntTableViewCell : UITableViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class IntCollectionViewCell : UICollectionViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class OtherIntTableViewCell : UITableViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

class OtherIntCollectionViewCell : UICollectionViewCell, ModelTransfer {
    func update(with model: Int) {
        
    }
}

@MainActor
class MappingTestCase: XCTestCase {
    
    var mappings : [ViewModelMappingProtocol]!
    
    @MainActor override func setUp() {
        super.setUp()
        mappings = []
    }
    
    func testProtocolModelIsFindable() {
        let mapping = CellViewModelMapping<ProtocolTestableCollectionViewCell, ProtocolTestableCollectionViewCell.ModelType>(viewClass: ProtocolTestableCollectionViewCell.self)
        mappings.append(mapping)
        
        let candidates = ViewType.cell.mappingCandidates(for: mappings, withModel: ConformingClass(), at: indexPath(0, 0))
        
        XCTAssertEqual(candidates.count, 1)
        XCTAssert(candidates.first?.viewClass == ProtocolTestableCollectionViewCell.self)
    }
    
    func testOptionalModelOfProtocolIsFindable() {
        let mapping = CellViewModelMapping<ProtocolTestableCollectionViewCell, ProtocolTestableCollectionViewCell.ModelType>(viewClass: ProtocolTestableCollectionViewCell.self)
        mappings.append(mapping)
        let optional: ConformingClass? = ConformingClass()
        let candidates = ViewType.cell.mappingCandidates(for: mappings, withModel: optional ?? 0, at: indexPath(0, 0))
        XCTAssertEqual(candidates.count, 1)
        XCTAssert(candidates.first?.viewClass == ProtocolTestableCollectionViewCell.self)
    }
    
    func testSubclassModelMappingIsFindable() {
        let mapping = CellViewModelMapping<SubclassTestableCollectionViewCell, SubclassTestableCollectionViewCell.ModelType>(viewClass: SubclassTestableCollectionViewCell.self)
        mappings.append(mapping)
        let candidates = ViewType.cell.mappingCandidates(for: mappings, withModel: Subclass(), at: indexPath(0, 0))
        
        XCTAssertEqual(candidates.count, 1)
        XCTAssert(candidates.first?.viewClass == SubclassTestableCollectionViewCell.self)
    }
    
    func testNilModelDoesNotReturnMappingCandidates() {
        let mapping = CellViewModelMapping<SubclassTestableCollectionViewCell, SubclassTestableCollectionViewCell.ModelType>(viewClass: SubclassTestableTableViewCell.self)
        mappings.append(mapping)
        let model : AncestorClass? = nil
        let candidates = ViewType.cell.mappingCandidates(for: mappings, withModel: model as Any, at: indexPath(0, 0))
        
        XCTAssertEqual(candidates.count, 0)
    }
    
    func testSectionConditionIsVeryfiable() {
        let firstMapping = CellViewModelMapping<ProtocolTestableCollectionViewCell, ProtocolTestableCollectionViewCell.ModelType>(viewClass: ProtocolTestableCollectionViewCell.self)
        firstMapping.condition = .section(0)
        
        let secondMapping = CellViewModelMapping<ProtocolTestableCollectionViewCellSubclass, ProtocolTestableCollectionViewCellSubclass.ModelType>(viewClass: ProtocolTestableCollectionViewCellSubclass.self)
        secondMapping.condition = .section(1)
        mappings.append(firstMapping)
        mappings.append(secondMapping)
        
        let firstCandidates = ViewType.cell.mappingCandidates(for: mappings, withModel: ConformingClass(), at: indexPath(0, 0))
        XCTAssertEqual(firstCandidates.count, 1)
        XCTAssert(firstCandidates.first?.viewClass === ProtocolTestableCollectionViewCell.self)
        
        let secondCandidates = ViewType.cell.mappingCandidates(for: mappings, withModel: ConformingClass(), at: indexPath(0, 1))
        XCTAssertEqual(secondCandidates.count, 1)
        XCTAssert(secondCandidates.first?.viewClass === ProtocolTestableCollectionViewCellSubclass.self)
    }
    
    func testCustomConditionIsVeryfiable() {
        let firstMapping = CellViewModelMapping<IntCollectionViewCell, Int>(viewClass: IntCollectionViewCell.self)
        firstMapping.condition = .custom({ _, model  in
            return (model as? Int ?? 0) > 5
        })
        let secondMapping = CellViewModelMapping<OtherIntCollectionViewCell, Int>(viewClass: OtherIntCollectionViewCell.self)
        secondMapping.condition = .custom({ _, model  in
            return (model as? Int ?? 0) <= 5
        })
        mappings.append(firstMapping)
        mappings.append(secondMapping)
        
        let firstCandidates = ViewType.cell.mappingCandidates(for: mappings, withModel: 3, at: indexPath(0, 0))
        XCTAssertEqual(firstCandidates.count, 1)
        XCTAssert(firstCandidates.first?.viewClass === OtherIntCollectionViewCell.self)
        
        let secondCandidates = ViewType.cell.mappingCandidates(for: mappings, withModel: 6, at: indexPath(0, 1))
        XCTAssertEqual(secondCandidates.count, 1)
        XCTAssert(secondCandidates.first?.viewClass === IntCollectionViewCell.self)
    }
    
    func testModelMappingInferringModelType() {
        let firstMapping = CellViewModelMapping<IntCollectionViewCell, Int>(viewClass: IntCollectionViewCell.self)
        firstMapping.condition = IntCollectionViewCell.modelCondition { _, model in model > 5 }
        let secondMapping = CellViewModelMapping<OtherIntCollectionViewCell, Int>(viewClass: OtherIntCollectionViewCell.self)
        secondMapping.condition = OtherIntCollectionViewCell.modelCondition { _, model in model <= 5 }
        mappings.append(firstMapping)
        mappings.append(secondMapping)
        
        let firstCandidates = ViewType.cell.mappingCandidates(for: mappings, withModel: 3, at: indexPath(0, 0))
        XCTAssertEqual(firstCandidates.count, 1)
        XCTAssert(firstCandidates.first?.viewClass === OtherIntCollectionViewCell.self)
        
        let secondCandidates = ViewType.cell.mappingCandidates(for: mappings, withModel: 6, at: indexPath(0, 1))
        XCTAssertEqual(secondCandidates.count, 1)
        XCTAssert(secondCandidates.first?.viewClass === IntCollectionViewCell.self)
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
    
    func testModelTypeCanBeDeterminedByType() {
        let mapping = CellViewModelMapping<UICollectionViewCell, String>(viewClass: UICollectionViewCell.self)
        
        XCTAssert(mapping.modelTypeTypeCheckingBlock(String.self))

    }
    
}
