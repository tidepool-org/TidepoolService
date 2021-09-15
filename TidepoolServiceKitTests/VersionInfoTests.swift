//
//  VersionInfoTests.swift
//  TidepoolServiceKitTests
//
//  Created by Rick Pasetto on 9/10/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import XCTest
import LoopKit
@testable import TidepoolServiceKit

class VersionInfoTests: XCTestCase {

    let info = VersionInfo(minimumSupported: "1.2.0", criticalUpdateNeeded: ["1.1.0", "0.3.1"])!

    func testInit() {
        XCTAssertNotNil(VersionInfo(minimumSupported: "1.2.0", criticalUpdateNeeded: ["1.1.0", "0.3.1"]))
        XCTAssertNotNil(VersionInfo(minimumSupported: "1.2.0", criticalUpdateNeeded: []))
        XCTAssertNil(VersionInfo(minimumSupported: nil, criticalUpdateNeeded: ["1.1.0", "0.3.1"]))
    }
    
    func testNeedsCriticalUpdate() {
        XCTAssertFalse(info.needsCriticalUpdate(version: "1.2.0"))
        XCTAssertTrue(info.needsCriticalUpdate(version: "1.1.0"))
    }
    
    func testNeedsSupportedUpdate() {
        XCTAssertFalse(info.needsSupportedUpdate(version: "1.2.0"))
        XCTAssertFalse(info.needsSupportedUpdate(version: "1.2.1"))
        XCTAssertFalse(info.needsSupportedUpdate(version: "2.1.0"))
        XCTAssertTrue(info.needsSupportedUpdate(version: "0.1.0"))
        XCTAssertTrue(info.needsSupportedUpdate(version: "0.3.0"))
        XCTAssertTrue(info.needsSupportedUpdate(version: "0.3.1"))
        XCTAssertTrue(info.needsSupportedUpdate(version: "1.1.0"))
        XCTAssertTrue(info.needsSupportedUpdate(version: "1.1.99"))
    }
    
    func testGetVersionUpdateNeeded() {
        XCTAssertEqual(.noneNeeded, info.getVersionUpdateNeeded(currentVersion: "1.2.0"))
        XCTAssertEqual(.noneNeeded, info.getVersionUpdateNeeded(currentVersion: "1.2.1"))
        XCTAssertEqual(.noneNeeded, info.getVersionUpdateNeeded(currentVersion: "2.1.0"))
        XCTAssertEqual(.supportedNeeded, info.getVersionUpdateNeeded(currentVersion: "0.1.0"))
        XCTAssertEqual(.supportedNeeded, info.getVersionUpdateNeeded(currentVersion: "0.3.0"))
        XCTAssertEqual(.criticalNeeded, info.getVersionUpdateNeeded(currentVersion: "0.3.1"))
        XCTAssertEqual(.criticalNeeded, info.getVersionUpdateNeeded(currentVersion: "1.1.0"))
        XCTAssertEqual(.supportedNeeded, info.getVersionUpdateNeeded(currentVersion: "1.1.99"))
    }
}
