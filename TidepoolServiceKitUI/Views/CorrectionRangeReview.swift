//
//  CorrectionRangeReview.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 6/29/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//
import SwiftUI
import LoopKitUI
import LoopKit
import HealthKit
import TidepoolServiceKit

struct CorrectionRangeReview: View {
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
        CorrectionRangeScheduleEditor(
            schedule: prescription.glucoseTargetRangeSchedule,
            unit: prescription.bloodGlucoseUnit.hkUnit,
            minValue: prescription.suspendThreshold.quantity,
            onSave: { newSchedule in
                self.viewModel.saveCorrectionRange(range: newSchedule)
                self.viewModel.didFinishStep()
            },
            mode: .flow,
            userHasEdited: $userHasEdited
        )
    }
}