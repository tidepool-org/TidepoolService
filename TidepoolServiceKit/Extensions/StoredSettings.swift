//
//  StoredSettings.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/1/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import HealthKit
import LoopKit
import TidepoolKit

extension StoredSettings {
    var datum: TDatum {
        return TPumpSettingsDatum(time: datumTime,
                                  activeScheduleName: datumActiveScheduleName,
                                  automatedDelivery: datumAutomatedDelivery,
                                  basal: datumBasal,
                                  basalRateSchedules: datumBasalRateSchedules,
                                  bloodGlucoseSuspendThreshold: datumBloodGlucoseSuspendThreshold,
                                  bloodGlucoseTargetPhysicalActivity: datumBloodGlucoseTargetPhysicalActivity,
                                  bloodGlucoseTargetPreprandial: datumBloodGlucoseTargetPreprandial,
                                  bloodGlucoseTargetSchedules: datumBloodGlucoseTargetSchedules,
                                  bolus: datumBolus,
                                  carbohydrateRatioSchedules: datumCarbohydrateRatioSchedules,
                                  display: datumDisplay,
                                  insulinModel: datumInsulinModel,
                                  insulinSensitivitySchedules: datumInsulinSensitivitySchedules,
                                  scheduleTimeZoneOffset: datumScheduleTimeZoneOffset,
                                  units: datumUnits).adorn(withOrigin: datumOrigin)
    }
    
    private var datumTime: Date { date }
    
    private var datumActiveScheduleName: String { "Default" }
    
    private var datumAutomatedDelivery: Bool { dosingEnabled }
    
    private var datumBasal: TPumpSettingsDatum.Basal? {
        guard let maximumBasalRatePerHour = maximumBasalRatePerHour else {
            return nil
        }
        return TPumpSettingsDatum.Basal(rateMaximum: TPumpSettingsDatum.Basal.RateMaximum(maximumBasalRatePerHour, .unitsPerHour))
    }
    
    private var datumBasalRateSchedules: [String: [TPumpSettingsDatum.BasalRateStart]]? {
        guard let basalRateSchedule = basalRateSchedule else {
            return nil
        }
        return [datumActiveScheduleName: basalRateSchedule.items.map { TPumpSettingsDatum.BasalRateStart(start: Int($0.startTime.milliseconds), rate: $0.value) }]
    }
    
    private var datumBloodGlucoseSuspendThreshold: Double? {
        guard let suspendThreshold = suspendThreshold else {
            return nil
        }
        return suspendThreshold.value.converted(from: suspendThreshold.unit, to: .milligramsPerDeciliter)
    }
    
    private var datumBloodGlucoseTargetPhysicalActivity: TPumpSettingsDatum.BloodGlucoseTarget? {
        guard let bloodGlucoseUnit = bloodGlucoseUnit, let workoutTargetRange = workoutTargetRange else {
            return nil
        }
        let targetRange = workoutTargetRange.converted(from: HKUnit(from: bloodGlucoseUnit), to: .milligramsPerDeciliter)
        return TPumpSettingsDatum.BloodGlucoseTarget(low: targetRange.minValue, high: targetRange.maxValue)
    }
    
    private var datumBloodGlucoseTargetPreprandial: TPumpSettingsDatum.BloodGlucoseTarget? {
        guard let bloodGlucoseUnit = bloodGlucoseUnit, let preMealTargetRange = preMealTargetRange else {
            return nil
        }
        let targetRange = preMealTargetRange.converted(from: HKUnit(from: bloodGlucoseUnit), to: .milligramsPerDeciliter)
        return TPumpSettingsDatum.BloodGlucoseTarget(low: targetRange.minValue, high: targetRange.maxValue)
    }
    
    private var datumBloodGlucoseTargetSchedules: [String: [TPumpSettingsDatum.BloodGlucoseStartTarget]]? {
        guard let glucoseTargetRangeSchedule = glucoseTargetRangeSchedule else {
            return nil
        }
        return [datumActiveScheduleName: glucoseTargetRangeSchedule.items(for: .milligramsPerDeciliter).map { TPumpSettingsDatum.BloodGlucoseStartTarget(start: Int($0.startTime.milliseconds), low: $0.value.minValue, high: $0.value.maxValue) }]
    }
    
    private var datumBolus: TPumpSettingsDatum.Bolus? {
        guard let maximumBolus = maximumBolus else {
            return nil
        }
        return TPumpSettingsDatum.Bolus(amountMaximum: TPumpSettingsDatum.Bolus.AmountMaximum(maximumBolus, .units))
    }
    
    private var datumCarbohydrateRatioSchedules: [String: [TPumpSettingsDatum.CarbohydrateRatioStart]]? {
        guard let carbRatioSchedule = carbRatioSchedule else {
            return nil
        }
        return [datumActiveScheduleName: carbRatioSchedule.items(for: .gram()).map { TPumpSettingsDatum.CarbohydrateRatioStart(start: Int($0.startTime.milliseconds), amount: $0.value) }]
    }
    
    private var datumDisplay: TPumpSettingsDatum.Display? {
        guard let bloodGlucoseUnit = bloodGlucoseUnit else {
            return nil
        }
        
        var units: TPumpSettingsDatum.Display.BloodGlucose.Units
        switch HKUnit(from: bloodGlucoseUnit) {
        case .milligramsPerDeciliter:
            units = .milligramsPerDeciliter
        case .millimolesPerLiter:
            units = .millimolesPerLiter
        default:
            return nil
        }
        
        return TPumpSettingsDatum.Display(bloodGlucose: TPumpSettingsDatum.Display.BloodGlucose(units))
    }
    
    private var datumInsulinModel: TPumpSettingsDatum.InsulinModel? {
        guard let insulinModel = insulinModel else {
            return nil
        }
        
        var modelType: TPumpSettingsDatum.InsulinModel.ModelType
        switch insulinModel.modelType {
        case .fiasp:
            modelType = .fiasp
        case .rapidAdult:
            modelType = .rapidAdult
        case .rapidChild:
            modelType = .rapidChild
        case .walsh:
            modelType = .walsh
        }
        
        let actionDuration = Int(insulinModel.actionDuration)
        
        var actionPeakOffset: Int?
        if let peakActivity = insulinModel.peakActivity {
            actionPeakOffset = Int(peakActivity)
        }
        
        return TPumpSettingsDatum.InsulinModel(modelType: modelType, actionDuration: actionDuration, actionPeakOffset: actionPeakOffset)
    }
    
    private var datumInsulinSensitivitySchedules: [String: [TPumpSettingsDatum.InsulinSensitivityStart]]? {
        guard let insulinSensitivitySchedule = insulinSensitivitySchedule else {
            return nil
        }
        return [datumActiveScheduleName: insulinSensitivitySchedule.items(for: .milligramsPerDeciliter).map { return TPumpSettingsDatum.InsulinSensitivityStart(start: Int($0.startTime.milliseconds), amount: $0.value) }]
    }
    
    private var datumScheduleTimeZoneOffset: Int? {
        if let basalRateSchedule = basalRateSchedule {
            return basalRateSchedule.timeZone.secondsFromGMT() / 60
        }
        if let glucoseTargetRangeSchedule = glucoseTargetRangeSchedule {
            return glucoseTargetRangeSchedule.timeZone.secondsFromGMT() / 60
        }
        if let carbRatioSchedule = carbRatioSchedule {
            return carbRatioSchedule.timeZone.secondsFromGMT() / 60
        }
        if let insulinSensitivitySchedule = insulinSensitivitySchedule {
            return insulinSensitivitySchedule.timeZone.secondsFromGMT() / 60
        }
        return nil
    }
    
    private var datumUnits: TPumpSettingsDatum.Units {
        return TPumpSettingsDatum.Units(bloodGlucose: .milligramsPerDeciliter, carbohydrate: .grams, insulin: .units)
    }
    
    private var datumOrigin: TOrigin {
        return TOrigin(id: syncIdentifier)
    }
}
