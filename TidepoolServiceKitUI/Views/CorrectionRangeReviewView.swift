//
//  CorrectionRangeReviewView.swift
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


struct CorrectionRangeReviewView: View {
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
        CorrectionRangeScheduleEditor(
            schedule: prescription.therapySettings.glucoseTargetRangeSchedule,
            unit: prescription.bloodGlucoseUnit.hkUnit,
            minValue: prescription.therapySettings.suspendThreshold?.quantity,
            onSave: { newSchedule in
                self.viewModel.saveCorrectionRange(range: newSchedule)
                self.viewModel.didFinishStep()
            },
            mode: .flow
        )
    }
}
