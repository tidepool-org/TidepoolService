//
//  LoopVersionInfo.swift
//  TidepoolServiceKit
//
//  Created by Rick Pasetto on 9/13/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

public struct LoopVersionInfo {
    public let minimumSupported: String
    public let criticalUpdateNeeded: [String]
    
    public init?(minimumSupported: String? = nil, criticalUpdateNeeded: [String] = []) {
        guard let minimumSupported = minimumSupported else {
            return nil
        }
        self.minimumSupported = minimumSupported
        self.criticalUpdateNeeded = criticalUpdateNeeded
    }
    
    public func getVersionUpdateNeeded(currentVersion version: String) -> VersionUpdate {
        if needsCriticalUpdate(version: version) {
            return .criticalNeeded
        }
        if needsSupportedUpdate(version: version) {
            return .supportedNeeded
        }
        return .noneNeeded
    }
    
    public func needsCriticalUpdate(version: String) -> Bool {
        return criticalUpdateNeeded.contains(version)
    }
    
    public func needsSupportedUpdate(version: String) -> Bool {
        guard let minimumSupportedVersion = SemanticVersion(minimumSupported),
              let thisVersion = SemanticVersion(version) else {
            return false
        }
        return thisVersion < minimumSupportedVersion
    }
}

extension LoopVersionInfo {
    init?(_ info: TInfo) {
        self.init(minimumSupported: info.versions?.loop?.minimumSupported,
                  criticalUpdateNeeded: info.versions?.loop?.criticalUpdateNeeded ?? [])
    }
}
