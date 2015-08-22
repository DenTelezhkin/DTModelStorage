//
//  ModelTransfer.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

/// `ModelTransfer` protocol is used to pass `model` data to your cell or supplementary view. Every cell or supplementary view subclass you have should conform to this protocol.
/// 
/// - Note: `CellModel` is associated type, that works like generic constraint for specific cell or view. When implementing this method, use model type, that you wish to transfer to cell.
public protocol ModelTransfer
{
    /// This is a placeholder for your model type
    typealias CellModel
    
    /// Update your view with model
    /// - Parameter model: model of CellModel type
    func updateWithModel(model : CellModel)
}