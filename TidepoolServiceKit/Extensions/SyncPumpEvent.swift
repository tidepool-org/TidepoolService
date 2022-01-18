//
//  SyncPumpEvent.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 1/7/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

/*
 SyncPumpEvent

 Properties:
 - date                     Date                .time
 - type                     PumpEventType       .type, .subType
 - alarmType                PumpAlarmType       .alarmType, .payload["otherAlarmType"]
 - mutable                  Bool                .normal, .expectedNormal
 - dose                     DoseEntry?          -
 -   type                   DoseType            (N/A - same as top-level type)
 -   startDate              Date                .time, .duration, .expectedDuration, .payload["duration"]
 -   endDate                Date                .duration, .expectedDuration, .payload["duration"]
 -   value                  Double              .rate, .normal
 -   unit                   DoseUnit            (internal use only)
 -   deliveredUnits         Double?             .normal
 -   description            String?             (N/A - unused)
 -   insulinType            InsulinType?        .insulinFormulation
 -   automatic              Bool?               .subType, .deliveryType
 -   manuallyEntered        Bool                .subType
 -   duringSuspend          Bool?               .deliveryType
 -   syncIdentifier         String?             (N/A - same as top-level syncIdentifier)
 -   scheduledBasalRate     HKQuantity?         .rate, .suppressed.rate
 - syncIdentifier          String               .id, .origin.id, .payload["syncIdentifier"]
 */

extension SyncPumpEvent: IdentifiableDatum {
    func datum(for userId: String) -> TDatum? {
        switch type {
        case .alarm:
            return datumForAlarm(for: userId)
        case .alarmClear:
            return datumForAlarmClear(for: userId)
        case .basal:
            return datumForBasal(for: userId)
        case .bolus:
            return datumForBolus(for: userId)
        case .prime:
            return datumForPrime(for: userId)
        case .resume:
            return datumForResume(for: userId)
        case .rewind:
            return datumForRewind(for: userId)
        case .suspend:
            return datumForSuspend(for: userId)
        case .tempBasal:
            return datumForTempBasal(for: userId)
        }
    }

    var syncIdentifierAsString: String { syncIdentifier.md5hash! }  // Actual sync identifier may be human readable and of variable length

    private func datumForAlarm(for userId: String) -> TAlarmDeviceEventDatum {
        var payload = datumPayload
        if let alarmType = alarmType, case .other(let details) = alarmType {
            payload["otherAlarmType"] = details
        }

        var datum = TAlarmDeviceEventDatum(time: datumTime, alarmType: datumAlarmType ?? .other)
        datum = datum.adornWith(id: datumId(for: userId, type: TAlarmDeviceEventDatum.self),
                                payload: payload,
                                origin: datumOrigin(for: TAlarmDeviceEventDatum.self))
        return datum
    }

    private func datumForAlarmClear(for userId: String) -> TDatum? { nil }  // Not supported by Tidepool backend data model

    private func datumForBasal(for userId: String) -> TScheduledBasalDatum? {
        guard let dose = dose, let datumDuration = datumDuration, let datumScheduledBasalRate = datumScheduledBasalRate else {
            return nil
        }

        var payload = datumPayload
        payload["deliveredUnits"] = dose.programmedUnits

        var datum = TScheduledBasalDatum(time: datumTime,
                                         duration: datumDuration,
                                         rate: datumScheduledBasalRate,
                                         scheduleName: StoredSettings.activeScheduleNameDefault,
                                         insulinFormulation: datumInsulinFormulation)
        datum = datum.adornWith(id: datumId(for: userId, type: TScheduledBasalDatum.self),
                                payload: payload,
                                origin: datumOrigin(for: TScheduledBasalDatum.self))
        return datum
    }

    private func datumForBolus(for userId: String) -> TDatum? {
        guard let dose = dose else {
            return nil
        }
        if dose.manuallyEntered {
            return datumForBolusManuallyEntered(for: userId)
        } else if dose.automatic != true {
            return datumForBolusManual(for: userId)
        } else {
            return datumForBolusAutomatic(for: userId)
        }
    }

    private func datumForBolusManuallyEntered(for userId: String) -> TInsulinDatum? {
        guard let dose = dose else {
            return nil
        }

        var payload = datumPayload
        payload["duration"] = datumDuration?.milliseconds

        var datum = TInsulinDatum(time: datumTime,
                                  dose: TInsulinDatum.Dose(total: dose.deliveredUnits ?? dose.programmedUnits),
                                  formulation: datumInsulinFormulation)
        datum = datum.adornWith(id: datumId(for: userId, type: TInsulinDatum.self),
                                payload: payload,
                                origin: datumOrigin(for: TInsulinDatum.self))
        return datum
    }

    private func datumForBolusManual(for userId: String) -> TNormalBolusDatum? {
        guard let dose = dose else {
            return nil
        }

        var payload = datumPayload
        payload["duration"] = datumDuration?.milliseconds

        let programmedUnits = dose.programmedUnits
        let deliveredUnits = dose.deliveredUnits ?? programmedUnits

        var datum = TNormalBolusDatum(time: datumTime,
                                      normal: !mutable ? deliveredUnits : programmedUnits,
                                      expectedNormal: !mutable && programmedUnits != deliveredUnits ? programmedUnits : nil,
                                      insulinFormulation: datumInsulinFormulation)
        datum = datum.adornWith(id: datumId(for: userId, type: TNormalBolusDatum.self),
                                payload: payload,
                                origin: datumOrigin(for: TNormalBolusDatum.self))
        return datum
    }

    private func datumForBolusAutomatic(for userId: String) -> TAutomatedBolusDatum? {
        guard let dose = dose else {
            return nil
        }

        var payload = datumPayload
        payload["duration"] = datumDuration?.milliseconds

        let programmedUnits = dose.programmedUnits
        let deliveredUnits = dose.deliveredUnits ?? programmedUnits

        var datum = TAutomatedBolusDatum(time: datumTime,
                                         normal: !mutable ? deliveredUnits : programmedUnits,
                                         expectedNormal: !mutable && programmedUnits != deliveredUnits ? programmedUnits : nil,
                                         insulinFormulation: datumInsulinFormulation)
        datum = datum.adornWith(id: datumId(for: userId, type: TAutomatedBolusDatum.self),
                                payload: payload,
                                origin: datumOrigin(for: TAutomatedBolusDatum.self))
        return datum
    }

    private func datumForPrime(for userId: String) -> TPrimeDeviceEventDatum? {
        var datum = TPrimeDeviceEventDatum(time: datumTime, target: .tubing)        // Default to tubing until we have further information
        datum = datum.adornWith(id: datumId(for: userId, type: TPrimeDeviceEventDatum.self),
                                payload: datumPayload,
                                origin: datumOrigin(for: TPrimeDeviceEventDatum.self))
        return datum
    }

    private func datumForResume(for userId: String) -> TStatusDeviceEventDatum? {
        guard let dose = dose else {
            return nil
        }

        var reason = TDictionary()
        reason["resumed"] = dose.automatic == true ? "automatic" : "manual"

        var datum = TStatusDeviceEventDatum(time: datumTime,
                                            name: .resumed,
                                            reason: reason)
        datum = datum.adornWith(id: datumId(for: userId, type: TStatusDeviceEventDatum.self),
                                payload: datumPayload,
                                origin: datumOrigin(for: TStatusDeviceEventDatum.self))
        return datum
    }

    private func datumForRewind(for userId: String) -> TReservoirChangeDeviceEventDatum? {
        var datum = TReservoirChangeDeviceEventDatum(time: datumTime)
        datum = datum.adornWith(id: datumId(for: userId, type: TReservoirChangeDeviceEventDatum.self),
                                payload: datumPayload,
                                origin: datumOrigin(for: TReservoirChangeDeviceEventDatum.self))
        return datum
    }

    private func datumForSuspend(for userId: String) -> TStatusDeviceEventDatum? {
        guard let dose = dose else {
            return nil
        }

        var reason = TDictionary()
        reason["suspended"] = dose.automatic == true ? "automatic" : "manual"

        var datum = TStatusDeviceEventDatum(time: datumTime,
                                            name: .suspended,
                                            reason: reason)
        datum = datum.adornWith(id: datumId(for: userId, type: TStatusDeviceEventDatum.self),
                                payload: datumPayload,
                                origin: datumOrigin(for: TStatusDeviceEventDatum.self))
        return datum
    }

    private func datumForTempBasal(for userId: String) -> TBasalDatum? {
        guard let dose = dose else {
            return nil
        }
        if dose.duringSuspend == true {
            return datumForTempBasalDuringSuspend(for: userId)
        } else if dose.automatic == false {
            return datumForTempBasalManual(for: userId)
        } else {
            return datumForTempBasalAutomatic(for: userId)
        }
    }

    private func datumForTempBasalDuringSuspend(for userId: String) -> TSuspendedBasalDatum? {
        guard let datumDuration = datumDuration else {
            return nil
        }

        var datum = TSuspendedBasalDatum(time: datumTime,
                                         duration: datumDuration)
        datum.suppressed = datumSuppressed
        datum = datum.adornWith(id: datumId(for: userId, type: TSuspendedBasalDatum.self),
                                payload: datumPayload,
                                origin: datumOrigin(for: TSuspendedBasalDatum.self))
        return datum
    }

    private func datumForTempBasalManual(for userId: String) -> TTemporaryBasalDatum? {
        guard let dose = dose, let datumDuration = datumDuration, let datumRate = datumRate else {
            return nil
        }

        var payload = datumPayload
        payload["deliveredUnits"] = dose.deliveredUnits

        var datum = TTemporaryBasalDatum(time: datumTime,
                                         duration: datumDuration,
                                         expectedDuration: !mutable && datumDuration < basalDatumExpectedDuration ? basalDatumExpectedDuration : nil,
                                         rate: datumRate,
                                         insulinFormulation: datumInsulinFormulation)
        datum.suppressed = datumSuppressed
        datum = datum.adornWith(id: datumId(for: userId, type: TTemporaryBasalDatum.self),
                                payload: payload,
                                origin: datumOrigin(for: TTemporaryBasalDatum.self))
        return datum
    }

    private func datumForTempBasalAutomatic(for userId: String) -> TAutomatedBasalDatum? {
        guard let dose = dose, let datumDuration = datumDuration, let datumRate = datumRate else {
            return nil
        }

        var payload = datumPayload
        payload["deliveredUnits"] = dose.deliveredUnits

        var datum = TAutomatedBasalDatum(time: datumTime,
                                         duration: datumDuration,
                                         expectedDuration: !mutable && datumDuration < basalDatumExpectedDuration ? basalDatumExpectedDuration : nil,
                                         rate: datumRate,
                                         scheduleName: StoredSettings.activeScheduleNameDefault,
                                         insulinFormulation: datumInsulinFormulation)
        datum.suppressed = datumSuppressed
        datum = datum.adornWith(id: datumId(for: userId, type: TAutomatedBasalDatum.self),
                                payload: payload,
                                origin: datumOrigin(for: TAutomatedBasalDatum.self))
        return datum
    }

    private var datumTime: Date { dose?.startDate ?? date }

    private var datumAlarmType: TAlarmDeviceEventDatum.AlarmType? { alarmType?.datum ?? .other }

    private var datumDuration: TimeInterval? { dose.map { $0.startDate.distance(to: $0.endDate) } }

    private var datumRate: Double? { dose?.unitsPerHour }

    private var datumScheduledBasalRate: Double? { dose?.scheduledBasalRate?.doubleValue(for: .internationalUnitsPerHour) }

    private var datumSuppressed: TScheduledBasalDatum.Suppressed? {
        guard let datumScheduledBasalRate = datumScheduledBasalRate else {
            return nil
        }
        return TScheduledBasalDatum.Suppressed(rate: datumScheduledBasalRate,
                                               scheduleName: StoredSettings.activeScheduleNameDefault)
    }

    private var datumInsulinFormulation: TInsulinDatum.Formulation? { dose?.insulinType?.datum }

    private var datumPayload: TDictionary {
        var dictionary = TDictionary()
        dictionary["syncIdentifier"] = syncIdentifier
        return dictionary
    }

    private var basalDatumExpectedDuration: TimeInterval { .minutes(30) }
}

fileprivate extension PumpAlarmType {
    var datum: TAlarmDeviceEventDatum.AlarmType {
        switch self {
        case .autoOff:
            return .autoOff
        case .lowInsulin:
            return .lowInsulin
        case .lowPower:
            return .lowPower
        case .noDelivery:
            return .noDelivery
        case .noInsulin:
            return .noInsulin
        case .noPower:
            return .noPower
        case .occlusion:
            return .occlusion
        case .other:
            return .other
        case .overLimit:
            return .overLimit
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

extension TAlarmDeviceEventDatum: TypedDatum {
    static var resolvedType: String { "\(TDatum.DatumType.deviceEvent.rawValue)/\(TDeviceEventDatum.SubType.alarm.rawValue)" }
}

extension TPrimeDeviceEventDatum: TypedDatum {
    static var resolvedType: String { "\(TDatum.DatumType.deviceEvent.rawValue)/\(TDeviceEventDatum.SubType.prime.rawValue)" }
}

extension TReservoirChangeDeviceEventDatum: TypedDatum {
    static var resolvedType: String { "\(TDatum.DatumType.deviceEvent.rawValue)/\(TDeviceEventDatum.SubType.reservoirChange.rawValue)" }
}

extension TStatusDeviceEventDatum: TypedDatum {
    static var resolvedType: String { "\(TDatum.DatumType.deviceEvent.rawValue)/\(TDeviceEventDatum.SubType.status.rawValue)" }
}

extension TInsulinDatum: TypedDatum {
    static var resolvedType: String { TDatum.DatumType.insulin.rawValue }
}
