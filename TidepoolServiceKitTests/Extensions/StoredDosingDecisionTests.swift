//
//  StoredDosingDecisionTests.swift
//  TidepoolServiceKitTests
//
//  Created by Darin Krauss on 10/29/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import XCTest
import HealthKit
import LoopKit
import TidepoolKit
@testable import TidepoolServiceKit

class StoredDosingDecisionTests: XCTestCase {
    func testDatumDosingDecision() {
        let data = try! Self.encoder.encode(StoredDosingDecision.test.datumDosingDecision(for: "1234567890"))
        XCTAssertEqual(String(data: data, encoding: .utf8), """
{
  "associations" : [
    {
      "id" : "422688f3a1d0d48b7ba3d2261a0776a0",
      "reason" : "pumpSettings",
      "type" : "datum"
    },
    {
      "id" : "5069fefe9309fafa60a7ccafffedd5b8",
      "reason" : "originalFood",
      "type" : "datum"
    },
    {
      "id" : "5069fefe9309fafa60a7ccafffedd5b8",
      "reason" : "food",
      "type" : "datum"
    },
    {
      "id" : "0cde31b2d44ffba00f085dde6ff18bcc",
      "reason" : "smbg",
      "type" : "datum"
    }
  ],
  "bgForecast" : [
    {
      "time" : "2020-05-14T22:43:15.000Z",
      "value" : 123
    },
    {
      "time" : "2020-05-14T22:48:15.000Z",
      "value" : 126
    }
  ],
  "bgHistorical" : [
    {
      "time" : "2020-05-14T22:29:15.000Z",
      "value" : 117.3
    },
    {
      "time" : "2020-05-14T22:33:15.000Z",
      "value" : 119.5
    },
    {
      "time" : "2020-05-14T22:38:15.000Z",
      "value" : 121.8
    }
  ],
  "bgTargetSchedule" : [
    {
      "high" : 110,
      "low" : 100,
      "start" : 0
    },
    {
      "high" : 100,
      "low" : 90,
      "start" : 25200000
    },
    {
      "high" : 120,
      "low" : 110,
      "start" : 75600000
    }
  ],
  "carbsOnBoard" : {
    "amount" : 45.5,
    "time" : "2020-05-14T22:48:41.000Z"
  },
  "errors" : [
    {
      "id" : "alpha"
    },
    {
      "id" : "bravo",
      "metadata" : {
        "size" : "tiny"
      }
    }
  ],
  "food" : {
    "nutrition" : {
      "carbohydrate" : {
        "net" : 29,
        "units" : "grams"
      },
      "estimatedAbsorptionDuration" : 18000
    },
    "time" : "2020-01-02T03:00:23.000Z"
  },
  "id" : "c7e1169fa718cfa015f66293f435ff1f",
  "insulinOnBoard" : {
    "amount" : 1.5,
    "time" : "2020-05-14T22:38:26.000Z"
  },
  "origin" : {
    "id" : "2A67A303-5203-4CB8-8263-79498265368E:dosingDecision",
    "name" : "com.apple.dt.xctest.tool",
    "type" : "application"
  },
  "originalFood" : {
    "nutrition" : {
      "carbohydrate" : {
        "net" : 19,
        "units" : "grams"
      },
      "estimatedAbsorptionDuration" : 18000
    },
    "time" : "2020-01-02T03:00:23.000Z"
  },
  "payload" : {
    "syncIdentifier" : "2A67A303-5203-4CB8-8263-79498265368E"
  },
  "reason" : "test",
  "recommendedBasal" : {
    "duration" : 1800000,
    "rate" : 0.75
  },
  "recommendedBolus" : {
    "amount" : 1.25
  },
  "requestedBolus" : {
    "amount" : 0.80000000000000004
  },
  "smbg" : {
    "time" : "2020-05-14T22:09:00.000Z",
    "value" : 400
  },
  "time" : "2020-05-14T22:38:14.000Z",
  "timezone" : "America/Los_Angeles",
  "timezoneOffset" : -420,
  "type" : "dosingDecision",
  "units" : {
    "bg" : "mg/dL",
    "carb" : "grams",
    "insulin" : "Units"
  },
  "warnings" : [
    {
      "id" : "one"
    },
    {
      "id" : "two",
      "metadata" : {
        "size" : "small"
      }
    }
  ]
}
"""
        )
    }

    func testDatumControllerStatus() {
        let data = try! Self.encoder.encode(StoredDosingDecision.test.datumControllerStatus(for: "1234567890"))
        XCTAssertEqual(String(data: data, encoding: .utf8), """
{
  "battery" : {
    "remaining" : 0.5,
    "state" : "charging",
    "units" : "percent"
  },
  "id" : "ac3b6bdb9665f62eac07bf476f53795d",
  "origin" : {
    "id" : "2A67A303-5203-4CB8-8263-79498265368E:controllerStatus",
    "name" : "com.apple.dt.xctest.tool",
    "type" : "application"
  },
  "payload" : {
    "syncIdentifier" : "2A67A303-5203-4CB8-8263-79498265368E"
  },
  "time" : "2020-05-14T22:38:14.000Z",
  "timezone" : "America/Los_Angeles",
  "timezoneOffset" : -420,
  "type" : "controllerStatus"
}
"""
        )
    }

    func testDatumPumpStatus() {
        let data = try! Self.encoder.encode(StoredDosingDecision.test.datumPumpStatus(for: "1234567890"))
        XCTAssertEqual(String(data: data, encoding: .utf8), """
{
  "basalDelivery" : {
    "state" : "initiatingTemporary"
  },
  "battery" : {
    "remaining" : 0.75,
    "units" : "percent"
  },
  "bolusDelivery" : {
    "state" : "none"
  },
  "id" : "4df2e9d703df3217bd3b834845acfe4d",
  "origin" : {
    "id" : "2A67A303-5203-4CB8-8263-79498265368E:pumpStatus",
    "name" : "com.apple.dt.xctest.tool",
    "type" : "application"
  },
  "payload" : {
    "syncIdentifier" : "2A67A303-5203-4CB8-8263-79498265368E"
  },
  "reservoir" : {
    "remaining" : 113.3,
    "time" : "2020-05-14T22:07:19.000Z",
    "units" : "Units"
  },
  "time" : "2020-05-14T22:38:14.000Z",
  "timezone" : "America/Los_Angeles",
  "timezoneOffset" : -420,
  "type" : "pumpStatus"
}
"""
        )
    }

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder.tidepool
        encoder.outputFormatting.insert(.prettyPrinted)
        return encoder
    }()
}

fileprivate extension StoredDosingDecision {
    static var test: StoredDosingDecision {
        let controllerTimeZone = TimeZone(identifier: "America/Los_Angeles")!
        let scheduleTimeZone = TimeZone(secondsFromGMT: TimeZone(identifier: "America/Phoenix")!.secondsFromGMT())!
        let reason = "test"
        let settings = StoredDosingDecision.Settings(syncIdentifier: UUID(uuidString: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")!)
        let scheduleOverride = TemporaryScheduleOverride(context: .preMeal,
                                                         settings: TemporaryScheduleOverrideSettings(unit: .milligramsPerDeciliter,
                                                                                                     targetRange: DoubleRange(minValue: 80.0,
                                                                                                                              maxValue: 90.0),
                                                                                                     insulinNeedsScaleFactor: 1.5),
                                                         startDate: dateFormatter.date(from: "2020-05-14T22:22:01Z")!,
                                                         duration: .finite(.hours(1)),
                                                         enactTrigger: .local,
                                                         syncIdentifier: UUID(uuidString: "394818CF-99CD-4B12-99CD-0E678414986B")!)
        let controllerStatus = StoredDosingDecision.ControllerStatus(batteryState: .charging,
                                                                     batteryLevel: 0.5)
        let pumpManagerStatus = PumpManagerStatus(timeZone: scheduleTimeZone,
                                                  device: HKDevice(name: "Pump Name",
                                                                   manufacturer: "Pump Manufacturer",
                                                                   model: "Pump Model",
                                                                   hardwareVersion: "Pump Hardware Version",
                                                                   firmwareVersion: "Pump Firmware Version",
                                                                   softwareVersion: "Pump Software Version",
                                                                   localIdentifier: "Pump Local Identifier",
                                                                   udiDeviceIdentifier: "Pump UDI Device Identifier"),
                                                  pumpBatteryChargeRemaining: 0.75,
                                                  basalDeliveryState: .initiatingTempBasal,
                                                  bolusState: .noBolus,
                                                  insulinType: .novolog)
        let cgmManagerStatus = CGMManagerStatus(hasValidSensorSession: true,
                                                lastCommunicationDate: dateFormatter.date(from: "2020-05-14T22:07:01Z")!,
                                                device: HKDevice(name: "CGM Name",
                                                                 manufacturer: "CGM Manufacturer",
                                                                 model: "CGM Model",
                                                                 hardwareVersion: "CGM Hardware Version",
                                                                 firmwareVersion: "CGM Firmware Version",
                                                                 softwareVersion: "CGM Software Version",
                                                                 localIdentifier: "CGM Local Identifier",
                                                                 udiDeviceIdentifier: "CGM UDI Device Identifier"))
        let lastReservoirValue = StoredDosingDecision.LastReservoirValue(startDate: dateFormatter.date(from: "2020-05-14T22:07:19Z")!,
                                                                         unitVolume: 113.3)
        let historicalGlucose = [HistoricalGlucoseValue(startDate: dateFormatter.date(from: "2020-05-14T22:29:15Z")!,
                                                        quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 117.3)),
                                 HistoricalGlucoseValue(startDate: dateFormatter.date(from: "2020-05-14T22:33:15Z")!,
                                                        quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 119.5)),
                                 HistoricalGlucoseValue(startDate: dateFormatter.date(from: "2020-05-14T22:38:15Z")!,
                                                        quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 121.8))]
        let originalCarbEntry = StoredCarbEntry(uuid: UUID(uuidString: "18CF3948-0B3D-4B12-8BFE-14986B0E6784")!,
                                                provenanceIdentifier: "com.loopkit.loop",
                                                syncIdentifier: "2B03D96C-6F5D-4140-99CD-80C3E64D6010",
                                                syncVersion: 1,
                                                startDate: dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                                quantity: HKQuantity(unit: .gram(), doubleValue: 19),
                                                foodType: "Pizza",
                                                absorptionTime: .hours(5),
                                                createdByCurrentApp: true,
                                                userCreatedDate: dateFormatter.date(from: "2020-05-14T22:06:12Z")!,
                                                userUpdatedDate: nil)
        let carbEntry = StoredCarbEntry(uuid: UUID(uuidString: "135CDABE-9343-7242-4233-1020384789AE")!,
                                        provenanceIdentifier: "com.loopkit.loop",
                                        syncIdentifier: "2B03D96C-6F5D-4140-99CD-80C3E64D6010",
                                        syncVersion: 2,
                                        startDate: dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                        quantity: HKQuantity(unit: .gram(), doubleValue: 29),
                                        foodType: "Pizza",
                                        absorptionTime: .hours(5),
                                        createdByCurrentApp: true,
                                        userCreatedDate: dateFormatter.date(from: "2020-05-14T22:06:12Z")!,
                                        userUpdatedDate: dateFormatter.date(from: "2020-05-14T22:07:32Z")!)
        let manualGlucoseSample = StoredGlucoseSample(uuid: UUID(uuidString: "da0ced44-e4f1-49c4-baf8-6efa6d75525f")!,
                                                      provenanceIdentifier: "com.loopkit.loop",
                                                      syncIdentifier: "d3876f59-adb3-4a4f-8b29-315cda22062e",
                                                      syncVersion: 1,
                                                      startDate: dateFormatter.date(from: "2020-05-14T22:09:00Z")!,
                                                      quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 400),
                                                      condition: .aboveRange,
                                                      trend: .downDownDown,
                                                      trendRate: HKQuantity(unit: .milligramsPerDeciliterPerMinute, doubleValue: -10.2),
                                                      isDisplayOnly: false,
                                                      wasUserEntered: true,
                                                      device: HKDevice(name: "Device Name",
                                                                       manufacturer: "Device Manufacturer",
                                                                       model: "Device Model",
                                                                       hardwareVersion: "Device Hardware Version",
                                                                       firmwareVersion: "Device Firmware Version",
                                                                       softwareVersion: "Device Software Version",
                                                                       localIdentifier: "Device Local Identifier",
                                                                       udiDeviceIdentifier: "Device UDI Device Identifier"),
                                                      healthKitEligibleDate: nil)
        let carbsOnBoard = CarbValue(startDate: dateFormatter.date(from: "2020-05-14T22:48:41Z")!,
                                     endDate: dateFormatter.date(from: "2020-05-14T23:18:41Z")!,
                                     quantity: HKQuantity(unit: .gram(), doubleValue: 45.5))
        let insulinOnBoard = InsulinValue(startDate: dateFormatter.date(from: "2020-05-14T22:38:26Z")!, value: 1.5)
        let glucoseTargetRangeSchedule = GlucoseRangeSchedule(rangeSchedule: DailyQuantitySchedule(unit: .milligramsPerDeciliter,
                                                                                                   dailyItems: [RepeatingScheduleValue(startTime: .hours(0), value: DoubleRange(minValue: 100.0, maxValue: 110.0)),
                                                                                                                RepeatingScheduleValue(startTime: .hours(7), value: DoubleRange(minValue: 90.0, maxValue: 100.0)),
                                                                                                                RepeatingScheduleValue(startTime: .hours(21), value: DoubleRange(minValue: 110.0, maxValue: 120.0))],
                                                                                                   timeZone: scheduleTimeZone)!,
                                                              override: GlucoseRangeSchedule.Override(value: DoubleRange(minValue: 105.0, maxValue: 115.0),
                                                                                                      start: dateFormatter.date(from: "2020-05-14T21:12:17Z")!,
                                                                                                      end: dateFormatter.date(from: "2020-05-14T23:12:17Z")!))
        let predictedGlucose = [PredictedGlucoseValue(startDate: dateFormatter.date(from: "2020-05-14T22:43:15Z")!,
                                                      quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 123.3)),
                                PredictedGlucoseValue(startDate: dateFormatter.date(from: "2020-05-14T22:48:15Z")!,
                                                      quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 125.5)),
                                PredictedGlucoseValue(startDate: dateFormatter.date(from: "2020-05-14T22:53:15Z")!,
                                                      quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 127.8))]
        let tempBasalRecommendation = TempBasalRecommendation(unitsPerHour: 0.75,
                                                              duration: .minutes(30))
        let automaticDoseRecommendation = AutomaticDoseRecommendation(basalAdjustment: tempBasalRecommendation, bolusUnits: 1.25)
        let manualBolusRecommendation = ManualBolusRecommendationWithDate(recommendation: ManualBolusRecommendation(amount: 1.2,
                                                                                                                    pendingInsulin: 0.75,
                                                                                                                    notice: .predictedGlucoseBelowTarget(minGlucose: PredictedGlucoseValue(startDate: dateFormatter.date(from: "2020-05-14T23:03:15Z")!,
                                                                                                                                                                                           quantity: HKQuantity(unit: .milligramsPerDeciliter, doubleValue: 75.5)))),
                                                                          date: dateFormatter.date(from: "2020-05-14T22:38:16Z")!)
        let manualBolusRequested = 0.8
        let warnings: [Issue] = [Issue(id: "one"),
                                 Issue(id: "two", details: ["size": "small"])]
        let errors: [Issue] = [Issue(id: "alpha"),
                               Issue(id: "bravo", details: ["size": "tiny"])]
        
        return StoredDosingDecision(date: dateFormatter.date(from: "2020-05-14T22:38:14Z")!,
                                    controllerTimeZone: controllerTimeZone,
                                    reason: reason,
                                    settings: settings,
                                    scheduleOverride: scheduleOverride,
                                    controllerStatus: controllerStatus,
                                    pumpManagerStatus: pumpManagerStatus,
                                    cgmManagerStatus: cgmManagerStatus,
                                    lastReservoirValue: lastReservoirValue,
                                    historicalGlucose: historicalGlucose,
                                    originalCarbEntry: originalCarbEntry,
                                    carbEntry: carbEntry,
                                    manualGlucoseSample: manualGlucoseSample,
                                    carbsOnBoard: carbsOnBoard,
                                    insulinOnBoard: insulinOnBoard,
                                    glucoseTargetRangeSchedule: glucoseTargetRangeSchedule,
                                    predictedGlucose: predictedGlucose,
                                    automaticDoseRecommendation: automaticDoseRecommendation,
                                    manualBolusRecommendation: manualBolusRecommendation,
                                    manualBolusRequested: manualBolusRequested,
                                    warnings: warnings,
                                    errors: errors,
                                    syncIdentifier: UUID(uuidString: "2A67A303-5203-4CB8-8263-79498265368E")!)
    }
    
    private static let dateFormatter = ISO8601DateFormatter()
}
