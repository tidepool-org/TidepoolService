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
import HealthKit

struct CorrectionRangeOverrideReview: View {
    @ObservedObject var viewModel: TherapySettingsViewModel
    let unit: HKUnit
    
    init(model: TherapySettingsViewModel){
        self.viewModel = model
        self.unit = model.therapySettings.glucoseUnit ?? .milligramsPerDeciliter
    }
    
    var body: some View {
        CorrectionRangeOverridesEditor(
            value: CorrectionRangeOverrides(
                preMeal: viewModel.therapySettings.preMealTargetRange,
                workout: viewModel.therapySettings.workoutTargetRange,
                unit: unit
            ),
            unit: unit,
            correctionRangeScheduleRange: (viewModel.therapySettings.glucoseTargetRangeSchedule?.scheduleRange())!,
            minValue: viewModel.therapySettings.suspendThreshold?.quantity,
            onSave: { overrides in
                self.viewModel.saveCorrectionRangeOverrides(overrides: overrides, unit: self.viewModel.therapySettings.glucoseTargetRangeSchedule!.unit) // ANNA TODO
                if let didFinishStep = self.viewModel.didFinishStep {
                    didFinishStep()
                }
            },
            sensitivityOverridesEnabled: false,
            mode: .flow
        )
    }
}
