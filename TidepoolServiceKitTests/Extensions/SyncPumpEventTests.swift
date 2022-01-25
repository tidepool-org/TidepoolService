//
//  SyncPumpEventTests.swift
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

class SyncPumpEventTests: XCTestCase {
    func testDataAlarm() {
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .alarm,
                                      alarmType: .other("Test Alarm"),
                                      mutable: false,
                                      dose: nil,
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .alarm,
                                      alarmType: .other("Test Alarm"),
                                      mutable: false,
                                      dose: DoseEntry(suspendDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                      automatic: true),
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .alarm,
                                      alarmType: .other("Test Alarm"),
                                      mutable: false,
                                      dose: DoseEntry(resumeDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                      automatic: true),
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .alarmClear,
                                      mutable: false,
                                      dose: nil,
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertTrue(data.isEmpty)
    }

    func testDataAlarmClearWithSuspend() {
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .alarmClear,
                                      mutable: false,
                                      dose: DoseEntry(suspendDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                      automatic: true),
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .alarmClear,
                                      mutable: false,
                                      dose: DoseEntry(resumeDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                      automatic: true),
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .basal,
                                      mutable: false,
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
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "deliveryType" : "scheduled",
    "duration" : 1500000,
    "id" : "ecabf24a123e1d8028a6e41beb00dd13",
    "insulinFormulation" : {
      "simple" : {
        "actingType" : "rapid",
        "brand" : "NovaLog"
      }
    },
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:basal/scheduled",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "deliveredUnits" : 0.75,
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
    },
    "rate" : 2,
    "scheduleName" : "Default",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "basal"
  }
]
"""
        )
    }

    func testDataBolus() {
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .bolus,
                                      mutable: false,
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
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "expectedNormal" : 4.25,
    "id" : "8a53d0b7449ffefe549acf2b664365f3",
    "insulinFormulation" : {
      "simple" : {
        "actingType" : "rapid",
        "brand" : "Apidra"
      }
    },
    "normal" : 3.5,
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:bolus/normal",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "duration" : 30000,
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
    },
    "subType" : "normal",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "bolus"
  }
]
"""
        )
    }

    func testDataBolusManual() {
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .bolus,
                                      mutable: false,
                                      dose: DoseEntry(type: .bolus,
                                                      startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                      endDate: Self.dateFormatter.date(from: "2020-01-02T03:00:53Z")!,
                                                      value: 4.25,
                                                      unit: .units,
                                                      deliveredUnits: nil,
                                                      description: "Test Bolus Dose",
                                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                                      scheduledBasalRate: nil,
                                                      insulinType: .apidra,
                                                      automatic: false,
                                                      manuallyEntered: true),
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "dose" : {
      "total" : 4.25,
      "units" : "Units"
    },
    "formulation" : {
      "simple" : {
        "actingType" : "rapid",
        "brand" : "Apidra"
      }
    },
    "id" : "ad1a320c554f491bc2a3287def00dd1b",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:insulin",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "duration" : 30000,
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
    },
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "insulin"
  }
]
"""
        )
    }

    func testDataPrime() {
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .prime,
                                      mutable: false,
                                      dose: nil,
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .prime,
                                      mutable: false,
                                      dose: DoseEntry(suspendDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                      automatic: true),
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .prime,
                                      mutable: false,
                                      dose: DoseEntry(resumeDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                      automatic: true),
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .resume,
                                      mutable: false,
                                      dose: DoseEntry(resumeDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!),
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .rewind,
                                      mutable: false,
                                      dose: nil,
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .rewind,
                                      mutable: false,
                                      dose: DoseEntry(suspendDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                      automatic: true),
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .rewind,
                                      mutable: false,
                                      dose: DoseEntry(resumeDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                      automatic: true),
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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

    func testDataSuspendIsStatusDeviceEvent() {
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .suspend,
                                      mutable: false,
                                      dose: DoseEntry(suspendDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                      automatic: true),
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
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
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
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

    func testDataSuspendIsSuspendedBasal() {
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .suspend,
                                      mutable: true,
                                      dose: DoseEntry(type: .suspend,
                                                      startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                      endDate: Self.dateFormatter.date(from: "2020-01-02T03:30:23Z")!,
                                                      value: 0,
                                                      unit: .unitsPerHour,
                                                      deliveredUnits: nil,
                                                      description: "Test Suspend Basal Dose",
                                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                                      scheduledBasalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 2.0),
                                                      insulinType: .fiasp,
                                                      automatic: true,
                                                      manuallyEntered: false),
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "deliveryType" : "suspend",
    "duration" : 1800000,
    "id" : "49f79400d814f64d3a4ff60078de89a1",
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:basal/suspend",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
    },
    "suppressed" : {
      "deliveryType" : "scheduled",
      "rate" : 2,
      "scheduleName" : "Default",
      "type" : "basal"
    },
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "basal"
  }
]
"""
        )
    }

    func testDataTempBasal() {
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .tempBasal,
                                      mutable: false,
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
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "deliveryType" : "automated",
    "duration" : 1200000,
    "expectedDuration" : 1800000,
    "id" : "f839af02f6832d7c81d636dbbbadbc01",
    "insulinFormulation" : {
      "simple" : {
        "actingType" : "rapid",
        "brand" : "Fiasp"
      }
    },
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:basal/automated",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "deliveredUnits" : 0.5,
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
    },
    "rate" : 1.5,
    "scheduleName" : "Default",
    "suppressed" : {
      "deliveryType" : "scheduled",
      "rate" : 2,
      "scheduleName" : "Default",
      "type" : "basal"
    },
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "basal"
  }
]
"""
        )
    }

    func testDataTempBasalMutable() {
        let pumpEvent = SyncPumpEvent(date: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                      type: .tempBasal,
                                      mutable: true,
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
                                      syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")
        let data = pumpEvent.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "deliveryType" : "automated",
    "duration" : 1200000,
    "id" : "f839af02f6832d7c81d636dbbbadbc01",
    "insulinFormulation" : {
      "simple" : {
        "actingType" : "rapid",
        "brand" : "Fiasp"
      }
    },
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:basal/automated",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "deliveredUnits" : 0.5,
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
    },
    "rate" : 1.5,
    "scheduleName" : "Default",
    "suppressed" : {
      "deliveryType" : "scheduled",
      "rate" : 2,
      "scheduleName" : "Default",
      "type" : "basal"
    },
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "basal"
  }
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
