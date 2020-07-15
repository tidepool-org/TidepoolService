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

public enum CGMType: String, Codable {
    case g6
}

public enum PumpType: String, Codable {
    case dash
}

public struct MockPrescription: Codable {
    public let datePrescribed: Date // Date prescription was prescribed
    public let providerName: String // Name of clinician prescribing
    public let cgm: CGMType // CGM type (manufacturer & model)
    public let pump: PumpType // Pump type (manufacturer & model)
    public let bloodGlucoseUnit: BGUnit
    public let therapySettings: TherapySettings

    public init(datePrescribed: Date,
                providerName: String,
                cgmType: CGMType,
                pumpType: PumpType,
                bloodGlucoseUnit: BGUnit,
                therapySettings: TherapySettings
    ) {
        self.datePrescribed = datePrescribed
        self.providerName = providerName
        self.cgm = cgmType
        self.pump = pumpType
        self.bloodGlucoseUnit = bloodGlucoseUnit
        self.therapySettings = therapySettings
    }
}
