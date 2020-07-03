//
//  PrescriptionCodeEntryViewModel.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 6/22/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolServiceKit
import LoopKit
import LoopKitUI
import HealthKit

class PrescriptionReviewViewModel: ObservableObject {
    var didFinishStep: (() -> Void)
    var didCancel: (() -> Void)?
    
    var prescription: MockPrescription?
    let prescriptionCodeLength = 4
    
    var settings: LoopSettings
    
    init(finishedStepHandler: @escaping () -> Void = { },
         settings: LoopSettings) {
        self.didFinishStep = finishedStepHandler
        self.settings = settings
    }
    
    func entryNavigation(success: Bool) {
        if success {
            didFinishStep()
        } else {
           // TODO: handle error
        }
    }
    
    func validatePrescriptionCode(prescriptionCode: String) -> Bool {
        return prescriptionCode.count == prescriptionCodeLength
    }
    
    func loadPrescriptionFromCode(prescriptionCode: String) {
        guard validatePrescriptionCode(prescriptionCode: prescriptionCode) else {
            // TODO: handle error
            return
        }

        // TODO: call function to properly query the backend; if prescription couldn't be retrieved, raise unableToRetreivePrescription error
        MockPrescriptionManager().getPrescriptionData { result in
            switch result {
            case .failure:
                fatalError("Mock prescription manager should always return a prescription")
            case .success(let prescription):
                self.prescription = prescription
                self.entryNavigation(success: true)
            }
        }
    }
    
    func saveCorrectionRange(range: GlucoseRangeSchedule) {
        settings.glucoseTargetRangeSchedule = range
    }
    
    func saveCorrectionRangeOverrides(overrides: CorrectionRangeOverrides, unit: HKUnit) {
        settings.preMealTargetRange = overrides.preMeal?.doubleRange(for: unit)
        settings.legacyWorkoutTargetRange = overrides.workout?.doubleRange(for: unit)
    }
    
    func saveSuspendThreshold(value: GlucoseThreshold) {
        settings.suspendThreshold = value
    }
}
