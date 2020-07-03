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
        BasalRateScheduleEditor(
            buttonText: buttonText,
            schedule: prescription.basalRateSchedule,
            supportedBasalRates: supportedBasalRates,
            maximumBasalRate: prescription.maximumBasalRatePerHour,
            maximumScheduleEntryCount: maximumBasalScheduleEntryCount,
            syncSchedule: { result, error  in
                // Since pump isn't set up, this syncing shouldn't do anything
            },
            onSave: { newSchedule in
                // ANNA TODO: think about how to best save the schedule
                self.viewModel.didFinishStep()
            },
            mode: .flow
        )
    }
    
    private var supportedBasalRates: [Double] {
        switch prescription.pump {
        case .dash:
            // ANNA TODO: make this (1, 600) once guardrail bug is resolved
            return (0...600).map { round(Double($0) / Double(1/0.05) * 100) / 100 }
        }
    }
    
    private var maximumBasalScheduleEntryCount: Int {
        switch prescription.pump {
        case .dash:
            return 24
        }
    }
    
    private var syncBasalRateSchedule: Int {
        switch prescription.pump {
        case .dash:
            return 24
        }
    }
    
    private var buttonText: Text {
        return !userHasEdited ? Text(LocalizedString("Accept Setting", comment: "The button text for accepting the prescribed setting")) : Text(LocalizedString("Save Setting", comment: "The button text for saving the edited setting"))
    }
}
