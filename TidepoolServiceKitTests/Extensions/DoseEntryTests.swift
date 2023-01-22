//
//  DoseEntryTests.swift
//  TidepoolServiceKitTests
//
//  Created by Darin Krauss on 2/7/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import Foundation

import XCTest
import Foundation
import HealthKit
import LoopKit
import TidepoolKit
@testable import TidepoolServiceKit

class DoseEntryDataTests: XCTestCase {
    let hostIdentifier = "com.loopkit.Loop"
    let hostVersion = "1.0.0"

    func testDataBasal() {
        let doseEntry = DoseEntry(type: .basal,
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
                                  manuallyEntered: false)
        let data = doseEntry.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011", hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "deliveryType" : "scheduled",
    "duration" : 1500000,
    "id" : "ecabf24a123e1d8028a6e41beb00dd13",
    "insulinFormulation" : {
      "simple" : {
        "actingType" : "rapid",
        "brand" : "NovoLog"
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

    func testDataBolusManuallyEntered() {
        let doseEntry = DoseEntry(type: .bolus,
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
                                  manuallyEntered: true)
        let data = doseEntry.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011", hostIdentifier: hostIdentifier, hostVersion: hostVersion)
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

    func testDataBolusManualImmutable() {
        let doseEntry = DoseEntry(type: .bolus,
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
                                  manuallyEntered: false)
        let data = doseEntry.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011", hostIdentifier: hostIdentifier, hostVersion: hostVersion)
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

    func testDataBolusManualMutable() {
        let doseEntry = DoseEntry(type: .bolus,
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
                                  manuallyEntered: false,
                                  isMutable: true)
        let data = doseEntry.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011", hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "annotations" : [
      {
        "code" : "bolus/mutable"
      }
    ],
    "id" : "8a53d0b7449ffefe549acf2b664365f3",
    "insulinFormulation" : {
      "simple" : {
        "actingType" : "rapid",
        "brand" : "Apidra"
      }
    },
    "normal" : 4.25,
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

    func testDataBolusAutomaticImmutable() {
        let doseEntry = DoseEntry(type: .bolus,
                                  startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                  endDate: Self.dateFormatter.date(from: "2020-01-02T03:00:53Z")!,
                                  value: 4.25,
                                  unit: .units,
                                  deliveredUnits: 3.5,
                                  description: "Test Bolus Dose",
                                  syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                  scheduledBasalRate: nil,
                                  insulinType: .apidra,
                                  automatic: true,
                                  manuallyEntered: false)
        let data = doseEntry.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011", hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "expectedNormal" : 4.25,
    "id" : "1ee0e82b79f29ca633f5b369f4ff8e1c",
    "insulinFormulation" : {
      "simple" : {
        "actingType" : "rapid",
        "brand" : "Apidra"
      }
    },
    "normal" : 3.5,
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:bolus/automated",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "duration" : 30000,
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
    },
    "subType" : "automated",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "bolus"
  }
]
"""
        )
    }

    func testDataBolusAutomaticMutable() {
        let doseEntry = DoseEntry(type: .bolus,
                                  startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                  endDate: Self.dateFormatter.date(from: "2020-01-02T03:00:53Z")!,
                                  value: 4.25,
                                  unit: .units,
                                  deliveredUnits: 3.5,
                                  description: "Test Bolus Dose",
                                  syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                  scheduledBasalRate: nil,
                                  insulinType: .apidra,
                                  automatic: true,
                                  manuallyEntered: false,
                                  isMutable: true)
        let data = doseEntry.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011", hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "annotations" : [
      {
        "code" : "bolus/mutable"
      }
    ],
    "id" : "1ee0e82b79f29ca633f5b369f4ff8e1c",
    "insulinFormulation" : {
      "simple" : {
        "actingType" : "rapid",
        "brand" : "Apidra"
      }
    },
    "normal" : 4.25,
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:bolus/automated",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "duration" : 30000,
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
    },
    "subType" : "automated",
    "time" : "2020-01-02T03:00:23.000Z",
    "type" : "bolus"
  }
]
"""
        )
    }

    func testDataResume() {
        let doseEntry = DoseEntry(type: .resume,
                                  startDate: Self.dateFormatter.date(from: "2020-01-02T03:30:23Z")!,
                                  endDate: Self.dateFormatter.date(from: "2020-01-02T03:30:23Z")!,
                                  value: 0,
                                  unit: .unitsPerHour,
                                  deliveredUnits: nil,
                                  description: "Test Resume Dose",
                                  syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                  scheduledBasalRate: nil,
                                  insulinType: nil,
                                  automatic: true,
                                  manuallyEntered: false)
        let data = doseEntry.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011", hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[

]
"""
        )
    }
    func testDataSuspend() {
        let doseEntry = DoseEntry(type: .suspend,
                                  startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                  endDate: Self.dateFormatter.date(from: "2020-01-02T03:30:23Z")!,
                                  value: 0,
                                  unit: .unitsPerHour,
                                  deliveredUnits: nil,
                                  description: "Test Suspend Dose",
                                  syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                  scheduledBasalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 2.0),
                                  insulinType: .fiasp,
                                  automatic: true,
                                  manuallyEntered: false)
        let data = doseEntry.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011", hostIdentifier: hostIdentifier, hostVersion: hostVersion)
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

    func testDataTempBasalManualImmutable() {
        let doseEntry = DoseEntry(type: .tempBasal,
                                  startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                  endDate: Self.dateFormatter.date(from: "2020-01-02T03:20:23Z")!,
                                  value: 1.5,
                                  unit: .unitsPerHour,
                                  deliveredUnits: 0.5,
                                  description: "Test Temp Basal Dose",
                                  syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                  scheduledBasalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 2.0),
                                  insulinType: .fiasp,
                                  automatic: false,
                                  manuallyEntered: false)
        let data = doseEntry.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011", hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "deliveryType" : "temp",
    "duration" : 1200000,
    "expectedDuration" : 1800000,
    "id" : "e30f6c68b7a21590622c6dcf9fa57f95",
    "insulinFormulation" : {
      "simple" : {
        "actingType" : "rapid",
        "brand" : "Fiasp"
      }
    },
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:basal/temp",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "deliveredUnits" : 0.5,
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
    },
    "rate" : 1.5,
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

    func testDataTempBasalManualMutable() {
        let doseEntry = DoseEntry(type: .tempBasal,
                                  startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                  endDate: Self.dateFormatter.date(from: "2020-01-02T03:20:23Z")!,
                                  value: 1.5,
                                  unit: .unitsPerHour,
                                  deliveredUnits: 0.5,
                                  description: "Test Temp Basal Dose",
                                  syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                  scheduledBasalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 2.0),
                                  insulinType: .fiasp,
                                  automatic: false,
                                  manuallyEntered: false,
                                  isMutable: true)
        let data = doseEntry.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011", hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "annotations" : [
      {
        "code" : "basal/unknown-duration"
      }
    ],
    "deliveryType" : "temp",
    "duration" : 0,
    "id" : "e30f6c68b7a21590622c6dcf9fa57f95",
    "insulinFormulation" : {
      "simple" : {
        "actingType" : "rapid",
        "brand" : "Fiasp"
      }
    },
    "origin" : {
      "id" : "ab0a722d639669875017a899a5214677:basal/temp",
      "name" : "com.apple.dt.xctest.tool",
      "type" : "application"
    },
    "payload" : {
      "deliveredUnits" : 0.5,
      "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784"
    },
    "rate" : 1.5,
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

    func testDataTempBasalAutomaticImmutable() {
        let doseEntry = DoseEntry(type: .tempBasal,
                                  startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                  endDate: Self.dateFormatter.date(from: "2020-01-02T03:20:23Z")!,
                                  value: 1.5,
                                  unit: .unitsPerHour,
                                  deliveredUnits: 0.5,
                                  description: "Test Temp Basal Dose",
                                  syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                  scheduledBasalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 2.0),
                                  insulinType: .fiasp,
                                  manuallyEntered: false)
        let data = doseEntry.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011", hostIdentifier: hostIdentifier, hostVersion: hostVersion)
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

    func testDataTempBasalAutomaticMutable() {
        let doseEntry = DoseEntry(type: .tempBasal,
                                  startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                  endDate: Self.dateFormatter.date(from: "2020-01-02T03:20:23Z")!,
                                  value: 1.5,
                                  unit: .unitsPerHour,
                                  deliveredUnits: 0.5,
                                  description: "Test Temp Basal Dose",
                                  syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                  scheduledBasalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 2.0),
                                  insulinType: .fiasp,
                                  manuallyEntered: false,
                                  isMutable: true)
        let data = doseEntry.data(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011", hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        XCTAssertEqual(String(data: try! Self.encoder.encode(data), encoding: .utf8), """
[
  {
    "annotations" : [
      {
        "code" : "basal/unknown-duration"
      }
    ],
    "deliveryType" : "automated",
    "duration" : 0,
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

class DoseEntrySelectorTests: XCTestCase {
    func testSelectorBasal() {
        let doseEntry = DoseEntry(type: .basal,
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
                                  manuallyEntered: false)
        XCTAssertEqual(doseEntry.selectors, [TDatum.Selector(origin: TDatum.Selector.Origin(id: "ab0a722d639669875017a899a5214677:basal/scheduled"))])
    }

    func testSelectorBolusManuallyEntered() {
        let doseEntry = DoseEntry(type: .bolus,
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
                                  manuallyEntered: true)
        XCTAssertEqual(doseEntry.selectors, [TDatum.Selector(origin: TDatum.Selector.Origin(id: "ab0a722d639669875017a899a5214677:insulin"))])
    }

    func testSelectorBolusManual() {
        let doseEntry = DoseEntry(type: .bolus,
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
                                  manuallyEntered: false)
        XCTAssertEqual(doseEntry.selectors, [TDatum.Selector(origin: TDatum.Selector.Origin(id: "ab0a722d639669875017a899a5214677:bolus/normal"))])
    }

    func testSelectorBolusAutomatic() {
        let doseEntry = DoseEntry(type: .bolus,
                                  startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                  endDate: Self.dateFormatter.date(from: "2020-01-02T03:00:53Z")!,
                                  value: 4.25,
                                  unit: .units,
                                  deliveredUnits: 3.5,
                                  description: "Test Bolus Dose",
                                  syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                  scheduledBasalRate: nil,
                                  insulinType: .apidra,
                                  automatic: true,
                                  manuallyEntered: false)
        XCTAssertEqual(doseEntry.selectors, [TDatum.Selector(origin: TDatum.Selector.Origin(id: "ab0a722d639669875017a899a5214677:bolus/automated"))])
    }

    func testSelectorResume() {
        let doseEntry = DoseEntry(type: .resume,
                                  startDate: Self.dateFormatter.date(from: "2020-01-02T03:30:23Z")!,
                                  endDate: Self.dateFormatter.date(from: "2020-01-02T03:30:23Z")!,
                                  value: 0,
                                  unit: .unitsPerHour,
                                  deliveredUnits: nil,
                                  description: "Test Resume Dose",
                                  syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                  scheduledBasalRate: nil,
                                  insulinType: nil,
                                  automatic: true,
                                  manuallyEntered: false)
        XCTAssertEqual(doseEntry.selectors, [])
    }

    func testSelectorSuspend() {
        let doseEntry = DoseEntry(type: .suspend,
                                  startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                  endDate: Self.dateFormatter.date(from: "2020-01-02T03:30:23Z")!,
                                  value: 0,
                                  unit: .unitsPerHour,
                                  deliveredUnits: nil,
                                  description: "Test Suspend Dose",
                                  syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                  scheduledBasalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 2.0),
                                  insulinType: .fiasp,
                                  automatic: true,
                                  manuallyEntered: false)
        XCTAssertEqual(doseEntry.selectors, [TDatum.Selector(origin: TDatum.Selector.Origin(id: "ab0a722d639669875017a899a5214677:basal/suspend"))])
    }

    func testSelectorTempBasalManual() {
        let doseEntry = DoseEntry(type: .tempBasal,
                                  startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                  endDate: Self.dateFormatter.date(from: "2020-01-02T03:20:23Z")!,
                                  value: 1.5,
                                  unit: .unitsPerHour,
                                  deliveredUnits: 0.5,
                                  description: "Test Temp Basal Dose",
                                  syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                  scheduledBasalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 2.0),
                                  insulinType: .fiasp,
                                  automatic: false,
                                  manuallyEntered: false)
        XCTAssertEqual(doseEntry.selectors, [TDatum.Selector(origin: TDatum.Selector.Origin(id: "ab0a722d639669875017a899a5214677:basal/temp"))])
    }

    func testSelectorTempBasalAutomatic() {
        let doseEntry = DoseEntry(type: .tempBasal,
                                  startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                  endDate: Self.dateFormatter.date(from: "2020-01-02T03:20:23Z")!,
                                  value: 1.5,
                                  unit: .unitsPerHour,
                                  deliveredUnits: 0.5,
                                  description: "Test Temp Basal Dose",
                                  syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                  scheduledBasalRate: HKQuantity(unit: .internationalUnitsPerHour, doubleValue: 2.0),
                                  insulinType: .fiasp,
                                  manuallyEntered: false)
        XCTAssertEqual(doseEntry.selectors, [TDatum.Selector(origin: TDatum.Selector.Origin(id: "ab0a722d639669875017a899a5214677:basal/automated"))])
    }

    private static let dateFormatter = ISO8601DateFormatter()
}
