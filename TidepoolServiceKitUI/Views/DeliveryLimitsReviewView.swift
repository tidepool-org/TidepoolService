//
//  DeliveryLimitsReviewView.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 7/6/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKitUI
import LoopKit
import HealthKit
import TidepoolServiceKit


struct DeliveryLimitsReviewView: View {
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
        DeliveryLimitsEditor(
            buttonText: buttonText,
            value: DeliveryLimits(maximumBasalRate: maxBasal, maximumBolus: maxBolus),
            supportedBasalRates: supportedBasalRates,
            scheduledBasalRange: prescription.basalRateSchedule.valueRange(),
            supportedBolusVolumes: supportedBolusVolumes,
            onSave: { limits in
                self.viewModel.saveDeliveryLimits(limits: limits)
                self.viewModel.didFinishStep()
            },
            mode: .flow,
            userHasEdited: $userHasEdited
        )
    }
    
    private var maxBasal: HKQuantity {
        return HKQuantity(unit: HKUnit.internationalUnit().unitDivided(by: .hour()), doubleValue: prescription.maximumBasalRatePerHour)
    }
    
    private var maxBolus: HKQuantity {
        return HKQuantity(unit: .internationalUnit(), doubleValue: prescription.maximumBolus)
    }
    
    private var supportedBasalRates: [Double] {
        switch prescription.pump {
        case .dash:
            // ANNA TODO: make this (1, 600) once guardrail bug is resolved
            return (0...600).map { round(Double($0) / Double(1/0.05)) }
        }
    }
    
    private var supportedBolusVolumes: [Double] {
        switch prescription.pump {
        case .dash:
            // ANNA TODO: make this (1, 600) once guardrail bug is resolved
            return (0...600).map { round(Double($0) / Double(1/0.05)) }
        }
    }
    
    private var buttonText: Text {
        return !userHasEdited ? Text(LocalizedString("Accept Setting", comment: "The button text for accepting the prescribed setting")) : Text(LocalizedString("Save Setting", comment: "The button text for saving the edited setting"))
    }
}
