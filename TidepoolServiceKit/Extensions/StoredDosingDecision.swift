//
//  StoredDosingDecision.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/2/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

extension StoredDosingDecision {
    var datum: TDatum {
        return TDosingDecisionDatum(time: datumTime,
                                    insulinOnBoard: datumInsulinOnBoard,
                                    carbohydratesOnBoard: datumCarbohydratesOnBoard,
                                    bloodGlucoseTargetSchedule: datumBloodGlucoseTargetSchedule,
                                    bloodGlucoseForecast: datumBloodGlucoseForecast,
                                    recommendedBasal: datumRecommendedBasal,
                                    recommendedBolus: datumRecommendedBolus,
                                    units: datumUnits).adorn(withOrigin: datumOrigin)
    }

    private var datumTime: Date { date }

    private var datumInsulinOnBoard: TDosingDecisionDatum.InsulinOnBoard? {
        guard let insulinOnBoard = insulinOnBoard else {
            return nil
        }
        return TDosingDecisionDatum.InsulinOnBoard(startTime: insulinOnBoard.startDate, amount: insulinOnBoard.value)
    }

    private var datumCarbohydratesOnBoard: TDosingDecisionDatum.CarbohydratesOnBoard? {
        guard let carbsOnBoard = carbsOnBoard else {
            return nil
        }
        return TDosingDecisionDatum.CarbohydratesOnBoard(startTime: carbsOnBoard.startDate, endTime: carbsOnBoard.endDate, amount: carbsOnBoard.quantity.doubleValue(for: .gram()))
    }

    private var datumBloodGlucoseTargetSchedule: [TDosingDecisionDatum.BloodGlucoseStartTarget]? {
        guard let glucoseTargetRangeSchedule = glucoseTargetRangeSchedule else {
            return nil
        }
        return glucoseTargetRangeSchedule.items(for: .milligramsPerDeciliter).map { TDosingDecisionDatum.BloodGlucoseStartTarget(start: Int($0.startTime.milliseconds), low: $0.value.minValue, high: $0.value.maxValue) }
    }

    private var datumBloodGlucoseForecast: TDosingDecisionDatum.BloodGlucoseForecast? {
        guard let startDate = predictedGlucose?.first?.startDate ?? predictedGlucoseIncludingPendingInsulin?.first?.startDate else {
            return nil
        }

        return TDosingDecisionDatum.BloodGlucoseForecast(startTime: startDate,
                                                         timeOffset: 300,
                                                         net: predictedGlucose?.map { $0.quantity.doubleValue(for: .milligramsPerDeciliter) },
                                                         netIncludingPendingInsulin: predictedGlucoseIncludingPendingInsulin?.map { $0.quantity.doubleValue(for: .milligramsPerDeciliter) })
    }

    private var datumRecommendedBasal: TDosingDecisionDatum.RecommendedBasal? {
        guard let recommendedTempBasal = recommendedTempBasal else {
            return nil
        }
        return TDosingDecisionDatum.RecommendedBasal(time: recommendedTempBasal.date, rate: recommendedTempBasal.recommendation.unitsPerHour, duration: Int(recommendedTempBasal.recommendation.duration))
    }

    private var datumRecommendedBolus: TDosingDecisionDatum.RecommendedBolus? {
        guard let recommendedBolus = recommendedBolus else {
            return nil
        }
        return TDosingDecisionDatum.RecommendedBolus(time: recommendedBolus.date, amount: recommendedBolus.recommendation.amount)
    }

    private var datumUnits: TDosingDecisionDatum.Units {
        return TDosingDecisionDatum.Units(bloodGlucose: .milligramsPerDeciliter, carbohydrate: .grams, insulin: .units)
    }

    private var datumOrigin: TOrigin {
        return TOrigin(id: syncIdentifier)
    }
}
