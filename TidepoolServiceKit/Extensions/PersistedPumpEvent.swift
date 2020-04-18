//
//  PersistedPumpEvent.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/2/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

//public struct PersistedPumpEvent {
//    /// The date of the event
//    public let date: Date
//    /// The date the event was persisted
//    public let persistedDate: Date
//    /// The insulin dose described by the event, if applicable
//    public let dose: DoseEntry?
//    /// Whether the event has been successfully uploaded
//    public let isUploaded: Bool
//    /// The NSManagedObject identifier of the event used by the store
//    public let objectIDURL: URL
//    /// The opaque raw data representing the event
//    public let raw: Data?
//    /// A human-readable short description of the event
//    public let title: String?
//    /// The type of pump event
//    public let type: PumpEventType?
//    /// Whether the pump event is marked mutable
//    public let isMutable: Bool
//}

// for Tidepool data model alarm of:
//    no_insulin
//    no_power
//    occlusion
//    no_delivery
//    auto_off
// may need to add status event to indicate suspended if one not already generated separately by Loop

extension PersistedPumpEvent {
    var datum: TDatum? {
// TODO: Implement

        guard let type = type else {
            return nil
        }

        let datum: TDatum?

        switch type {
        case .alarm:
            datum = nil // TODO: Do we need to pull out suspend?
        case .alarmClear:
            datum = nil // TODO: Do we need to pull out resume and update previous suspend?
        case .prime:
            datum = nil // TODO: Do we need to pull out resume and update previous suspend?
        case .rewind:
            datum = nil // TODO: Do we need to pull out suspend?
        default:
            datum = nil  // Other types are handled by Doses
        }

//        datum?.origin = TOrigin(id: syncIdentifier)   // TODO: What do we use for syncIdentifier?
        return datum
    }
}
