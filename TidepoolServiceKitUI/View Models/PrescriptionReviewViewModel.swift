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
    // MARK: Navigation
    var didFinishStep: (() -> Void)
    var didCancel: (() -> Void)?
    
    // MARK: State
    @Published var shouldDisplayError = false
    
    // MARK: Prescription Information
    var prescription: MockPrescription?
    let prescriptionCodeLength = 6

    // MARK: Date Picker Information
    let validDateRange = Calendar.current.date(byAdding: .year, value: -130, to: Date())!...Date()
    let placeholderFieldText = LocalizedString("Select birthdate", comment: "Prompt to select birthdate with picker")
    
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
        return prescriptionCode.count == prescriptionCodeLength && validDateRange.contains(birthday)
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
