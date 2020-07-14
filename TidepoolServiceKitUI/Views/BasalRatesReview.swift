//
//  BasalRatesReview.swift
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


struct BasalRatesReview: View {
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
        BasalRateScheduleEditor(
            schedule: prescription.therapySettings.basalRateSchedule,
            supportedBasalRates: supportedBasalRates,
            maximumBasalRate: prescription.therapySettings.maximumBasalRatePerHour,
            maximumScheduleEntryCount: maximumBasalScheduleEntryCount,
            syncSchedule: { result, error  in
                // Since pump isn't set up, this syncing shouldn't do anything
            },
            onSave: { newRates in
                self.viewModel.saveBasalRates(basalRates: newRates)
                self.viewModel.didFinishStep()
            },
            mode: .flow
        )
    }
    
    // TODO: don't hard-code these values
    private var supportedBasalRates: [Double] {
        switch prescription.pump {
        case .dash:
            return (0...600).map { round(Double($0) / Double(1/0.05) * 100) / 100 }
        }
    }
    
    // TODO: don't hard-code these values
    private var maximumBasalScheduleEntryCount: Int {
        switch prescription.pump {
        case .dash:
            return 24
        }
    }
    
    // TODO: don't hard-code these values
    private var syncBasalRateSchedule: Int {
        switch prescription.pump {
        case .dash:
            return 24
        }
    }
}
