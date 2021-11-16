//
//  TDatum.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/3/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import Foundation
import TidepoolKit

extension TDatum {
    func adornWith(id: String? = nil,
                   deviceId: String? = nil,
                   timeZone: TimeZone? = nil,
                   timeZoneOffset: TimeInterval? = nil,
                   annotations: [TDictionary]? = nil,
                   associations: [TAssociation]? = nil,
                   payload: TDictionary? = nil,
                   origin: TOrigin? = nil) -> Self {
        if let id = id {
            self.id = !id.isEmpty ? id : nil
        }
        if let deviceId = deviceId {
            self.deviceId = !deviceId.isEmpty ? deviceId : nil
        }
        if let timeZone = timeZone {
            self.timeZone = timeZone
        }
        if let timeZoneOffset = timeZoneOffset {
            self.timeZoneOffset = timeZoneOffset
        }
        if let annotations = annotations {
            self.annotations = annotations.contains(where: { !$0.isEmpty }) ? annotations : nil
        }
        if let associations = associations {
            self.associations = !associations.isEmpty ? associations : nil
        }
        if let payload = payload {
            self.payload = !payload.isEmpty ? payload : nil
        }
        if let origin = origin {
            self.origin = origin
        }
        return self
    }

    func append(associations: [TAssociation]) {
        guard !associations.isEmpty else {
            return
        }
        if self.associations == nil {
            self.associations = []
        }
        self.associations?.append(contentsOf: associations)
    }
}

extension TDatum: CustomDebugStringConvertible {
    public var debugDescription: String {
        guard let data = try? encoder.encode(self) else {
            return "error: failure to encode datum as data"
        }
        guard let string = String(data: data, encoding: .utf8) else {
            return "error: failure to encode data as string"
        }
        return string
    }
}

fileprivate let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    encoder.dateEncodingStrategy = .tidepool
    return encoder
}()
