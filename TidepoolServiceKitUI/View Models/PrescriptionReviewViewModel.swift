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
    let prescriptionCodeLength = 6
    
    @Published var shouldDisplayError = false
    
    init(finishedStepHandler: @escaping () -> Void = { }) {
        self.didFinishStep = finishedStepHandler
    }
    
    func entryNavigation(success: Bool) {
        if success {
            shouldDisplayError = false
            didFinishStep()
        } else {
           shouldDisplayError = true
        }
    }
    
    func validatePrescriptionCode(_ prescriptionCode: String, _ birthday: Date) -> Bool {
        return prescriptionCode.count == prescriptionCodeLength && birthday.timeIntervalSinceReferenceDate > 0
    }
    
    func loadPrescriptionFromCode(prescriptionCode: String, birthday: Date) {
        guard validatePrescriptionCode(prescriptionCode, birthday) else {
            self.entryNavigation(success: false)
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
}
