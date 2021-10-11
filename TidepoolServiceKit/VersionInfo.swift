//
//  VersionInfo.swift
//  TidepoolServiceKit
//
//  Created by Rick Pasetto on 9/13/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

struct VersionInfo {
    private let loop: TInfo.Versions.Loop
    
    init?(bundleIdentifier: String, loop: TInfo.Versions.Loop) {
        // Right now, there's a "hard-coded mapping" between the bundle identifier for Tidepool Loop and
        // TInfo.Versions.Loop.  Otherwise, return nil.
        guard bundleIdentifier == "org.tidepool.Loop" else {
            return nil
        }
        self.loop = loop
    }
    
    func getVersionUpdateNeeded(currentVersion version: String) -> VersionUpdate {
        return loop.getVersionUpdateNeeded(currentVersion: version)
    }

    fileprivate static let decoder = JSONDecoder()
    fileprivate static let encoder = JSONEncoder()
}

extension TInfo.Versions.Loop {
     func getVersionUpdateNeeded(currentVersion version: String) -> VersionUpdate {
        if needsCriticalUpdate(version: version) {
            return .required
        }
        if needsSupportedUpdate(version: version) {
            return .recommended
        }
        return .none
    }
    
    func needsCriticalUpdate(version: String) -> Bool {
        return criticalUpdateNeeded?.contains(version) ?? false
    }
    
    func needsSupportedUpdate(version: String) -> Bool {
        guard let minimumSupported = minimumSupported,
              let minimumSupportedVersion = SemanticVersion(minimumSupported),
              let thisVersion = SemanticVersion(version) else {
            return false
        }
        return thisVersion < minimumSupportedVersion
    }
}

extension VersionInfo : Codable {
    init?(from json: String) {
        guard let data = json.data(using: .utf8),
              let info = try? VersionInfo.decoder.decode(VersionInfo.self, from: data)
              else {
            return nil
        }
        self = info
    }

    func toJSON() -> String? {
        guard let data = try? VersionInfo.encoder.encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
