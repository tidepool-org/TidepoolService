//
//  PrescriptionCodeEntryModel.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 6/22/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import Foundation
import TidepoolServiceKit

class PrescriptionCodeEntryViewModel: ObservableObject {
    var didFinishStep: (() -> Void)
    var didCancel: (() -> Void)?
    
    var prescription: Prescription?
    
    init(finishedStepHandler: @escaping () -> Void = { }) {
        self.didFinishStep = finishedStepHandler
    }
    
    func entryNavigation(success: Bool) {
        if success {
            didFinishStep()
        } else {
           // Handle error
        }
    }
    
    func loadPrescriptionFromCode(prescriptionCode: String) {
        // TODO: validate prescription code and check if it works; if not, raise invalidCode error

        MockPrescriptionManager().getPrescriptionData { result in
            switch result {
            case .failure:
                fatalError("Mock prescription manager should always return a prescription")
            case .success(let prescription):
                self.prescription = prescription
                self.entryNavigation(success: true)
            }
        }
        // TODO: call function to properly query the backend
        // TODO: if prescription couldn't be retrieved from backend, raise unableToRetreivePrescription error
    }
}
