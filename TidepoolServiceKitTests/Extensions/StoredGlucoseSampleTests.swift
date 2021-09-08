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
    func testCalibrationDeviceEvent() {
        let sample = StoredGlucoseSample(uuid: UUID(),
                                         provenanceIdentifier: UUID().uuidString,
                                         syncIdentifier: UUID().uuidString,
                                         syncVersion: 1,
                                         startDate: Date(),
                                         quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 123),
                                         condition: nil,
                                         trend: nil,
                                         trendRate: nil,
                                         isDisplayOnly: true,
                                         wasUserEntered: false,
                                         device: nil,
                                         healthKitEligibleDate: nil)
        let datum = sample.datum as? TidepoolKit.TCalibrationDeviceEventDatum
        XCTAssertNotNil(datum)
        XCTAssertEqual(datum?.time, sample.startDate)
        XCTAssertEqual(datum?.value, 123)
        XCTAssertEqual(datum?.units, .milligramsPerDeciliter)
        XCTAssertNil(datum?.annotations)
        XCTAssertNotNil(datum?.origin)
        XCTAssertEqual(datum?.origin?.id, sample.syncIdentifier)
        XCTAssertEqual(datum?.origin?.name, sample.provenanceIdentifier)
        XCTAssertNil(datum?.origin?.version)
        XCTAssertEqual(datum?.origin?.type, .application)
    }
    
    func testSMBG() {
        let sample = StoredGlucoseSample(uuid: UUID(),
                                         provenanceIdentifier: UUID().uuidString,
                                         syncIdentifier: UUID().uuidString,
                                         syncVersion: 2,
                                         startDate: Date(),
                                         quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 167),
                                         condition: nil,
                                         trend: nil,
                                         trendRate: nil,
                                         isDisplayOnly: false,
                                         wasUserEntered: true,
                                         device: nil,
                                         healthKitEligibleDate: nil)
        let datum = sample.datum as? TidepoolKit.TSMBGDatum
        XCTAssertNotNil(datum)
        XCTAssertEqual(datum?.time, sample.startDate)
        XCTAssertEqual(datum?.value, 167)
        XCTAssertEqual(datum?.units, .milligramsPerDeciliter)
        XCTAssertEqual(datum?.subType, .manual)
        XCTAssertNil(datum?.annotations)
        XCTAssertNotNil(datum?.origin)
        XCTAssertEqual(datum?.origin?.id, sample.syncIdentifier)
        XCTAssertEqual(datum?.origin?.name, sample.provenanceIdentifier)
        XCTAssertNil(datum?.origin?.version)
        XCTAssertEqual(datum?.origin?.type, .application)
    }
    
    func testCBGNormal() {
        let sample = StoredGlucoseSample(uuid: UUID(),
                                         provenanceIdentifier: UUID().uuidString,
                                         syncIdentifier: UUID().uuidString,
                                         syncVersion: 3,
                                         startDate: Date(),
                                         quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 123),
                                         condition: nil,
                                         trend: .flat,
                                         trendRate: HKQuantity(unit: .milligramsPerDeciliterPerMinute, doubleValue: 0.1),
                                         isDisplayOnly: false,
                                         wasUserEntered: false,
                                         device: nil,
                                         healthKitEligibleDate: nil)
        let datum = sample.datum as? TidepoolKit.TCBGDatum
        XCTAssertNotNil(datum)
        XCTAssertEqual(datum?.time, sample.startDate)
        XCTAssertEqual(datum?.value, 123)
        XCTAssertEqual(datum?.units, .milligramsPerDeciliter)
        XCTAssertEqual(datum?.trend, .constant)
        XCTAssertEqual(datum?.trendRate, 0.1)
        XCTAssertNil(datum?.annotations)
        XCTAssertNotNil(datum?.origin)
        XCTAssertEqual(datum?.origin?.id, sample.syncIdentifier)
        XCTAssertEqual(datum?.origin?.name, sample.provenanceIdentifier)
        XCTAssertNil(datum?.origin?.version)
        XCTAssertEqual(datum?.origin?.type, .application)
    }
    
    func testCBGBelowRange() {
        let sample = StoredGlucoseSample(uuid: UUID(),
                                         provenanceIdentifier: UUID().uuidString,
                                         syncIdentifier: UUID().uuidString,
                                         syncVersion: 4,
                                         startDate: Date(),
                                         quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 39.0),
                                         condition: .belowRange(threshold: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 40.0)),
                                         trend: .down,
                                         trendRate: HKQuantity(unit: .milligramsPerDeciliterPerMinute, doubleValue: -1.0),
                                         isDisplayOnly: false,
                                         wasUserEntered: false,
                                         device: nil,
                                         healthKitEligibleDate: nil)
        let datum = sample.datum as? TidepoolKit.TCBGDatum
        XCTAssertNotNil(datum)
        XCTAssertEqual(datum?.time, sample.startDate)
        XCTAssertEqual(datum?.value, 39.0)
        XCTAssertEqual(datum?.units, .milligramsPerDeciliter)
        XCTAssertEqual(datum?.trend, .slowFall)
        XCTAssertEqual(datum?.trendRate, -1.0)
        XCTAssertNotNil(datum?.annotations)
        XCTAssertEqual(datum?.annotations?.count, 1)
        XCTAssertEqual(datum?.annotations?[0]["code"] as? String, "bg/out-of-range")
        XCTAssertEqual(datum?.annotations?[0]["value"] as? String, "low")
        XCTAssertEqual(datum?.annotations?[0]["threshold"] as? Double, 40.0)
        XCTAssertNotNil(datum?.origin)
        XCTAssertEqual(datum?.origin?.id, sample.syncIdentifier)
        XCTAssertEqual(datum?.origin?.name, sample.provenanceIdentifier)
        XCTAssertNil(datum?.origin?.version)
        XCTAssertEqual(datum?.origin?.type, .application)
    }
    
    func testCBGAboveRange() {
        let sample = StoredGlucoseSample(uuid: UUID(),
                                         provenanceIdentifier: UUID().uuidString,
                                         syncIdentifier: UUID().uuidString,
                                         syncVersion: 5,
                                         startDate: Date(),
                                         quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 401.0),
                                         condition: .aboveRange(threshold: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 400.0)),
                                         trend: .upUp,
                                         trendRate: HKQuantity(unit: .milligramsPerDeciliterPerMinute, doubleValue: 4.0),
                                         isDisplayOnly: false,
                                         wasUserEntered: false,
                                         device: nil,
                                         healthKitEligibleDate: nil)
        let datum = sample.datum as? TidepoolKit.TCBGDatum
        XCTAssertNotNil(datum)
        XCTAssertEqual(datum?.time, sample.startDate)
        XCTAssertEqual(datum?.value, 401.0)
        XCTAssertEqual(datum?.units, .milligramsPerDeciliter)
        XCTAssertEqual(datum?.trend, .moderateRise)
        XCTAssertEqual(datum?.trendRate, 4.0)
        XCTAssertNotNil(datum?.annotations)
        XCTAssertEqual(datum?.annotations?.count, 1)
        XCTAssertEqual(datum?.annotations?[0]["code"] as? String, "bg/out-of-range")
        XCTAssertEqual(datum?.annotations?[0]["value"] as? String, "high")
        XCTAssertEqual(datum?.annotations?[0]["threshold"] as? Double, 400.0)
        XCTAssertNotNil(datum?.origin)
        XCTAssertEqual(datum?.origin?.id, sample.syncIdentifier)
        XCTAssertEqual(datum?.origin?.name, sample.provenanceIdentifier)
        XCTAssertNil(datum?.origin?.version)
        XCTAssertEqual(datum?.origin?.type, .application)
    }
}
