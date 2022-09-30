//
//  StoredSettingsTests.swift
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

class StoredSettingsTests: XCTestCase {
    func testDatumControllerSettings() {
        let data = try! Self.encoder.encode(StoredSettings.test.datumControllerSettings(for: "1234567890"))
        XCTAssertEqual(String(data: data, encoding: .utf8), """
{
  "device" : {
    "manufacturers" : [
      "Apple"
    ],
    "model" : "Controller Model Identifier",
    "name" : "Controller Name",
    "softwareVersion" : "Controller System Version"
  },
  "id" : "771f448b16fa6f154c25a0a976d70e6f",
  "notifications" : {
    "alert" : false,
    "alertStyle" : "banner",
    "announcement" : true,
    "authorization" : "authorized",
    "badge" : true,
    "criticalAlert" : true,
    "lockScreen" : false,
    "notificationCenter" : false,
    "scheduledDelivery" : false,
    "sound" : true,
    "timeSensitive" : true
  },
  "origin" : {
    "id" : "2A67A303-1234-4CB8-1234-79498265368E:controllerSettings",
    "name" : "com.apple.dt.xctest.tool",
    "type" : "application"
  },
  "payload" : {
    "syncIdentifier" : "2A67A303-1234-4CB8-1234-79498265368E"
  },
  "time" : "2020-05-14T22:48:15.000Z",
  "timezone" : "America/Los_Angeles",
  "timezoneOffset" : -420,
  "type" : "controllerSettings"
}
"""
        )
    }

    func testDatumCGMSettings() {
        let data = try! Self.encoder.encode(StoredSettings.test.datumCGMSettings(for: "1234567890"))
        XCTAssertEqual(String(data: data, encoding: .utf8), """
{
  "firmwareVersion" : "CGM Firmware Version",
  "hardwareVersion" : "CGM Hardware Version",
  "id" : "8c9463e463bfed71cf23f833be163f69",
  "manufacturers" : [
    "CGM Manufacturer"
  ],
  "model" : "CGM Model",
  "name" : "CGM Name",
  "origin" : {
    "id" : "2A67A303-1234-4CB8-1234-79498265368E:cgmSettings",
    "name" : "com.apple.dt.xctest.tool",
    "type" : "application"
  },
  "payload" : {
    "syncIdentifier" : "2A67A303-1234-4CB8-1234-79498265368E"
  },
  "serialNumber" : "CGM Local Identifier",
  "softwareVersion" : "CGM Software Version",
  "time" : "2020-05-14T22:48:15.000Z",
  "timezone" : "America/Los_Angeles",
  "timezoneOffset" : -420,
  "type" : "cgmSettings",
  "units" : "mg/dL"
}
"""
        )
    }

    func testDatumPumpSettings() {
        let data = try! Self.encoder.encode(StoredSettings.test.datumPumpSettings(for: "1234567890"))
        XCTAssertEqual(String(data: data, encoding: .utf8), """
{
  "activeSchedule" : "Default",
  "automatedDelivery" : true,
  "basal" : {
    "rateMaximum" : {
      "units" : "Units/hour",
      "value" : 3.5
    }
  },
  "basalSchedules" : {
    "Default" : [
      {
        "rate" : 1,
        "start" : 0
      },
      {
        "rate" : 1.5,
        "start" : 21600000
      },
      {
        "rate" : 1.25,
        "start" : 64800000
      }
    ]
  },
  "bgSafetyLimit" : 75,
  "bgTargetPhysicalActivity" : {
    "high" : 160,
    "low" : 150
  },
  "bgTargetPreprandial" : {
    "high" : 90,
    "low" : 80
  },
  "bgTargets" : {
    "Default" : [
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
    ]
  },
  "bolus" : {
    "amountMaximum" : {
      "units" : "Units",
      "value" : 10
    }
  },
  "carbRatios" : {
    "Default" : [
      {
        "amount" : 15,
        "start" : 0
      },
      {
        "amount" : 14,
        "start" : 32400000
      },
      {
        "amount" : 18,
        "start" : 72000000
      }
    ]
  },
  "display" : {
    "bloodGlucose" : {
      "units" : "mg/dL"
    }
  },
  "firmwareVersion" : "Pump Firmware Version",
  "hardwareVersion" : "Pump Hardware Version",
  "id" : "7e81874fd60ce84e7f83731bf80aba49",
  "insulinFormulation" : {
    "simple" : {
      "actingType" : "rapid",
      "brand" : "Humalog"
    }
  },
  "insulinModel" : {
    "actionDelay" : 600,
    "actionDuration" : 21600,
    "actionPeakOffset" : 10800,
    "modelType" : "rapidAdult"
  },
  "insulinSensitivities" : {
    "Default" : [
      {
        "amount" : 45,
        "start" : 0
      },
      {
        "amount" : 40,
        "start" : 10800000
      },
      {
        "amount" : 50,
        "start" : 54000000
      }
    ]
  },
  "manufacturers" : [
    "Pump Manufacturer"
  ],
  "model" : "Pump Model",
  "name" : "Pump Name",
  "origin" : {
    "id" : "2A67A303-1234-4CB8-1234-79498265368E:pumpSettings",
    "name" : "com.apple.dt.xctest.tool",
    "type" : "application"
  },
  "overridePresets" : {
    "Apple" : {
      "abbreviation" : "🍎",
      "basalRateScaleFactor" : 2,
      "bgTarget" : {
        "high" : 140,
        "low" : 130
      },
      "carbRatioScaleFactor" : 0.5,
      "duration" : 3600,
      "insulinSensitivityScaleFactor" : 0.5
    }
  },
  "payload" : {
    "syncIdentifier" : "2A67A303-1234-4CB8-1234-79498265368E"
  },
  "serialNumber" : "Pump Local Identifier",
  "softwareVersion" : "Pump Software Version",
  "time" : "2020-05-14T22:48:15.000Z",
  "timezone" : "America/Los_Angeles",
  "timezoneOffset" : -420,
  "type" : "pumpSettings",
  "units" : {
    "bg" : "mg/dL",
    "carb" : "grams",
    "insulin" : "Units"
  }
}
"""
        )
    }
    
    func testDatumPumpSettingsOverrideDeviceEvent() {
        let data = try! Self.encoder.encode(StoredSettings.test.datumPumpSettingsOverrideDeviceEvent(for: "1234567890"))
        XCTAssertEqual(String(data: data, encoding: .utf8), """
{
  "basalRateScaleFactor" : 0.5,
  "bgTarget" : {
    "high" : 90,
    "low" : 80
  },
  "carbRatioScaleFactor" : 2,
  "id" : "f89ad59a42430ab89dd2eab3a3e4df84",
  "insulinSensitivityScaleFactor" : 2,
  "method" : "manual",
  "origin" : {
    "id" : "2A67A303-1234-4CB8-1234-79498265368E:deviceEvent/pumpSettingsOverride",
    "name" : "com.apple.dt.xctest.tool",
    "type" : "application"
  },
  "overrideType" : "preprandial",
  "payload" : {
    "syncIdentifier" : "2A67A303-1234-4CB8-1234-79498265368E"
  },
  "subType" : "pumpSettingsOverride",
  "time" : "2020-05-14T14:38:39.000Z",
  "timezone" : "America/Los_Angeles",
  "timezoneOffset" : -420,
  "type" : "deviceEvent",
  "units" : {
    "bg" : "mg/dL"
  }
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

fileprivate extension StoredSettings {
    static var test: StoredSettings {
        let controllerTimeZone = TimeZone(identifier: "America/Los_Angeles")!
        let scheduleTimeZone = TimeZone(secondsFromGMT: TimeZone(identifier: "America/Phoenix")!.secondsFromGMT())!
        let dosingEnabled = true
        let glucoseTargetRangeSchedule = GlucoseRangeSchedule(rangeSchedule: DailyQuantitySchedule(unit: .milligramsPerDeciliter,
                                                                                                   dailyItems: [RepeatingScheduleValue(startTime: .hours(0), value: DoubleRange(minValue: 100.0, maxValue: 110.0)),
                                                                                                                RepeatingScheduleValue(startTime: .hours(7), value: DoubleRange(minValue: 90.0, maxValue: 100.0)),
                                                                                                                RepeatingScheduleValue(startTime: .hours(21), value: DoubleRange(minValue: 110.0, maxValue: 120.0))],
                                                                                                   timeZone: scheduleTimeZone)!,
                                                              override: GlucoseRangeSchedule.Override(value: DoubleRange(minValue: 105.0, maxValue: 115.0),
                                                                                                      start: dateFormatter.date(from: "2020-05-14T12:48:15Z")!,
                                                                                                      end: dateFormatter.date(from: "2020-05-14T14:48:15Z")!))
        let preMealTargetRange = DoubleRange(minValue: 80.0, maxValue: 90.0).quantityRange(for: .milligramsPerDeciliter)
        let workoutTargetRange = DoubleRange(minValue: 150.0, maxValue: 160.0).quantityRange(for: .milligramsPerDeciliter)
        let overridePresets = [TemporaryScheduleOverridePreset(id: UUID(uuidString: "2A67A303-5203-4CB8-8263-79498265368E")!,
                                                               symbol: "🍎",
                                                               name: "Apple",
                                                               settings: TemporaryScheduleOverrideSettings(unit: .milligramsPerDeciliter,
                                                                                                           targetRange: DoubleRange(minValue: 130.0, maxValue: 140.0),
                                                                                                           insulinNeedsScaleFactor: 2.0),
                                                               duration: .finite(.minutes(60)))]
        let scheduleOverride = TemporaryScheduleOverride(context: .preMeal,
                                                         settings: TemporaryScheduleOverrideSettings(unit: .milligramsPerDeciliter,
                                                                                                     targetRange: DoubleRange(minValue: 110.0, maxValue: 120.0),
                                                                                                     insulinNeedsScaleFactor: 1.5),
                                                         startDate: dateFormatter.date(from: "2020-05-14T14:48:19Z")!,
                                                         duration: .finite(.minutes(60)),
                                                         enactTrigger: .remote("127.0.0.1"),
                                                         syncIdentifier: UUID(uuidString: "2A67A303-1234-4CB8-8263-79498265368E")!)
        let preMealOverride = TemporaryScheduleOverride(context: .preMeal,
                                                        settings: TemporaryScheduleOverrideSettings(unit: .milligramsPerDeciliter,
                                                                                                    targetRange: DoubleRange(minValue: 80.0, maxValue: 90.0),
                                                                                                    insulinNeedsScaleFactor: 0.5),
                                                        startDate: dateFormatter.date(from: "2020-05-14T14:38:39Z")!,
                                                        duration: .indefinite,
                                                        enactTrigger: .local,
                                                        syncIdentifier: UUID(uuidString: "2A67A303-5203-1234-8263-79498265368E")!)
        let maximumBasalRatePerHour = 3.5
        let maximumBolus = 10.0
        let suspendThreshold = GlucoseThreshold(unit: .milligramsPerDeciliter, value: 75.0)
        let insulinType = InsulinType.humalog
        let defaultRapidActingModel = StoredInsulinModel(modelType: .rapidAdult, delay: .minutes(10), actionDuration: .hours(6), peakActivity: .hours(3))
        let basalRateSchedule = BasalRateSchedule(dailyItems: [RepeatingScheduleValue(startTime: .hours(0), value: 1.0),
                                                               RepeatingScheduleValue(startTime: .hours(6), value: 1.5),
                                                               RepeatingScheduleValue(startTime: .hours(18), value: 1.25)],
                                                  timeZone: scheduleTimeZone)
        let insulinSensitivitySchedule = InsulinSensitivitySchedule(unit: .milligramsPerDeciliter,
                                                                    dailyItems: [RepeatingScheduleValue(startTime: .hours(0), value: 45.0),
                                                                                 RepeatingScheduleValue(startTime: .hours(3), value: 40.0),
                                                                                 RepeatingScheduleValue(startTime: .hours(15), value: 50.0)],
                                                                    timeZone: scheduleTimeZone)
        let carbRatioSchedule = CarbRatioSchedule(unit: .gram(),
                                                  dailyItems: [RepeatingScheduleValue(startTime: .hours(0), value: 15.0),
                                                               RepeatingScheduleValue(startTime: .hours(9), value: 14.0),
                                                               RepeatingScheduleValue(startTime: .hours(20), value: 18.0)],
                                                  timeZone: scheduleTimeZone)
        let notificationSettings = NotificationSettings(authorizationStatus: .authorized,
                                                        soundSetting: .enabled,
                                                        badgeSetting: .enabled,
                                                        alertSetting: .disabled,
                                                        notificationCenterSetting: .notSupported,
                                                        lockScreenSetting: .disabled,
                                                        carPlaySetting: .notSupported,
                                                        alertStyle: .banner,
                                                        showPreviewsSetting: .whenAuthenticated,
                                                        criticalAlertSetting: .enabled,
                                                        providesAppNotificationSettings: true,
                                                        announcementSetting: .enabled,
                                                        timeSensitiveSetting: .enabled,
                                                        scheduledDeliverySetting: .disabled,
                                                        temporaryMuteAlertsSetting: .disabled)
        let controllerDevice = StoredSettings.ControllerDevice(name: "Controller Name",
                                                               systemName: "Controller System Name",
                                                               systemVersion: "Controller System Version",
                                                               model: "Controller Model",
                                                               modelIdentifier: "Controller Model Identifier")
        let cgmDevice = HKDevice(name: "CGM Name",
                                 manufacturer: "CGM Manufacturer",
                                 model: "CGM Model",
                                 hardwareVersion: "CGM Hardware Version",
                                 firmwareVersion: "CGM Firmware Version",
                                 softwareVersion: "CGM Software Version",
                                 localIdentifier: "CGM Local Identifier",
                                 udiDeviceIdentifier: "CGM UDI Device Identifier")
        let pumpDevice = HKDevice(name: "Pump Name",
                                  manufacturer: "Pump Manufacturer",
                                  model: "Pump Model",
                                  hardwareVersion: "Pump Hardware Version",
                                  firmwareVersion: "Pump Firmware Version",
                                  softwareVersion: "Pump Software Version",
                                  localIdentifier: "Pump Local Identifier",
                                  udiDeviceIdentifier: "Pump UDI Device Identifier")
        let bloodGlucoseUnit = HKUnit.milligramsPerDeciliter
        
        return StoredSettings(date: dateFormatter.date(from: "2020-05-14T22:48:15Z")!,
                              controllerTimeZone: controllerTimeZone,
                              dosingEnabled: dosingEnabled,
                              glucoseTargetRangeSchedule: glucoseTargetRangeSchedule,
                              preMealTargetRange: preMealTargetRange,
                              workoutTargetRange: workoutTargetRange,
                              overridePresets: overridePresets,
                              scheduleOverride: scheduleOverride,
                              preMealOverride: preMealOverride,
                              maximumBasalRatePerHour: maximumBasalRatePerHour,
                              maximumBolus: maximumBolus,
                              suspendThreshold: suspendThreshold,
                              insulinType: insulinType,
                              defaultRapidActingModel: defaultRapidActingModel,
                              basalRateSchedule: basalRateSchedule,
                              insulinSensitivitySchedule: insulinSensitivitySchedule,
                              carbRatioSchedule: carbRatioSchedule,
                              notificationSettings: notificationSettings,
                              controllerDevice: controllerDevice,
                              cgmDevice: cgmDevice,
                              pumpDevice: pumpDevice,
                              bloodGlucoseUnit: bloodGlucoseUnit,
                              syncIdentifier: UUID(uuidString: "2A67A303-1234-4CB8-1234-79498265368E")!)
    }
    
    private static let dateFormatter = ISO8601DateFormatter()
}
