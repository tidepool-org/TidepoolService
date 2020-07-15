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
    @ObservedObject var viewModel: TherapySettingsViewModel
    
    init(
        model: TherapySettingsViewModel
    ) {
        self.viewModel = model
    }
    
    var body: some View {
        CorrectionRangeOverridesEditor(
            value: CorrectionRangeOverrides(
                preMeal: viewModel.therapySettings.preMealTargetRange,
                workout: viewModel.therapySettings.workoutTargetRange,
                // ANNA TODO: add units into view model & don't force unwrap
                unit: viewModel.therapySettings.glucoseTargetRangeSchedule!.unit
            ),
            // ANNA TODO: add units into view model & don't force unwrap
            unit: viewModel.therapySettings.glucoseTargetRangeSchedule!.unit,
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
