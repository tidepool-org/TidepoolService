//
//  Data.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 2/7/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import CryptoKit

extension Data {
    var md5hash: String? {
        let hash = Insecure.MD5.hash(data: self)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
