//
//  DoseEntry.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 2/7/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit
import LoopAlgorithm
import HealthKit

/*
 DoseEntry

 Properties:
 - type                         DoseType                    .type, .deliveryType, .subType
 - startDate                    Date                        .time, .duration
 - endDate                      Date                        .duration
 - value                        Double                      .dose.total, .normal, .expectedNormal, .rate, .payload["deliveredUnits"]
 - unit                         DoseUnit                    .dose.total, .normal, .expectedNormal, .rate, .payload["deliveredUnits"]
 - deliveredUnits               Double?                     .dose.total, .normal, .expectedNormal, .payload["deliveredUnits"]
 - description                  String?                     (N/A - unused)
 - insulinType                  InsulinType?                .formulation, .insulinFormulation
 - automatic                    Bool?                       .type, .deliveryType, .subType
 - manuallyEntered              Bool                        .type, .subType
 - syncIdentifier               String?                     .id, .origin.id, .payload["syncIdentifier"]
 - scheduledBasalRate           HKQuantity?                 .rate, .supressed.rate
 - isMutable                    Bool                        .normal, .expectedNormal, .duration, .expectedDuration, .annotations
*/

extension DoseEntry: IdentifiableDatum {
    func data(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        guard syncIdentifier != nil else {
            return []
        }

        switch type {
        case .basal:
            return dataForBasal(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        case .bolus:
            return dataForBolus(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        case .resume:
            return []
        case .suspend:
            return dataForSuspend(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        case .tempBasal:
            return dataForTempBasal(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        }
    }

    var syncIdentifierAsString: String { syncIdentifier!.md5hash! }  // Actual sync identifier may be human readable and of variable length

    private func dataForBasal(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        if automatic != true {
            return dataForBasalManual(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        } else {
            return dataForBasalAutomatic(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        }
    }

    private func dataForBasalManual(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {

        var payload = datumPayload
        payload["deliveredUnits"] = datumBasalDeliveredUnits

        var datum = TScheduledBasalDatum(time: datumTime,
                                         duration: datumDuration,
                                         rate: datumScheduledBasalRate,
                                         scheduleName: StoredSettings.activeScheduleNameDefault,
                                         insulinFormulation: datumInsulinFormulation)

        let origin = datumOrigin(for: resolvedIdentifier(for: TScheduledBasalDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        datum = datum.adornWith(id: datumId(for: userId, type: TScheduledBasalDatum.self),
                                annotations: datumAnnotations,
                                payload: payload,
                                origin: origin)
        return [datum]
    }

    private func dataForBasalAutomatic(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        var payload = datumPayload
        payload["deliveredUnits"] = datumBasalDeliveredUnits

        var datum = TAutomatedBasalDatum(time: datumTime,
                                         duration: datumDuration,
                                         expectedDuration: nil,
                                         rate: datumScheduledBasalRate,
                                         scheduleName: StoredSettings.activeScheduleNameDefault,
                                         insulinFormulation: datumInsulinFormulation)
        let origin = datumOrigin(for: resolvedIdentifier(for: TAutomatedBasalDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        datum = datum.adornWith(id: datumId(for: userId, type: TAutomatedBasalDatum.self),
                                annotations: datumAnnotations,
                                payload: payload,
                                origin: origin)
        return [datum]
    }

    private func dataForBolus(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        if manuallyEntered {
            return dataForBolusManuallyEntered(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)

            
        } else if automatic != true {
            return dataForBolusManual(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        }  else {
            return dataForBolusAutomatic(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        }
    }

    private func dataForBolusManuallyEntered(for userId: String, hostIdentifier: String, hostVersion: String) ->[TDatum] {
        var payload = datumPayload
        payload["duration"] = datumDuration.milliseconds

        var datum = TInsulinDatum(time: datumTime,
                                  dose: TInsulinDatum.Dose(total: deliveredUnits ?? programmedUnits),
                                  formulation: datumInsulinFormulation)

        let origin = datumOrigin(for: resolvedIdentifier(for: TInsulinDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        datum = datum.adornWith(id: datumId(for: userId, type: TInsulinDatum.self),
                                annotations: datumAnnotations,
                                payload: payload,
                                origin: origin)
        return [datum]
    }

    private func dataForBolusManual(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        var payload = datumPayload
        payload["duration"] = datumDuration.milliseconds

        let programmedUnits = programmedUnits
        let deliveredUnits = deliveredUnits ?? programmedUnits

        var datum = TNormalBolusDatum(time: datumTime,
                                      normal: !isMutable ? deliveredUnits : programmedUnits,
                                      expectedNormal: !isMutable && programmedUnits != deliveredUnits ? programmedUnits : nil,
                                      insulinFormulation: datumInsulinFormulation)
        let origin = datumOrigin(for: resolvedIdentifier(for: TNormalBolusDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        datum = datum.adornWith(id: datumId(for: userId, type: TNormalBolusDatum.self),
                                annotations: datumAnnotations,
                                payload: payload,
                                origin: origin)
        return [datum]
    }

    private func dataForBolusAutomatic(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        var payload = datumPayload
        payload["duration"] = datumDuration.milliseconds

        let programmedUnits = programmedUnits
        let deliveredUnits = deliveredUnits ?? programmedUnits

        var datum = TAutomatedBolusDatum(time: datumTime,
                                         normal: !isMutable ? deliveredUnits : programmedUnits,
                                         expectedNormal: !isMutable && programmedUnits != deliveredUnits ? programmedUnits : nil,
                                         insulinFormulation: datumInsulinFormulation)
        let origin = datumOrigin(for: resolvedIdentifier(for: TAutomatedBolusDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        datum = datum.adornWith(id: datumId(for: userId, type: TAutomatedBolusDatum.self),
                                annotations: datumAnnotations,
                                payload: payload,
                                origin: origin)
        return [datum]
    }

    private func dataForSuspend(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        var datum = TSuspendedBasalDatum(time: datumTime,
                                         duration: datumDuration)
        datum.suppressed = datumSuppressed
        let origin = datumOrigin(for: resolvedIdentifier(for: TSuspendedBasalDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        datum = datum.adornWith(id: datumId(for: userId, type: TSuspendedBasalDatum.self),
                                annotations: datumAnnotations,
                                payload: datumPayload,
                                origin: origin)
        return [datum]
    }

    private func dataForTempBasal(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        if automatic == false {
            return dataForTempBasalManual(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        } else {
            return dataForTempBasalAutomatic(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        }
    }

    private func dataForTempBasalManual(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        var payload = datumPayload
        payload["deliveredUnits"] = deliveredUnits

        var datum = TTemporaryBasalDatum(time: datumTime,
                                         duration: !isMutable ? datumDuration : 0,
                                         expectedDuration: !isMutable && datumDuration < basalDatumExpectedDuration ? basalDatumExpectedDuration : nil,
                                         rate: datumRate,
                                         insulinFormulation: datumInsulinFormulation)
        datum.suppressed = datumSuppressed
        let origin = datumOrigin(for: resolvedIdentifier(for: TTemporaryBasalDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        datum = datum.adornWith(id: datumId(for: userId, type: TTemporaryBasalDatum.self),
                                annotations: datumAnnotations,
                                payload: payload,
                                origin: origin)
        return [datum]
    }

    private func dataForTempBasalAutomatic(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        var payload = datumPayload
        payload["deliveredUnits"] = deliveredUnits

        var datum = TAutomatedBasalDatum(time: datumTime,
                                         duration: datumDuration,
                                         expectedDuration: datumDuration < basalDatumExpectedDuration ? basalDatumExpectedDuration : nil,
                                         rate: datumRate,
                                         scheduleName: StoredSettings.activeScheduleNameDefault,
                                         insulinFormulation: datumInsulinFormulation)
        datum.suppressed = datumSuppressed
        let origin = datumOrigin(for: resolvedIdentifier(for: TAutomatedBasalDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        datum = datum.adornWith(id: datumId(for: userId, type: TAutomatedBasalDatum.self),
                                annotations: datumAnnotations,
                                payload: payload,
                                origin: origin)
        return [datum]
    }

    private var datumTime: Date { startDate }

    private var datumDuration: TimeInterval { startDate.distance(to: endDate) }

    private var datumRate: Double { unitsPerHour }


    private var datumBasalDeliveredUnits: Double? {
        guard type == .basal || type == .tempBasal else {
            return nil
        }

        if let deliveredUnits = deliveredUnits {
            return deliveredUnits
        }

        if unit == .units {
            return programmedUnits
        }

        return nil
    }

    private var datumScheduledBasalRate: Double {

        if let rate = scheduledBasalRate?.doubleValue(for: .internationalUnitsPerHour) {
            return rate
        }

        return unitsPerHour
    }

    private var datumSuppressed: TScheduledBasalDatum.Suppressed? {
        guard type == .tempBasal || type == .suspend else {
            return nil
        }
        return TScheduledBasalDatum.Suppressed(rate: datumScheduledBasalRate,
                                               scheduleName: StoredSettings.activeScheduleNameDefault)
    }

    private var datumInsulinFormulation: TInsulinDatum.Formulation? { insulinType?.datum }

    private var datumAnnotations: [TDictionary]? {
        guard isMutable else {
            return nil
        }

        switch type {
        case .basal, .suspend, .tempBasal:
            return [TDictionary(["code": "basal/unknown-duration"])]
        case .bolus:
            return [TDictionary(["code": "bolus/mutable"])]
        case .resume:
            return nil
        }
    }

    private var datumPayload: TDictionary {
        var dictionary = TDictionary()
        dictionary["syncIdentifier"] = syncIdentifier
        return dictionary
    }

    private var basalDatumExpectedDuration: TimeInterval { .minutes(30) }
}

extension DoseEntry {
    var selectors: [TDatum.Selector] {
        guard syncIdentifier != nil else {
            return []
        }

        switch type {
        case .basal:
            return [datumSelector(for: TScheduledBasalDatum.self)]
        case .bolus:
            if manuallyEntered {
                return [datumSelector(for: TInsulinDatum.self)]
            } else if automatic != true {
                return [datumSelector(for: TNormalBolusDatum.self)]
            } else {
                return [datumSelector(for: TAutomatedBolusDatum.self)]
            }
        case .resume:
            return []
        case .suspend:
            return [datumSelector(for: TSuspendedBasalDatum.self)]
        case .tempBasal:
            if automatic == false {
                return [datumSelector(for: TTemporaryBasalDatum.self)]
            } else {
                return [datumSelector(for: TAutomatedBasalDatum.self)]
            }
        }
    }
}

extension TAutomatedBasalDatum: TypedDatum {
    static var resolvedType: String { "\(TDatum.DatumType.basal.rawValue)/\(TBasalDatum.DeliveryType.automated.rawValue)" }
}

extension TScheduledBasalDatum: TypedDatum {
    static var resolvedType: String { "\(TDatum.DatumType.basal.rawValue)/\(TBasalDatum.DeliveryType.scheduled.rawValue)" }
}

extension TSuspendedBasalDatum: TypedDatum {
    static var resolvedType: String { "\(TDatum.DatumType.basal.rawValue)/\(TBasalDatum.DeliveryType.suspended.rawValue)" }
}

extension TTemporaryBasalDatum: TypedDatum {
    static var resolvedType: String { "\(TDatum.DatumType.basal.rawValue)/\(TBasalDatum.DeliveryType.temporary.rawValue)" }
}

extension TAutomatedBolusDatum: TypedDatum {
    static var resolvedType: String { "\(TDatum.DatumType.bolus.rawValue)/\(TBolusDatum.SubType.automated.rawValue)" }
}

extension TNormalBolusDatum: TypedDatum {
    static var resolvedType: String { "\(TDatum.DatumType.bolus.rawValue)/\(TBolusDatum.SubType.normal.rawValue)" }
}

extension TInsulinDatum: TypedDatum {
    static var resolvedType: String { TDatum.DatumType.insulin.rawValue }
}

extension DoseEntry {

    /// Annotates a dose with the context of a history of scheduled basal rates
    ///
    /// If the dose crosses a schedule boundary, it will be split into multiple doses so each dose has a
    /// single scheduled basal rate.
    ///
    /// - Parameter basalHistory: The history of basal schedule values to apply. Only schedule values overlapping the dose should be included.
    /// - Returns: An array of annotated doses
    fileprivate func annotated(with basalHistory: [AbsoluteScheduleValue<Double>]) -> [DoseEntry] {

        guard type == .tempBasal || type == .suspend, !basalHistory.isEmpty else {
            return [self]
        }

        if type == .suspend {
            guard value == 0 else {
                preconditionFailure("suspend with non-zero delivery")
            }
        } else {
            guard unit != .units else {
                preconditionFailure("temp basal without rate unsupported")
            }
        }

        if isMutable {
            var newDose = self
            let basal = basalHistory.first!
            newDose.scheduledBasalRate = HKQuantity(unit: .internationalUnitsPerHour, doubleValue: basal.value)
            return [newDose]
        }

        var doses: [DoseEntry] = []

        for (index, basalItem) in basalHistory.enumerated() {
            let startDate: Date
            let endDate: Date

            if index == 0 {
                startDate = self.startDate
            } else {
                startDate = basalItem.startDate
            }

            if index == basalHistory.count - 1 {
                endDate = self.endDate
            } else {
                endDate = basalHistory[index + 1].startDate
            }

            let segmentStartDate = max(startDate, self.startDate)
            let segmentEndDate = max(startDate, min(endDate, self.endDate))
            let segmentDuration = segmentEndDate.timeIntervalSince(segmentStartDate)
            let segmentPortion = (segmentDuration / duration)

            var annotatedDose = self
            annotatedDose.startDate = segmentStartDate
            annotatedDose.endDate = segmentEndDate
            annotatedDose.scheduledBasalRate = HKQuantity(unit: .internationalUnitsPerHour, doubleValue: basalItem.value)

            if let deliveredUnits {
                annotatedDose.deliveredUnits = deliveredUnits * segmentPortion
            }

            doses.append(annotatedDose)
        }

        if doses.count > 1 {
            for (index, dose) in doses.enumerated() {
                if let originalIdentifier = dose.syncIdentifier, index>0 {
                    doses[index].syncIdentifier = originalIdentifier + "\(index+1)/\(doses.count)"
                }
            }
        }

        return doses
    }
    
}


extension Collection where Element == DoseEntry {

    /// Annotates a sequence of dose entries with the configured basal history
    ///
    /// Doses which cross time boundaries in the basal rate schedule are split into multiple entries.
    ///
    /// - Parameter basalHistory: A history of basal rates covering the timespan of these doses.
    /// - Returns: An array of annotated dose entries
    public func annotated(with basalHistory: [AbsoluteScheduleValue<Double>]) -> [DoseEntry] {
        var annotatedDoses: [DoseEntry] = []

        for dose in self {
            let basalItems = basalHistory.filterDateRange(dose.startDate, dose.endDate)
            annotatedDoses += dose.annotated(with: basalItems)
        }

        return annotatedDoses
    }


    /// Assigns an automation status to any dose where automation is not already specified
    ///
    /// - Parameters:
    ///   - automationHistory: A history of automation periods.
    /// - Returns: An array of doses, with the automation flag set based on automation history. Doses will be split if the automation state changes mid-dose.

    public func overlayAutomationHistory(
        _ automationHistory: [AbsoluteScheduleValue<Bool>]
    ) -> [DoseEntry] {

        guard count > 0 else {
            return []
        }

        var newEntries = [DoseEntry]()

        var automation = automationHistory

        // Assume automation if doses start before automationHistory
        if let firstAutomation = automation.first, firstAutomation.startDate > first!.startDate {
            automation.insert(AbsoluteScheduleValue(startDate: first!.startDate, endDate: firstAutomation.startDate, value: true), at: 0)
        }

        // Overlay automation periods
        func annotateDoseWithAutomation(dose: DoseEntry) {

            var addedCount = 0
            for period in automation {
                if period.endDate > dose.startDate && period.startDate < dose.endDate {
                    var newDose = dose

                    if dose.isMutable {
                        newDose.automatic = period.value
                        newEntries.append(newDose)
                        return
                    }

                    newDose.startDate = Swift.max(period.startDate, dose.startDate)
                    newDose.endDate = Swift.min(period.endDate, dose.endDate)
                    if let delivered = dose.deliveredUnits {
                        newDose.deliveredUnits = newDose.duration / dose.duration * delivered
                    }
                    newDose.automatic = period.value
                    if addedCount > 0 {
                        newDose.syncIdentifier = "\(dose.syncIdentifierAsString)\(addedCount+1)"
                    }
                    newEntries.append(newDose)
                    addedCount += 1
                }
            }
            if addedCount == 0 {
                // automation history did not cover dose; mark automatic as default
                var newDose = dose
                newDose.automatic = true
                newEntries.append(newDose)
            }
        }

        for dose in self {
            switch dose.type {
            case .tempBasal, .basal, .suspend:
                if dose.automatic == nil {
                    annotateDoseWithAutomation(dose: dose)
                } else {
                    newEntries.append(dose)
                }
            default:
                newEntries.append(dose)
                break
            }
        }
        return newEntries
    }

}

extension DoseEntry {
    var simpleDesc: String {
        let seconds = Int(duration)
        let automatic = automatic?.description ?? "na"
        return "\(startDate) (\(seconds)s) - \(type) - isMutable:\(isMutable) automatic:\(automatic) value:\(value) delivered:\(String(describing: deliveredUnits)) scheduled:\(String(describing: scheduledBasalRate)) syncId:\(String(describing: syncIdentifier))"
    }
}


