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
        expect(UIReactionType.cellSelection) == UIReactionType.cellSelection
        expect(UIReactionType.cellConfiguration) != UIReactionType.cellSelection
        expect(UIReactionType.cellConfiguration) == UIReactionType.cellConfiguration
    }
    
    func testReactionTypeSupplementaryEquatable() {
        expect(UIReactionType.supplementaryConfiguration(kind: "foo")) == UIReactionType.supplementaryConfiguration(kind: "foo")
        expect(UIReactionType.supplementaryConfiguration(kind: "foo")) != UIReactionType.supplementaryConfiguration(kind: "bar")
    }
    
    func testSupplementaryGetter() {
        expect(UIReactionType.supplementaryConfiguration(kind: "foo").supplementaryKind()) == "foo"
        expect(UIReactionType.cellSelection.supplementaryKind()).to(beNil())
    }
    
    func testReactionsAreSearchable() {
        let reaction = UIReaction(.cellConfiguration, viewClass: UIView.self)
        reactions.append(reaction)
        
        let candidates = reactions.reactionsOfType(.cellConfiguration, forView: UIView())
        let missedCandidates = reactions.reactionsOfType(.cellConfiguration, forView: UITableViewCell())
        let nilView: UIView? = nil
        let nilCandidates = reactions.reactionsOfType(.cellConfiguration, forView: nilView)
        
        expect(candidates.count) == 1
        expect(missedCandidates.count) == 0
        expect(nilCandidates.count) == 0
    }
    
    func testReactionsForOptionalViewsAreSearchable() {
        let reaction = UIReaction(.cellConfiguration, viewClass: UIView.self)
        reactions.append(reaction)
        
        let nilView: UIView? = UIView()
        
        let candidates = reactions.reactionsOfType(.cellConfiguration, forView: nilView)
        
        expect(candidates.count) == 1
    }
    
    func testReactionBlockIsPerformable() {
        let reaction = UIReaction(.cellSelection, viewClass: UIView.self)
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
