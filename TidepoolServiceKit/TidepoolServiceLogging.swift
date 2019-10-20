//
//  TidepoolServiceLogging.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 8/20/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import os.log
import LoopKit
import TidepoolKit

public final class TidepoolServiceLogging: TPLogging {

    private let log = OSLog(category: "TidepoolServiceLogging")

    public init() {}

    public func logVerbose(_ message: String, file: StaticString, function: StaticString, line: UInt) {
        log.debug("%s:%s:%d %s", file.description, function.description, line, message)
    }

    public func logInfo(_ message: String, file: StaticString, function: StaticString, line: UInt) {
        log.info("%s:%s:%d %s", file.description, function.description, line, message)
    }

    public func logError(_ message: String, file: StaticString, function: StaticString, line: UInt) {
        log.error("%s:%s:%d %s", file.description, function.description, line, message)
    }

}
