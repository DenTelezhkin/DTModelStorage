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
import HeckelDiff

class DwifftDiffer: EquatableDiffingAlgorithm {
    func diff<T:Identifiable & Equatable>(from: [T], to: [T]) -> [SingleSectionOperation] {
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

class HeckelDiffer : HashableDiffingAlgorithm {
    func diff<T>(from: [T], to: [T]) -> [SingleSectionOperation] where T : Identifiable, T : Hashable {
        let diffs = HeckelDiff.diff(from, to)
        return diffs.map {
            switch $0 {
            case .delete(let index):
                return SingleSectionOperation.delete(index)
            case .insert(let index):
                return SingleSectionOperation.insert(index)
            case .move(let old, let new):
                return SingleSectionOperation.move(from: old, to: new)
            case .update(let index):
                return SingleSectionOperation.update(index)
            }
        }
    }
}

extension String: Identifiable {
    public var identifier: AnyHashable {
        return self
    }
}

class SingleSectionStorageTestCase: XCTestCase {

    func testChangesAreCalculatableUsingEquatableDiffer() {
        let observer = StorageUpdatesObserver()
        let stringStorage = SingleSectionEquatableStorage(items: ["foo", "bar"], differ: DwifftDiffer())
        stringStorage.delegate = observer
        stringStorage.setItems(["bar", "foo"])
        
        XCTAssertEqual(observer.update?.objectChanges.count, 2)
        XCTAssertEqual(observer.update?.objectChanges.first?.0, .delete)
        XCTAssertEqual(observer.update?.objectChanges.last?.0, .insert)
        XCTAssertEqual(observer.update?.objectChanges.first?.1, [indexPath(0, 0)])
        XCTAssertEqual(observer.update?.objectChanges.last?.1, [indexPath(1, 0)])
        
        observer.update?.applyDeferredDatasourceUpdates()
        
        XCTAssertEqual(stringStorage.items, ["bar", "foo"])
    }
    
    func testChangesAreCalculatedUsingHashableDiffer() {
        let observer = StorageUpdatesObserver()
        let stringStorage = SingleSectionHashableStorage(items: ["foo", "bar"], differ: HeckelDiffer())
        stringStorage.delegate = observer
        stringStorage.setItems(["bar", "foo"])
        
        XCTAssertEqual(observer.update?.objectChanges.count, 2)
        XCTAssertEqual(observer.update?.objectChanges.first?.0, .move)
        XCTAssertEqual(observer.update?.objectChanges.last?.0, .move)
        XCTAssertEqual(observer.update?.objectChanges.first?.1, [indexPath(1, 0), indexPath(0, 0)])
        XCTAssertEqual(observer.update?.objectChanges.last?.1, [indexPath(0, 0), indexPath(1, 0)])
        
        observer.update?.applyDeferredDatasourceUpdates()
        
        XCTAssertEqual(stringStorage.items, ["bar", "foo"])
    }

}
