//
//  TidepoolRemoteData.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 8/9/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import LoopKit
import TidepoolKit

enum TransformError: Error {
    case identifierMissing(Any)
    case invalidData
    case invalidArray([Error])
}

typealias TidepoolDeviceData = TPDeviceData

protocol TidepoolDeviceDataTransformable {

    func transformTidepoolDeviceData() -> Result<[TidepoolDeviceData], Error>

}

extension Array: TidepoolDeviceDataTransformable where Element: TidepoolDeviceDataTransformable {

    func transformTidepoolDeviceData() -> Result<[TidepoolDeviceData], Error> {
        var errors: [Error] = []
        var transformed: [TidepoolDeviceData] = []
        for data in self {
            switch data.transformTidepoolDeviceData() {
            case .failure(let error):
                errors.append(error)
            case .success(let data):
                transformed.append(contentsOf: data)
            }
        }
        guard errors.isEmpty else {
            return .failure(TransformError.invalidArray(errors))
        }
        return .success(transformed)
    }

}

typealias TidepoolDeleteItem = TPDeleteItem

protocol TidepoolDeleteItemTransformable {

    func transformTidepoolDeleteItem() -> Result<[TidepoolDeleteItem], Error>

}

extension Array: TidepoolDeleteItemTransformable where Element: TidepoolDeleteItemTransformable {

    func transformTidepoolDeleteItem() -> Result<[TidepoolDeleteItem], Error> {
        var errors: [Error] = []
        var transformed: [TidepoolDeleteItem] = []
        for data in self {
            switch data.transformTidepoolDeleteItem() {
            case .failure(let error):
                errors.append(error)
            case .success(let data):
                transformed.append(contentsOf: data)
            }
        }
        guard errors.isEmpty else {
            return .failure(TransformError.invalidArray(errors))
        }
        return .success(transformed)
    }

}

typealias TidepoolRemoteData = StoredAndDeletedRemoteData<TPDeviceData, TPDeleteItem>

extension StoredAndDeletedRemoteData where S: TidepoolDeviceDataTransformable, D: TidepoolDeleteItemTransformable {

    func transformTidepoolRemoteData() -> Result<TidepoolRemoteData, Error> {
        var errors: [Error] = []
        var transformed = TidepoolRemoteData()

        switch stored.transformTidepoolDeviceData() {
        case .failure(let error):
            errors.append(error)
        case .success(let stored):
            transformed.stored = stored
        }

        switch deleted.transformTidepoolDeleteItem() {
        case .failure(let error):
            errors.append(error)
        case .success(let deleted):
            transformed.deleted = deleted
        }

        guard errors.isEmpty else {
            return .failure(TransformError.invalidArray(errors))
        }
        return .success(transformed)
    }

}

extension StoredStatus: TidepoolDeviceDataTransformable {

    func transformTidepoolDeviceData() -> Result<[TidepoolDeviceData], Error> {
        return .success([]) // TODO: Add data type
    }

}

extension StoredSettings: TidepoolDeviceDataTransformable {

    func transformTidepoolDeviceData() -> Result<[TidepoolDeviceData], Error> {
        return .success([]) // TODO: Add data type
    }

}

extension StoredGlucoseSample: TidepoolDeviceDataTransformable {

    func transformTidepoolDeviceData() -> Result<[TidepoolDeviceData], Error> {
        let data = TPDataCbg(time: startDate, value: quantity.doubleValue(for: .milligramsPerDeciliter), units: .milligramsPerDeciliter)
        data.origin = TPDataOrigin(id: syncIdentifier, name: Bundle.main.bundleIdentifier!, type: .service, version: Bundle.main.bundleVersionBuild)
        return .success([data])
    }

}

extension PersistedPumpEvent: TidepoolDeviceDataTransformable {

    func transformTidepoolDeviceData() -> Result<[TidepoolDeviceData], Error> {
        guard let type = type else {
            return .failure(TransformError.invalidData)
        }

        let origin = TPDataOrigin(id: dose?.syncIdentifier ?? objectIDURL.absoluteString, name: Bundle.main.bundleIdentifier!, type: .service, version: Bundle.main.bundleVersionBuild)

        switch type {
        case .alarm:
            return .success([]) // TODO: Add data type
        case .alarmClear:
            return .success([]) // TODO: Add data type
        case .basal:
            guard
                let dose = dose,
                dose.type == .basal,
                dose.unit == .unitsPerHour
                else {
                    return .failure(TransformError.invalidData)
            }
            let basal = TPDataBasalScheduled(time: dose.startDate, rate: dose.unitsPerHour, duration: dose.endDate.timeIntervalSince(dose.startDate))
            basal.origin = origin
            return .success([basal])
        case .bolus:
            guard
                let dose = dose,
                dose.type == .bolus,
                dose.unit == .units
                else {
                    return .failure(TransformError.invalidData)
            }
            let data: TPDataBolusNormal
            if let deliveredUnits = dose.deliveredUnits, deliveredUnits != dose.programmedUnits {
                data = TPDataBolusNormal(time: dose.startDate, normal: deliveredUnits, expectedNormal: dose.programmedUnits)
            } else {
                data = TPDataBolusNormal(time: dose.startDate, normal: dose.programmedUnits)
            }
            data.origin = origin
            return .success([data])
        case .prime:
            return .success([]) // TODO: Add data type
        case .resume:
            return .success([]) // TODO: Add data type
        case .rewind:
            return .success([]) // TODO: Add data type
        case .suspend:
            return .success([]) // TODO: Add data type
        case .tempBasal:
            guard
                let dose = dose,
                dose.type == .tempBasal,
                dose.unit == .unitsPerHour
                else {
                    return .failure(TransformError.invalidData)
            }
            let data = TPDataBasalAutomated(time: dose.startDate, rate: dose.unitsPerHour, duration: dose.endDate.timeIntervalSince(dose.startDate))
            data.origin = origin
            return .success([data])
        }
    }

}

extension StoredCarbEntry: TidepoolDeviceDataTransformable {

    func transformTidepoolDeviceData() -> Result<[TidepoolDeviceData], Error> {
        let nutrition = TPDataNutrition(carbohydrate: TPDataCarbohydrate(net: quantity.doubleValue(for: .gram())))
        let data = TPDataFood(time: startDate, name: foodType, nutrition: nutrition)
        data.origin = TPDataOrigin(id: syncIdentifier ?? sampleUUID.uuidString, name: Bundle.main.bundleIdentifier!, type: .service, version: Bundle.main.bundleVersionBuild)
        return .success([data])
    }

}

extension DeletedCarbEntry: TidepoolDeleteItemTransformable {

    func transformTidepoolDeleteItem() -> Result<[TidepoolDeleteItem], Error> {
        guard let id = syncIdentifier ?? uuid?.uuidString else {
            return .failure(TransformError.identifierMissing(self))
        }

        let deleteItem = TPDeleteItem(origin: TPDataOrigin(id: id))!
        return .success([deleteItem])
    }

}
