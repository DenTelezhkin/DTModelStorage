//
//  AnomaliesTestCase.swift
//  Tests
//
//  Created by Denys Telezhkin on 28.04.2018.
//  Copyright © 2018 Denys Telezhkin. All rights reserved.
//

import XCTest
import DTModelStorage

enum TestAnomaly : Equatable, CustomDebugStringConvertible {
    case itemEventCalledWithCellType(ObjectIdentifier)
    case weirdIndexPathAction(IndexPath)
    
    var debugDescription: String { return "" }
}

class DTTestAnomalyHandler : AnomalyHandler {
    var anomalyAction : (TestAnomaly) -> Void = { print($0.debugDescription) }
}

extension XCTestExpectation {
    func expect(anomaly: TestAnomaly) -> (TestAnomaly) -> Void {
        return {
            guard $0 == anomaly else { return }
            self.fulfill()
        }
    }
    
    func expect(anomaly: MemoryStorageAnomaly) -> (MemoryStorageAnomaly) -> Void {
        return {
            guard $0 == anomaly else { return }
            self.fulfill()
        }
    }
}

class AnomaliesTestCase: XCTestCase {
    
    var sut: DTTestAnomalyHandler!
    
    override func setUp() {
        super.setUp()
        sut = DTTestAnomalyHandler()
    }
    
    func testAnomaliesCanBePositivelyValidated()  {
        let exp = expectation(description: "Should receive item event anomaly")
        sut.anomalyAction = exp.expect(anomaly: .itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        sut.reportAnomaly(.itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        waitForExpectations(timeout: 0.1)
    }
    
    func testWrongAnomalyFailsTheTest() {
        let exp = expectation(description: "Should not receive item event anomaly")
        exp.isInverted = true
        sut.anomalyAction = exp.expect(anomaly: .itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        sut.reportAnomaly(.weirdIndexPathAction(indexPath(0, 0)))
        waitForExpectations(timeout: 0.1)
    }
    
    func testSilencingAnomalyLeadsToAnomalyNotBeingTriggered() {
        let exp = expectation(description: "Should receive item event anomaly")
        exp.isInverted = true
        sut.anomalyAction = exp.expect(anomaly: .itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        sut.silenceAnomaly(.itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        sut.reportAnomaly(.itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        waitForExpectations(timeout: 0.1)
    }
    
    func testNotSilencedAnomaliesAreStillTriggered() {
        let exp = expectation(description: "Should receive item event anomaly")
        sut.anomalyAction = exp.expect(anomaly: .itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        sut.silenceAnomaly(.itemEventCalledWithCellType(ObjectIdentifier(BaseUpdateDeliveringStorage.self)))
        sut.reportAnomaly(.itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        waitForExpectations(timeout: 0.1)
    }
    
    func testSilencingAnomalyUsingBlockWorks() {
        let exp = expectation(description: "Should receive item event anomaly")
        exp.isInverted = true
        sut.anomalyAction = exp.expect(anomaly: .itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        sut.silenceAnomaly { anomaly  in
            switch anomaly {
            case .itemEventCalledWithCellType: return true
            default: return false
            }
        }
        sut.reportAnomaly(.itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        waitForExpectations(timeout: 0.1)
    }
    
    func testSilencingAnomalyUsingBlock_StillTriggersOtherAnomalies() {
        let exp = expectation(description: "Should receive item event anomaly")
        sut.anomalyAction = exp.expect(anomaly: .itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        sut.silenceAnomaly { anomaly in
            anomaly == .weirdIndexPathAction(indexPath(0, 0))
        }
        sut.reportAnomaly(.itemEventCalledWithCellType(ObjectIdentifier(MemoryStorage.self)))
        waitForExpectations(timeout: 0.1)
    }
}
