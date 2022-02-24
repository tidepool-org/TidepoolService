//
//  PersistedPumpEventTests.swift
//  TidepoolServiceKitTests
//
//  Created by Darin Krauss on 1/12/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import XCTest
import Foundation
import HealthKit
import LoopKit
@testable import TidepoolServiceKit

class PersistedPumpEventTests: XCTestCase {
    func testDataAlarm() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: nil,
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .alarm,
                                           automatic: true,
                                           alarmType: .other("Test Alarm"))
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "alarmType" : "other",
    "id" : "a07718a631a79cbe9dfafdc7aa3bc227",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/alarm",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "otherAlarmType" : "Test Alarm",
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "subType" : "alarm",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  }
]
"""
        )
    }

    func testDataAlarmWithSuspend() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: DoseEntry(suspendDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                           automatic: true),
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .alarm,
                                           automatic: true,
                                           alarmType: .other("Test Alarm"))
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "id" : "383e8a915ae51534a2907f9d9a527e5b",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/status",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "reason" : {
      "suspended" : "automatic"
    },
    "status" : "suspended",
    "subType" : "status",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  },
  {
    "alarmType" : "other",
    "id" : "a07718a631a79cbe9dfafdc7aa3bc227",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/alarm",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "otherAlarmType" : "Test Alarm",
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "subType" : "alarm",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  }
]
"""
        )
    }

    func testDataAlarmWithResume() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: DoseEntry(resumeDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                           automatic: true),
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .alarm,
                                           automatic: true,
                                           alarmType: .other("Test Alarm"))
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "alarmType" : "other",
    "id" : "a07718a631a79cbe9dfafdc7aa3bc227",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/alarm",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "otherAlarmType" : "Test Alarm",
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "subType" : "alarm",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  },
  {
    "id" : "383e8a915ae51534a2907f9d9a527e5b",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/status",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "reason" : {
      "resumed" : "automatic"
    },
    "status" : "resumed",
    "subType" : "status",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  }
]
"""
        )
    }

    func testDataAlarmClear() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: nil,
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .alarmClear)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertTrue(data.isEmpty)
    }

    func testDataAlarmClearWithSuspend() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: DoseEntry(suspendDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                           automatic: true),
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .alarmClear)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "id" : "383e8a915ae51534a2907f9d9a527e5b",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/status",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "reason" : {
      "suspended" : "automatic"
    },
    "status" : "suspended",
    "subType" : "status",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  }
]
"""
        )
    }

    func testDataAlarmClearWithResume() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: DoseEntry(resumeDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                           automatic: true),
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .alarmClear)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "id" : "383e8a915ae51534a2907f9d9a527e5b",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/status",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "reason" : {
      "resumed" : "automatic"
    },
    "status" : "resumed",
    "subType" : "status",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  }
]
"""
        )
    }

    func testDataBasal() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: DoseEntry(type: .basal,
                                                           startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                           endDate: Self.dateFormatter.date(from: "2020-01-02T03:25:23Z")!,
                                                           value: 0.75,
                                                           unit: .units,
                                                           deliveredUnits: nil,
                                                           description: "Test Basal Dose",
                                                           syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                                           scheduledBasalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 2.0),
                                                           insulinType: .novolog,
                                                           automatic: true,
                                                           manuallyEntered: false),
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .basal,
                                           automatic: true)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[

]
"""
        )
    }

    func testDataBolus() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: DoseEntry(type: .bolus,
                                                           startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                           endDate: Self.dateFormatter.date(from: "2020-01-02T03:00:53Z")!,
                                                           value: 4.25,
                                                           unit: .units,
                                                           deliveredUnits: 3.5,
                                                           description: "Test Bolus Dose",
                                                           syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                                           scheduledBasalRate: nil,
                                                           insulinType: .apidra,
                                                           automatic: false,
                                                           manuallyEntered: false),
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .basal,
                                           automatic: false)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[

]
"""
        )
    }

    func testDataPrime() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: nil,
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .prime)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "id" : "00e23a994ef6b0393a8c31db6bc5b264",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/prime",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "primeTarget" : "tubing",
    "subType" : "prime",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  }
]
"""
        )
    }

    func testDataPrimeWithSuspend() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: DoseEntry(suspendDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                           automatic: true),
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .prime)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "id" : "383e8a915ae51534a2907f9d9a527e5b",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/status",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "reason" : {
      "suspended" : "automatic"
    },
    "status" : "suspended",
    "subType" : "status",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  },
  {
    "id" : "00e23a994ef6b0393a8c31db6bc5b264",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/prime",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "primeTarget" : "tubing",
    "subType" : "prime",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  }
]
"""
        )
    }

    func testDataPrimeWithResume() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: DoseEntry(resumeDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                           automatic: true),
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .prime)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "id" : "00e23a994ef6b0393a8c31db6bc5b264",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/prime",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "primeTarget" : "tubing",
    "subType" : "prime",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  },
  {
    "id" : "383e8a915ae51534a2907f9d9a527e5b",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/status",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "reason" : {
      "resumed" : "automatic"
    },
    "status" : "resumed",
    "subType" : "status",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  }
]
"""
        )
    }

    func testDataResume() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: DoseEntry(resumeDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!),
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .resume)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "id" : "383e8a915ae51534a2907f9d9a527e5b",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/status",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "reason" : {
      "resumed" : "manual"
    },
    "status" : "resumed",
    "subType" : "status",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  }
]
"""
        )
    }

    func testDataRewind() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: nil,
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .rewind)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "id" : "16d248ca92e6a625d0fc0b344916bee7",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/reservoirChange",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "subType" : "reservoirChange",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  }
]
"""
        )
    }

    func testDataRewindWithSuspend() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: DoseEntry(suspendDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                           automatic: true),
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .rewind)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "id" : "383e8a915ae51534a2907f9d9a527e5b",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/status",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "reason" : {
      "suspended" : "automatic"
    },
    "status" : "suspended",
    "subType" : "status",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  },
  {
    "id" : "16d248ca92e6a625d0fc0b344916bee7",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/reservoirChange",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "subType" : "reservoirChange",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  }
]
"""
        )
    }

    func testDataRewindWithResume() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: DoseEntry(resumeDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                           automatic: true),
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .rewind)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "id" : "16d248ca92e6a625d0fc0b344916bee7",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/reservoirChange",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "subType" : "reservoirChange",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  },
  {
    "id" : "383e8a915ae51534a2907f9d9a527e5b",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/status",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "reason" : {
      "resumed" : "automatic"
    },
    "status" : "resumed",
    "subType" : "status",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  }
]
"""
        )
    }

    func testDataSuspend() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: DoseEntry(suspendDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                           automatic: true),
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .suspend,
                                           automatic: true)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "id" : "383e8a915ae51534a2907f9d9a527e5b",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:deviceEvent/status",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "ab0a722d639669875017a899a5214677"
    },
    "reason" : {
      "suspended" : "automatic"
    },
    "status" : "suspended",
    "subType" : "status",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "deviceEvent"
  }
]
"""
        )
    }

    func testDataTempBasal() {
        let pumpEvent = PersistedPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           persistedDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                           dose: DoseEntry(type: .tempBasal,
                                                           startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                           endDate: Self.dateFormatter.date(from: "2020-01-02T03:20:23Z")!,
                                                           value: 1.5,
                                                           unit: .unitsPerHour,
                                                           deliveredUnits: 0.5,
                                                           description: "Test Temp Basal Dose",
                                                           syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                                           scheduledBasalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 2.0),
                                                           insulinType: .fiasp,
                                                           automatic: true,
                                                           manuallyEntered: false),
                                           isUploaded: false,
                                           objectIDURL: URL(string: "x-coredata:///PumpEvent/18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                           raw: "18CF3948-0B3D-4B12-8BFE-14986B0E6784".data(using: .utf8),
                                           title: nil,
                                           type: .tempBasal,
                                           automatic: true)
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[

]
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
