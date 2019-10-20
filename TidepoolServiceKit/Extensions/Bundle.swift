//
//  Bundle.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 10/20/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

extension Bundle {

    var bundleVersionBuild: String? {
        guard
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        else {
            return nil
        }
        return "\(version).\(build)"
    }

}
