//
//  PrescriptionCodeEntryModel.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 6/22/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolServiceKit

class PrescriptionCodeEntryViewModel: ObservableObject {
    var didFinishStep: (() -> Void)
    var didCancel: (() -> Void)?
    
    var prescription: MockPrescription?
    let prescriptionCodeLength = 4
    
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
    
    func validateCode(prescriptionCode: String) -> Bool {
        return prescriptionCode.count == prescriptionCodeLength
    }
    
    func loadPrescriptionFromCode(prescriptionCode: String) {
        guard validateCode(prescriptionCode: prescriptionCode) else {
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
}
