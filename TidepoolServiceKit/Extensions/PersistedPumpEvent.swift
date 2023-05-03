//
//  PersistedPumpEvent.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 1/7/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

/*
 PersistedPumpEvent

 Properties:
 - date                     Date                .time
 - persistedDate            Date                (N/A - unused)
 - dose                     DoseEntry?          -
 -   type                   DoseType            .type, .subType (embedded suspend/resume)
 -   startDate              Date                (N/A - unused by pump event data)
 -   endDate                Date                (N/A - unused by pump event data)
 -   value                  Double              (N/A - unused by pump event data)
 -   unit                   DoseUnit            (N/A - unused by pump event data)
 -   deliveredUnits         Double?             (N/A - unused by pump event data)
 -   description            String?             (N/A - unused by pump event data)
 -   insulinType            InsulinType?        (N/A - unused by pump event data)
 -   automatic              Bool?               .reason["resumed"], .reason["suspended"]
 -   manuallyEntered        Bool                (N/A - unused by pump event data)
 -   syncIdentifier         String?             (N/A - unused by pump event data)
 -   scheduledBasalRate     HKQuantity?         (N/A - unused by pump event data)
 -   isMutable              Bool                (N/A - unused by pump event data)
 - isUploaded               Bool                (N/A - unused)
 - objectIDURL              URL                 (N/A - unused)
 - raw                      Data?               .id, .origin.id, .payload["syncIdentifier"]
 - title                    String?             (N/A - unused)
 - type                     PumpEventType?      .type, .subType
 - automatic                Bool?               (N/A - unused)
 - alarmType                PumpAlarmType?      .alarmType, .payload["otherAlarmType"]
 */

extension PersistedPumpEvent: IdentifiableDatum {
    func data(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        guard let type = type, syncIdentifier != nil else {
            return []
        }

        switch type {
        case .alarm:
            return dataForAlarm(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        case .alarmClear:
            return dataForAlarmClear(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        case .prime:
            return dataForPrime(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        case .resume:
            return dataForResume(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        case .rewind:
            return dataForRewind(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        case .suspend:
            return dataForSuspend(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        default:
            return []
        }
    }

    private var syncIdentifier: String? { raw?.md5hash }  // Actual sync identifier may be human readable and of variable length

    var syncIdentifierAsString: String { syncIdentifier! }

    private func dataForAlarm(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        var data: [TDatum] = []
        if dose?.type == .suspend {
            data.append(contentsOf: dataForSuspend(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion))
        }

        var payload = datumPayload
        if let alarmType = alarmType, case .other(let details) = alarmType {
            payload["otherAlarmType"] = details
        }

        var datum = TAlarmDeviceEventDatum(time: date, alarmType: datumAlarmType ?? .other)
        let origin = datumOrigin(for: resolvedIdentifier(for: TAlarmDeviceEventDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        datum = datum.adornWith(id: datumId(for: userId, type: TAlarmDeviceEventDatum.self),
                                payload: payload,
                                origin: origin)
        data.append(datum)

        if dose?.type == .resume {
            data.append(contentsOf: dataForResume(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion))
        }
        return data
    }

    private func dataForAlarmClear(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        if dose?.type == .suspend {
            return dataForSuspend(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        } else if dose?.type == .resume {
            return dataForResume(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        } else {
            return []
        }
    }

    private func dataForPrime(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        var data: [TDatum] = []
        if dose?.type == .suspend {
            data.append(contentsOf: dataForSuspend(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion))
        }

        var datum = TPrimeDeviceEventDatum(time: date, target: .tubing)        // Default to tubing until we have further information
        let origin = datumOrigin(for: resolvedIdentifier(for: TPrimeDeviceEventDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        datum = datum.adornWith(id: datumId(for: userId, type: TPrimeDeviceEventDatum.self),
                                payload: datumPayload,
                                origin: origin)
        data.append(datum)

        if dose?.type == .resume {
            data.append(contentsOf: dataForResume(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion))
        }
        return data
    }

    private func dataForResume(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        guard let dose = dose else {
            return []
        }

        var reason = TDictionary()
        reason["resumed"] = dose.automatic == true ? "automatic" : "manual"

        var datum = TStatusDeviceEventDatum(time: datumTime,
                                            name: .resumed,
                                            reason: reason)
        let origin = datumOrigin(for: resolvedIdentifier(for: TStatusDeviceEventDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        datum = datum.adornWith(id: datumId(for: userId, type: TStatusDeviceEventDatum.self),
                                payload: datumPayload,
                                origin: origin)
        return [datum]
    }

    private func dataForRewind(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        var data: [TDatum] = []
        if dose?.type == .suspend {
            data.append(contentsOf: dataForSuspend(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion))
        }

        var datum = TReservoirChangeDeviceEventDatum(time: date)
        let origin = datumOrigin(for: resolvedIdentifier(for: TReservoirChangeDeviceEventDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        datum = datum.adornWith(id: datumId(for: userId, type: TReservoirChangeDeviceEventDatum.self),
                                payload: datumPayload,
                                origin: origin)
        data.append(datum)

        if dose?.type == .resume {
            data.append(contentsOf: dataForResume(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion))
        }
        return data
    }

    private func dataForSuspend(for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        guard let dose = dose else {
            return []
        }

        var reason = TDictionary()
        reason["suspended"] = dose.automatic == true ? "automatic" : "manual"

        var datum = TStatusDeviceEventDatum(time: datumTime,
                                            name: .suspended,
                                            reason: reason)
        let origin = datumOrigin(for: resolvedIdentifier(for: TStatusDeviceEventDatum.self), hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        datum = datum.adornWith(id: datumId(for: userId, type: TStatusDeviceEventDatum.self),
                                payload: datumPayload,
                                origin: origin)
        return [datum]
    }

    private var datumTime: Date { dose?.startDate ?? date }

    private var datumAlarmType: TAlarmDeviceEventDatum.AlarmType? { alarmType?.datum ?? .other }

    private var datumPayload: TDictionary {
        var dictionary = TDictionary()
        dictionary["syncIdentifier"] = syncIdentifier
        return dictionary
    }
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
        }
    }
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
