//
//  MockPrescriptionManager.swift
//  TidepoolServiceKit
//
//  Created by Anna Quinlan on 6/18/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation
import LoopKit

public class MockPrescriptionManager {
    private var prescription: MockPrescription
    
    public init(prescription: MockPrescription? = nil) {
        if let prescription = prescription {
            self.prescription = prescription
        } else {
            self.prescription = MockPrescription(
                datePrescribed: Date(),
                providerName: "Sally Seastar",
                cgmType: CGMType.g6,
                pumpType: PumpType.dash,
                bloodGlucoseUnit: .mgdl,
                therapySettings: TherapySettings.mockTherapySettings
            )
        }
    }
    
    public func getPrescriptionData(completion: @escaping (Result<MockPrescription, Error>) -> Void) {
        completion(.success(self.prescription))
    }
}
