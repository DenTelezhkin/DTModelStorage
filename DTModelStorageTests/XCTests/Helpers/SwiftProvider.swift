//
//  SwiftProvider.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 29.09.14.
//  Copyright (c) 2014 Denys Telezhkin. All rights reserved.
//

import UIKit

class SwiftProvider: NSObject {
    class func swiftClass() -> AnyObject {
        return SwiftClass.self
    }
    
    class func swiftString() -> String
    {
        return "foo"
    }
    
    class func swiftNumberArray() -> [Int]
    {
        return [1]
    }
    
    class func swiftArray() -> [AnyObject]
    {
        return [1,"foo"]
    }
    
    class func swiftDictionary() -> [Int:String]
    {
        return [1:"1",5:"3"]
    }
    
    class func boolArray() -> [Bool]
    {
        return [true,false]
    }
    
    class func swiftObject() -> SwiftClass
    {
        return SwiftClass()
    }
    
    class func renamedClassObject() -> RenamedSwiftClass
    {
        return RenamedSwiftClass()
    }
}
