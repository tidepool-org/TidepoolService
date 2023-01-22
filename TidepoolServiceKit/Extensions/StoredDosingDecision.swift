//
//  StoredDosingDecision.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 10/4/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import HealthKit
import LoopKit
import TidepoolKit

/*
 StoredDosingDecision

 Properties:
 - date                            Date                                 .time
 - controllerTimeZone              TimeInterval                         .timeZone, .timeZoneOffset
 - reason                          String                               TDosingDecisionDatum.reason
 - settings                        Settings?                            TDosingDecisionDatum.associations
 - scheduleOverride                TemporaryScheduleOverride?           (unused, included in glucoseTargetRangeSchedule)
 - controllerStatus                ControllerStatus?                    TControllerStatusDatum.battery
 - pumpManagerStatus               PumpManagerStatus?                   TPumpStatusDatum[.basalDelivery, .battery, .bolusDelivery, deliveryIndeterminant]
 - cgmManagerStatus                CGMManagerStatus?                    TODO: https://tidepool.atlassian.net/browse/LOOP-3929
 - lastReservoirValue              LastReservoirValue?                  TPumpStatusDatum.reservoir
 - originalCarbEntry               StoredCarbEntry?                     TDosingDecisionDatum.originalFood (partial), TDosingDecisionDatum.associations
 - carbEntry                       StoredCarbEntry?                     TDosingDecisionDatum.food (partial), TDosingDecisionDatum.associations
 - manualGlucoseSample             StoredGlucoseSample?                 TDosingDecisionDatum.selfMonitoredBloodGlucose (partial), TDosingDecisionDatum.associations
 - carbsOnBoard                    CarbValue?                           TDosingDecisionDatum.carbohydratesOnBoard
 - insulinOnBoard                  InsulinValue?                        TDosingDecisionDatum.insulinOnBoard
 - glucoseTargetRangeSchedule      GlucoseRangeSchedule?                TDosingDecisionDatum.glucoseTargetRangeSchedule
 - predictedGlucose                [PredictedGlucoseValue]?             TDosingDecisionDatum.bloodGlucoseForecast
 - automaticDoseRecommendation     AutomaticDoseRecommendation?         TDosingDecisionDatum.recommendedBasal, TDosingDecisionDatum.recommendedBolus
 - manualBolusRecommendation       ManualBolusRecommendationWithDate?   TDosingDecisionDatum.recommendedBolus
 - manualBolusRequested            Double?                              TDosingDecisionDatum.requestedBolus
 - warnings                        [Issue]                              TDosingDecisionDatum.warnings
 - errors                          [Issue]                              TDosingDecisionDatum.errors
 - syncIdentifier                  UUID                                 .id, .origin, .payload["syncIdentifier"]

 Notes:
 - StoredDosingDecision.carbsOnBoard.endDate is not included as Tidepool backend assumes carbsOnBoard to be point-in-time.
 - StoredDosingDecision.pumpManagerStatus.timeZone is not included as it is irrelevant to TPumpStatusDatum.
 - StoredDosingDecision.manualBolusRecommendation.date is not included as it is assumed to be synonymous with StoredDosingDecision.date.
 - StoredDosingDecision.manualBolusRecommendation.pendingInsulin is not included as it is always zero.
 - StoredDosingDecision.manualBolusRecommendation.notice is not included as it is unneeded by backend.
 */

extension StoredDosingDecision: IdentifiableDatum {
    func datumDosingDecision(for userId: String, hostIdentifier: String, hostVersion: String) -> TDosingDecisionDatum {
        var associations: [TAssociation] = []
        if let id = settings?.datumId(for: userId, type: TPumpSettingsDatum.self) {
            associations.append(TAssociation(type: .datum, id: id, reason: "pumpSettings"))
        }
        if let id = originalCarbEntry?.datumId(for: userId) {
            associations.append(TAssociation(type: .datum, id: id, reason: "originalFood"))
        }
        if let id = carbEntry?.datumId(for: userId) {
            associations.append(TAssociation(type: .datum, id: id, reason: "food"))
        }
        if let id = manualGlucoseSample?.datumId(for: userId) {
            associations.append(TAssociation(type: .datum, id: id, reason: "smbg"))
        }
        let datum = TDosingDecisionDatum(time: datumTime,
                                         reason: datumReason,
                                         originalFood: datumOriginalFood,
                                         food: datumFood,
                                         selfMonitoredBloodGlucose: datumSelfMonitoredBloodGlucose,
                                         carbohydratesOnBoard: datumCarbohydratesOnBoard,
                                         insulinOnBoard: datumInsulinOnBoard,
                                         bloodGlucoseTargetSchedule: datumBloodGlucoseTargetSchedule,
                                         historicalBloodGlucose: datumHistoricalBloodGlucose,
                                         forecastBloodGlucose: datumForecastBloodGlucose,
                                         recommendedBasal: datumRecommendedBasal,
                                         recommendedBolus: datumRecommendedBolus,
                                         requestedBolus: datumRequestedBolus,
                                         warnings: datumWarnings,
                                         errors: datumErrors,
                                         scheduleTimeZoneOffset: datumScheduleTimeZoneOffset,
                                         units: datumUnits)
        let origin = datumOrigin(for: resolvedIdentifier(for: TDosingDecisionDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        return datum.adornWith(id: datumId(for: userId, type: TDosingDecisionDatum.self),
                               timeZone: datumTimeZone,
                               timeZoneOffset: datumTimeZoneOffset,
                               associations: associations,
                               payload: datumPayload,
                               origin: origin)
    }

    func datumControllerStatus(for userId: String, hostIdentifier: String, hostVersion: String) -> TControllerStatusDatum {
        let datum = TControllerStatusDatum(time: datumTime,
                                           battery: datumControllerBattery)
        let origin = datumOrigin(for: resolvedIdentifier(for: TControllerStatusDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        return datum.adornWith(id: datumId(for: userId, type: TControllerStatusDatum.self),
                               timeZone: datumTimeZone,
                               timeZoneOffset: datumTimeZoneOffset,
                               payload: datumPayload,
                               origin: origin)
    }

    func datumPumpStatus(for userId: String, hostIdentifier: String, hostVersion: String) -> TPumpStatusDatum {
        let datum = TPumpStatusDatum(time: datumTime,
                                     basalDelivery: datumBasalDelivery,
                                     battery: datumPumpBattery,
                                     bolusDelivery: datumBolusDelivery,
                                     deliveryIndeterminant: datumDeliveryIndeterminant,
                                     reservoir: datumReservoir)
        let origin = datumOrigin(for: resolvedIdentifier(for: TPumpStatusDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        return datum.adornWith(id: datumId(for: userId, type: TPumpStatusDatum.self),
                               timeZone: datumTimeZone,
                               timeZoneOffset: datumTimeZoneOffset,
                               payload: datumPayload,
                               origin: origin)
    }

    var syncIdentifierAsString: String { syncIdentifier.uuidString }

    private var datumTime: Date { date }

    private var datumTimeZone: TimeZone { controllerTimeZone }

    private var datumTimeZoneOffset: TimeInterval { TimeInterval(controllerTimeZone.secondsFromGMT(for: date)) }

    private var datumReason: String { reason }

    private var datumOriginalFood: TDosingDecisionDatum.Food? {
        guard let originalCarbEntry = originalCarbEntry else {
            return nil
        }
        let carbohydrate = TDosingDecisionDatum.Nutrition.Carbohydrate(net: originalCarbEntry.quantity.doubleValue(for: .gram()), units: .grams)
        let nutrition = TDosingDecisionDatum.Nutrition(carbohydrate: carbohydrate, estimatedAbsorptionDuration: originalCarbEntry.absorptionTime)
        return TDosingDecisionDatum.Food(time: originalCarbEntry.startDate, nutrition: nutrition)
    }

    private var datumFood: TDosingDecisionDatum.Food? {
        guard let carbEntry = carbEntry else {
            return nil
        }
        let carbohydrate = TDosingDecisionDatum.Nutrition.Carbohydrate(net: carbEntry.quantity.doubleValue(for: .gram()), units: .grams)
        let nutrition = TDosingDecisionDatum.Nutrition(carbohydrate: carbohydrate, estimatedAbsorptionDuration: carbEntry.absorptionTime)
        return TDosingDecisionDatum.Food(time: carbEntry.startDate, nutrition: nutrition)
    }

    private var datumSelfMonitoredBloodGlucose: TDosingDecisionDatum.BloodGlucose? {
        guard let manualGlucoseSample = manualGlucoseSample else {
            return nil
        }
        return TDosingDecisionDatum.BloodGlucose(time: manualGlucoseSample.startDate,
                                                 value: manualGlucoseSample.quantity.doubleValue(for: .milligramsPerDeciliter))
    }

    private var datumCarbohydratesOnBoard: TDosingDecisionDatum.CarbohydratesOnBoard? {
        guard let carbsOnBoard = carbsOnBoard else {
            return nil
        }
        return TDosingDecisionDatum.CarbohydratesOnBoard(time: carbsOnBoard.startDate, amount: carbsOnBoard.quantity.doubleValue(for: .gram()).rounded(decimalPlaces: 4))
    }

    private var datumInsulinOnBoard: TDosingDecisionDatum.InsulinOnBoard? {
        guard let insulinOnBoard = insulinOnBoard else {
            return nil
        }
        return TDosingDecisionDatum.InsulinOnBoard(time: insulinOnBoard.startDate, amount: insulinOnBoard.value.rounded(decimalPlaces: 4))
    }

    private var datumBloodGlucoseTargetSchedule: [TDosingDecisionDatum.BloodGlucoseStartTarget]? {
        guard let glucoseTargetRangeSchedule = glucoseTargetRangeSchedule else {
            return nil
        }
        return glucoseTargetRangeSchedule.items(for: .milligramsPerDeciliter).map { TDosingDecisionDatum.BloodGlucoseStartTarget(start: $0.startTime, low: $0.value.minValue, high: $0.value.maxValue) }
    }

    private var datumHistoricalBloodGlucose: [TDosingDecisionDatum.BloodGlucose]? {
        guard let historicalGlucose = historicalGlucose, !historicalGlucose.isEmpty else {
            return nil
        }
        return historicalGlucose.map { TDosingDecisionDatum.BloodGlucose(time: $0.startDate, value: $0.quantity.doubleValue(for: .milligramsPerDeciliter)) }
    }

    private var datumForecastBloodGlucose: [TDosingDecisionDatum.BloodGlucose]? {
        guard let predictedGlucose = predictedGlucose?.dropLast(), !predictedGlucose.isEmpty else {
            return nil
        }

        // Clamped blood glucose values are from 0-1000 mg/dL
        return predictedGlucose.map { TDosingDecisionDatum.BloodGlucose(time: $0.startDate, value: $0.quantity.doubleValueClampedAndRounded(for: .milligramsPerDeciliter)) }
    }

    private var datumRecommendedBasal: TDosingDecisionDatum.RecommendedBasal? {
        guard let basalAdjustment = automaticDoseRecommendation?.basalAdjustment else {
            return nil
        }
        return TDosingDecisionDatum.RecommendedBasal(rate: basalAdjustment.unitsPerHour, duration: basalAdjustment.duration)
    }

    private var datumRecommendedBolus: TDosingDecisionDatum.RecommendedBolus? {
        guard let amount = automaticDoseRecommendation?.bolusUnits ?? manualBolusRecommendation?.recommendation.amount else {
            return nil
        }
        return TDosingDecisionDatum.RecommendedBolus(amount: amount)
    }

    public var datumRequestedBolus: TDosingDecisionDatum.RequestedBolus? {
        guard let manualBolusRequested = manualBolusRequested else {
            return nil
        }
        return TDosingDecisionDatum.RequestedBolus(amount: manualBolusRequested)
    }

    private var datumWarnings: [TDosingDecisionDatum.Issue]? {
        guard !warnings.isEmpty else {
            return nil
        }
        return warnings.map { TDosingDecisionDatum.Issue(id: $0.id, metadata: $0.details.map { TDictionary($0) }) }
    }

    private var datumErrors: [TDosingDecisionDatum.Issue]? {
        guard !errors.isEmpty else {
            return nil
        }
        return errors.map { TDosingDecisionDatum.Issue(id: $0.id, metadata: $0.details.map { TDictionary($0) }) }
    }

    private var datumScheduleTimeZoneOffset: TimeInterval? {
        guard let scheduleTimeZone = glucoseTargetRangeSchedule?.timeZone,
              scheduleTimeZone.secondsFromGMT(for: date) != controllerTimeZone.secondsFromGMT(for: date)
        else {
            return nil
        }
        return TimeInterval(seconds: scheduleTimeZone.secondsFromGMT(for: date))
    }

    private var datumUnits: TDosingDecisionDatum.Units {
        return TDosingDecisionDatum.Units(bloodGlucose: .milligramsPerDeciliter, carbohydrate: .grams, insulin: .units)
    }

    private var datumControllerBattery: TControllerStatusDatum.Battery? {
        guard let controllerStatus = controllerStatus, controllerStatus.batteryState != nil || controllerStatus.batteryLevel != nil else {
            return nil
        }
        return TControllerStatusDatum.Battery(state: controllerStatus.batteryState?.datum,
                                              remaining: controllerStatus.batteryLevel.map { Double($0) },
                                              units: controllerStatus.batteryLevel.map { _ in .percent })
    }

    private var datumBasalDelivery: TPumpStatusDatum.BasalDelivery? {
        return pumpManagerStatus?.basalDeliveryState?.datum
    }

    private var datumPumpBattery: TPumpStatusDatum.Battery? {
        guard let pumpBatteryChargeRemaining = pumpManagerStatus?.pumpBatteryChargeRemaining else {
            return nil
        }
        return TPumpStatusDatum.Battery(remaining: min(max(pumpBatteryChargeRemaining, 0), 1), units: .percent)
    }

    private var datumBolusDelivery: TPumpStatusDatum.BolusDelivery? {
        return pumpManagerStatus?.bolusState.datum
    }

    private var datumDeliveryIndeterminant: Bool? {
        guard let deliveryIsUncertain = pumpManagerStatus?.deliveryIsUncertain, deliveryIsUncertain else {
            return nil
        }
        return deliveryIsUncertain
    }

    private var datumReservoir: TPumpStatusDatum.Reservoir? {
        guard let lastReservoirValue = lastReservoirValue else {
            return nil
        }
        return TPumpStatusDatum.Reservoir(time: lastReservoirValue.startDate, remaining: lastReservoirValue.unitVolume)
    }

    private var datumPayload: TDictionary {
        var dictionary = TDictionary()
        dictionary["syncIdentifier"] = syncIdentifier.uuidString
        return dictionary
    }
}

extension StoredDosingDecision.Settings: IdentifiableDatum {
    var syncIdentifierAsString: String { syncIdentifier.uuidString }
}

fileprivate extension StoredDosingDecision.ControllerStatus.BatteryState {
    var datum: TControllerStatusDatum.Battery.State? {
        switch self {
        case .unknown:
            return nil
        case .unplugged:
            return .unplugged
        case .charging:
            return .charging
        case .full:
            return .full
        }
    }
}

fileprivate extension PumpManagerStatus.BasalDeliveryState {
    var datum: TPumpStatusDatum.BasalDelivery {
        switch self {
        case .active(let at):
            return TPumpStatusDatum.BasalDelivery(state: .scheduled, time: at)
        case .initiatingTempBasal:
            return TPumpStatusDatum.BasalDelivery(state: .initiatingTemporary)
        case .tempBasal(let dose):
            return TPumpStatusDatum.BasalDelivery(state: .temporary, dose: dose.temporaryBasalDatum)
        case .cancelingTempBasal:
            return TPumpStatusDatum.BasalDelivery(state: .cancelingTemporary)
        case .suspending:
            return TPumpStatusDatum.BasalDelivery(state: .suspending)
        case .suspended(let at):
            return TPumpStatusDatum.BasalDelivery(state: .suspended, time: at)
        case .resuming:
            return TPumpStatusDatum.BasalDelivery(state: .resuming)
        }
    }
}

fileprivate extension PumpManagerStatus.BolusState {
    var datum: TPumpStatusDatum.BolusDelivery {
        switch self {
        case .noBolus:
            return TPumpStatusDatum.BolusDelivery(state: .none)
        case .initiating:
            return TPumpStatusDatum.BolusDelivery(state: .initiating)
        case .inProgress(let dose):
            return TPumpStatusDatum.BolusDelivery(state: .delivering, dose: dose.bolusDatum)
        case .canceling:
            return TPumpStatusDatum.BolusDelivery(state: .canceling)
        }
    }
}

fileprivate extension DoseEntry {
    var temporaryBasalDatum: TPumpStatusDatum.BasalDelivery.Dose {
        return TPumpStatusDatum.BasalDelivery.Dose(startTime: startDate, endTime: endDate, rate: unitsPerHour, amountDelivered: deliveredUnits)
    }

    var bolusDatum: TPumpStatusDatum.BolusDelivery.Dose {
        return TPumpStatusDatum.BolusDelivery.Dose(startTime: startDate, amount: programmedUnits, amountDelivered: deliveredUnits)
    }
}

fileprivate extension HKQuantity {
    func doubleValueClampedAndRounded(for unit: HKUnit) -> Double {
        let value = doubleValue(for: unit)
        switch unit {
        case .milligramsPerDeciliter:
            return TBloodGlucose.clamp(value: value.rounded(), for: .milligramsPerDeciliter)
        case .millimolesPerLiter:
            return TBloodGlucose.clamp(value: value.rounded(decimalPlaces: 2), for: .millimolesPerLiter)
        default:
            return value
        }
    }
}

fileprivate extension Double {
    func rounded(decimalPlaces: Int) -> Double {
        let factor = pow(10, Double(decimalPlaces))
        return (self * factor).rounded() / factor
    }
}

extension TDosingDecisionDatum: TypedDatum {
    static var resolvedType: String { TDatum.DatumType.dosingDecision.rawValue }
}

extension TControllerStatusDatum: TypedDatum {
    static var resolvedType: String { TDatum.DatumType.controllerStatus.rawValue }
}

extension TPumpStatusDatum: TypedDatum {
    static var resolvedType: String { TDatum.DatumType.pumpStatus.rawValue }
}
