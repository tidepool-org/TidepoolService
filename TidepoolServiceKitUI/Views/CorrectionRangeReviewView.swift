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
    @ObservedObject var viewModel: TherapySettingsViewModel
    
    init(model: TherapySettingsViewModel){
        self.viewModel = model
    }
    
    var body: some View {
        CorrectionRangeScheduleEditor(
            schedule: viewModel.therapySettings.glucoseTargetRangeSchedule,
            unit: viewModel.therapySettings.glucoseUnit ?? .milligramsPerDeciliter,
            minValue: viewModel.therapySettings.suspendThreshold?.quantity,
            onSave: { newSchedule in
                self.viewModel.saveCorrectionRange(range: newSchedule)
                if let didFinishStep = self.viewModel.didFinishStep {
                    didFinishStep()
                }
            },
            mode: .flow
        )
    }
}
