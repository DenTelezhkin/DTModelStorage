//
//  SectionModel.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 10.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

class SectionModel : Section
{
    var objects = [Any]()
    var numberOfObjects: Int {
        return self.objects.count
    }
    
    private var supplementaries = [String:Any]()
    
    init() {}
    
    func supplementaryModelOfKind(kind: String) -> Any?
    {
        return self.supplementaries[kind]
    }
    
    func setSupplementaryModel(model : Any?, forKind kind: String)
    {
        self.supplementaries[kind] = model
    }
}