//
//  TidepoolService.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 7/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import os.log
import LoopKit
import TidepoolKit

public enum TidepoolServiceError: Error {
    case configuration
    case versionMissing
}

public protocol SessionStorage {
    func setSession(_ session: TSession?, for service: String) throws
    func getSession(for service: String) throws -> TSession?
}

public final class TidepoolService: Service, TAPIObserver {

    public static let serviceIdentifier = "TidepoolService"

    public static let localizedTitle = LocalizedString("Tidepool", comment: "The title of the Tidepool service")

    public weak var serviceDelegate: ServiceDelegate?

    public lazy var sessionStorage: SessionStorage? = KeychainManager()

    public let tapi: TAPI

    public private (set) var error: Error?

    private let id: String

    private var dataSetId: String? {
        didSet {
            completeUpdate()
        }
    }

    private var lastVersionInfo: VersionInfo?
    
    private let log = OSLog(category: "TidepoolService")
    private let tidepoolKitLog = OSLog(category: "TidepoolKit")

    public init(automaticallyFetchEnvironments: Bool = true) {
        self.id = UUID().uuidString
        tapi = TAPI(automaticallyFetchEnvironments: automaticallyFetchEnvironments)
        tapi.addObserver(self)
    }

    deinit {
        tapi.removeObserver(self)
    }

    public init?(rawState: RawStateValue) {
        tapi = TAPI()
        guard let id = rawState["id"] as? String else {
            return nil
        }
        do {
            self.id = id
            self.dataSetId = rawState["dataSetId"] as? String
            self.lastVersionInfo = (rawState["lastVersionInfo"] as? String).flatMap { VersionInfo(from: $0) }
            tapi.session = try sessionStorage?.getSession(for: sessionService)
        } catch let error {
            self.error = error
        }
        tapi.addObserver(self)
    }

    public var rawState: RawStateValue {
        var rawValue: RawStateValue = [:]
        rawValue["id"] = id
        rawValue["dataSetId"] = dataSetId
        rawValue["lastVersionInfo"] = lastVersionInfo?.toJSON()
        return rawValue
    }

    public let isOnboarded = true   // No distinction between created and onboarded

    public func apiDidUpdateSession(_ session: TSession?) {
        if session == nil {
            self.dataSetId = nil
        }
        do {
            try sessionStorage?.setSession(session, for: sessionService)
        } catch let error {
            self.error = error
        }
    }

    public func completeCreate(completion: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.getDataSet(completion: completion)
        }
    }

    public func completeUpdate() {
        serviceDelegate?.serviceDidUpdateState(self)
    }

    public func completeDelete() {
        DispatchQueue.global(qos: .background).async {
            self.tapi.logout() { _ in }
        }
        serviceDelegate?.serviceWantsDeletion(self)
    }

    private func getDataSet(completion: @escaping (Error?) -> Void) {
        guard let clientName = Bundle.main.bundleIdentifier else {
            completion(TidepoolServiceError.configuration)
            return
        }
        tapi.listDataSets(filter: TDataSet.Filter(clientName: clientName)) { result in
            switch result {
            case .failure(let error):
                completion(error)
            case .success(let dataSets):
                if !dataSets.isEmpty {
                    if dataSets.count > 1 {
                        self.log.error("Found multiple matching data sets; expected zero or one")
                    }
                    self.dataSetId = dataSets.first?.uploadId
                    completion(nil)
                } else {
                    self.createDataSet(completion: completion)
                }
            }
        }
    }

    private func createDataSet(completion: @escaping (Error?) -> Void) {
        guard let clientName = Bundle.main.bundleIdentifier, let clientVersion = Bundle.main.semanticVersion else {
            completion(TidepoolServiceError.configuration)
            return
        }
        let dataSet = TDataSet(dataSetType: .continuous,
                               client: TDataSet.Client(name: clientName, version: clientVersion),
                               deduplicator: TDataSet.Deduplicator(name: .dataSetDeleteOrigin))
        tapi.createDataSet(dataSet) { result in
            switch result {
            case .failure(let error):
                completion(error)
            case .success(let dataSet):
                self.dataSetId = dataSet.uploadId
                completion(nil)
            }
        }
    }

    private var sessionService: String { "org.tidepool.TidepoolService.\(id)" }
}

extension TidepoolService: TLogging {
    public func debug(_ message: String, function: StaticString, file: StaticString, line: UInt) {
        tidepoolKitLog.debug("%{public}@ %{public}@", message, location(function: function, file: file, line: line))
    }

    public func info(_ message: String, function: StaticString, file: StaticString, line: UInt) {
        tidepoolKitLog.info("%{public}@ %{public}@", message, location(function: function, file: file, line: line))
    }

    public func error(_ message: String, function: StaticString, file: StaticString, line: UInt) {
        tidepoolKitLog.error("%{public}@ %{public}@", message, location(function: function, file: file, line: line))
    }

    private func location(function: StaticString, file: StaticString, line: UInt) -> String {
        return "[\(URL(fileURLWithPath: file.description).lastPathComponent):\(line):\(function)]"
    }
}

extension TidepoolService: RemoteDataService {

    public var carbDataLimit: Int? { return 1000 }

    public func uploadCarbData(created: [SyncCarbObject], updated: [SyncCarbObject], deleted: [SyncCarbObject], completion: @escaping (Result<Bool, Error>) -> Void) {
        // TODO: This implementation is incorrect and will not record the full carb history, but only the latest change within this
        // subset of data. Waiting on https://tidepool.atlassian.net/browse/BACK-815 for backend to support new API to capture full
        // history of carb changes. Once backend support is available, this will be updated in https://tidepool.atlassian.net/browse/LOOP-1660.
        createData(created.compactMap { $0.datum }) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let createdUploaded):
                self.createData(updated.compactMap { $0.datum }) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let updatedUploaded):
                        self.deleteData(withSelectors: deleted.compactMap { $0.selector }) { result in
                            switch result {
                            case .failure(let error):
                                completion(.failure(error))
                            case .success(let deletedUploaded):
                                completion(.success(createdUploaded || updatedUploaded || deletedUploaded))
                            }
                        }
                    }
                }
            }
        }
    }

    public var doseDataLimit: Int? { return 1000 }

    public var dosingDecisionDataLimit: Int? { return 50 }  // Each can be up to 20K bytes of serialized JSON, target ~1M or less

    public var glucoseDataLimit: Int? { return 1000 }

    public func uploadGlucoseData(_ stored: [StoredGlucoseSample], completion: @escaping (Result<Bool, Error>) -> Void) {
        createData(stored.compactMap { $0.datum }, completion: completion)
    }

    public var pumpEventDataLimit: Int? { return 1000 }

    public var settingsDataLimit: Int? { return 400 }  // Each can be up to 2.5K bytes of serialized JSON, target ~1M or less

    private func createData(_ data: [TDatum], completion: @escaping (Result<Bool, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let dataSetId = dataSetId else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        tapi.createData(data, dataSetId: dataSetId) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(!data.isEmpty))
        }
    }

    private func deleteData(withSelectors selectors: [TDatum.Selector], completion: @escaping (Result<Bool, Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let dataSetId = dataSetId else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        tapi.deleteData(withSelectors: selectors, dataSetId: dataSetId) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(!selectors.isEmpty))
        }
    }
}

extension TidepoolService: VersionCheckService {
    
    public func checkVersion(bundleIdentifier: String, currentVersion: String, completion: @escaping (Result<VersionUpdate?, Error>) -> Void) {
        // TODO: ideally the backend API takes `bundleIdentifier` as a parameter, instead of returning a big struct
        // with all version info (which we parse below)
        // Note also that this will use the _default environment_ unless the user
        // switches environments and logs in.
        tapi.getInfo() { [weak self] result in
            switch result {
            case .failure(let error):
                // If an error occurs, respond with the last-known version info, otherwise, reply with an error
                if let versionInfo = self?.lastVersionInfo {
                    self?.log.error("checkVersion error: %{public}@ Returning %{public}@",
                                    error.localizedDescription,
                                    versionInfo.getVersionUpdateNeeded(currentVersion: currentVersion).localizedDescription)
                    completion(.success(versionInfo.getVersionUpdateNeeded(currentVersion: currentVersion)))
                } else {
                    self?.log.error("checkVersion error: %{public}@", error.localizedDescription)
                    completion(.failure(error))
                }
            case .success(let info):
                self?.log.debug("checkVersion info = %{public}@ for %{public}@", info.versions.debugDescription, bundleIdentifier)
                let versionInfo = info.versions?.loop.flatMap { VersionInfo(bundleIdentifier: bundleIdentifier, loop: $0) }
                self?.lastVersionInfo = versionInfo
                completion(.success(versionInfo?.getVersionUpdateNeeded(currentVersion: currentVersion)))
            }
        }
    }
}

extension KeychainManager: SessionStorage {
    public func setSession(_ session: TSession?, for service: String) throws {
        try deleteGenericPassword(forService: service)
        guard let session = session else {
            return
        }
        let sessionData = try JSONEncoder.tidepool.encode(session)
        try replaceGenericPassword(sessionData, forService: service)
    }

    public func getSession(for service: String) throws -> TSession? {
        let sessionData = try getGenericPasswordForServiceAsData(service)
        return try JSONDecoder.tidepool.decode(TSession.self, from: sessionData)
    }
}

extension TidepoolServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .configuration: return NSLocalizedString("Configuration Error", comment: "Error string for configuration error")
        case .versionMissing: return NSLocalizedString("Version response missing", comment: "Error string for version missing error")
        }
    }
}
