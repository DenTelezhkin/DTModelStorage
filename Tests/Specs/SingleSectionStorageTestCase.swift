//
//  SingleSectionStorageTestCase.swift
//  Tests
//
//  Created by Denys Telezhkin on 15.09.2018.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import XCTest
import Dwifft
import DTModelStorage

class DwifftDiffer: DiffingAlgorithm {
    func diff<T:Identifiable>(from: [T], to: [T]) -> [SingleSectionOperation] {
        let diffs = Dwifft.diff(from, to)
        return diffs.map {
            switch $0 {
            case .delete(let index, _):
                return SingleSectionOperation.delete(index)
            case .insert(let index, _):
                return SingleSectionOperation.insert(index)
            }
        }
    }
}

extension String: Identifiable {
    public var identifier: String {
        return self
    }
}

class SingleSectionStorageTestCase: XCTestCase {

    func testChangesAreCalculatableUsingDwifftDiffer() {
        let observer = StorageUpdatesObserver()
        let stringStorage = SingleSectionStorage(items: ["foo", "bar"], differ: DwifftDiffer())
        stringStorage.delegate = observer
        stringStorage.setItems(["bar", "foo"])
        
        XCTAssertEqual(observer.update?.objectChanges.count, 2)
    }

}
