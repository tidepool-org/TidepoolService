//
//  SuspendThresholdReview.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 7/3/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKitUI
import LoopKit
import HealthKit
import TidepoolServiceKit


struct SuspendThresholdReview: View {
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
        SuspendThresholdEditor(
            buttonText: buttonText,
            value: prescription.suspendThreshold.quantity,
            unit: prescription.bloodGlucoseUnit.hkUnit,
            maxValue: prescription.glucoseTargetRangeSchedule.minLowerBound(),
            onSave: { newValue in
                let unit = self.prescription.bloodGlucoseUnit.hkUnit
                self.viewModel.saveSuspendThreshold(value: GlucoseThreshold(unit: unit, value: newValue.doubleValue(for: unit)))
                self.viewModel.didFinishStep()
            },
             mode: .flow,
             userHasEdited: $userHasEdited
        )
    }
    
    private var buttonText: Text {
        return !userHasEdited ? Text(LocalizedString("Accept Setting", comment: "The button text for accepting the prescribed setting")) : Text(LocalizedString("Save Setting", comment: "The button text for saving the edited setting"))
    }
}
