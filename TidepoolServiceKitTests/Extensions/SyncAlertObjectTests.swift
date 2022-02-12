//
//  SyncAlertObjectTests.swift
//  TidepoolServiceKitTests
//
//  Created by Darin Krauss on 2/3/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import Foundation
import XCTest
import LoopKit
import TidepoolKit
@testable import TidepoolServiceKit

class SyncAlertObjectTests: XCTestCase {
    func testDatum() {
        let object = SyncAlertObject(identifier: Alert.Identifier(managerIdentifier: "ManagerId",
                                                                  alertIdentifier: "AlertId"),
                                     trigger: .repeating(repeatInterval: .minutes(30)),
                                     interruptionLevel: .timeSensitive,
                                     foregroundContent: Alert.Content(title: "Foreground Title",
                                                                      body: "Foreground Body",
                                                                      acknowledgeActionButtonLabel: "Foreground Button"),
                                     backgroundContent: Alert.Content(title: "Background Title",
                                                                      body: "Background Body",
                                                                      acknowledgeActionButtonLabel: "Background Button"),
                                     sound: .sound(name: "Sound Name"),
                                     metadata: Alert.Metadata(dict: ["one": 1]),
                                     issuedDate: Self.dateFormatter.date(from: "2020-01-02T03:01:23Z")!,
                                     acknowledgedDate: Self.dateFormatter.date(from: "2020-01-02T03:05:34Z")!,
                                     retractedDate: Self.dateFormatter.date(from: "2020-01-02T03:06:45Z")!,
                                     syncIdentifier: UUID(uuidString: "2A67A303-1234-4CB8-8263-79498265368E")!)
        let datum = object.datum(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(datum), encoding: .utf8), """
{
  "acknowledgedTime" : "2020-01-02T03:05:34.000Z",
  "id" : "332e6adc6287f638138b8d186dd5bd41",
  "issuedTime" : "2020-01-02T03:01:23.000Z",
  "name" : "ManagerId.AlertId",
  "origin" : {
    "id" : "2A67A303-1234-4CB8-8263-79498265368E",
    "name" : "com.apple.dt.xctest.tool",
    "type" : "application"
  },
  "payload" : {
    "metadata" : {
      "one" : 1
    },
    "syncIdentifier" : "2A67A303-1234-4CB8-8263-79498265368E"
  },
  "priority" : "timeSensitive",
  "retractedTime" : "2020-01-02T03:06:45.000Z",
  "sound" : "name",
  "soundName" : "Sound Name",
  "time" : "2020-01-02T03:01:23.000Z",
  "trigger" : "repeating",
  "triggerDelay" : 1800,
  "type" : "alert"
}
"""
        )
    }

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder.tidepool
        encoder.outputFormatting.insert(.prettyPrinted)
        return encoder
    }()

    private static let dateFormatter = ISO8601DateFormatter()
}
