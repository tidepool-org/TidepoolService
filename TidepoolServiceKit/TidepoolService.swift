//
//  TidepoolService.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 7/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

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
            saveSession()
        }
    }

    public init() {
        self.id = UUID().uuidString
    }

    public init?(rawState: RawStateValue) {
        guard let id = rawState["id"] as? String else {
            return nil
        }
        self.id = id
        restoreSession()
    }

    public var rawState: RawStateValue {
        var rawValue: RawStateValue = [:]
        rawValue["id"] = id
        return rawValue
    }

    public func completeCreate(withSession session: TSession) {
        self.session = session
    }

    public func completeUpdate() {
        serviceDelegate?.serviceDidUpdateState(self)
    }

    public func completeDelete() {
        self.session = nil
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
