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
            value: prescription.suspendThreshold.quantity,
            unit: prescription.bloodGlucoseUnit.hkUnit,
            maxValue: prescription.glucoseTargetRangeSchedule.minLowerBound(),
            onSave: { newValue in
                let unit = self.prescription.bloodGlucoseUnit.hkUnit
                self.viewModel.saveSuspendThreshold(value: GlucoseThreshold(unit: unit, value: newValue.doubleValue(for: unit)))
                self.viewModel.didFinishStep()
            },
            mode: .flow
        )
    }
}
