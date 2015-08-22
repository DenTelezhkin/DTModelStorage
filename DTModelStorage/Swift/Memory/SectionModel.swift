//
//  SectionModel.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 10.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

/// Class represents data of the section used by `MemoryStorage`.
public class SectionModel : Section
{
    /// Items for current section
    public var objects = [Any]()
    
    /// Number of items in current section
    public var numberOfObjects: Int {
        return self.objects.count
    }
    
    private var supplementaries = [String:Any]()
    
    public init() {}
    
    /// Retrieve supplementaryModel of specific kind
    /// - Parameter: kind - kind of supplementary
    /// - Returns: supplementary model or nil, if there are no model
    public func supplementaryModelOfKind(kind: String) -> Any?
    {
        return self.supplementaries[kind]
    }
    
    /// Set supplementary model of specific kind
    /// - Parameter model: model to set
    /// - Parameter forKind: kind of supplementary
    public func setSupplementaryModel(model : Any?, forKind kind: String)
    {
        self.supplementaries[kind] = model
    }
}