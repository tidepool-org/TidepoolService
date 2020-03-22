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

public protocol SessionStorage {
    func setSession(_ session: TSession?, for service: String) throws
    func getSession(for service: String) throws -> TSession?
}

public final class TidepoolService: Service {

    public static let serviceIdentifier = "TidepoolService"

    public static let localizedTitle = LocalizedString("Tidepool", comment: "The title of the Tidepool service")

    public weak var serviceDelegate: ServiceDelegate?

    public lazy var sessionStorage: SessionStorage? = KeychainManager()

    public let tapi = TAPI()

    public private (set) var error: Error?

    private let id: String

    private var session: TSession? {
        didSet {
            if session == nil {
                self.dataSetId = nil
            }
            saveSession()
        }
    }

    private var dataSetId: String? {
        didSet {
            completeUpdate()
        }
    }

    private let log = OSLog(category: "TidepoolService")

    public init() {
        self.id = UUID().uuidString
    }

    public init?(rawState: RawStateValue) {
        guard let id = rawState["id"] as? String else {
            return nil
        }
        self.id = id
        self.dataSetId = rawState["dataSetId"] as? String
        restoreSession()
    }

    public var rawState: RawStateValue {
        var rawValue: RawStateValue = [:]
        rawValue["id"] = id
        rawValue["dataSetId"] = dataSetId
        return rawValue
    }

    public func completeCreate(withSession session: TSession) {
        self.session = session

        DispatchQueue.global(qos: .background).async {
            self.getDataSet()
        }
    }

    public func completeUpdate() {
        serviceDelegate?.serviceDidUpdateState(self)
    }

    public func completeDelete() {
        guard let session = session else {
            return
        }

        self.session = nil

        DispatchQueue.global(qos: .background).async {
            self.tapi.logout(session: session) { _ in }
        }
    }

    private func getDataSet() {
        guard let session = session, let clientName = Bundle.main.bundleIdentifier else {
            return
        }
        tapi.listDataSets(filter: TDataSet.Filter(clientName: clientName), session: session) { result in
            switch result {
            case .failure(let error):
                self.error = error
            case .success(let dataSets):
                if !dataSets.isEmpty {
                    if dataSets.count > 1 {
                        self.log.error("Found multiple matching data sets; expected zero or one")
                    }
                    self.dataSetId = dataSets.first?.uploadId
                } else {
                    self.createDataSet()
                }
            }
        }
    }

    private func createDataSet() {
        guard let session = session, let clientName = Bundle.main.bundleIdentifier, let clientVersion = Bundle.main.semanticVersion else {
            return
        }
        let dataSet = TDataSet(dataSetType: .continuous,
                               client: TDataSet.Client(name: clientName, version: clientVersion),
                               deduplicator: TDataSet.Deduplicator(name: .dataSetDeleteOrigin))
        tapi.createDataSet(dataSet, session: session) { result in
            switch result {
            case .failure(let error):
                self.error = error
            case .success(let dataSet):
                self.dataSetId = dataSet.uploadId
            }
        }
    }

    private var sessionService: String { "org.tidepool.TidepoolService.\(id)" }

    private func saveSession() {
        do {
            try sessionStorage?.setSession(session, for: sessionService)
        } catch let error {
            self.error = error
        }
    }

    private func restoreSession() {
        do {
            self.session = try sessionStorage?.getSession(for: sessionService)
        } catch let error {
            self.error = error
        }
    }
}

extension KeychainManager: SessionStorage {
    public func setSession(_ session: TSession?, for service: String) throws {
        try replaceGenericPassword(nil, forService: service)
        guard let session = session else {
            return
        }
        let sessionData = try JSONEncoder.tidepool.encode(session)
        guard let sessionString = String(data: sessionData, encoding: .utf8) else {
            throw SessionStorageError()
        }
        try replaceGenericPassword(sessionString, forService: service)
    }

    public func getSession(for service: String) throws -> TSession? {
        let sessionString = try getGenericPasswordForService(service)
        guard let sessionData = sessionString.data(using: .utf8) else {
            throw SessionStorageError()
        }
        return try JSONDecoder.tidepool.decode(TSession.self, from: sessionData)
    }

    public struct SessionStorageError: Error {}
}
