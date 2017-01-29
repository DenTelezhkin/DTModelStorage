//
//  Deprecated-Realm.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 29.01.17.
//  Copyright © 2017 Denys Telezhkin. All rights reserved.
//

import Foundation
import RealmSwift

extension RealmStorage {
    @available(*, unavailable, renamed: "section(at:)")
    open func sectionAtIndex(_ sectionIndex: Int) -> Section? {
        fatalError("UNAVAILABLE")
    }
    
    @available(*, unavailable, renamed: "addSection(with:)")
    open func addSectionWithResults<T:Object>(_ results: Results<T>) {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"setSection(with:forSection:)")
    open func setSectionWithResults<T:Object>(_ results: Results<T>, forSectionIndex index: Int) {
        fatalError("UNAVAILABLE")
    }
}
