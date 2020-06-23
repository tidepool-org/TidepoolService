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
    var didFinish: (() -> Void)?
    var didCancel: (() -> Void)?
    
    var prescription: Prescription?
    
    func loadPrescriptionFromCode(prescriptionCode: String) {
        #if targetEnvironment(simulator)
        MockPrescriptionManager().getPrescriptionData { result in
            switch result {
            case .failure:
                fatalError("Mock prescription manager should always return a prescription")
            case .success(let prescription):
                self.prescription = prescription
            }
        }
        #else
        // TODO: add in proper query to backend
        #endif
    }
}
