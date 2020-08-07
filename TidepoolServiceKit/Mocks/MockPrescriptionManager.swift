//
//  MockPrescriptionManager.swift
//  TidepoolServiceKit
//
//  Created by Anna Quinlan on 6/18/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation
import LoopKit

public class MockPrescriptionManager {
    private var prescription: MockPrescription
    
    public init(prescription: MockPrescription? = nil) {
        if let prescription = prescription {
            self.prescription = prescription
        } else {
            let timeZone = TimeZone(identifier: "America/Los_Angeles")!
            let glucoseTargetRangeSchedule =  GlucoseRangeSchedule(
                rangeSchedule: DailyQuantitySchedule(unit: .milligramsPerDeciliter,
                    dailyItems: [RepeatingScheduleValue(startTime: .hours(0), value: DoubleRange(minValue: 100.0, maxValue: 110.0)),
                                 RepeatingScheduleValue(startTime: .hours(8), value: DoubleRange(minValue: 90.0, maxValue: 100.0)),
                                 RepeatingScheduleValue(startTime: .hours(21), value: DoubleRange(minValue: 100.0, maxValue: 110.0))],
                    timeZone: timeZone)!,
                override: GlucoseRangeSchedule.Override(value: DoubleRange(minValue: 80.0, maxValue: 90.0),
                                                        start: Date().addingTimeInterval(.minutes(-30)),
                                                        end: Date().addingTimeInterval(.minutes(30)))
            )
            let basalRateSchedule = BasalRateSchedule(
                dailyItems: [RepeatingScheduleValue(startTime: .hours(0), value: 1),
                             RepeatingScheduleValue(startTime: .hours(15), value: 0.85)],
                timeZone: timeZone)!
            let insulinSensitivitySchedule = InsulinSensitivitySchedule(
                unit: .milligramsPerDeciliter,
                dailyItems: [RepeatingScheduleValue(startTime: .hours(0), value: 45.0),
                             RepeatingScheduleValue(startTime: .hours(9), value: 55.0)],
                timeZone: timeZone)!
            let carbRatioSchedule = CarbRatioSchedule(
                unit: .gram(),
                                                      
                dailyItems: [RepeatingScheduleValue(startTime: .hours(0), value: 10.0)],
                timeZone: timeZone)!
            
            let therapySettings = TherapySettings(
                glucoseTargetRangeSchedule: glucoseTargetRangeSchedule,
                preMealTargetRange: DoubleRange(minValue: 80.0, maxValue: 90.0),
                workoutTargetRange: DoubleRange(minValue: 140.0, maxValue: 160.0),
                maximumBasalRatePerHour: 5,
                maximumBolus: 10,
                suspendThreshold: GlucoseThreshold(unit: .milligramsPerDeciliter, value: 75),
                insulinSensitivitySchedule: insulinSensitivitySchedule,
                carbRatioSchedule: carbRatioSchedule,
                basalRateSchedule: basalRateSchedule,
                insulinModelSettings: InsulinModelSettings(model: ExponentialInsulinModelPreset.humalogNovologAdult)
            )
            
            self.prescription = MockPrescription(
                datePrescribed: Date(),
                providerName: "Sally Seastar",
                cgmType: CGMType.g6,
                pumpType: PumpType.dash,
                bloodGlucoseUnit: .mgdl,
                therapySettings: therapySettings
            )
        }
    }
    
    public func getPrescriptionData(completion: @escaping (Result<MockPrescription, Error>) -> Void) {
        completion(.success(self.prescription))
    }
}
