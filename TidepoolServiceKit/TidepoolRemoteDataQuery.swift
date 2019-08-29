//
//  TidepoolRemoteDataQuery.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 8/9/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import os.log
import LoopKit

protocol TidepoolRemoteDataQueryable {

    var limit: Int? { get }

    var latestDate: Date? { get }

    func execute(maximumLimit: Int, completion: @escaping (Result<TidepoolRemoteData?, Error>) -> Void)

    func abort()

    func commit()

}

class TidepoolRangedRemoteDataQuery<Q: RemoteDataQueryable>: TidepoolRemoteDataQueryable, RawRepresentable where Q.D: TidepoolRemoteDataTransformable {

    public typealias RawValue = [String: Any]

    public var name: String = ""

    public internal(set) var query: Q

    public var limit: Int? {
        get {
            return query.limit
        }
        set {
            query.limit = newValue
        }
    }

    public private(set) var latestDate: Date?

    private(set) var pendingLatestDate: Date?

    let log: OSLog

    public init(startDate: Date? = nil, endDate: Date? = nil) {
        let anchor = RemoteDataAnchor(startDate: startDate, endDate: endDate, includeCache: true, includeHealthKit: true)
        self.query = Q.init(anchor: anchor)
        self.log = OSLog(category: String(describing: Swift.type(of: self)))
    }

    public required init?(rawValue: RawValue) {
        guard let queryRawValue = rawValue["query"] as? Q.RawValue,
            let query = Q.init(rawValue: queryRawValue) else {
                return nil
        }

        self.query = query
        self.latestDate = rawValue["latestDate"] as? Date
        self.log = OSLog(category: String(describing: Swift.type(of: self)))
    }

    public var rawValue: RawValue {
        var rawValue: RawValue = [:]
        rawValue["query"] = query.rawValue
        rawValue["latestDate"] = latestDate
        return rawValue
    }

    public func execute(maximumLimit: Int, completion: @escaping (Result<TidepoolRemoteData?, Error>) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)
        var queryResult: Result<Q.D, Error>?

        query.execute(maximumLimit: maximumLimit) { result in
            queryResult = result
            semaphore.signal()
        }

        switch semaphore.wait(timeout: .now() + .seconds(60)) {
        case .timedOut:
            completion(.failure(RemoteDataError.queryTimeout))
        case .success:
            switch queryResult! {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                if data.isEmpty {
                    completion(.success(nil))
                } else {
                    switch data.transformTidepoolRemoteData() {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let data):
                        completion(.success(self.pending(data)))
                    }
                }
            }
        }
    }

    func pending(_ data: TidepoolRemoteData) -> TidepoolRemoteData {
        let dataLatestDate = data.latestDate
        if pendingLatestDate ?? .distantPast < dataLatestDate ?? .distantPast {
            pendingLatestDate = dataLatestDate
        }
        return data
    }

    public func abort() {
        query.abort()
        pendingLatestDate = nil
        log.debug("[%{public}@] Query aborted", name)
    }

    public func commit() {
        query.commit()
        if latestDate ?? .distantPast < pendingLatestDate ?? .distantPast {
            latestDate = pendingLatestDate
        }
        pendingLatestDate = nil
        log.debug("[%{public}@] Query committed [latestDate: %{public}@]", name, String(describing: latestDate))
    }

    public func reset() {
        query.reset()
        latestDate = nil
        pendingLatestDate = nil
    }

}

class TidepoolRecentRemoteDataQuery<Q: RemoteDataQueryable>: TidepoolRangedRemoteDataQuery<Q> where Q.D: TidepoolRemoteDataTransformable {

    public var timeInterval: TimeInterval?

    public init(timeInterval: TimeInterval? = nil) {
        self.timeInterval = timeInterval
        super.init()
    }

    public required init?(rawValue: RawValue) {
        super.init(rawValue: rawValue)
    }

    public override func execute(maximumLimit: Int, completion: @escaping (Result<TidepoolRemoteData?, Error>) -> Void) {
        // If a time interval is specified and there is either no query start date or the latest date from
        // the query is too old, then restart the recent query with a new start date
        if let timeInterval = timeInterval {
            let currentStartDate = Date() - timeInterval
            let currentLatestDate = max(latestDate ?? .distantPast, pendingLatestDate ?? .distantPast)
            if query.anchor.startDate == nil || (currentLatestDate != .distantPast && currentLatestDate < currentStartDate) {       // TODO: Temporary, not quite right
                let anchor = RemoteDataAnchor(startDate: currentStartDate, endDate: query.anchor.endDate, includeCache: query.anchor.includeCache, includeHealthKit: query.anchor.includeHealthKit)
                query = Q.init(anchor: anchor)
                print(currentLatestDate)
                print(currentStartDate)
                log.debug("[%{public}@] Query updated [startDate: %{public}@]", name, String(describing: currentStartDate))
            }
        }

        super.execute(maximumLimit: maximumLimit, completion: completion)
    }

}

class TidepoolInstalledRemoteDataQuery<Q: RemoteDataQueryable>: TidepoolRangedRemoteDataQuery<Q> where Q.D: TidepoolRemoteDataTransformable {}

class TidepoolHistoricRemoteDataQuery<Q: RemoteDataQueryable>: TidepoolRangedRemoteDataQuery<Q> where Q.D: TidepoolRemoteDataTransformable {

    override func pending(_ data: TidepoolRemoteData) -> TidepoolRemoteData {
        return super.pending(TidepoolRemoteData(stored: data.stored))   // Do not upload historic deleted, already captured by previous queries
    }

}
