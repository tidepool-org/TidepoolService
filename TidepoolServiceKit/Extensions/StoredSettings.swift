//
//  StoredSettings.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 10/4/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import HealthKit
import LoopKit
import TidepoolKit

/*
 StoredSettings
 
 Properties:
 - date                             Date                                    .time
 - controllerTimeZone               TimeInterval                            .timeZone, .timeZoneOffset
 - dosingEnabled                    Bool                                    TPumpSettingsDatum.automatedDelivery
 - glucoseTargetRangeSchedule       GlucoseRangeSchedule?                   TPumpSettingsDatum.bloodGlucoseTargetSchedules["Default"]
 - preMealTargetRange               ClosedRange<HKQuantity>?                TPumpSettingsDatum.bloodGlucoseTargetPreprandial
 - workoutTargetRange               ClosedRange<HKQuantity>?                TPumpSettingsDatum.bloodGlucoseTargetPhysicalActivity
 - overridePresets                  [TemporaryScheduleOverridePreset]?      TPumpSettingsDatum.overridePresets
 - scheduleOverride                 TemporaryScheduleOverride?              TPumpSettingsOverrideDeviceEventDatum.*
 - preMealOverride                  TemporaryScheduleOverride?              TPumpSettingsOverrideDeviceEventDatum.*
 - maximumBasalRatePerHour          Double?                                 TPumpSettingsDatum.basal.rateMaximum.value
 - maximumBolus                     Double?                                 TPumpSettingsDatum.bolus.amountMaximum.value
 - suspendThreshold                 GlucoseThreshold?                       TPumpSettingsDatum.bloodGlucoseSafetyLimit
 - defaultRapidActingModel          StoredInsulinModel?                     TPumpSettingsDatum.insulinModel
 - basalRateSchedule                BasalRateSchedule?                      TPumpSettingsDatum.basalRateSchedules["Default"]
 - insulinSensitivitySchedule       InsulinSensitivitySchedule?             TPumpSettingsDatum.insulinSensitivitySchedules["Default"]
 - carbRatioSchedule                CarbRatioSchedule?                      TPumpSettingsDatum.carbohydrateRatioSchedules["Default"]
 - notificationSettings             NotificationSettings?                   TControllerSettingsDatum.notifications
 - controllerDevice                 ControllerDevice?                       TControllerSettingsDatum.device
 - pumpDevice                       HKDevice?                               TPumpSettingsDatum[.firmwareVersion, .hardwareVersion, .manufacturers, .model, .serialNumber, .softwareVersion]
 - cgmDevice                        HKDevice?                               TCGMSettingsDatum[.firmwareVersion, .hardwareVersion, .manufacturers, .model, .serialNumber, .softwareVersion]
 - bloodGlucoseUnit                 HKUnit?                                 TPumpSettingsDatum.display.bloodGlucose.units
 - syncIdentifier                   UUID                                    .id, .origin, .payload["syncIdentifier"]
 
 Notes:
 - The active override (scheduleOverride or preMealOverride) are stored in TPumpSettingsOverrideDeviceEventDatum.
 - Assumes same time zone for basalRateSchedule, glucoseTargetRangeSchedule, carbRatioSchedule, insulinSensitivitySchedule.
 - StoredSettings.notificationSettings.carPlaySetting is not included as it is unneeded by backend.
 - StoredSettings.notificationSettings.showPreviewsSetting is not included as it is unneeded by backend.
 - StoredSettings.notificationSettings.providesAppNotificationSettings is not included as it is unneeded by backend.
 - StoredSettings.controllerDevice.systemName is not included as it is implicit with StoredDosingDecision.deviceSettings.modelIdentifier.
 - StoredSettings.controllerDevice.model is not included as it is implicit in StoredDosingDecision.deviceSettings.modelIdentifier.
 - The associated pumpDevice properties may also change via TPumpStatus data from StoredDosingDecision.
 */

extension StoredSettings: IdentifiableDatum {
    func datumControllerSettings(for userId: String, hostIdentifier: String, hostVersion: String) -> TControllerSettingsDatum {
        let datum = TControllerSettingsDatum(time: datumTime,
                                             device: datumControllerDevice,
                                             notifications: datumControllerNotifications)
        let origin = datumOrigin(for: resolvedIdentifier(for: TControllerSettingsDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        return datum.adornWith(id: datumId(for: userId, type: TControllerSettingsDatum.self),
                               timeZone: datumTimeZone,
                               timeZoneOffset: datumTimeZoneOffset,
                               payload: datumPayload,
                               origin: origin)
    }

    func datumCGMSettings(for userId: String, hostIdentifier: String, hostVersion: String) -> TCGMSettingsDatum {
        let datum = TCGMSettingsDatum(time: datumTime,
                                      firmwareVersion: datumCGMFirmwareVersion,
                                      hardwareVersion: datumCGMHardwareVersion,
                                      manufacturers: datumCGMManufacturers,
                                      model: datumCGMModel,
                                      name: datumCGMName,
                                      serialNumber: datumCGMSerialNumber,
                                      softwareVersion: datumCGMSoftwareVersion,
                                      transmitterId: nil,       // TODO: https://tidepool.atlassian.net/browse/LOOP-3929
                                      units: datumCGMUnits,
                                      defaultAlerts: nil,       // TODO: https://tidepool.atlassian.net/browse/LOOP-3929
                                      scheduledAlerts: nil)     // TODO: https://tidepool.atlassian.net/browse/LOOP-3929
        let origin = datumOrigin(for: resolvedIdentifier(for: TCGMSettingsDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        return datum.adornWith(id: datumId(for: userId, type: TCGMSettingsDatum.self),
                               timeZone: datumTimeZone,
                               timeZoneOffset: datumTimeZoneOffset,
                               payload: datumPayload,
                               origin: origin)
    }

    func datumPumpSettings(for userId: String, hostIdentifier: String, hostVersion: String) -> TPumpSettingsDatum {
        let datum = TPumpSettingsDatum(time: datumTime,
                                       activeScheduleName: datumPumpActiveScheduleName,
                                       automatedDelivery: datumPumpAutomatedDelivery,
                                       basal: datumPumpBasal,
                                       basalRateSchedules: datumPumpBasalRateSchedules,
                                       bloodGlucoseSafetyLimit: datumPumpBloodGlucoseSafetyLimit,
                                       bloodGlucoseTargetPhysicalActivity: datumPumpBloodGlucoseTargetPhysicalActivity,
                                       bloodGlucoseTargetPreprandial: datumPumpBloodGlucoseTargetPreprandial,
                                       bloodGlucoseTargetSchedules: datumPumpBloodGlucoseTargetSchedules,
                                       bolus: datumPumpBolus,
                                       carbohydrateRatioSchedules: datumPumpCarbohydrateRatioSchedules,
                                       display: datumPumpDisplay,
                                       firmwareVersion: datumPumpFirmwareVersion,
                                       hardwareVersion: datumPumpHardwareVersion,
                                       insulinFormulation: datumPumpInsulinFormulation,
                                       insulinModel: datumPumpInsulinModel,
                                       insulinSensitivitySchedules: datumPumpInsulinSensitivitySchedules,
                                       manufacturers: datumPumpManufacturers,
                                       model: datumPumpModel,
                                       name: datumPumpName,
                                       overridePresets: datumPumpOverridePresets,
                                       scheduleTimeZoneOffset: datumPumpScheduleTimeZoneOffset,
                                       serialNumber: datumPumpSerialNumber,
                                       softwareVersion: datumPumpSoftwareVersion,
                                       units: datumPumpUnits)
        let origin = datumOrigin(for: resolvedIdentifier(for: TPumpSettingsDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        return datum.adornWith(id: datumId(for: userId, type: TPumpSettingsDatum.self),
                               timeZone: datumTimeZone,
                               timeZoneOffset: datumTimeZoneOffset,
                               payload: datumPayload,
                               origin: origin)
    }
    
    func datumPumpSettingsOverrideDeviceEvent(for userId: String, hostIdentifier: String, hostVersion: String) -> TPumpSettingsOverrideDeviceEventDatum? {
        guard let activeOverride = activeOverride else {
            return nil
        }
        let datum = TPumpSettingsOverrideDeviceEventDatum(time: activeOverride.datumTime,
                                                          overrideType: activeOverride.datumOverrideType,
                                                          overridePreset: activeOverride.datumOverridePreset,
                                                          method: activeOverride.datumMethod,
                                                          duration: activeOverride.datumDuration,
                                                          expectedDuration: activeOverride.datumExpectedDuration,
                                                          bloodGlucoseTarget: activeOverride.datumBloodGlucoseTarget,
                                                          basalRateScaleFactor: activeOverride.datumBasalRateScaleFactor,
                                                          carbohydrateRatioScaleFactor: activeOverride.datumCarbohydrateRatioScaleFactor,
                                                          insulinSensitivityScaleFactor: activeOverride.datumInsulinSensitivityScaleFactor,
                                                          units: activeOverride.datumUnits)
        let origin = datumOrigin(for: resolvedIdentifier(for: TPumpSettingsOverrideDeviceEventDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        return datum.adornWith(id: datumId(for: userId, type: TPumpSettingsOverrideDeviceEventDatum.self),
                               timeZone: datumTimeZone,
                               timeZoneOffset: datumTimeZoneOffset,
                               payload: datumPayload,
                               origin: origin)
    }

    var syncIdentifierAsString: String { syncIdentifier.uuidString }

    private var datumTime: Date { date }
    
    private var datumTimeZone: TimeZone { controllerTimeZone }

    private var datumTimeZoneOffset: TimeInterval { TimeInterval(controllerTimeZone.secondsFromGMT(for: date)) }

    private var datumControllerDevice: TControllerSettingsDatum.Device? {
        guard let controllerDevice = controllerDevice else {
            return nil
        }
        return TControllerSettingsDatum.Device(manufacturers: ["Apple"],
                                               model: controllerDevice.modelIdentifier,
                                               name: controllerDevice.name,
                                               softwareVersion: controllerDevice.systemVersion)
    }

    private var datumControllerNotifications: TControllerSettingsDatum.Notifications? {
        return notificationSettings?.datum
    }

    private var datumCGMFirmwareVersion: String? { cgmDevice?.firmwareVersion }

    private var datumCGMHardwareVersion: String? { cgmDevice?.hardwareVersion }

    private var datumCGMManufacturers: [String]? { cgmDevice?.manufacturer.map { [$0] } }

    private var datumCGMModel: String? { cgmDevice?.model }

    private var datumCGMName: String? { cgmDevice?.name }

    private var datumCGMSerialNumber: String? { cgmDevice?.localIdentifier }

    private var datumCGMSoftwareVersion: String? { cgmDevice?.softwareVersion }

    private var datumCGMUnits: TCGMSettingsDatum.Units { .milligramsPerDeciliter }

    private var datumPumpActiveScheduleName: String? {
        guard basalRateSchedule != nil ||
                glucoseTargetRangeSchedule != nil ||
                carbRatioSchedule != nil ||
                insulinSensitivitySchedule != nil else {
            return nil
        }
        return Self.activeScheduleNameDefault
    }
    
    private var datumPumpAutomatedDelivery: Bool { dosingEnabled }
    
    private var datumPumpBasal: TPumpSettingsDatum.Basal? {
        guard let maximumBasalRatePerHour = maximumBasalRatePerHour else {
            return nil
        }
        return TPumpSettingsDatum.Basal(rateMaximum: TPumpSettingsDatum.Basal.RateMaximum(maximumBasalRatePerHour, .unitsPerHour))
    }
    
    private var datumPumpBasalRateSchedules: [String: [TPumpSettingsDatum.BasalRateStart]]? {
        guard let basalRateSchedule = basalRateSchedule else {
            return nil
        }
        return [Self.activeScheduleNameDefault: basalRateSchedule.items.map { TPumpSettingsDatum.BasalRateStart(start: $0.startTime, rate: $0.value) }]
    }
    
    private var datumPumpBloodGlucoseSafetyLimit: Double? {
        guard let suspendThreshold = suspendThreshold else {
            return nil
        }
        return suspendThreshold.convertTo(unit: .milligramsPerDeciliter).value
    }
    
    private var datumPumpBloodGlucoseTargetPhysicalActivity: TPumpSettingsDatum.BloodGlucoseTarget? {
        guard let workoutTargetRange = workoutTargetRange else {
            return nil
        }
        return TPumpSettingsDatum.BloodGlucoseTarget(low: workoutTargetRange.lowerBound.doubleValue(for: .milligramsPerDeciliter),
                                                     high: workoutTargetRange.upperBound.doubleValue(for: .milligramsPerDeciliter))
    }
    
    private var datumPumpBloodGlucoseTargetPreprandial: TPumpSettingsDatum.BloodGlucoseTarget? {
        guard let preMealTargetRange = preMealTargetRange else {
            return nil
        }
        return TPumpSettingsDatum.BloodGlucoseTarget(low: preMealTargetRange.lowerBound.doubleValue(for: .milligramsPerDeciliter),
                                                     high: preMealTargetRange.upperBound.doubleValue(for: .milligramsPerDeciliter))
    }
    
    private var datumPumpBloodGlucoseTargetSchedules: [String: [TPumpSettingsDatum.BloodGlucoseStartTarget]]? {
        guard let glucoseTargetRangeSchedule = glucoseTargetRangeSchedule else {
            return nil
        }
        return [Self.activeScheduleNameDefault: glucoseTargetRangeSchedule.items(for: .milligramsPerDeciliter).map { TPumpSettingsDatum.BloodGlucoseStartTarget(start: $0.startTime, low: $0.value.minValue, high: $0.value.maxValue) }]
    }
    
    private var datumPumpBolus: TPumpSettingsDatum.Bolus? {
        guard let maximumBolus = maximumBolus else {
            return nil
        }
        return TPumpSettingsDatum.Bolus(amountMaximum: TPumpSettingsDatum.Bolus.AmountMaximum(maximumBolus, .units))
    }
    
    private var datumPumpCarbohydrateRatioSchedules: [String: [TPumpSettingsDatum.CarbohydrateRatioStart]]? {
        guard let carbRatioSchedule = carbRatioSchedule else {
            return nil
        }
        return [Self.activeScheduleNameDefault: carbRatioSchedule.items(for: .gram()).map { TPumpSettingsDatum.CarbohydrateRatioStart(start: $0.startTime, amount: $0.value) }]
    }
    
    private var datumPumpDisplay: TPumpSettingsDatum.Display? {
        guard let bloodGlucoseUnit = bloodGlucoseUnit else {
            return nil
        }
        
        var units: TPumpSettingsDatum.Display.BloodGlucose.Units
        switch bloodGlucoseUnit {
        case .milligramsPerDeciliter:
            units = .milligramsPerDeciliter
        case .millimolesPerLiter:
            units = .millimolesPerLiter
        default:
            return nil
        }
        
        return TPumpSettingsDatum.Display(bloodGlucose: TPumpSettingsDatum.Display.BloodGlucose(units))
    }

    private var datumPumpFirmwareVersion: String? { pumpDevice?.firmwareVersion }

    private var datumPumpHardwareVersion: String? { pumpDevice?.hardwareVersion }

    private var datumPumpInsulinFormulation: TPumpSettingsDatum.InsulinFormulation? {
        return insulinType?.datum
    }

    private var datumPumpInsulinModel: TPumpSettingsDatum.InsulinModel? {
        guard let defaultRapidActingModel = defaultRapidActingModel else {
            return nil
        }
        
        var modelType: TPumpSettingsDatum.InsulinModel.ModelType
        switch defaultRapidActingModel.modelType {
        case .fiasp:
            modelType = .fiasp
        case .rapidAdult:
            modelType = .rapidAdult
        case .rapidChild:
            modelType = .rapidChild
        default:
            modelType = .other
        }
        
        return TPumpSettingsDatum.InsulinModel(modelType: modelType,
                                               actionDelay: defaultRapidActingModel.delay,
                                               actionDuration: defaultRapidActingModel.actionDuration,
                                               actionPeakOffset: defaultRapidActingModel.peakActivity)
    }
    
    private var datumPumpInsulinSensitivitySchedules: [String: [TPumpSettingsDatum.InsulinSensitivityStart]]? {
        guard let insulinSensitivitySchedule = insulinSensitivitySchedule else {
            return nil
        }
        return [Self.activeScheduleNameDefault: insulinSensitivitySchedule.items(for: .milligramsPerDeciliter).map { return TPumpSettingsDatum.InsulinSensitivityStart(start: $0.startTime, amount: $0.value) }]
    }

    private var datumPumpManufacturers: [String]? { pumpDevice?.manufacturer.map { [$0] } }

    private var datumPumpModel: String? { pumpDevice?.model }

    private var datumPumpName: String? { pumpDevice?.name }

    private var datumPumpOverridePresets: [String: TPumpSettingsDatum.OverridePreset]? {
        guard let overridePresets = overridePresets, !overridePresets.isEmpty else {
            return nil
        }
        return overridePresets.reduce(into: [:]) { $0[$1.name] = $1.datum }
    }
    
    private var datumPumpScheduleTimeZoneOffset: TimeInterval? {
        guard let scheduleTimeZone = basalRateSchedule?.timeZone ?? glucoseTargetRangeSchedule?.timeZone ?? carbRatioSchedule?.timeZone ?? insulinSensitivitySchedule?.timeZone,
              scheduleTimeZone.secondsFromGMT(for: date) != controllerTimeZone.secondsFromGMT(for: date)
        else {
            return nil
        }
        return TimeInterval(seconds: scheduleTimeZone.secondsFromGMT(for: date))
    }

    private var datumPumpSerialNumber: String? { pumpDevice?.localIdentifier }

    private var datumPumpSoftwareVersion: String? { pumpDevice?.softwareVersion }
    
    private var datumPumpUnits: TPumpSettingsDatum.Units {
        return TPumpSettingsDatum.Units(bloodGlucose: .milligramsPerDeciliter, carbohydrate: .grams, insulin: .units)
    }
    
    private var datumPayload: TDictionary {
        var dictionary = TDictionary()
        dictionary["syncIdentifier"] = syncIdentifier.uuidString
        return dictionary
    }
    
    private var activeOverride: TemporaryScheduleOverride? {
        switch (preMealOverride, scheduleOverride) {
        case (let preMealOverride?, nil):
            return preMealOverride
        case (nil, let scheduleOverride?):
            return scheduleOverride
        case (let preMealOverride?, let scheduleOverride?):
            return preMealOverride.scheduledEndDate > date ? preMealOverride : scheduleOverride
        case (nil, nil):
            return nil
        }
    }

    public static var activeScheduleNameDefault: String { "Default" }
}

fileprivate extension NotificationSettings {
    var datum: TControllerSettingsDatum.Notifications {
        return TControllerSettingsDatum.Notifications(authorization: authorizationStatus.datum,
                                                      alert: alertSetting.datum,
                                                      criticalAlert: criticalAlertSetting.datum,
                                                      badge: badgeSetting.datum,
                                                      sound: soundSetting.datum,
                                                      announcement: announcementSetting.datum,
                                                      timeSensitive: timeSensitiveSetting.datum,
                                                      scheduledDelivery: scheduledDeliverySetting.datum,
                                                      notificationCenter: notificationCenterSetting.datum,
                                                      lockScreen: lockScreenSetting.datum,
                                                      alertStyle: alertStyle.datum)
    }
}

fileprivate extension NotificationSettings.AuthorizationStatus {
    var datum: TControllerSettingsDatum.Notifications.Authorization? {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .provisional:
            return .provisional
        case .ephemeral:
            return .ephemeral
        case .unknown:
            return nil
        }
    }
}

fileprivate extension NotificationSettings.NotificationSetting {
    var datum: Bool? {
        switch self {
        case .notSupported:
            return false
        case .disabled:
            return false
        case .enabled:
            return true
        case .unknown:
            return nil
        }
    }
}

fileprivate extension NotificationSettings.AlertStyle {
    var datum: TControllerSettingsDatum.Notifications.AlertStyle? {
        switch self {
        case .none:
            return TControllerSettingsDatum.Notifications.AlertStyle.none
        case .banner:
            return .banner
        case .alert:
            return .alert
        case .unknown:
            return nil
        }
    }
}

fileprivate extension TemporaryScheduleOverridePreset {
    var datum: TPumpSettingsDatum.OverridePreset {
        return TPumpSettingsDatum.OverridePreset(abbreviation: datumAbbreviation,
                                                 duration: datumDuration,
                                                 bloodGlucoseTarget: settings.datumBloodGlucoseTarget,
                                                 basalRateScaleFactor: settings.datumBasalRateScaleFactor,
                                                 carbohydrateRatioScaleFactor: settings.datumCarbohydrateRatioScaleFactor,
                                                 insulinSensitivityScaleFactor: settings.datumInsulinSensitivityScaleFactor)
    }
    
    var datumAbbreviation: String? { symbol }
    
    var datumDuration: TimeInterval? { duration.isFinite ? duration.timeInterval : nil }
}

fileprivate extension TemporaryScheduleOverride {
    var datumTime: Date { startDate }

    var datumOverrideType: TPumpSettingsOverrideDeviceEventDatum.OverrideType { context.datumOverrideType }
    
    var datumOverridePreset: String? {
        guard case .preset(let preset) = context else {
            return nil
        }
        return preset.name
    }
    
    var datumMethod: TPumpSettingsOverrideDeviceEventDatum.Method? { .manual }
    
    var datumDuration: TimeInterval? {
        switch duration {
        case .finite(let interval):
            return interval
        case .indefinite:
            return nil
        }
    }
    
    var datumExpectedDuration: TimeInterval? { nil }
    
    var datumBloodGlucoseTarget: TPumpSettingsOverrideDeviceEventDatum.BloodGlucoseTarget? { settings.datumBloodGlucoseTarget }
    
    var datumBasalRateScaleFactor: Double? { settings.datumBasalRateScaleFactor }
    
    var datumCarbohydrateRatioScaleFactor: Double? { settings.datumCarbohydrateRatioScaleFactor }
    
    var datumInsulinSensitivityScaleFactor: Double? { settings.datumInsulinSensitivityScaleFactor }

    var datumUnits: TPumpSettingsOverrideDeviceEventDatum.Units? { settings.datumUnits }
}

fileprivate extension TemporaryScheduleOverride.Context {
    var datumOverrideType: TPumpSettingsOverrideDeviceEventDatum.OverrideType {
        switch self {
        case .preMeal:
            return .preprandial
        case .legacyWorkout:
            return .physicalActivity
        case .preset(_):
            return .preset
        case .custom:
            return .custom
        }
    }
}

fileprivate extension TemporaryScheduleOverrideSettings {
    var datumBloodGlucoseTarget: TPumpSettingsDatum.BloodGlucoseTarget? {
        guard let targetRange = targetRange else {
            return nil
        }
        return TPumpSettingsDatum.BloodGlucoseTarget(low: targetRange.lowerBound.doubleValue(for: .milligramsPerDeciliter),
                                                     high: targetRange.upperBound.doubleValue(for: .milligramsPerDeciliter))
    }
    
    var datumBasalRateScaleFactor: Double? { basalRateMultiplier }
    
    var datumCarbohydrateRatioScaleFactor: Double? { carbRatioMultiplier }
    
    var datumInsulinSensitivityScaleFactor: Double? { insulinSensitivityMultiplier }

    var datumUnits: TPumpSettingsOverrideDeviceEventDatum.Units? {
        guard targetRange != nil else {
            return nil
        }
        return TPumpSettingsOverrideDeviceEventDatum.Units(bloodGlucose: .milligramsPerDeciliter)
    }
}

extension TCGMSettingsDatum: TypedDatum {
    static var resolvedType: String { TDatum.DatumType.cgmSettings.rawValue }
}

extension TControllerSettingsDatum: TypedDatum {
    static var resolvedType: String { TDatum.DatumType.controllerSettings.rawValue }
}

extension TPumpSettingsDatum: TypedDatum {
    static var resolvedType: String { TDatum.DatumType.pumpSettings.rawValue }
}

extension TPumpSettingsOverrideDeviceEventDatum: TypedDatum {
    static var resolvedType: String { "\(TDatum.DatumType.deviceEvent.rawValue)/\(TDeviceEventDatum.SubType.pumpSettingsOverride.rawValue)" }
}
