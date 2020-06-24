//
//  MockPrescriptionManager.swift
//  TidepoolServiceKit
//
//  Created by Anna Quinlan on 6/18/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import Foundation
import LoopKit


extension TimeInterval {
    static func minutes(_ minutes: Double) -> TimeInterval {
        return TimeInterval(minutes * 60 /* seconds in minute */)
    }

    static func hours(_ hours: Double) -> TimeInterval {
        return TimeInterval(hours * 60 /* minutes in hr */ * 60 /* seconds in minute */)
    }
}

public class MockPrescriptionManager {
    private var prescription: Prescription
    
    public init(prescription: Prescription? = nil) {
        if let prescription = prescription {
            self.prescription = prescription
        } else {
            let timeZone = TimeZone(identifier: "America/Los_Angeles")!
            let glucoseTargetRangeSchedule =  GlucoseRangeSchedule(
                rangeSchedule: DailyQuantitySchedule(unit: .milligramsPerDeciliter,
                    dailyItems: [RepeatingScheduleValue(startTime: .hours(0), value: DoubleRange(minValue: 100.0, maxValue: 110.0)), RepeatingScheduleValue(startTime: .hours(8), value: DoubleRange(minValue: 95.0, maxValue: 105.0)), RepeatingScheduleValue(startTime: .hours(14), value: DoubleRange(minValue: 95.0, maxValue: 105.0)), RepeatingScheduleValue(startTime: .hours(16), value: DoubleRange(minValue: 100.0, maxValue: 110.0)), RepeatingScheduleValue(startTime: .hours(18), value: DoubleRange(minValue: 90.0, maxValue: 100.0)), RepeatingScheduleValue(startTime: .hours(21), value: DoubleRange(minValue: 110.0, maxValue: 120.0))],
                    timeZone: timeZone)!,
                override: GlucoseRangeSchedule.Override(value: DoubleRange(minValue: 80.0, maxValue: 90.0),
                                                        start: Date().addingTimeInterval(-.minutes(30)),
                                                        end: Date().addingTimeInterval(.minutes(30)))
            )
            let basalRateSchedule = BasalRateSchedule(
                dailyItems: [RepeatingScheduleValue(startTime: .hours(0), value: 1.0),
                             RepeatingScheduleValue(startTime: .hours(8), value: 1.125),
                             RepeatingScheduleValue(startTime: .hours(10), value: 1.25),
                             RepeatingScheduleValue(startTime: .hours(12), value: 1.5),
                             RepeatingScheduleValue(startTime: .hours(14), value: 1.25),
                             RepeatingScheduleValue(startTime: .hours(16), value: 1.5),
                             RepeatingScheduleValue(startTime: .hours(18), value: 1.25),
                             RepeatingScheduleValue(startTime: .hours(21), value: 1.0)],
                timeZone: timeZone)!
            let insulinSensitivitySchedule = InsulinSensitivitySchedule(
                unit: .milligramsPerDeciliter,
                dailyItems: [RepeatingScheduleValue(startTime: .hours(0), value: 45.0),
                             RepeatingScheduleValue(startTime: .hours(8), value: 40.0),
                             RepeatingScheduleValue(startTime: .hours(10), value: 35.0),
                             RepeatingScheduleValue(startTime: .hours(12), value: 30.0),
                             RepeatingScheduleValue(startTime: .hours(14), value: 35.0),
                             RepeatingScheduleValue(startTime: .hours(16), value: 40.0)],
                timeZone: timeZone)!
            let carbRatioSchedule = CarbRatioSchedule(
                unit: .gram(),
                                                      
                dailyItems: [RepeatingScheduleValue(startTime: .hours(0), value: 10.0),
                             RepeatingScheduleValue(startTime: .hours(8), value: 12.0),
                             RepeatingScheduleValue(startTime: .hours(10), value: 9.0),
                             RepeatingScheduleValue(startTime: .hours(12), value: 10.0),
                             RepeatingScheduleValue(startTime: .hours(14), value: 11.0),
                             RepeatingScheduleValue(startTime: .hours(16), value: 12.0),
                             RepeatingScheduleValue(startTime: .hours(18), value: 8.0),
                             RepeatingScheduleValue(startTime: .hours(21), value: 10.0)],
                timeZone: timeZone)!
            
            
            
            self.prescription = Prescription(
                datePrescribed: Date(),
                providerName: "Sally Seastar",
                cgmType: CGMType.g6,
                pumpType: PumpType.dash,
                bloodGlucoseUnit: .milligramsPerDeciliter,
                basalRateSchedule: basalRateSchedule,
                glucoseTargetRangeSchedule: glucoseTargetRangeSchedule,
                carbRatioSchedule: carbRatioSchedule,
                insulinSensitivitySchedule: insulinSensitivitySchedule,
                maximumBasalRatePerHour: 3.0,
                maximumBolus: 5.0,
                suspendThreshold: GlucoseThreshold(unit: .milligramsPerDeciliter, value: 70),
                insulinModel: Prescription.InsulinModel(modelType: .rapidAdult, actionDuration: .hours(6), peakActivity: .hours(3)))
        }
    }
    
    public func getPrescriptionData(completion: @escaping (Result<Prescription, Error>) -> Void) {
        completion(.success(self.prescription))
    }
}