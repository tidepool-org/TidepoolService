//
//  StoredGlucoseSample.swift
//  TidepoolServiceKitTests
//
//  Created by Darin Krauss on 9/7/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import XCTest
import HealthKit
import TidepoolKit
import LoopKit
@testable import TidepoolServiceKit

class StoredGlucoseSampleTests: XCTestCase {
    func testDatumCalibrationDeviceEvent() {
        let sample = StoredGlucoseSample(uuid: UUID(uuidString: "2A67A303-1234-4CB8-8263-79498265368E")!,
                                         provenanceIdentifier: "135CDABE-9343-7242-4233-1020384789AE",
                                         syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                         syncVersion: 1,
                                         startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                         quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 123),
                                         condition: nil,
                                         trend: nil,
                                         trendRate: nil,
                                         isDisplayOnly: true,
                                         wasUserEntered: false,
                                         device: nil,
                                         healthKitEligibleDate: nil)
        let datum = sample.datum(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(datum), encoding: .utf8), """
{
  "id" : "4cf2a0566365e60b3f9618f39de149b8",
  "origin" : {
    "id" : "e71808a78873168e1c21dcd6636290ba",
    "name" : "135CDABE-9343-7242-4233-1020384789AE",
    "type" : "application"
  },
  "payload" : {
    "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
    "syncVersion" : 1,
    "uuid" : "2A67A303-1234-4CB8-8263-79498265368E"
  },
  "subType" : "calibration",
  "time" : "2020-01-02T03:00:23.000Z",
  "type" : "deviceEvent",
  "units" : "mg/dL",
  "value" : 123
}
"""
        )
    }
    
    func testDatumSMBG() {
        let sample = StoredGlucoseSample(uuid: UUID(uuidString: "2A67A303-1234-4CB8-8263-79498265368E")!,
                                         provenanceIdentifier: "135CDABE-9343-7242-4233-1020384789AE",
                                         syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                         syncVersion: 2,
                                         startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                         quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 167),
                                         condition: nil,
                                         trend: nil,
                                         trendRate: nil,
                                         isDisplayOnly: false,
                                         wasUserEntered: true,
                                         device: nil,
                                         healthKitEligibleDate: nil)
        let datum = sample.datum(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(datum), encoding: .utf8), """
{
  "id" : "4cf2a0566365e60b3f9618f39de149b8",
  "origin" : {
    "id" : "e71808a78873168e1c21dcd6636290ba",
    "name" : "135CDABE-9343-7242-4233-1020384789AE",
    "type" : "application"
  },
  "payload" : {
    "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
    "syncVersion" : 2,
    "uuid" : "2A67A303-1234-4CB8-8263-79498265368E"
  },
  "subType" : "manual",
  "time" : "2020-01-02T03:00:23.000Z",
  "type" : "smbg",
  "units" : "mg/dL",
  "value" : 167
}
"""
        )
    }
    
    func testDatumCBGNormal() {
        let sample = StoredGlucoseSample(uuid: UUID(uuidString: "2A67A303-1234-4CB8-8263-79498265368E")!,
                                         provenanceIdentifier: "135CDABE-9343-7242-4233-1020384789AE",
                                         syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                         syncVersion: 3,
                                         startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                         quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 123),
                                         condition: nil,
                                         trend: .flat,
                                         trendRate: HKQuantity(unit: .milligramsPerDeciliterPerMinute, doubleValue: 0.1),
                                         isDisplayOnly: false,
                                         wasUserEntered: false,
                                         device: nil,
                                         healthKitEligibleDate: nil)
        let datum = sample.datum(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(datum), encoding: .utf8), """
{
  "id" : "4cf2a0566365e60b3f9618f39de149b8",
  "origin" : {
    "id" : "e71808a78873168e1c21dcd6636290ba",
    "name" : "135CDABE-9343-7242-4233-1020384789AE",
    "type" : "application"
  },
  "payload" : {
    "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
    "syncVersion" : 3,
    "uuid" : "2A67A303-1234-4CB8-8263-79498265368E"
  },
  "time" : "2020-01-02T03:00:23.000Z",
  "trend" : "constant",
  "trendRate" : 0.10000000000000001,
  "type" : "cbg",
  "units" : "mg/dL",
  "value" : 123
}
"""
        )
    }
    
    func testDatumCBGBelowRange() {
        let sample = StoredGlucoseSample(uuid: UUID(uuidString: "2A67A303-1234-4CB8-8263-79498265368E")!,
                                         provenanceIdentifier: "135CDABE-9343-7242-4233-1020384789AE",
                                         syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                         syncVersion: 4,
                                         startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                         quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 40.0),
                                         condition: .belowRange,
                                         trend: .down,
                                         trendRate: HKQuantity(unit: .milligramsPerDeciliterPerMinute, doubleValue: -1.0),
                                         isDisplayOnly: false,
                                         wasUserEntered: false,
                                         device: nil,
                                         healthKitEligibleDate: nil)
        let datum = sample.datum(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(datum), encoding: .utf8), """
{
  "annotations" : [
    {
      "code" : "bg/out-of-range",
      "threshold" : 40,
      "value" : "low"
    }
  ],
  "id" : "4cf2a0566365e60b3f9618f39de149b8",
  "origin" : {
    "id" : "e71808a78873168e1c21dcd6636290ba",
    "name" : "135CDABE-9343-7242-4233-1020384789AE",
    "type" : "application"
  },
  "payload" : {
    "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
    "syncVersion" : 4,
    "uuid" : "2A67A303-1234-4CB8-8263-79498265368E"
  },
  "time" : "2020-01-02T03:00:23.000Z",
  "trend" : "slowFall",
  "trendRate" : -1,
  "type" : "cbg",
  "units" : "mg/dL",
  "value" : 39
}
"""
        )
    }
    
    func testDatumCBGAboveRange() {
        let sample = StoredGlucoseSample(uuid: UUID(uuidString: "2A67A303-1234-4CB8-8263-79498265368E")!,
                                         provenanceIdentifier: "135CDABE-9343-7242-4233-1020384789AE",
                                         syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                         syncVersion: 5,
                                         startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                         quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 400.0),
                                         condition: .aboveRange,
                                         trend: .upUp,
                                         trendRate: HKQuantity(unit: .milligramsPerDeciliterPerMinute, doubleValue: 4.0),
                                         isDisplayOnly: false,
                                         wasUserEntered: false,
                                         device: nil,
                                         healthKitEligibleDate: nil)
        let datum = sample.datum(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(datum), encoding: .utf8), """
{
  "annotations" : [
    {
      "code" : "bg/out-of-range",
      "threshold" : 400,
      "value" : "high"
    }
  ],
  "id" : "4cf2a0566365e60b3f9618f39de149b8",
  "origin" : {
    "id" : "e71808a78873168e1c21dcd6636290ba",
    "name" : "135CDABE-9343-7242-4233-1020384789AE",
    "type" : "application"
  },
  "payload" : {
    "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
    "syncVersion" : 5,
    "uuid" : "2A67A303-1234-4CB8-8263-79498265368E"
  },
  "time" : "2020-01-02T03:00:23.000Z",
  "trend" : "moderateRise",
  "trendRate" : 4,
  "type" : "cbg",
  "units" : "mg/dL",
  "value" : 401
}
"""
        )
    }
    
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder.tidepool
        encoder.outputFormatting.insert(.prettyPrinted)
        return encoder
    }()
    
    private static let dateFormatter = ISO8601DateFormatter()
}
