//
//  TOrigin.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/1/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import TidepoolKit

extension TOrigin {
    init(id: String) {
        self.init(id: id, name: Bundle.main.bundleIdentifier, version: Bundle.main.semanticVersion, type: .application)
    }
}
