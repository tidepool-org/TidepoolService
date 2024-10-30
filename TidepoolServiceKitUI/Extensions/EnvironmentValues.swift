//
//  EnvironmentValues.swift
//  TidepoolService
//
//  Created by Nathaniel Hamming on 2024-10-30.
//  Copyright © 2024 LoopKit Authors. All rights reserved.
//

import SwiftUI

private struct AllowDebugFeaturesKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

public extension EnvironmentValues {
    var allowDebugFeatures: Bool {
        get { self[AllowDebugFeaturesKey.self] }
        set { self[AllowDebugFeaturesKey.self] = newValue }
    }
}
