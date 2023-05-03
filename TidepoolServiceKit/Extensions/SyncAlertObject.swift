//
//  SyncAlertObject.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 2/2/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

/*
 SyncAlertObject

 Properties:
 - identifier               Alert.Identifier            .name
 - trigger                  Alert.Trigger               .trigger, .triggerDelay
 - interruptionLevel        Alert.InterruptionLevel     .priority
 - foregroundContent        Alert.Content?              (N/A - localized strings ignored)
 - backgroundContent        Alert.Content?              (N/A - localized strings ignored)
 - sound                    Alert.Sound?                .sound, .soundName
 - issuedDate               Date                        .issuedTime
 - acknowledgedDate         Date?                       .acknowledgedTime
 - retractedDate            Date?                       .retractedTime
 - syncIdentifier           UUID                        .id, .origin.id, .payload["syncIdentifier"]
 */

extension SyncAlertObject: IdentifiableDatum {
    func datum(for userId: String, hostIdentifier: String, hostVersion: String) -> TAlertDatum? {
        guard triggered else {      // If alert not yet triggered due to delay, then ignore
            return nil
        }
        let datum = TAlertDatum(time: datumTime,
                                name: datumName,
                                priority: datumPriority,
                                trigger: datumTrigger,
                                triggerDelay: datumTriggerDelay,
                                sound: datumSound,
                                soundName: datumSoundName,
                                issuedTime: datumIssuedTime,
                                acknowledgedTime: datumAcknowledgedTime,
                                retractedTime: datumRetractedTime)
        return datum.adornWith(id: datumId(for: userId),
                               payload: datumPayload,
                               origin: datumOrigin(for: resolvedIdentifier, hostIdentifier: hostIdentifier, hostVersion: hostVersion))
    }

    var syncIdentifierAsString: String { syncIdentifier.uuidString }

    private var datumTime: Date { issuedDate }

    private var datumName: String { identifier.value }

    private var datumPriority: TAlertDatum.Priority { interruptionLevel.datum }

    private var datumTrigger: TAlertDatum.Trigger { trigger.datum }

    private var datumTriggerDelay: TimeInterval? { trigger.datumDelay }

    private var datumSound: TAlertDatum.Sound? { sound?.datum }

    private var datumSoundName: String? { sound?.datumName }

    private var datumIssuedTime: Date { issuedDate }

    private var datumAcknowledgedTime: Date? { acknowledgedDate }

    private var datumRetractedTime: Date? { retractedDate }

    private var datumPayload: TDictionary {
        var dictionary = TDictionary()
        dictionary["syncIdentifier"] = syncIdentifier.uuidString
        dictionary["metadata"] = metadata?.datum
        return dictionary
    }
}

fileprivate extension SyncAlertObject {
    var triggered: Bool {
        guard let triggerDelay = trigger.datumDelay else {
            return true
        }
        return issuedDate.addingTimeInterval(triggerDelay) <= Date()
    }
}

fileprivate extension Alert.InterruptionLevel {
    var datum: TAlertDatum.Priority {
        switch self {
        case .active:
            return .normal
        case .timeSensitive:
            return .timeSensitive
        case .critical:
            return .critical
        }
    }
}

fileprivate extension Alert.Trigger {
    var datum: TAlertDatum.Trigger {
        switch self {
        case .immediate:
            return .immediate
        case .delayed:
            return .delayed
        case .repeating:
            return .repeating
        }
    }

    var datumDelay: TimeInterval? {
        switch self {
        case .immediate:
            return nil
        case .delayed(let interval):
            return interval
        case .repeating(let interval):
            return interval
        }
    }
}

fileprivate extension Alert.Sound {
    var datum: TAlertDatum.Sound {
        switch self {
        case .vibrate:
            return .vibrate
        case .sound:
            return .name
        }
    }

    var datumName: String? {
        switch self {
        case .vibrate:
            return nil
        case .sound(let name):
            return name
        }
    }
}

fileprivate extension Alert.Metadata {
    var datum: [String: Any] {
        var dictionary = [String: Any]()
        for (key, value) in self {
            dictionary[key] = value.wrapped
        }
        return dictionary
    }
}
