//
//  TOrigin.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/1/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import TidepoolKit

extension TOrigin {
    init?(id: String) {
        guard let name = Bundle.main.bundleIdentifier, let semanticVersion = Bundle.main.semanticVersion else {
            return nil
        }
        self.init(id: id, name: name, version: semanticVersion, type: .application)
    }
}
