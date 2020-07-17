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
    @ObservedObject var viewModel: TherapySettingsViewModel
    let unit: HKUnit
    
    init(model: TherapySettingsViewModel) {
        precondition(model.therapySettings.glucoseUnit != nil)
        self.viewModel = model
        self.unit = model.therapySettings.glucoseUnit!
    }
    
    var body: some View {
        SuspendThresholdEditor(
            value: viewModel.therapySettings.suspendThreshold?.quantity,
            unit: unit,
            maxValue: Guardrail.maxSuspendThresholdValue(
                correctionRangeSchedule: viewModel.therapySettings.glucoseTargetRangeSchedule,
                preMealTargetRange: viewModel.therapySettings.preMealTargetRange,
                workoutTargetRange: viewModel.therapySettings.workoutTargetRange,
                unit: unit
            ),
            onSave: { newValue in
                self.viewModel.saveSuspendThreshold(value: GlucoseThreshold(unit: self.unit, value: newValue.doubleValue(for: self.unit)))
                self.viewModel.didFinishStep?()
            },
            mode: .flow
        )
    }
}
