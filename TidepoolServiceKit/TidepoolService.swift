//
//  TidepoolService.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 7/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import os.log
import HealthKit
import LoopKit
import TidepoolKit

public final class TidepoolService: Service {

    public static let serviceIdentifier = "TidepoolService"

    public static let localizedTitle = LocalizedString("Tidepool", comment: "The title of the Tidepool service")

    public weak var serviceDelegate: ServiceDelegate?

    public weak var remoteDataServiceDelegate: RemoteDataServiceDelegate?

    public let tidepoolKit: TidepoolKit = TidepoolKit(logger: TidepoolServiceLogging()) // TODO: Consider specifying dispatch queue here

    private let queue = DispatchQueue(label: "org.tidepool.TidepoolServiceQueue", qos: .utility)

    public private(set) var host: String

    private var error: TPError?

    private var session: TPSession?

    public var user: TPUser? { return session?.user }

    private var dataSet: TPDataset?

    public let limit: Int = 2000

    private let statusRemoteDataQueryMaximumLimit = 1000

    private var statusRemoteDataQuery: StatusRemoteDataQuery

    private let settingsRemoteDataQueryMaximumLimit = 1000

    private var settingsRemoteDataQuery: SettingsRemoteDataQuery

    private let glucoseRemoteDataQueryMaximumLimit = 1000

    private var glucoseRemoteDataQuery: GlucoseRemoteDataQuery

    private let doseRemoteDataQueryMaximumLimit = 1000

    private var doseRemoteDataQuery: DoseRemoteDataQuery

    private let carbRemoteDataQueryMaximumLimit = 1000

    private var carbRemoteDataQuery: CarbRemoteDataQuery

    private let log = OSLog(category: "TidepoolService")

    public init() {
        self.statusRemoteDataQuery = StatusRemoteDataQuery()
        self.settingsRemoteDataQuery = SettingsRemoteDataQuery()
        self.glucoseRemoteDataQuery = GlucoseRemoteDataQuery()
        self.doseRemoteDataQuery = DoseRemoteDataQuery()
        self.carbRemoteDataQuery = CarbRemoteDataQuery()
        self.host = "api.tidepool.org"
    }

    public init?(rawState: RawStateValue) {
        guard
            let rawStatusRemoteDataQuery = rawState["statusRemoteDataQuery"] as? StatusRemoteDataQuery.RawValue,
            let statusRemoteDataQuery = StatusRemoteDataQuery(rawValue: rawStatusRemoteDataQuery),
            let rawSettingsRemoteDataQuery = rawState["settingsRemoteDataQuery"] as? SettingsRemoteDataQuery.RawValue,
            let settingsRemoteDataQuery = SettingsRemoteDataQuery(rawValue: rawSettingsRemoteDataQuery),
            let rawGlucoseRemoteDataQuery = rawState["glucoseRemoteDataQuery"] as? GlucoseRemoteDataQuery.RawValue,
            let glucoseRemoteDataQuery = GlucoseRemoteDataQuery(rawValue: rawGlucoseRemoteDataQuery),
            let rawDoseRemoteDataQuery = rawState["doseRemoteDataQuery"] as? DoseRemoteDataQuery.RawValue,
            let doseRemoteDataQuery = DoseRemoteDataQuery(rawValue: rawDoseRemoteDataQuery),
            let rawCarbRemoteDataQuery = rawState["carbRemoteDataQuery"] as? CarbRemoteDataQuery.RawValue,
            let carbRemoteDataQuery = CarbRemoteDataQuery(rawValue: rawCarbRemoteDataQuery),
            let host = rawState["host"] as? String
        else {
            return nil
        }

        self.statusRemoteDataQuery = statusRemoteDataQuery
        self.settingsRemoteDataQuery = settingsRemoteDataQuery
        self.glucoseRemoteDataQuery = glucoseRemoteDataQuery
        self.doseRemoteDataQuery = doseRemoteDataQuery
        self.carbRemoteDataQuery = carbRemoteDataQuery
        self.host = host

        restoreSession()
    }

    public var rawState: RawStateValue {
        var rawState: RawStateValue = [:]
        rawState["statusRemoteDataQuery"] = statusRemoteDataQuery.rawValue
        rawState["settingsRemoteDataQuery"] = settingsRemoteDataQuery.rawValue
        rawState["glucoseRemoteDataQuery"] = glucoseRemoteDataQuery.rawValue
        rawState["doseRemoteDataQuery"] = doseRemoteDataQuery.rawValue
        rawState["carbRemoteDataQuery"] = carbRemoteDataQuery.rawValue
        rawState["host"] = host
        return rawState
    }

    public func completeCreate(withSession session: TPSession) {
        self.host = session.serverHost

        saveSession(session)
        restoreDataset()
    }

    public func completeUpdate() {
        serviceDelegate?.serviceDidUpdateState(self)
    }

    public func completeDelete() {
        if let session = session {
            tidepoolKit.logOut(from: session) { result in
                self.clearSession()
            }
        }
    }

    private func saveSession(_ session: TPSession) {
        try! KeychainManager().setTidepoolAuthenticationToken(session.authenticationToken)
        self.session = session
    }

    private func restoreSession() {
        if let tidepoolAuthenticationToken = try? KeychainManager().getTidepoolAuthenticationToken() {
            let session = TPSession(tidepoolAuthenticationToken, serverHost: host)
            tidepoolKit.refreshSession(session) { result in
                switch result {
                case .failure(let error):
                    self.error = error
                case .success(let session):
                    self.session = session
                    self.restoreDataset()
                }
            }
        } else {
            self.error = .unauthorized
        }
    }

    private func clearSession() {
        try! KeychainManager().setTidepoolAuthenticationToken()
        self.session = nil
    }

    private func restoreDataset() {
        guard
            let session = session,
            let user = session.user,
            let name = Bundle.main.bundleIdentifier,
            let version = Bundle.main.bundleVersionBuild
        else {
            self.error = .internalError
            return
        }

        let client = TPDatasetClient(name: name, version: version)
        let deduplicator = TPDeduplicator(type: .dataset_delete_origin)
        let dataSet = TPDataset(client: client, deduplicator: deduplicator, dataSetType: .continuous)
        tidepoolKit.getDataset(for: user, matching: dataSet, with: session) { result in
            switch result {
            case .failure(let error):
                self.error = error
            case .success(let dataSet):
                self.dataSet = dataSet
            }
        }
    }

}

extension TidepoolService: RemoteDataService {

    public func synchronizeRemoteData(completion: @escaping (Result<Bool, Error>) -> Void) {
        statusRemoteDataQuery.delegate = remoteDataServiceDelegate?.statusRemoteDataQueryDelegate
        settingsRemoteDataQuery.delegate = remoteDataServiceDelegate?.settingsRemoteDataQueryDelegate
        glucoseRemoteDataQuery.delegate = remoteDataServiceDelegate?.glucoseRemoteDataQueryDelegate
        doseRemoteDataQuery.delegate = remoteDataServiceDelegate?.doseRemoteDataQueryDelegate
        carbRemoteDataQuery.delegate = remoteDataServiceDelegate?.carbRemoteDataQueryDelegate

        synchronizeAllRemoteData(TidepoolRemoteData()) { result in
            switch result {
            case .failure(let error):
                self.statusRemoteDataQuery.abort()
                self.settingsRemoteDataQuery.abort()
                self.glucoseRemoteDataQuery.abort()
                self.doseRemoteDataQuery.abort()
                self.carbRemoteDataQuery.abort()
                completion(.failure(error))
            case .success(let uploaded):
                self.statusRemoteDataQuery.commit()
                self.settingsRemoteDataQuery.commit()
                self.glucoseRemoteDataQuery.commit()
                self.doseRemoteDataQuery.commit()
                self.carbRemoteDataQuery.commit()
                self.serviceDelegate?.serviceDidUpdateState(self)
                completion(.success(uploaded))
            }
        }
    }

    private func synchronizeAllRemoteData(_ data: TidepoolRemoteData, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let session = self.session,
            let dataSet = self.dataSet
        else {
            completion(.failure(TPError.unauthorized))
            return
        }

        // TODO: Prevent reentrancy
        synchronizeStatusRemoteData(data) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                self.synchronizeSettingsRemoteData(data) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let data):
                        self.synchronizeGlucoseRemoteData(data) { result in
                            switch result {
                            case .failure(let error):
                                completion(.failure(error))
                            case .success(let data):
                                self.synchronizeDoseRemoteData(data) { result in
                                    switch result {
                                    case .failure(let error):
                                        completion(.failure(error))
                                    case .success(let data):
                                        self.synchronizeCarbRemoteData(data) { result in
                                            switch result {
                                            case .failure(let error):
                                                completion(.failure(error))
                                            case .success(let data):
                                                self.tidepoolKit.putData(samples: data.stored, into: dataSet, with: session) { result in
                                                    switch result {
                                                    case .failure(let error):
                                                        completion(.failure(error))
                                                    case .success:
                                                        self.tidepoolKit.deleteData(samples: data.deleted, from: dataSet, with: session) { result in
                                                            switch result {
                                                            case .failure(let error):
                                                                completion(.failure(error))
                                                            case .success:
                                                                completion(.success(!data.isEmpty))
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func synchronizeStatusRemoteData(_ tidepoolRemoteData: TidepoolRemoteData, completion: @escaping (Result<TidepoolRemoteData, Error>) -> Void) {
        var tidepoolRemoteData = tidepoolRemoteData
        statusRemoteDataQuery.execute(maximumLimit: statusRemoteDataQueryMaximumLimit) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                switch data.transformTidepoolDeviceData() {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let transformedData):
                    tidepoolRemoteData.stored.append(contentsOf: transformedData)
                    completion(.success(tidepoolRemoteData))
                }
            }
        }
    }

    private func synchronizeSettingsRemoteData(_ tidepoolRemoteData: TidepoolRemoteData, completion: @escaping (Result<TidepoolRemoteData, Error>) -> Void) {
        var tidepoolRemoteData = tidepoolRemoteData
        settingsRemoteDataQuery.execute(maximumLimit: settingsRemoteDataQueryMaximumLimit) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                switch data.transformTidepoolDeviceData() {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let transformedData):
                    tidepoolRemoteData.stored.append(contentsOf: transformedData)
                    completion(.success(tidepoolRemoteData))
                }
            }
        }
    }

    private func synchronizeGlucoseRemoteData(_ tidepoolRemoteData: TidepoolRemoteData, completion: @escaping (Result<TidepoolRemoteData, Error>) -> Void) {
        var tidepoolRemoteData = tidepoolRemoteData
        glucoseRemoteDataQuery.execute(maximumLimit: glucoseRemoteDataQueryMaximumLimit) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                switch data.transformTidepoolDeviceData() {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let transformedData):
                    tidepoolRemoteData.stored.append(contentsOf: transformedData)
                    completion(.success(tidepoolRemoteData))
                }
            }
        }
    }

    private func synchronizeDoseRemoteData(_ tidepoolRemoteData: TidepoolRemoteData, completion: @escaping (Result<TidepoolRemoteData, Error>) -> Void) {
        var tidepoolRemoteData = tidepoolRemoteData
        doseRemoteDataQuery.execute(maximumLimit: doseRemoteDataQueryMaximumLimit) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                switch data.transformTidepoolDeviceData() {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let transformedData):
                    tidepoolRemoteData.stored.append(contentsOf: transformedData)
                    completion(.success(tidepoolRemoteData))
                }
            }
        }
    }

    private func synchronizeCarbRemoteData(_ tidepoolRemoteData: TidepoolRemoteData, completion: @escaping (Result<TidepoolRemoteData, Error>) -> Void) {
        var tidepoolRemoteData = tidepoolRemoteData
        carbRemoteDataQuery.execute(maximumLimit: carbRemoteDataQueryMaximumLimit) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                switch data.transformTidepoolRemoteData() {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let transformedData):
                    tidepoolRemoteData.stored.append(contentsOf: transformedData.stored)
                    tidepoolRemoteData.deleted.append(contentsOf: transformedData.deleted)
                    completion(.success(tidepoolRemoteData))
                }
            }
        }
    }

}

extension KeychainManager {

    func setTidepoolAuthenticationToken(_ tidepoolAuthenticationToken: String? = nil) throws {
        try replaceGenericPassword(tidepoolAuthenticationToken, forService: TidepoolAuthenticationTokenService)
    }

    func getTidepoolAuthenticationToken() throws -> String {
        return try getGenericPasswordForService(TidepoolAuthenticationTokenService)
    }

}

fileprivate let TidepoolAuthenticationTokenService = "TidepoolAuthenticationToken"
