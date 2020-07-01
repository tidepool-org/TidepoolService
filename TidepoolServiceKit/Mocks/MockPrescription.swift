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

public enum BGUnit: String, Codable {
    case mgdl
    case mmol
    
    public var hkUnit: HKUnit {
        switch self {
        case .mgdl:
            return .milligramsPerDeciliter
        case .mmol:
            return .millimolesPerLiter
        }
    }
}

public struct MockPrescription: Codable {
    public let datePrescribed: Date // Date prescription was prescribed
    public let providerName: String // Name of clinician prescribing
    public let cgm: CGMType // CGM type (manufacturer & model)
    public let pump: PumpType // Pump type (manufacturer & model)
    public let bloodGlucoseUnit: BGUnit
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
                bloodGlucoseUnit: BGUnit,
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
