//
//  BaseStorage.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//

import Foundation

public let DTTableViewElementSectionHeader = "DTTableViewElementSectionHeader"
public let DTTableViewElementSectionFooter = "DTTableViewElementSectionFooter"

class BaseStorage
{
    var supplementaryHeaderKind : String?
    var supplementaryFooterKind : String?
    
    weak var delegate : StorageUpdating?
    
    init(){}
}