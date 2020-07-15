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
        self.viewModel = model
        self.unit = model.therapySettings.glucoseUnit?.hkUnit ?? .milligramsPerDeciliter
    }
    
    var body: some View {
        SuspendThresholdEditor(
            value: viewModel.therapySettings.suspendThreshold?.quantity,
            unit: viewModel.therapySettings.glucoseUnit?.hkUnit ?? .milligramsPerDeciliter,
            maxValue: viewModel.therapySettings.glucoseTargetRangeSchedule?.minLowerBound(),
            onSave: { newValue in
                self.viewModel.saveSuspendThreshold(value: GlucoseThreshold(unit: self.unit, value: newValue.doubleValue(for: self.unit)))
                if let didFinishStep = self.viewModel.didFinishStep {
                    didFinishStep()
                }
            },
            mode: .flow
        )
    }
}
