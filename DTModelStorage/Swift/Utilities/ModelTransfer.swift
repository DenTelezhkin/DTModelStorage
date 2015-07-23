//
//  ModelTransfer.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

public protocol ModelTransfer
{
    typealias CellModel
    
    func updateWithModel(model : CellModel)
}