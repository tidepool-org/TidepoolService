//
//  TDatum.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/3/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import TidepoolKit

extension TDatum {
    func adorn(withOrigin origin: TOrigin?) -> TDatum {
        self.origin = origin
        return self
    }
}

extension TDatum: CustomDebugStringConvertible {
    public var debugDescription: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .tidepool
        guard let data = try? encoder.encode(self) else {
            return "error: failure to encode datum as data"
        }
        guard let string = String(data: data, encoding: .utf8) else {
            return "error: failure to encode data as string"
        }
        return string
    }
}
