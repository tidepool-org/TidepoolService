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
        precondition(model.therapySettings.glucoseUnit != nil)
        precondition(model.therapySettings.glucoseTargetRangeSchedule != nil)
        self.viewModel = model
        self.unit = model.therapySettings.glucoseUnit!
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
                self.viewModel.saveCorrectionRangeOverrides(overrides: overrides, unit: self.unit)
                self.viewModel.didFinishStep?()
            },
            sensitivityOverridesEnabled: false,
            mode: .flow
        )
    }
}
