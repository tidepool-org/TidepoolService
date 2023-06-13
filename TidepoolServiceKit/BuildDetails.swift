//
//  BuildDetails.swift
//  TidepoolServiceKit
//
//  Created by Pete Schwamb on 6/13/23.
//  Copyright © 2023 LoopKit Authors. All rights reserved.
//

import Foundation

class BuildDetails {

    static var `default` = BuildDetails()

    let dict: [String: Any]

    init() {
        guard let url = Bundle.main.url(forResource: "BuildDetails", withExtension: ".plist"),
           let data = try? Data(contentsOf: url),
           let parsed = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else
        {
            dict = [:]
            return
        }
        dict = parsed
    }

    // TidepoolServiceClientId should be set in the hosting app's info plist
    // TidepoolServiceRedirectURI generally does not need to be set, and the default can be used.

    var tidepoolServiceClientId: String {
        return dict["TidepoolServiceClientId"] as? String ?? "client-id-not-in-info-plist"
    }

    var tidepoolServiceRedirectURL: URL {
        if let str = dict["TidepoolServiceRedirectURL"] as? String, let url = URL(string: str) {
            return url
        }
        return URL(string: "org.tidepool.tidepoolkit.auth://redirect")!
    }

}
