//
//  TidepoolCarbRemoteDataQueryGroup.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 8/9/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import LoopKit
import TidepoolKit

struct TidepoolCarbRemoteDataQueryGroupSettings: TidepoolRemoteDataQueryGroupSettings {

    public static let recentTimeInterval: TimeInterval = .hours(6)  // TODO: Is this correct?

    public static let recentLimit: Int = 10         // 24 hours worth of data, more or less

    public static let installedLimit: Int = 10      // 24 hours worth of data, more or less

    public static let historicLimit: Int = 10       // 24 hours worth of data, more or less

}

final class TidepoolCarbRemoteDataQueryGroup: TidepoolRemoteDataQueryGroup<CarbRemoteDataQuery, TidepoolCarbRemoteDataQueryGroupSettings> {

    public weak var delegate: CarbRemoteDataQueryDelegate? {
        didSet {
            recent.query.delegate = delegate
            installed.query.delegate = delegate
            historic.query.delegate = delegate
        }
    }
    
}

extension StoredCarbEntry: TidepoolDeviceDataTransformable {

    func transformTidepoolDeviceData() -> Result<TidepoolDeviceData, Error> {

        // TODO: Rework and finish once TidepoolKit is more stable
        // TODO: Add absorptionTime to new field to be added by backend
        // TODO: Consider adding sampleUUID to food.payload["HKObjectUUID"]
        // TODO: Consider changing origin.type to "application"
        // TODO: Add multiple levels of origin
        // TODO: Are there any possible errors?
        // TODO: Fix TPDataFood to not be an optional
        // TODO: Fix origin

        var id: String
        var version: Int?

        if let syncIdentifier = syncIdentifier {
            id = syncIdentifier
            version = syncVersion
        } else {
            id = sampleUUID.uuidString
        }

        let nutrition = TPDataNutrition(carbohydrate: TPDataCarbohydrate(net: quantity.doubleValue(for: .gram())))
        let food = TPDataFood(time: startDate, name: foodType, nutrition: nutrition)
        food.origin = TPDataOrigin(id: id, name: Bundle.main.bundleIdentifier!, type: .service, version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)

        let descriptor = RemoteDataDescriptor(id: id, version: version ?? 0, kind: .create)

        return .success(TidepoolDeviceData(food, withDescriptor: descriptor))
    }

}

extension DeletedCarbEntry: TidepoolDeleteItemTransformable {

    func transformTidepoolDeleteItem() -> Result<TidepoolDeleteItem, Error> {

        // TODO: Fix TPDeleteItem to not be an optional

        var id: String
        var version: Int?

        if let syncIdentifier = syncIdentifier {
            id = syncIdentifier
            version = syncVersion
        } else if let uuidString = uuid?.uuidString {
            id = uuidString
        } else {
            return .failure(TransformError.identifierMissing(self))
        }

        let deleteItem = TPDeleteItem(origin: TPDataOrigin(id: id))!

        let descriptor = RemoteDataDescriptor(id: id, version: version ?? 0, kind: .delete)

        return .success(TidepoolDeleteItem(deleteItem, withDescriptor: descriptor))
    }

}
