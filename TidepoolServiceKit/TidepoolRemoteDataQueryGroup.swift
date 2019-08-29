//
//  TidepoolRemoteDataQueryGroup.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 8/9/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import LoopKit

protocol TidepoolRemoteDataQueryGroupable {

    /// Returns the recent query for the group
    var recentQuery: TidepoolRemoteDataQueryable { get }

    /// Returns the installed query for the group
    var installedQuery: TidepoolRemoteDataQueryable { get }

    /// Returns the historic query for the group
    var historicQuery: TidepoolRemoteDataQueryable { get }

}

protocol TidepoolRemoteDataQueryGroupSettings {

    /// Time interval for which data of this type is considered "recent" and relevant to an active Loop algorithm.
    /// Recent data is given priority over older data during upload. Also used to determine recent time before
    /// installed date.
    static var recentTimeInterval: TimeInterval { get }

    /// Maximum number of records of this data type queried at one time for a recent upload. An upload may consist
    /// of multiple queries of different data types while trying to keep each data type's data within a similar date range.
    /// The recent query uses startDate >= now - timeInterval with no endDate.
    static var recentLimit: Int { get }

    /// Maximum number of records of this data type queried at one time for a installed upload. An upload may consist
    /// of multiple queries of different data types while trying to keep each data type's data within a similar date range.
    /// The installed query uses startDate >= installDate - timeInterval with no endDate. The data retrieved from the installed
    /// query may overlap the recent query, but an internal cache will filter those duplicates.
    static var installedLimit: Int { get }

    /// Maximum number of records of this data type queried at one time for a historice upload. An upload may consist
    /// of multiple queries of different data types while trying to keep each data type's data within a similar date range.
    /// The historic query uses no startDate with endDate < installDate - timeInterval.
    static var historicLimit: Int { get }

}

class TidepoolRemoteDataQueryGroup<Q: RemoteDataQueryable, S: TidepoolRemoteDataQueryGroupSettings>: TidepoolRemoteDataQueryGroupable, RawRepresentable where Q.D: TidepoolRemoteDataTransformable {

    public typealias RawValue = [String: Any]

    public var recentQuery: TidepoolRemoteDataQueryable { return recent }

    public var installedQuery: TidepoolRemoteDataQueryable { return installed }

    public var historicQuery: TidepoolRemoteDataQueryable { return historic }

    private(set) var recent: TidepoolRecentRemoteDataQuery<Q>

    private(set) var installed: TidepoolInstalledRemoteDataQuery<Q>

    private(set) var historic: TidepoolHistoricRemoteDataQuery<Q>

    public init() {
        let installedDate = Date() - S.recentTimeInterval

        self.recent = TidepoolRecentRemoteDataQuery<Q>()
        self.installed = TidepoolInstalledRemoteDataQuery<Q>(startDate: installedDate, endDate: nil)
        self.historic = TidepoolHistoricRemoteDataQuery<Q>(startDate: nil, endDate: installedDate)

        initialize()
    }

    public required init?(rawValue: RawValue) {
        guard let recentRawValue = rawValue["recent"] as? TidepoolRecentRemoteDataQuery<Q>.RawValue,
            let recent = TidepoolRecentRemoteDataQuery<Q>(rawValue: recentRawValue),
            let installedRawValue = rawValue["installed"] as? TidepoolInstalledRemoteDataQuery<Q>.RawValue,
            let installed = TidepoolInstalledRemoteDataQuery<Q>(rawValue: installedRawValue),
            let historicRawValue = rawValue["historic"] as? TidepoolHistoricRemoteDataQuery<Q>.RawValue,
            let historic = TidepoolHistoricRemoteDataQuery<Q>(rawValue: historicRawValue) else {
                return nil
        }

        self.recent = recent
        self.installed = installed
        self.historic = historic

        initialize()
    }

    public var rawValue: RawValue {
        return [
            "recent": recent.rawValue,
            "installed": installed.rawValue,
            "historic": historic.rawValue
        ]
    }

    private func initialize() {
        recent.name = "recent"
        recent.timeInterval = S.recentTimeInterval
        recent.limit = S.recentLimit

        installed.name = "installed"
        installed.limit = S.installedLimit

        historic.name = "historic"
        historic.limit = S.historicLimit
    }

    public func reset() {
        recent.reset()
        installed.reset()
        historic.reset()
    }

}
