//
//  MemoryStorage+UpdateWithoutAnimations.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 11.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

extension MemoryStorage
{
    public func updateWithoutAnimations(block: () -> Void)
    {
        let delegate = self.delegate
        self.delegate = nil
        block()
        self.delegate = delegate
    }
}