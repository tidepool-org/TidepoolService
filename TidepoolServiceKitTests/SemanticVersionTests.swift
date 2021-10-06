//
//  SemanticVersionTests.swift
//  TidepoolServiceKitTests
//
//  Created by Rick Pasetto on 9/13/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import XCTest
@testable import TidepoolServiceKit

class SemanticVersionTests: XCTestCase {
    
    func testInvalid() {
        XCTAssertNil(SemanticVersion("abc123"))
        XCTAssertNil(SemanticVersion("foopyNoopy"))
        XCTAssertNil(SemanticVersion("1.2.3.4"))
        XCTAssertNil(SemanticVersion("-1.2.3.4"))
        XCTAssertNotNil(SemanticVersion("1.2.3"))
        XCTAssertNotNil(SemanticVersion("1.0.3"))
        XCTAssertNotNil(SemanticVersion("00.00.00"))
    }
    
    func testComparable() {
        XCTAssertEqual(SemanticVersion("1.2.3"), SemanticVersion("1.2.3"))
        XCTAssertEqual(SemanticVersion("01.2.3"), SemanticVersion("1.2.3"))
        XCTAssertEqual(SemanticVersion("00.00.00"), SemanticVersion("0.0.0"))
        XCTAssertGreaterThan(SemanticVersion("0.0.1")!, SemanticVersion("0.0.0")!)
        XCTAssertGreaterThan(SemanticVersion("1.2.3")!, SemanticVersion("1.2.2")!)
        XCTAssertLessThan(SemanticVersion("1.2.1")!, SemanticVersion("1.2.2")!)
        XCTAssertGreaterThan(SemanticVersion("1.3.2")!, SemanticVersion("1.2.2")!)
        XCTAssertLessThan(SemanticVersion("1.1.1")!, SemanticVersion("1.2.1")!)
        XCTAssertGreaterThan(SemanticVersion("2.2.3")!, SemanticVersion("1.2.3")!)
        XCTAssertLessThan(SemanticVersion("1.2.3")!, SemanticVersion("2.2.3")!)
    }
}
