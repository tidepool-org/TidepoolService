//
//  TidepoolServiceTests.swift
//  TidepoolServiceKitTests
//
//  Created by Rick Pasetto on 9/14/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import XCTest
import LoopKit
@testable import TidepoolKit
@testable import TidepoolServiceKit

class TidepoolServiceTests: XCTestCase {
    static var randomString: String { UUID().uuidString }
    static let info = TInfo(versions: TInfo.Versions(loop: TInfo.Versions.Loop(minimumSupported: "1.2.3", criticalUpdateNeeded: ["1.0.0", "1.1.0"])))
    
    let authenticationToken = randomString
    let refreshAuthenticationToken = randomString
    let userId = randomString
    var service: TidepoolService!
    enum TestError: Error {
       case test
    }

    override func setUp() {
        super.setUp()
        
        URLProtocolMock.handlers = []

        let environment = TEnvironment(host: "test.org", port: 443)
        let session = TSession(environment: environment, authenticationToken: authenticationToken, userId: userId)
        service = TidepoolService(automaticallyFetchEnvironments: false)
        service.tapi.session = session
        service.tapi.urlSessionConfiguration.protocolClasses = [URLProtocolMock.self]
    }

    override func tearDown() {
        XCTAssertTrue(URLProtocolMock.handlers.isEmpty)
    }

    func setupToReturnInfo() {
        URLProtocolMock.handlers = [URLProtocolMock.Handler(validator: URLProtocolMock.Validator(url: "https://test.org/info", method: "GET"),
                                                            success: URLProtocolMock.Success(statusCode: 200, body: Self.info))]
    }
    
    func setupToReturnErrorOnInfo() {
        URLProtocolMock.handlers = [URLProtocolMock.Handler(validator: URLProtocolMock.Validator(url: "https://test.org/info", method: "GET"),
                                                            error: TestError.test)]
    }
    
    func testCheckVersion() throws {
        setupToReturnInfo()
        var tempResult: Result<VersionUpdate?, Error>?
        let e = self.expectation(description: #function)
        service.checkVersion(bundleIdentifier: "org.tidepool.Loop", currentVersion: "1.2.0") {
            tempResult = $0
            e.fulfill()
        }
        wait(for: [e], timeout: 1.0)
        let result = try XCTUnwrap(tempResult)
        XCTAssertNil(result.error)
        XCTAssertEqual(VersionUpdate.recommended, result.value)
    }
    
    func testCheckVersionReturnsNilForOtherBundleIdentifiers() throws {
        setupToReturnInfo()
        var tempResult: Result<VersionUpdate?, Error>?
        let e = self.expectation(description: #function)
        service.checkVersion(bundleIdentifier: "foo.bar", currentVersion: "1.2.0") {
            tempResult = $0
            e.fulfill()
        }
        wait(for: [e], timeout: 1.0)
        let result = try XCTUnwrap(tempResult)
        XCTAssertNil(result.error)
        let value = try XCTUnwrap(result.value)
        XCTAssertNil(value)
    }
    
    func testCheckVersionError() throws {
        setupToReturnErrorOnInfo()
        var tempResult: Result<VersionUpdate?, Error>?
        let e = self.expectation(description: #function)
        service.checkVersion(bundleIdentifier: "org.tidepool.Loop", currentVersion: "1.2.0") {
            tempResult = $0
            e.fulfill()
        }
        wait(for: [e], timeout: 1.0)
        let result = try XCTUnwrap(tempResult)
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.value as Any?)
    }
    
    func testCheckVersionReturnsLastResultOnError() throws {
        setupToReturnInfo()
        var tempResult: Result<VersionUpdate?, Error>?
        let e = self.expectation(description: #function)
        service.checkVersion(bundleIdentifier: "org.tidepool.Loop", currentVersion: "1.2.0") {
            tempResult = $0
            e.fulfill()
        }
        wait(for: [e], timeout: 1.0)
        var result = try XCTUnwrap(tempResult)
        XCTAssertNil(result.error)
        XCTAssertEqual(VersionUpdate.recommended, result.value)
        
        setupToReturnErrorOnInfo()
        let e2 = self.expectation(description: #function + " error")
        service.checkVersion(bundleIdentifier: "org.tidepool.Loop", currentVersion: "1.2.0") {
            tempResult = $0
            e2.fulfill()
        }
        wait(for: [e2], timeout: 1.0)
        result = try XCTUnwrap(tempResult)
        XCTAssertNil(result.error)
        XCTAssertEqual(VersionUpdate.recommended, result.value)
    }
    
}

extension Result {
    var value: Success? {
        switch self {
        case .failure: return nil
        case .success(let val): return val
        }
    }
    var error: Failure? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}
