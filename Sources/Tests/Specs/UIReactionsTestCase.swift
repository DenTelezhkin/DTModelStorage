//
//  UIReactionsTestCase.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 29.11.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTModelStorage

@MainActor
class UIReactionsTestCase: XCTestCase {
    
    var mapping : ViewModelMappingProtocol!
    
    override func setUp() {
        super.setUp()
        mapping = CellViewModelMapping<CollectionCell, Int>(viewClass: CollectionCell.self)
    }
    
    override func tearDown() {
        super.tearDown()
        mapping.reactions.removeAll()
    }
    
    func testReactionTypeSupplementaryEquatable() {
        XCTAssertEqual(ViewType.supplementaryView(kind: "foo"), ViewType.supplementaryView(kind: "foo"))
        XCTAssertNotEqual(ViewType.supplementaryView(kind: "foo"), ViewType.supplementaryView(kind: "bar"))
    }
    
    func testReactionsAreSearchable() {
        mapping.reactions.append(EventReaction(viewType: CollectionCell.self, modelType: Int.self, signature: "foo") { _,_,_ in })
        let foundReaction = EventReaction.reaction(from: [mapping], signature: "foo", forModel: 5, at: indexPath(0, 0), view: nil)
        XCTAssertNotNil(foundReaction)
    }
    
    func testReactionsForOptionalModelsAreSearchable() {
        mapping.reactions.append(EventReaction(viewType: CollectionCell.self, modelType: Int.self, signature: "foo") { _,_,_ in })
        
        let nilModel: Int? = 5
        
        let foundReaction = EventReaction.reaction(from: [mapping], signature: "foo", forModel: nilModel as Any, at: indexPath(0, 0), view: nil)
        XCTAssertNotNil(foundReaction)
    }
    
    func testCellReactionIsExecutable() {
        let exp = expectation(description: "executeCell")
        let reaction = EventReaction(viewType: CollectionCell.self, modelType: Int.self, signature: "foo") { _,_,_ -> Int in
            exp.fulfill()
            return 3
        }
        mapping.reactions.append(reaction)
        let result = reaction.performWithArguments((CollectionCell(), 5, indexPath(0, 0)))
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result as? Int, 3)
    }
    
    func testReactionOfTypeIsPerformable() {
        let exp = expectation(description: "executeCell")
        let reaction = EventReaction(viewType: CollectionCell.self, modelType: Int.self, signature: "foo") { _,_,_ -> Int in
            exp.fulfill()
            return 3
        }
        mapping.reactions.append(reaction)
        let result = EventReaction.performReaction(from: [mapping], signature: "foo", view: CollectionCell(), model: 5, location: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result as? Int, 3)
    }
}
