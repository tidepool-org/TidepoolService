//
//  CorrectionRangeOverrideReviewView.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 7/1/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import TidepoolServiceKit
import LoopKit
import LoopKitUI

struct CorrectionRangeOverrideReview: View {
    @ObservedObject var viewModel: PrescriptionReviewViewModel
    @State var userHasEdited: Bool = false
    let prescription: MockPrescription
    
    init(
        model: PrescriptionReviewViewModel,
        prescription: MockPrescription
    ) {
        self.viewModel = model
        self.prescription = prescription
    }
    
    var body: some View {
        CorrectionRangeOverridesEditor(
            buttonText: buttonText,
            value: CorrectionRangeOverrides(
                preMeal: prescription.preMealTargetRange,
                workout: prescription.workoutTargetRange,
                unit: prescription.bloodGlucoseUnit.hkUnit
            ),
            unit: prescription.bloodGlucoseUnit.hkUnit,
            minValue: prescription.suspendThreshold.quantity,
            onSave: { overrides in
                self.viewModel.saveCorrectionRangeOverrides(overrides: overrides, unit: self.prescription.bloodGlucoseUnit.hkUnit)
                self.viewModel.didFinishStep()
            },
            sensitivityOverridesEnabled: true,
            mode: .flow,
            userHasEdited: $userHasEdited
        )
    }
    
    private var buttonText: Text {
        return !userHasEdited ? Text(LocalizedString("Accept Setting", comment: "The button text for accepting the prescribed setting")) : Text(LocalizedString("Save Setting", comment: "The button text for saving the edited setting"))
    }
}
