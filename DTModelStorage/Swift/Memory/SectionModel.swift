//
//  SectionModel.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 10.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

public class SectionModel : Section
{
    public var objects = [Any]()
    public var numberOfObjects: Int {
        return self.objects.count
    }
    
    private var supplementaries = [String:Any]()
    
    public init() {}
    
    public func supplementaryModelOfKind(kind: String) -> Any?
    {
        return self.supplementaries[kind]
    }
    
    public func setSupplementaryModel(model : Any?, forKind kind: String)
    {
        self.supplementaries[kind] = model
    }
}