//
//  TidepoolDoseRemoteDataQueryGroup.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 9/4/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

struct TidepoolDoseRemoteDataQueryGroupSettings: TidepoolRemoteDataQueryGroupSettings {

    public static let recentTimeInterval: TimeInterval = .hours(6)  // TODO: Is this correct?

    public static let recentLimit: Int = 288        // 24 hours worth of data, more or less

    public static let installedLimit: Int = 288     // 24 hours worth of data, more or less

    public static let historicLimit: Int = 288      // 24 hours worth of data, more or less

}

final class TidepoolDoseRemoteDataQueryGroup: TidepoolRemoteDataQueryGroup<DoseRemoteDataQuery, TidepoolDoseRemoteDataQueryGroupSettings> {

    public weak var delegate: DoseRemoteDataQueryDelegate? {
        didSet {
            recent.query.delegate = delegate
            installed.query.delegate = delegate
            historic.query.delegate = delegate
        }
    }

}

extension DoseEntry: TidepoolDeviceDataTransformable {

    func transformTidepoolDeviceData() -> Result<TidepoolDeviceData, Error> {

        // TODO: Rework and finish once TidepoolKit is more stable
        // TODO: Consider adding sampleUUID to food.payload["HKObjectUUID"]
        // TODO: Consider changing origin.type to "application"
        // TODO: Add multiple levels of origin
        // TODO: Are there any possible errors?
        // TODO: Fix origin

//        let cbg = TPDataCbg(time: startDate, value: quantity.doubleValue(for: .milligramsPerDeciliter), units: .milligramsPerDeciliter)!
//
//        cbg.origin = TPDataOrigin(id: syncIdentifier, name: Bundle.main.bundleIdentifier!, type: .service, version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
//
//        let descriptor = RemoteDataDescriptor(id: syncIdentifier, version: syncVersion, kind: .create)

        // TODO: How to deal with missing syncIdentifier

//        let origin = TPDataOrigin(id: syncIdentifier, name: Bundle.main.bundleIdentifier!, type: .service, version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
//
//        var data: TPDeviceData
//
//        switch type {
//        case .basal:
//            data = TPDataBasalScheduled(date: startDate, rate: unitsPerHour, duration: endDate - startDate)
//        case .bolus:
//        case .resume:
//        case .suspend:
//        case .tempBasal:
//        }

//->  review what Tidepool Mobile does for basals

        let cbg = TPDataCbg(time: startDate, value: 0, units: .milligramsPerDeciliter)   // TODO: This is wrong

        let descriptor = RemoteDataDescriptor(id: syncIdentifier ?? "WTF?", version: 1, kind: .create)    // TODO: Fix id & version

        return .success(TidepoolDeviceData(cbg, withDescriptor: descriptor))
    }

}

extension DeletedDoseEntry: TidepoolDeleteItemTransformable {

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
