//
//  Prescription.swift
//  TidepoolServiceKit
//
//  Created by Anna Quinlan on 6/18/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation
import HealthKit
import LoopKit


public enum CGMType: String, Codable {
    case g6
}

public enum PumpType: String, Codable {
    case dash
}

public enum TrainingType: String, Codable {
    case inPerson // Patient must have hands-on training with clinician/CDE
    case inModule // Patient can train in-app

}

public struct MockPrescription {
    public let datePrescribed: Date // Date prescription was prescribed
    public let providerName: String // Name of clinician prescribing
    public let cgm: CGMType // CGM type (manufacturer & model)
    public let pump: PumpType // Pump type (manufacturer & model)
    public let bloodGlucoseUnit: HKUnit // CGM type (manufacturer & model)
    public let basalRateSchedule: BasalRateSchedule
    public let glucoseTargetRangeSchedule: GlucoseRangeSchedule
    public let carbRatioSchedule: CarbRatioSchedule
    public let insulinSensitivitySchedule: InsulinSensitivitySchedule
    public let maximumBasalRatePerHour: Double
    public let maximumBolus: Double
    public let suspendThreshold: GlucoseThreshold
    public let insulinModel: InsulinModel
    public let preMealTargetRange: DoubleRange
    public let workoutTargetRange: DoubleRange

    public init(datePrescribed: Date,
                providerName: String,
                cgmType: CGMType,
                pumpType: PumpType,
                bloodGlucoseUnit: HKUnit,
                basalRateSchedule: BasalRateSchedule,
                glucoseTargetRangeSchedule: GlucoseRangeSchedule,
                carbRatioSchedule: CarbRatioSchedule,
                insulinSensitivitySchedule: InsulinSensitivitySchedule,
                maximumBasalRatePerHour: Double,
                maximumBolus: Double,
                suspendThreshold: GlucoseThreshold,
                insulinModel: InsulinModel,
                preMealTargetRange: DoubleRange,
                workoutTargetRange: DoubleRange) {
        self.datePrescribed = datePrescribed
        self.providerName = providerName
        self.cgm = cgmType
        self.pump = pumpType
        self.bloodGlucoseUnit = bloodGlucoseUnit
        self.basalRateSchedule = basalRateSchedule
        self.glucoseTargetRangeSchedule = glucoseTargetRangeSchedule
        self.carbRatioSchedule = carbRatioSchedule
        self.insulinSensitivitySchedule = insulinSensitivitySchedule
        self.maximumBasalRatePerHour = maximumBasalRatePerHour
        self.maximumBolus = maximumBolus
        self.suspendThreshold = suspendThreshold
        self.insulinModel = insulinModel
        self.preMealTargetRange = preMealTargetRange
        self.workoutTargetRange = workoutTargetRange
    }
    
    public struct InsulinModel: Codable, Equatable {
        public enum ModelType: String, Codable {
            case fiasp
            case rapidAdult
            case rapidChild
            case walsh
        }
        
        public let modelType: ModelType
        public let actionDuration: TimeInterval
        public let peakActivity: TimeInterval?

        public init(modelType: ModelType, actionDuration: TimeInterval, peakActivity: TimeInterval? = nil) {
            self.modelType = modelType
            self.actionDuration = actionDuration
            self.peakActivity = peakActivity
        }
    }
}

extension MockPrescription: Codable {
   public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var bloodGlucoseUnit: HKUnit?
        if let bloodGlucoseUnitString = try container.decodeIfPresent(String.self, forKey: .bloodGlucoseUnit) {
            bloodGlucoseUnit = HKUnit(from: bloodGlucoseUnitString)
        }
        self.init(datePrescribed: try container.decode(Date.self, forKey: .datePrescribed),
                  providerName: try container.decode(String.self, forKey: .providerName),
                  cgmType: try container.decode(CGMType.self, forKey: .cgm),
                  pumpType: try container.decode(PumpType.self, forKey: .pump),
                  bloodGlucoseUnit: bloodGlucoseUnit ?? .milligramsPerDeciliter,
                  basalRateSchedule: try container.decode(BasalRateSchedule.self, forKey: .basalRateSchedule),
                  glucoseTargetRangeSchedule: try container.decode(GlucoseRangeSchedule.self, forKey: .glucoseTargetRangeSchedule),
                  carbRatioSchedule: try container.decode(CarbRatioSchedule.self, forKey: .carbRatioSchedule),
                  insulinSensitivitySchedule: try container.decode(InsulinSensitivitySchedule.self, forKey: .insulinSensitivitySchedule),
                  maximumBasalRatePerHour: try container.decode(Double.self, forKey: .maximumBasalRatePerHour),
                  maximumBolus: try container.decode(Double.self, forKey: .maximumBolus),
                  suspendThreshold: try container.decode(GlucoseThreshold.self, forKey: .suspendThreshold),
                  insulinModel: try container.decode(InsulinModel.self, forKey: .insulinModel),
                  preMealTargetRange: try container.decode(DoubleRange.self, forKey: .preMealTargetRange),
                  workoutTargetRange: try container.decode(DoubleRange.self, forKey: .workoutTargetRange))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(datePrescribed, forKey: .datePrescribed)
        try container.encode(providerName, forKey: .providerName)
        try container.encode(cgm, forKey: .cgm)
        try container.encode(pump, forKey: .pump)
        try container.encode(bloodGlucoseUnit.unitString, forKey: .bloodGlucoseUnit)
        try container.encode(basalRateSchedule, forKey: .basalRateSchedule)
        try container.encode(glucoseTargetRangeSchedule, forKey: .glucoseTargetRangeSchedule)
        try container.encode(carbRatioSchedule, forKey: .carbRatioSchedule)
        try container.encode(insulinSensitivitySchedule, forKey: .insulinSensitivitySchedule)
        try container.encode(maximumBasalRatePerHour, forKey: .maximumBasalRatePerHour)
        try container.encode(maximumBolus, forKey: .maximumBolus)
        try container.encode(suspendThreshold, forKey: .suspendThreshold)
        try container.encode(insulinModel, forKey: .insulinModel)
        try container.encode(preMealTargetRange, forKey: .preMealTargetRange)
        try container.encode(workoutTargetRange, forKey: .workoutTargetRange)
    }

    private enum CodingKeys: String, CodingKey {
        case datePrescribed
        case providerName
        case cgm
        case pump
        case bloodGlucoseUnit
        case basalRateSchedule
        case glucoseTargetRangeSchedule
        case carbRatioSchedule
        case insulinSensitivitySchedule
        case maximumBasalRatePerHour
        case maximumBolus
        case suspendThreshold
        case insulinModel
        case preMealTargetRange
        case workoutTargetRange
    }
}
