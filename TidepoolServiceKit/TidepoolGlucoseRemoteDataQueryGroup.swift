//
//  TidepoolGlucoseRemoteDataQueryGroup.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 8/14/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

struct TidepoolGlucoseRemoteDataQueryGroupSettings: TidepoolRemoteDataQueryGroupSettings {

    public static let recentTimeInterval: TimeInterval = .hours(6)  // TODO: Is this correct?

    public static let recentLimit: Int = 288        // 24 hours worth of data, more or less

    public static let installedLimit: Int = 288     // 24 hours worth of data, more or less

    public static let historicLimit: Int = 288      // 24 hours worth of data, more or less

}

final class TidepoolGlucoseRemoteDataQueryGroup: TidepoolRemoteDataQueryGroup<GlucoseRemoteDataQuery, TidepoolGlucoseRemoteDataQueryGroupSettings> {

    public weak var delegate: GlucoseRemoteDataQueryDelegate? {
        didSet {
            recent.query.delegate = delegate
            installed.query.delegate = delegate
            historic.query.delegate = delegate
        }
    }

}

extension StoredGlucoseSample: TidepoolDeviceDataTransformable {

    func transformTidepoolDeviceData() -> Result<TidepoolDeviceData, Error> {

        // TODO: Rework and finish once TidepoolKit is more stable
        // TODO: Consider adding sampleUUID to food.payload["HKObjectUUID"]
        // TODO: Consider changing origin.type to "application"
        // TODO: Add multiple levels of origin
        // TODO: Are there any possible errors?
        // TODO: Is hardcoding .milligramsPerDeciliter right?
        // TODO: Fix TPDataCbg to not be an optional
        // TODO: Fix origin

        let cbg = TPDataCbg(time: startDate, value: quantity.doubleValue(for: .milligramsPerDeciliter), units: .milligramsPerDeciliter)

        cbg.origin = TPDataOrigin(id: syncIdentifier, name: Bundle.main.bundleIdentifier!, type: .service, version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)

        let descriptor = RemoteDataDescriptor(id: syncIdentifier, version: syncVersion, kind: .create)

        return .success(TidepoolDeviceData(cbg, withDescriptor: descriptor))
    }

}

extension DeletedGlucoseSample: TidepoolDeleteItemTransformable {

    func transformTidepoolDeleteItem() -> Result<TidepoolDeleteItem, Error> {

        // TODO: Fix TPDeleteItem to not be an optional

        var id: String
        var version: Int?

        if let syncIdentifier = syncIdentifier {
            id = syncIdentifier
            version = syncVersion
        } else {
            id = uuid.uuidString
        }

        let deleteItem = TPDeleteItem(origin: TPDataOrigin(id: id))!

        let descriptor = RemoteDataDescriptor(id: id, version: version ?? 0, kind: .delete)

        return .success(TidepoolDeleteItem(deleteItem, withDescriptor: descriptor))
    }

}
