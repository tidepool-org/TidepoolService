//
//  VersionInfo.swift
//  TidepoolServiceKit
//
//  Created by Rick Pasetto on 9/13/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

public struct VersionInfo {
    /// Minimum supported version.  A `nil` means all versions supported.
    public let minimumSupported: String?
    /// List of versions requiring critical updates.
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
        guard let minimumSupported = minimumSupported,
              let minimumSupportedVersion = SemanticVersion(minimumSupported),
              let thisVersion = SemanticVersion(version) else {
            return false
        }
        return thisVersion < minimumSupportedVersion
    }
    
    fileprivate static let decoder = JSONDecoder()
    fileprivate static let encoder = JSONEncoder()
}

extension TInfo {
    func versionInfo(for bundleIdentifier: String) -> VersionInfo? {
        // Right now, there's a "hard-coded mapping" between the bundle identifier for Tidepool Loop and
        // TInfo.Versions.Loop.  Otherwise, return nil.
        guard bundleIdentifier == "org.tidepool.Loop" else {
            return nil
        }
        return VersionInfo(minimumSupported: self.versions?.loop?.minimumSupported,
                           criticalUpdateNeeded: self.versions?.loop?.criticalUpdateNeeded ?? [])
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
