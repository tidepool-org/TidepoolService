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
            maxValue: [
                viewModel.therapySettings.glucoseTargetRangeSchedule?.minLowerBound().doubleValue(for: unit),
                viewModel.therapySettings.preMealTargetRange?.minValue,
                viewModel.therapySettings.workoutTargetRange?.minValue
            ]
            .compactMap { $0 }
            .min()
            .map { HKQuantity(unit: unit, doubleValue: $0) },
            onSave: { newValue in
                self.viewModel.saveSuspendThreshold(value: GlucoseThreshold(unit: self.unit, value: newValue.doubleValue(for: self.unit)))
                self.viewModel.didFinishStep?()
            },
            mode: .flow
        )
    }
}
