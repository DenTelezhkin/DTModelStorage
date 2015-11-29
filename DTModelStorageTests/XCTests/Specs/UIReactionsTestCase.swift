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
import Nimble

class UIReactionsTestCase: XCTestCase {
    
    var reactions : [UIReaction]!
    
    override func setUp() {
        super.setUp()
        reactions = []
    }
    
    func testReactionTypeEquatable() {
        expect(UIReactionType.CellSelection) == UIReactionType.CellSelection
        expect(UIReactionType.CellConfiguration) != UIReactionType.CellSelection
        expect(UIReactionType.CellConfiguration) == UIReactionType.CellConfiguration
    }
    
    func testReactionTypeSupplementaryEquatable() {
        expect(UIReactionType.SupplementaryConfiguration(kind: "foo")) == UIReactionType.SupplementaryConfiguration(kind: "foo")
        expect(UIReactionType.SupplementaryConfiguration(kind: "foo")) != UIReactionType.SupplementaryConfiguration(kind: "bar")
    }
    
    func testSupplementaryGetter() {
        expect(UIReactionType.SupplementaryConfiguration(kind: "foo").supplementaryKind()) == "foo"
        expect(UIReactionType.CellSelection.supplementaryKind()).to(beNil())
    }
    
    func testReactionsAreSearchable() {
        let reaction = UIReaction(.CellConfiguration, viewClass: UIView.self)
        reactions.append(reaction)
        
        let candidates = reactions.reactionsOfType(.CellConfiguration, forView: UIView())
        let missedCandidates = reactions.reactionsOfType(.CellConfiguration, forView: UITableViewCell())
        let nilView: UIView? = nil
        let nilCandidates = reactions.reactionsOfType(.CellConfiguration, forView: nilView)
        
        expect(candidates.count) == 1
        expect(missedCandidates.count) == 0
        expect(nilCandidates.count) == 0
    }
    
    func testReactionBlockIsPerformable() {
        let reaction = UIReaction(.CellSelection, viewClass: UIView.self)
        var blockCalled = false
        reaction.reactionBlock = { blockCalled = true }
        
        reaction.perform()
        
        expect(blockCalled) == true
    }
    
    func testViewDataCanBeConstructed()
    {
        _ = ViewData(view: UIView(), indexPath: indexPath(0, 0))
    }
}
