//
//  RuntimeHelperTestCase.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 15.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import UIKit
import XCTest
import DTModelStorage
import Nimble

class SwiftCell:UITableViewCell{}

class RuntimeHelperTestCase: XCTestCase {

    func testSummaryOfObjectiveCClasses()
    {
        let mirror = _reflect(UITableViewCell)
        expect(RuntimeHelper.classNameFromReflection(mirror)) == "UITableViewCell"
        expect(RuntimeHelper.classNameFromReflectionSummary(mirror.summary)) == "UITableViewCell"
    }
    
    func testSummaryOfSwiftCells()
    {
        let mirror = _reflect(SwiftCell)
        expect(RuntimeHelper.classNameFromReflection(mirror)) == "SwiftCell"
        expect(RuntimeHelper.classNameFromReflectionSummary(mirror.summary)) == "SwiftCell"
    }
    
    func testClassClusterUIColor()
    {
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(_reflect(UIColor.self)).summary) == "UIColor"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(UIColor())).summary) == "UIColor"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(UIColor.cyanColor())).summary) == "UIColor"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(UIColor(red: 0.5, green: 0.3, blue: 0.2, alpha: 0.8))).summary) == "UIColor"
    }
    
    func testClassClusterNSArray()
    {
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(_reflect(NSArray.self)).summary) == "NSArray"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSArray())).summary) == "NSArray"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSMutableArray())).summary) == "NSArray"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSArray(array: [1,""]))).summary) == "NSArray"
    }
    
    func testClassClusterNSDictionary()
    {
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(_reflect(NSDictionary.self)).summary) == "NSDictionary"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSDictionary())).summary) == "NSDictionary"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSMutableDictionary())).summary) == "NSDictionary"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSDictionary(dictionary: [1:"2"]))).summary) == "NSDictionary"
    }
    
    func testClassClusterNSNumber()
    {
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(_reflect(NSNumber.self)).summary) == "NSNumber"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSNumber(bool: true))).summary) == "NSNumber"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSNumber(double: 45))).summary) == "NSNumber"
    }
    
    func testClassClusterNSSet()
    {
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(_reflect(NSSet.self)).summary) == "NSSet"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSSet())).summary) == "NSSet"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSMutableSet(array: [1,2,3]))).summary) == "NSSet"
    }
    
    func testClassClusterNSOrderedSet()
    {
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(_reflect(NSOrderedSet.self)).summary) == "NSOrderedSet"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSOrderedSet())).summary) == "NSOrderedSet"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSMutableOrderedSet(array: [1,2,3]))).summary) == "NSOrderedSet"
    }
    
    func testClassClusterNSDate()
    {
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(_reflect(NSDate.self)).summary) == "NSDate"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSDate())).summary) == "NSDate"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSDate(timeIntervalSince1970: 500))).summary) == "NSDate"
    }
    
    func testClassClusterNSString()
    {
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(_reflect(NSString.self)).summary) == "NSString"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel("" as NSString)).summary) == "NSString"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSString(string: "foo"))).summary) == "NSString"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSMutableString(string: "foo"))).summary) == "NSString"
    }
    
    func testSimpleModelIntrospection()
    {
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(_reflect(Int.self)).summary) == "Swift.Int"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(5)).summary) == "Swift.Int"
    }

    func testClassClusterNSAttributedString()
    {
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(_reflect(NSAttributedString.self)).summary) == "NSAttributedString"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSAttributedString())).summary) == "NSAttributedString"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSAttributedString(string: "foo"))).summary) == "NSAttributedString"
        expect(RuntimeHelper.classClusterReflectionFromMirrorType(RuntimeHelper.mirrorFromModel(NSMutableAttributedString(string: "foo"))).summary) == "NSAttributedString"
    }
}
