//
//  TemporaryScheduleOverride.swift
//  TidepoolServiceKit
//
//  Created by Pete Schwamb on 8/26/24.
//  Copyright © 2024 LoopKit Authors. All rights reserved.
//

import Foundation
import TidepoolKit
import LoopKit

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

extension TemporaryScheduleOverrideSettings {
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

extension TemporaryScheduleOverride: IdentifiableDatum {

    var syncIdentifierAsString: String { syncIdentifier.uuidString }

    func datum(for userId: String, hostIdentifier: String, hostVersion: String) -> TDatum {
        let datum = TPumpSettingsOverrideDeviceEventDatum(time: datumTime,
                                                          overrideType: datumOverrideType,
                                                          overridePreset: datumOverridePreset,
                                                          method: datumMethod,
                                                          duration: datumDuration,
                                                          expectedDuration: datumExpectedDuration,
                                                          bloodGlucoseTarget: datumBloodGlucoseTarget,
                                                          basalRateScaleFactor: datumBasalRateScaleFactor,
                                                          carbohydrateRatioScaleFactor: datumCarbohydrateRatioScaleFactor,
                                                          insulinSensitivityScaleFactor: datumInsulinSensitivityScaleFactor,
                                                          units: datumUnits)
        let origin = datumOrigin(for: resolvedIdentifier(for: TPumpSettingsOverrideDeviceEventDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        return datum.adornWith(id: datumId(for: userId, type: TPumpSettingsOverrideDeviceEventDatum.self),
                               payload: datumPayload,
                               origin: origin)
    }

    private var datumPayload: TDictionary {
        var dictionary = TDictionary()
        dictionary["syncIdentifier"] = syncIdentifierAsString
        return dictionary
    }

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

extension TemporaryScheduleOverride {
    var selectors: [TDatum.Selector] {
        return [datumSelector(for: TPumpSettingsOverrideDeviceEventDatum.self)]
    }
}

