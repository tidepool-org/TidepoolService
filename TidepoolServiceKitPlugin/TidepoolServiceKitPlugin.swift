//
//  TidepoolServiceKitPlugin.swift
//  TidepoolServiceKitPlugin
//
//  Created by Darin Krauss on 10/18/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import os.log
import LoopKitUI
import TidepoolServiceKit
import TidepoolServiceKitUI

class TidepoolServiceKitPlugin: NSObject, ServiceUIPlugin {
    private let log = OSLog(category: "TidepoolServiceKitPlugin")

    public var serviceType: ServiceUI.Type? {
        return TidepoolService.self
    }

    override init() {
        super.init()
        log.default("Instantiated")
    }
}
