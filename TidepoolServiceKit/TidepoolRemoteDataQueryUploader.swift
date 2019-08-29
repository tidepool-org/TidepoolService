//
//  TidepoolRemoteDataQueryUploader.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 8/9/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import os.log
import LoopKit
import TidepoolKit

protocol TidepoolRemoteDataInsertDelegate: AnyObject {

    func insert(data: TidepoolRemoteData)

}

protocol TidepoolRemoteDataRemoveDelegate: AnyObject {

    func remove(data: TidepoolRemoteData)

}

protocol TidepoolRemoteDataFilterDelegate: AnyObject {

    func filter(data: TidepoolRemoteData) -> TidepoolRemoteData

}

final class TidepoolRemoteDataQueryUploader {

    public weak var insertDelegate: TidepoolRemoteDataInsertDelegate?

    public weak var removeDelegate: TidepoolRemoteDataRemoveDelegate?

    public weak var filterDelegate: TidepoolRemoteDataFilterDelegate?

    public let queries: [TidepoolRemoteDataQueryable]

    public let limit: Int

    private let tidepoolKit: TidepoolKit

    private let dataset: TPDataset

    private var pendingData: TidepoolRemoteData

    private let log = OSLog(category: "TidepoolRemoteDataQueryUploader")

    public init(queries: [TidepoolRemoteDataQueryable], limit: Int, tidepoolKit: TidepoolKit, dataset: TPDataset) {
        self.queries = queries
        self.limit = limit
        self.tidepoolKit = tidepoolKit
        self.dataset = dataset
        self.pendingData = TidepoolRemoteData()
    }

    public func upload(completion: @escaping (Result<Bool, Error>) -> Void) {
        upload(withQueries: queries) { result in
            switch result {
            case .failure:
                self.abort()
            case .success:
                self.commit()
            }
            completion(result)
        }
    }

    private func upload(withQueries queries: [TidepoolRemoteDataQueryable], completion: @escaping (Result<Bool, Error>) -> Void) {
        var completed = false
        var remainingLimit = limit - pendingData.limit
        var remainingQueries = queries
        while !completed && remainingLimit > 0 && !remainingQueries.isEmpty {
            remainingQueries.sort { return $0.latestDate ?? .distantPast < $1.latestDate ?? .distantPast }
            if let query = remainingQueries.first {
                query.execute(maximumLimit: remainingLimit) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                        completed = true
                    case .success(let data):
                        if let data = data {
                            self.pending(data)
                            remainingLimit = self.limit - self.pendingData.limit
                        } else {
                            remainingQueries = Array(remainingQueries.dropFirst())  // No further calls to this query if no data available from last query
                        }
                    }
                }
            }
        }
        if !completed {
            uploadStored(completion: completion)
        }
    }

    private func pending(_ data: TidepoolRemoteData) {
        pendingData.append(contentsOf: data)
        pendingData = pendingData.filter()
        if let filterDelegate = self.filterDelegate {
            pendingData = filterDelegate.filter(data: pendingData)
        }
    }

    private func abort() {
        queries.forEach { $0.abort() }
        pendingData.removeAll()
    }

    private func commit() {
        queries.forEach { $0.commit() }
        removeDelegate?.remove(data: pendingData)
        insertDelegate?.insert(data: pendingData)
        pendingData.removeAll()
    }

    private func uploadStored(completion: @escaping (Result<Bool, Error>) -> Void) {
        if pendingData.stored.isEmpty {
            uploadDeleted(completion: completion)
            return
        }

        let semaphore = DispatchSemaphore(value: 0)

        var tidepoolKitError: Error?
        tidepoolKit.putData(samples: pendingData.stored.map({ $0.data }), into: dataset) { result in
            switch result {
            case .failure(let error):
                tidepoolKitError = error
            case .success:
                break
            }
            semaphore.signal()
        }

        if semaphore.wait(timeout: .now() + .seconds(600)) == .timedOut {
            log.debug("TidepoolKit timeout during putData")
            completion(.failure(RemoteDataError.networkTimeout))
            return
        }

        if let tidepoolKitError = tidepoolKitError {
            completion(.failure(RemoteDataError.networkFailure(tidepoolKitError)))
            return
        }

        log.debug("Stored %d data", pendingData.stored.count)
        uploadDeleted(completion: completion)
    }

    private func uploadDeleted(completion: @escaping (Result<Bool, Error>) -> Void) {
        if pendingData.deleted.isEmpty {
            completion(.success(!pendingData.isEmpty))
            return
        }

        let semaphore = DispatchSemaphore(value: 0)

        var tidepoolKitError: Error?
        tidepoolKit.deleteData(samples: pendingData.deleted.map({ $0.data }), from: dataset) { result in
            switch result {
            case .failure(let error):
                tidepoolKitError = error
            case .success:
                break
            }
            semaphore.signal()
        }

        if semaphore.wait(timeout: .now() + .seconds(600)) == .timedOut {
            log.debug("TidepoolKit timeout during deleteData")
            completion(.failure(RemoteDataError.networkTimeout))
            return
        }

        if let tidepoolKitError = tidepoolKitError {
            completion(.failure(RemoteDataError.networkFailure(tidepoolKitError)))
            return
        }

        log.debug("Deleted %d data", pendingData.deleted.count)
        completion(.success(!pendingData.isEmpty))
    }

}

final class TidepoolRemoteDataQueryGroupUploader {

    private var uploaders: [TidepoolRemoteDataQueryUploader]
    
    public init(groups: [TidepoolRemoteDataQueryGroupable], limit: Int, descriptorCache: RemoteDataDescriptorCache, tidepoolKit: TidepoolKit, dataset: TPDataset) {
        let recent = TidepoolRemoteDataQueryUploader(queries: groups.map { $0.recentQuery }, limit: limit, tidepoolKit: tidepoolKit, dataset: dataset)
        recent.filterDelegate = descriptorCache
        recent.insertDelegate = descriptorCache

        let installed = TidepoolRemoteDataQueryUploader(queries: groups.map { $0.installedQuery }, limit: limit, tidepoolKit: tidepoolKit, dataset: dataset)
        installed.filterDelegate = descriptorCache
        installed.removeDelegate = descriptorCache

        let historic = TidepoolRemoteDataQueryUploader(queries: groups.map { $0.historicQuery }, limit: limit, tidepoolKit: tidepoolKit, dataset: dataset)

        self.uploaders = [recent, installed, historic]
    }

    public func upload(completion: @escaping (Result<Bool, Error>) -> Void) {
        var completed = false
        var remainingUploaders = uploaders
        while !completed && !remainingUploaders.isEmpty {
            remainingUploaders.first!.upload { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                    completed = true
                case .success(let uploaded):
                    if uploaded {
                        completion(.success(true))
                        completed = true
                    } else {
                        remainingUploaders = Array(remainingUploaders.dropFirst())
                    }
                }
            }
        }
        if !completed {
            completion(.success(false))
        }
    }

}
