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
    @ObservedObject var viewModel: TherapySettingsViewModel
    let pumpType: PumpType
    
    init(model: TherapySettingsViewModel, pump: PumpType){
        self.viewModel = model
        self.pumpType = pump
    }
    
    var body: some View {
        DeliveryLimitsEditor(
            value: DeliveryLimits(maximumBasalRate: maxBasal, maximumBolus: maxBolus),
            supportedBasalRates: supportedBasalRates,
            scheduledBasalRange: viewModel.therapySettings.basalRateSchedule?.valueRange(),
            supportedBolusVolumes: supportedBolusVolumes,
            onSave: { limits in
                self.viewModel.saveDeliveryLimits(limits: limits)
                self.viewModel.didFinishStep?()
            },
            mode: .flow
        )
    }

    private var maxBasal: HKQuantity {
        return HKQuantity(unit: .unitsPerHour, doubleValue: viewModel.therapySettings.maximumBasalRatePerHour!)
    }
    
    private var maxBolus: HKQuantity {
        return HKQuantity(unit: .internationalUnit(), doubleValue: viewModel.therapySettings.maximumBolus!)
    }
    
    private var supportedBasalRates: [Double] {
        switch pumpType {
        case .dash:
            // TODO: don't hard-code this value
            return (0...600).map { Double($0) / Double(1/0.05) }
        }
    }
    
    private var supportedBolusVolumes: [Double] {
        switch pumpType {
        case .dash:
            // TODO: don't hard-code this value
            return (0...600).map { Double($0) / Double(1/0.05) }
        }
    }
}
