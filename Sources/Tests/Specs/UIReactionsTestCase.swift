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

class UIReactionsTestCase: XCTestCase {
    
    var reactions : [EventReaction]!
    
    override func setUp() {
        super.setUp()
        reactions = []
    }
    
    func testReactionTypeEquatable() {
        XCTAssertEqual(ViewType.cell, ViewType.cell)
    }
    
    func testReactionTypeSupplementaryEquatable() {
        XCTAssertEqual(ViewType.supplementaryView(kind: "foo"), ViewType.supplementaryView(kind: "foo"))
        XCTAssertNotEqual(ViewType.supplementaryView(kind: "foo"), ViewType.supplementaryView(kind: "bar"))
    }
    
    func testReactionsAreSearchable() {
        let reaction = EventReaction(signature: "foo", viewType: .cell, modelType: Int.self)
        reaction.makeReaction(makeCellBlock({  }, cell: TableCell(), returnValue: 5))
        reactions.append(reaction)
        
        let foundReaction = reactions.reaction(of: .cell, signature: "foo", forModel: 5, view: nil)
        XCTAssertNotNil(foundReaction)
    }
    
    func testReactionsForOptionalModelsAreSearchable() {
        let reaction = EventReaction(signature: "foo", viewType: .cell, modelType: Int.self)
        reaction.makeReaction(makeCellBlock({  }, cell: TableCell(), returnValue: 5))
        reactions.append(reaction)
        
        let nilModel: Int? = 5
        
        let foundReaction = reactions.reaction(of: .cell, signature: "foo", forModel: nilModel as Any, view: nil)
        XCTAssertNotNil(foundReaction)
    }
    
    func makeCellBlock<T, U>(_ block: @escaping () -> Void, cell: T, returnValue: U) -> (T?, T.ModelType, IndexPath) -> U
        where T: ModelTransfer
    {
        return { one, two, three in
            block()
            return returnValue
        }
    }
    
    func makeSupplementaryBlock<T, U>(_ block: @escaping () -> Void, cell: T, returnValue: U) -> (T?, T.ModelType, IndexPath) -> U where T: ModelTransfer {
        return { one, two, three in
            block()
            return returnValue
        }
    }
    
    func testCellReactionIsExecutable() {
        let reaction = EventReaction(signature: "foo", viewType: .cell, modelType: Int.self)
        let exp = expectation(description: "executeCell")
        reaction.makeReaction(makeCellBlock({
            exp.fulfill()
            }, cell: TableCell(), returnValue: 3))
        let result = reaction.performWithArguments((TableCell(), 5, indexPath(0, 0)))
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result as? Int, 3)
    }
    
    func testSupplementaryReactionIsExecutable() {
        let reaction = EventReaction(signature: "foo", viewType: .supplementaryView(kind: "Foo"), modelType: Int.self)
        let exp = expectation(description: "executeCell")
        reaction.makeReaction(makeSupplementaryBlock({
            exp.fulfill()
            }, cell: TableCell(), returnValue: 3))
        let result = reaction.performWithArguments((TableCell(), 5, indexPath(0, 5)))
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result as? Int, 3)
    }
    
    func testReactionOfTypeIsPerformable() {
        let reaction = EventReaction(signature: "foo", viewType: .cell, modelType: Int.self)
        let exp = expectation(description: "executeCell")
        reaction.makeReaction(makeCellBlock({
            exp.fulfill()
            }, cell: TableCell(), returnValue: 3))
        reactions.append(reaction)
        let result = reactions.performReaction(of: .cell, signature: "foo", view: TableCell(), model: 5, location: indexPath(0, 0))
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(result as? Int, 3)
    }
}
