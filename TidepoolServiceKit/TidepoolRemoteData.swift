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
    case invalidArray([Error])
}

class TidepoolDataWithRemoteDataDescriptor<T>: RemoteDataDescriptable {

    var data: T

    var descriptor: RemoteDataDescriptor?

    public init(_ data: T, withDescriptor descriptor: RemoteDataDescriptor? = nil) {
        self.data = data
        self.descriptor = descriptor
    }

}

typealias TidepoolDeviceData = TidepoolDataWithRemoteDataDescriptor<TPDeviceData>

protocol TidepoolDeviceDataTransformable {

    func transformTidepoolDeviceData() -> Result<TidepoolDeviceData, Error>

}

extension Array where Element: TidepoolDeviceDataTransformable {

    func transformTidepoolDeviceData() -> Result<[TidepoolDeviceData], Error> {
        var errors: [Error] = []
        var transformed: [TidepoolDeviceData] = []
        for data in self {
            switch data.transformTidepoolDeviceData() {
            case .failure(let error):
                errors.append(error)
            case .success(let data):
                transformed.append(data)
            }
        }
        guard errors.isEmpty else {
            return .failure(TransformError.invalidArray(errors))
        }
        return .success(transformed)
    }

}

typealias TidepoolDeleteItem = TidepoolDataWithRemoteDataDescriptor<TPDeleteItem>

protocol TidepoolDeleteItemTransformable {

    func transformTidepoolDeleteItem() -> Result<TidepoolDeleteItem, Error>

}

extension Array where Element: TidepoolDeleteItemTransformable {

    func transformTidepoolDeleteItem() -> Result<[TidepoolDeleteItem], Error> {
        var errors: [Error] = []
        var transformed: [TidepoolDeleteItem] = []
        for data in self {
            switch data.transformTidepoolDeleteItem() {
            case .failure(let error):
                errors.append(error)
            case .success(let data):
                transformed.append(data)
            }
        }
        guard errors.isEmpty else {
            return .failure(TransformError.invalidArray(errors))
        }
        return .success(transformed)
    }

}

typealias TidepoolRemoteData = AbstractRemoteData<TidepoolDeviceData, TidepoolDeleteItem>

protocol TidepoolRemoteDataTransformable {

    var isEmpty: Bool { get }

    func transformTidepoolRemoteData() -> Result<TidepoolRemoteData, Error>

}

extension TidepoolRemoteData {

    var latestDate: Date? {
        return stored.compactMap { $0.data.time }.max() // deleted does not have time
    }

    func filter() -> TidepoolRemoteData {
        let filterCache = RemoteDataDescriptorCache()
        filterCache.insert(stored)
        filterCache.insert(deleted)

        return TidepoolRemoteData(
            stored: filterCache.filter(stored.unique, with: RemoteDataDescriptor.supercedes),
            deleted: filterCache.filter(deleted.unique, with: RemoteDataDescriptor.supercedes)
        )
    }

}

extension AbstractRemoteData: TidepoolRemoteDataTransformable where S: TidepoolDeviceDataTransformable, D: TidepoolDeleteItemTransformable {

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
