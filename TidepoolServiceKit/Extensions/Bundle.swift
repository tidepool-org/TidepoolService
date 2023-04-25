//
//  Bundle.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 3/16/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import Foundation

extension Bundle {
    var semanticVersion: String? {
        guard Bundle.main.bundleIdentifier != "com.apple.dt.xctest.tool" else {     // Ignore version for XCTest
            return nil
        }
        guard var semanticVersion = bundleShortVersionString else {
            return nil
        }
        while semanticVersion.split(separator: ".").count < 3 {
            semanticVersion += ".0"
        }
        if let bundleVersion = bundleVersion {
            semanticVersion += "+\(bundleVersion)"
        }
        return semanticVersion
    }

    var bundleShortVersionString: String? { string(forInfoDictionaryKey: "CFBundleShortVersionString") }

    var bundleVersion: String? { string(forInfoDictionaryKey: "CFBundleVersion") }

    private func string(forInfoDictionaryKey key: String) -> String? { object(forInfoDictionaryKey: key) as? String }
}

public extension Bundle {

    // TidepoolServiceClientId should be set in the hosting app's info plist
    // TidepoolServiceRedirectURI generally does not need to be set, and the default can be used.

    var tidepoolServiceClientId: String {
        return object(forInfoDictionaryKey: "TidepoolServiceClientId") as? String ?? "client-id-not-in-info-plist"
    }

    var tidepoolServiceRedirectURL: URL {
        if let str = object(forInfoDictionaryKey: "TidepoolServiceRedirectURL") as? String, let url = URL(string: str) {
            return url
        }
        return URL(string: "org.tidepool.tidepoolkit.auth://redirect")!
    }
}
