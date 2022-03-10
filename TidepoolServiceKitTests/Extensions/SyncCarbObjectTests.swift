//
//  SyncCarbObjectTests.swift
//  TidepoolServiceKitTests
//
//  Created by Darin Krauss on 10/29/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import Foundation
import XCTest
import HealthKit
import TidepoolKit
import LoopKit
@testable import TidepoolServiceKit

class SyncCarbObjectDatumTests: XCTestCase {
    func testDatumCalibrationDeviceEvent() {
        let object = SyncCarbObject(absorptionTime: .hours(5),
                                    createdByCurrentApp: true,
                                    foodType: "Pizza",
                                    grams: 45,
                                    startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                    uuid: UUID(uuidString: "2A67A303-1234-4CB8-8263-79498265368E")!,
                                    provenanceIdentifier: "com.loopkit.Loop",
                                    syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                    syncVersion: 2,
                                    userCreatedDate: Self.dateFormatter.date(from: "2020-01-02T03:01:23Z")!,
                                    userUpdatedDate: Self.dateFormatter.date(from: "2020-01-02T03:05:23Z")!,
                                    userDeletedDate: nil,
                                    operation: .update,
                                    addedDate: Self.dateFormatter.date(from: "2020-01-02T03:05:23Z")!,
                                    supercededDate: nil)
        let datum = object.datum(for: "2B03D96C-6F5D-4140-99CD-80C3E64D6011")
        XCTAssertEqual(String(data: try! Self.encoder.encode(datum), encoding: .utf8), """
{
  "id" : "6bcc86152b10e405e126714fb583b783",
  "name" : "Pizza",
  "nutrition" : {
    "carbohydrate" : {
      "net" : 45,
      "units" : "grams"
    },
    "estimatedAbsorptionDuration" : 18000
  },
  "origin" : {
    "id" : "72b3626cfe267489df889fb597995437",
    "name" : "com.loopkit.Loop",
    "type" : "application"
  },
  "payload" : {
    "addedDate" : "2020-01-02T03:05:23.000Z",
    "syncIdentifier" : "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
    "syncVersion" : 2,
    "userCreatedDate" : "2020-01-02T03:01:23.000Z",
    "userUpdatedDate" : "2020-01-02T03:05:23.000Z",
    "uuid" : "2A67A303-1234-4CB8-8263-79498265368E"
  },
  "time" : "2020-01-02T03:00:23.000Z",
  "type" : "food"
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

class SyncCarbObjectSelectorTests: XCTestCase {
    func testDatumCalibrationDeviceEvent() {
        let object = SyncCarbObject(absorptionTime: .hours(5),
                                    createdByCurrentApp: true,
                                    foodType: "Pizza",
                                    grams: 45,
                                    startDate: Self.dateFormatter.date(from: "2020-01-02T03:00:23Z")!,
                                    uuid: UUID(uuidString: "2A67A303-1234-4CB8-8263-79498265368E")!,
                                    provenanceIdentifier: "com.loopkit.Loop",
                                    syncIdentifier: "18CF3948-0B3D-4B12-8BFE-14986B0E6784",
                                    syncVersion: 2,
                                    userCreatedDate: Self.dateFormatter.date(from: "2020-01-02T03:01:23Z")!,
                                    userUpdatedDate: Self.dateFormatter.date(from: "2020-01-02T03:05:23Z")!,
                                    userDeletedDate: nil,
                                    operation: .update,
                                    addedDate: Self.dateFormatter.date(from: "2020-01-02T03:05:23Z")!,
                                    supercededDate: nil)
        XCTAssertEqual(object.selector, TDatum.Selector(origin: TDatum.Selector.Origin(id: "72b3626cfe267489df889fb597995437")))
    }

    private static let dateFormatter = ISO8601DateFormatter()
}
