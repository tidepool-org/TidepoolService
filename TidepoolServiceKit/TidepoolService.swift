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
    case missingDataSetId
}

extension TidepoolServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .configuration: return LocalizedString("Configuration Error", comment: "Error string for TidepoolServiceError.configuration")
        case .missingDataSetId: return LocalizedString("Missing DataSet Id", comment: "Error string for TidepoolServiceError.missingDataSetId")
        }
    }
}



public protocol SessionStorage {
    func setSession(_ session: TSession?, for service: String) throws
    func getSession(for service: String) throws -> TSession?
}

public final class TidepoolService: Service, TAPIObserver, ObservableObject {

    public static let serviceIdentifier = "TidepoolService"

    public static let localizedTitle = LocalizedString("Tidepool", comment: "The title of the Tidepool service")

    public weak var serviceDelegate: ServiceDelegate? {
        didSet {
            self.hostIdentifier = serviceDelegate?.hostIdentifier
            self.hostVersion = serviceDelegate?.hostVersion
        }
    }

    public lazy var sessionStorage: SessionStorage = KeychainManager()

    public let tapi: TAPI = TAPI(clientId: BuildDetails.default.tidepoolServiceClientId, redirectURL: BuildDetails.default.tidepoolServiceRedirectURL)

    public private (set) var error: Error?

    private let id: String


    private var lastControllerSettingsDatum: TControllerSettingsDatum?

    private var lastCGMSettingsDatum: TCGMSettingsDatum?

    private var lastPumpSettingsDatum: TPumpSettingsDatum?

    private var lastPumpSettingsOverrideDeviceEventDatum: TPumpSettingsOverrideDeviceEventDatum?

    private var hostIdentifier: String?
    private var hostVersion: String?

    private let log = OSLog(category: "TidepoolService")
    private let tidepoolKitLog = OSLog(category: "TidepoolKit")

    public init(hostIdentifier: String, hostVersion: String) {
        self.id = UUID().uuidString
        self.hostIdentifier = hostIdentifier
        self.hostVersion = hostVersion

        Task {
            await tapi.setLogging(self)
            await tapi.addObserver(self)
        }
    }

    public init?(rawState: RawStateValue) {
        self.isOnboarded = true // Assume when restoring from state, that we're onboarded
        guard let id = rawState["id"] as? String else {
            return nil
        }
        do {
            self.id = id
            if let dataSetId = rawState["dataSetId"] as? String {
                self.dataSetIdCacheStatus = .fetched(dataSetId)
            }
            self.lastControllerSettingsDatum = (rawState["lastControllerSettingsDatum"] as? Data).flatMap { try? Self.decoder.decode(TControllerSettingsDatum.self, from: $0) }
            self.lastCGMSettingsDatum = (rawState["lastCGMSettingsDatum"] as? Data).flatMap { try? Self.decoder.decode(TCGMSettingsDatum.self, from: $0) }
            self.lastPumpSettingsDatum = (rawState["lastPumpSettingsDatum"] as? Data).flatMap { try? Self.decoder.decode(TPumpSettingsDatum.self, from: $0) }
            self.lastPumpSettingsOverrideDeviceEventDatum = (rawState["lastPumpSettingsOverrideDeviceEventDatum"] as? Data).flatMap { try? Self.decoder.decode(TPumpSettingsOverrideDeviceEventDatum.self, from: $0) }
            self.session = try sessionStorage.getSession(for: sessionService)
            Task {
                await tapi.setSession(session)
                await tapi.setLogging(self)
                await tapi.addObserver(self)
            }
        } catch let error {
            tidepoolKitLog.error("Error initializing TidepoolService %{public}@", error.localizedDescription)
            self.error = error
            return nil
        }
    }

    public var rawState: RawStateValue {
        var rawValue: RawStateValue = [:]
        rawValue["id"] = id
        if case .fetched(let dataSetId) = dataSetIdCacheStatus {
            rawValue["dataSetId"] = dataSetId
        }
        rawValue["lastControllerSettingsDatum"] = lastControllerSettingsDatum.flatMap { try? Self.encoder.encode($0) }
        rawValue["lastCGMSettingsDatum"] = lastCGMSettingsDatum.flatMap { try? Self.encoder.encode($0) }
        rawValue["lastPumpSettingsDatum"] = lastPumpSettingsDatum.flatMap { try? Self.encoder.encode($0) }
        rawValue["lastPumpSettingsOverrideDeviceEventDatum"] = lastPumpSettingsOverrideDeviceEventDatum.flatMap { try? Self.encoder.encode($0) }
        return rawValue
    }

    public var isOnboarded = false   // No distinction between created and onboarded

    @Published public var session: TSession?

    public func apiDidUpdateSession(_ session: TSession?) {
        guard session != self.session else {
            return
        }

        // If userId changed, then current dataSetId is invalid
        if session?.userId != self.session?.userId {
            clearCachedDataSetId()
        }

        self.session = session

        do {
            try sessionStorage.setSession(session, for: sessionService)
        } catch let error {
            self.error = error
        }

        if session == nil {
            clearCachedDataSetId()
            let content = Alert.Content(title: LocalizedString("Tidepool Service Authorization", comment: "The title for an alert generated when TidepoolService is no longer authorized."),
                                        body: LocalizedString("Tidepool service is no longer authorized. Please navigate to Tidepool Service settings and reauthenticate.", comment: "The body text for an alert generated when TidepoolService is no longer authorized."),
                                        acknowledgeActionButtonLabel: LocalizedString("OK", comment: "Alert acknowledgment OK button"))
            serviceDelegate?.issueAlert(Alert(identifier: Alert.Identifier(managerIdentifier: "TidepoolService",
                                                                    alertIdentifier: "authentication-needed"),
                                       foregroundContent: content, backgroundContent: content,
                                       trigger: .immediate))
        }
    }

    public func completeCreate() async throws {
        self.isOnboarded = true
    }

    public func completeUpdate() {
        serviceDelegate?.serviceDidUpdateState(self)
    }

    public func deleteService() {
        Task {
            await self.tapi.logout()
        }
        serviceDelegate?.serviceWantsDeletion(self)
    }

    private var sessionService: String { "org.tidepool.TidepoolService.\(id)" }

    private var userId: String? { session?.userId }

    private static var encoder: PropertyListEncoder = {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        return encoder
    }()

    private static var decoder = PropertyListDecoder()

    // MARK: - DataSetId

    enum DataSetIdCacheStatus {
        case inProgress(Task<String, Error>)
        case fetched(String)
    }

    private var dataSetIdCacheStatus: DataSetIdCacheStatus?

    private func clearCachedDataSetId() {
        dataSetIdCacheStatus = nil
    }

    // This is the main accessor for data set id. It will trigger a fetch or creation
    // of the Loop data set associated with the currently logged in account, and will
    // handle caching and minimizing the number of network requests.
    public func getCachedDataSetId() async throws -> String {
        if let fetchStatus = dataSetIdCacheStatus {
            switch fetchStatus {
            case .fetched(let dataSetId):
                return dataSetId
            case .inProgress(let task):
                return try await task.value
            }
        }

        let task: Task<String, Error> = Task {
            return try await fetchDataSetId()
        }

        dataSetIdCacheStatus = .inProgress(task)
        let dataSetId = try await task.value
        dataSetIdCacheStatus = .fetched(dataSetId)
        return dataSetId
    }

    private func fetchDataSetId() async throws -> String {
        guard let clientName = hostIdentifier else {
            throw TidepoolServiceError.configuration
        }

        let dataSets = try await tapi.listDataSets(filter: TDataSet.Filter(clientName: clientName, deleted: false))

        if !dataSets.isEmpty {
            if dataSets.count > 1 {
                self.log.error("Found multiple matching data sets; expected zero or one")
            }

            guard let dataSetId = dataSets.first?.uploadId else {
                throw TidepoolServiceError.missingDataSetId
            }
            return dataSetId
        } else {
            let dataSet = try await self.createDataSet()
            guard let dataSetId = dataSet.id else {
                throw TidepoolServiceError.missingDataSetId
            }
            return dataSetId
        }
    }

    private func createDataSet() async throws -> TDataSet {
        guard let clientName = hostIdentifier, let clientVersion = hostVersion else {
            throw TidepoolServiceError.configuration
        }

        let dataSet = TDataSet(client: TDataSet.Client(name: clientName, version: clientVersion),
                               dataSetType: .continuous,
                               deduplicator: TDataSet.Deduplicator(name: .dataSetDeleteOrigin),
                               deviceTags: [.bgm, .cgm, .insulinPump])

        return try await tapi.createDataSet(dataSet)
    }

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

    public func uploadTemporaryOverrideData(updated: [TemporaryScheduleOverride], deleted: [TemporaryScheduleOverride], completion: @escaping (Result<Bool, Error>) -> Void) {
        // TODO: Implement
        completion(.success(true))
    }

    public var alertDataLimit: Int? { return 1000 }

    public func uploadAlertData(_ stored: [SyncAlertObject], completion: @escaping (_ result: Result<Bool, Error>) -> Void) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }
        Task {
            do {
                let result = try await createData(stored.compactMap { $0.datum(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion) })
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public var carbDataLimit: Int? { return 1000 }

    public func uploadCarbData(created: [SyncCarbObject], updated: [SyncCarbObject], deleted: [SyncCarbObject], completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        Task {
            do {
                let createdUploaded = try await createData(created.compactMap { $0.datum(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion) })
                let updatedUploaded = try await updateData(updated.compactMap { $0.datum(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion) })
                let deletedUploaded = try await deleteData(withSelectors: deleted.compactMap { $0.selector })
                completion(.success(createdUploaded || updatedUploaded || deletedUploaded))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public var doseDataLimit: Int? { return 1000 }

    public func uploadDoseData(created: [DoseEntry], deleted: [DoseEntry], completion: @escaping (_ result: Result<Bool, Error>) -> Void) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        Task {
            do {
                let createdUploaded = try await createData(created.flatMap { $0.data(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion) })
                let deletedUploaded = try await deleteData(withSelectors: deleted.flatMap { $0.selectors })
                completion(.success(createdUploaded || deletedUploaded))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public var dosingDecisionDataLimit: Int? { return 50 }  // Each can be up to 20K bytes of serialized JSON, target ~1M or less

    public func uploadDosingDecisionData(_ stored: [StoredDosingDecision], completion: @escaping (_ result: Result<Bool, Error>) -> Void) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        Task {
            do {
                let result = try await createData(calculateDosingDecisionData(stored, for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion))
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func calculateDosingDecisionData(_ stored: [StoredDosingDecision], for userId: String, hostIdentifier: String, hostVersion: String) -> [TDatum] {
        var created: [TDatum] = []

        stored.forEach {
            let dosingDecisionDatum = $0.datumDosingDecision(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
            let controllerStatusDatum = $0.datumControllerStatus(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
            let pumpStatusDatum = $0.datumPumpStatus(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)

            var dosingDecisionAssociations: [TAssociation] = []
            var controllerStatusAssociations: [TAssociation] = []
            var pumpStatusAssociations: [TAssociation] = []

            if !dosingDecisionDatum.isEffectivelyEmpty {
                let association = TAssociation(type: .datum, id: dosingDecisionDatum.id!, reason: "dosingDecision")
                controllerStatusAssociations.append(association)
                pumpStatusAssociations.append(association)
            }
            if !controllerStatusDatum.isEffectivelyEmpty {
                let association = TAssociation(type: .datum, id: controllerStatusDatum.id!, reason: "controllerStatus")
                dosingDecisionAssociations.append(association)
                pumpStatusAssociations.append(association)
            }
            if !pumpStatusDatum.isEffectivelyEmpty {
                let association = TAssociation(type: .datum, id: pumpStatusDatum.id!, reason: "pumpStatus")
                dosingDecisionAssociations.append(association)
                controllerStatusAssociations.append(association)
            }

            dosingDecisionDatum.append(associations: dosingDecisionAssociations)
            controllerStatusDatum.append(associations: controllerStatusAssociations)
            pumpStatusDatum.append(associations: pumpStatusAssociations)

            if !dosingDecisionDatum.isEffectivelyEmpty {
                created.append(dosingDecisionDatum)
            }
            if !controllerStatusDatum.isEffectivelyEmpty {
                created.append(controllerStatusDatum)
            }
            if !pumpStatusDatum.isEffectivelyEmpty {
                created.append(pumpStatusDatum)
            }
        }

        return created
    }

    public var glucoseDataLimit: Int? { return 1000 }

    public func uploadGlucoseData(_ stored: [StoredGlucoseSample], completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        Task {
            do {
                let result = try await createData(stored.compactMap { $0.datum(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion) })
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public var pumpDataEventLimit: Int? { return 1000 }

    public func uploadPumpEventData(_ stored: [PersistedPumpEvent], completion: @escaping (_ result: Result<Bool, Error>) -> Void) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        Task {
            do {
                let result = try await createData(stored.flatMap { $0.data(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion) })
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public var settingsDataLimit: Int? { return 400 }  // Each can be up to 2.5K bytes of serialized JSON, target ~1M or less

    public func uploadSettingsData(_ stored: [StoredSettings], completion: @escaping (_ result: Result<Bool, Error>) -> Void) {
        guard let userId = userId, let hostIdentifier = hostIdentifier, let hostVersion = hostVersion else {
            completion(.failure(TidepoolServiceError.configuration))
            return
        }

        let (created, updated, lastControllerSettingsDatum, lastCGMSettingsDatum, lastPumpSettingsDatum, lastPumpSettingsOverrideDeviceEventDatum) = calculateSettingsData(stored, for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)

        Task {
            do {
                let createdUploaded = try await createData(created)
                let updatedUploaded = try await updateData(updated)
                self.lastControllerSettingsDatum = lastControllerSettingsDatum
                self.lastCGMSettingsDatum = lastCGMSettingsDatum
                self.lastPumpSettingsDatum = lastPumpSettingsDatum
                self.lastPumpSettingsOverrideDeviceEventDatum = lastPumpSettingsOverrideDeviceEventDatum
                self.completeUpdate()
                completion(.success(createdUploaded || updatedUploaded))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func calculateSettingsData(_ stored: [StoredSettings], for userId: String, hostIdentifier: String, hostVersion: String) -> ([TDatum], [TDatum], TControllerSettingsDatum?, TCGMSettingsDatum?, TPumpSettingsDatum?, TPumpSettingsOverrideDeviceEventDatum?) {
        var created: [TDatum] = []
        var updated: [TDatum] = []
        var lastControllerSettingsDatum = lastControllerSettingsDatum
        var lastCGMSettingsDatum = lastCGMSettingsDatum
        var lastPumpSettingsDatum = lastPumpSettingsDatum
        var lastPumpSettingsOverrideDeviceEventDatum = lastPumpSettingsOverrideDeviceEventDatum

        // A StoredSettings can generate a TPumpSettingsDatum and an optional TPumpSettingsOverrideDeviceEventDatum if there is an
        // enabled override. Only upload the TPumpSettingsDatum or TPumpSettingsOverrideDeviceEventDatum if they have CHANGED.
        // If the TPumpSettingsOverrideDeviceEventDatum has changed, then also re-upload the previous uploaded
        // TPumpSettingsOverrideDeviceEventDatum with an updated duration and potentially expected duration, but only if the
        // duration is calculated to be ended early.

        stored.forEach {

            // Calculate the data

            let controllerSettingsDatum = $0.datumControllerSettings(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
            let controllerSettingsDatumIsEffectivelyEquivalent = TControllerSettingsDatum.areEffectivelyEquivalent(old: lastControllerSettingsDatum, new: controllerSettingsDatum)

            let cgmSettingsDatum = $0.datumCGMSettings(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
            let cgmSettingsDatumIsEffectivelyEquivalent = TCGMSettingsDatum.areEffectivelyEquivalent(old: lastCGMSettingsDatum, new: cgmSettingsDatum)

            let pumpSettingsDatum = $0.datumPumpSettings(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
            let pumpSettingsDatumIsEffectivelyEquivalent = TPumpSettingsDatum.areEffectivelyEquivalent(old: lastPumpSettingsDatum, new: pumpSettingsDatum)

            let pumpSettingsOverrideDeviceEventDatum = $0.datumPumpSettingsOverrideDeviceEvent(for: userId, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
            let pumpSettingsOverrideDeviceEventDatumIsEffectivelyEquivalent = TPumpSettingsOverrideDeviceEventDatum.areEffectivelyEquivalent(old: lastPumpSettingsOverrideDeviceEventDatum, new: pumpSettingsOverrideDeviceEventDatum)

            // Associate the data

            var controllerSettingsAssociations: [TAssociation] = []
            var cgmSettingsAssociations: [TAssociation] = []
            var pumpSettingsAssociations: [TAssociation] = []
            var pumpSettingsOverrideDeviceEventAssociations: [TAssociation] = []

            if let controllerSettingsDatum = controllerSettingsDatumIsEffectivelyEquivalent ? lastControllerSettingsDatum : controllerSettingsDatum {
                let association = TAssociation(type: .datum, id: controllerSettingsDatum.id!, reason: "controllerSettings")
                cgmSettingsAssociations.append(association)
                pumpSettingsAssociations.append(association)
            }
            if let cgmSettingsDatum = cgmSettingsDatumIsEffectivelyEquivalent ? lastCGMSettingsDatum : cgmSettingsDatum {
                let association = TAssociation(type: .datum, id: cgmSettingsDatum.id!, reason: "cgmSettings")
                controllerSettingsAssociations.append(association)
                pumpSettingsAssociations.append(association)
            }
            if let pumpSettingsDatum = pumpSettingsDatumIsEffectivelyEquivalent ? lastPumpSettingsDatum : pumpSettingsDatum {
                let association = TAssociation(type: .datum, id: pumpSettingsDatum.id!, reason: "pumpSettings")
                controllerSettingsAssociations.append(association)
                cgmSettingsAssociations.append(association)
                pumpSettingsOverrideDeviceEventAssociations.append(association)
            }

            controllerSettingsDatum.append(associations: controllerSettingsAssociations)
            cgmSettingsDatum.append(associations: cgmSettingsAssociations)
            pumpSettingsDatum.append(associations: pumpSettingsAssociations)
            pumpSettingsOverrideDeviceEventDatum?.append(associations: pumpSettingsOverrideDeviceEventAssociations)

            // Upload and update the data, if necessary

            if !controllerSettingsDatumIsEffectivelyEquivalent {
                created.append(controllerSettingsDatum)
                lastControllerSettingsDatum = controllerSettingsDatum
            }

            if !cgmSettingsDatumIsEffectivelyEquivalent {
                created.append(cgmSettingsDatum)
                lastCGMSettingsDatum = cgmSettingsDatum
            }

            if !pumpSettingsDatumIsEffectivelyEquivalent {
                created.append(pumpSettingsDatum)
                lastPumpSettingsDatum = pumpSettingsDatum
            }

            if !pumpSettingsOverrideDeviceEventDatumIsEffectivelyEquivalent {

                // If we need to update the duration of the last override, then do so
                if let lastPumpSettingsOverrideDeviceEventDatum = lastPumpSettingsOverrideDeviceEventDatum,
                   lastPumpSettingsOverrideDeviceEventDatum.updateDuration(basedUpon: pumpSettingsOverrideDeviceEventDatum?.time ?? pumpSettingsDatum.time) {

                    // If it isn't already being created, then update it
                    if !created.contains(where: { $0 === lastPumpSettingsOverrideDeviceEventDatum }) {
                        updated.append(lastPumpSettingsOverrideDeviceEventDatum)
                    }
                }

                if let pumpSettingsOverrideDeviceEventDatum = pumpSettingsOverrideDeviceEventDatum {
                    created.append(pumpSettingsOverrideDeviceEventDatum)
                }
                lastPumpSettingsOverrideDeviceEventDatum = pumpSettingsOverrideDeviceEventDatum
            }
        }

        return (created, updated, lastControllerSettingsDatum, lastCGMSettingsDatum, lastPumpSettingsDatum, lastPumpSettingsOverrideDeviceEventDatum)
    }

    private func createData(_ data: [TDatum]) async throws -> Bool {
        if let error = error {
            throw error
        }

        let dataSetId = try await getCachedDataSetId()

        do {
            try await tapi.createData(data, dataSetId: dataSetId)
            return !data.isEmpty
        } catch {
            self.log.error("Failed to create data - %{public}@", error.localizedDescription)
            self.log.error("Failed data: %{public}@", String(describing: data))
            throw error
        }
    }

    private func updateData(_ data: [TDatum]) async throws -> Bool {
        if let error = error {
            throw error
        }

        let dataSetId = try await getCachedDataSetId()

        // TODO: This implementation is incorrect and will not record the correct history when data is updated. Currently waiting on
        // https://tidepool.atlassian.net/browse/BACK-815 for backend to support new API to capture full history of data changes.
        // This work will be covered in https://tidepool.atlassian.net/browse/LOOP-3943. For now just call createData with the
        // updated data as it will just overwrite the previous data with the updated data.
        do {
            try await tapi.createData(data, dataSetId: dataSetId)
            return !data.isEmpty
        } catch {
            self.log.error("Failed to update data - %{public}@", error.localizedDescription)
            throw error
        }
    }

    private func deleteData(withSelectors selectors: [TDatum.Selector]) async throws -> Bool {
        if let error = error {
            throw error
        }

        let dataSetId = try await getCachedDataSetId()

        do {
            try await tapi.deleteData(withSelectors: selectors, dataSetId: dataSetId)
            return !selectors.isEmpty
        } catch {
            self.log.error("Failed to delete data - %{public}@", error.localizedDescription)
            throw error
        }
    }

    public func uploadCgmEventData(_ stored: [LoopKit.PersistedCgmEvent], completion: @escaping (Result<Bool, Error>) -> Void) {
        // TODO: Upload sensor/transmitter changes
        completion(.success(false))
    }

    public func remoteNotificationWasReceived(_ notification: [String: AnyObject]) async throws {
        throw RemoteNotificationError.remoteCommandsNotSupported
    }
    
    enum RemoteNotificationError: LocalizedError {
        case remoteCommandsNotSupported
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

fileprivate protocol EffectivelyEquivalent {
    func isEffectivelyEquivalent(to other: Self) -> Bool
    var isEffectivelyEmpty: Bool { get }
}

fileprivate extension EffectivelyEquivalent {
    static func areEffectivelyEquivalent(old: Self?, new: Self?) -> Bool {
        if let new = new {
            return old?.isEffectivelyEquivalent(to: new) ?? new.isEffectivelyEmpty     // Prevents uploading effectively empty datum
        } else {
            return old == nil
        }
    }
}

extension TControllerSettingsDatum: EffectivelyEquivalent {

    // All TDatum properties can be ignored for this datum type
    func isEffectivelyEquivalent(to other: TControllerSettingsDatum) -> Bool {
        return self.device == other.device &&
            self.notifications == other.notifications
    }

    var isEffectivelyEmpty: Bool {
        return device == nil &&
            notifications == nil
    }
}

extension TCGMSettingsDatum: EffectivelyEquivalent {

    // All TDatum properties can be ignored for this datum type
    func isEffectivelyEquivalent(to other: TCGMSettingsDatum) -> Bool {
        return self.firmwareVersion == other.firmwareVersion &&
            self.hardwareVersion == other.hardwareVersion &&
            self.manufacturers == other.manufacturers &&
            self.model == other.model &&
            self.name == other.name &&
            self.serialNumber == other.serialNumber &&
            self.softwareVersion == other.softwareVersion &&
            self.transmitterId == other.transmitterId &&
            self.units == other.units &&
            self.defaultAlerts == other.defaultAlerts &&
            self.scheduledAlerts == other.scheduledAlerts &&
            self.highAlertsDEPRECATED == other.highAlertsDEPRECATED &&
            self.lowAlertsDEPRECATED == other.lowAlertsDEPRECATED &&
            self.outOfRangeAlertsDEPRECATED == other.outOfRangeAlertsDEPRECATED &&
            self.rateOfChangeAlertsDEPRECATED == other.rateOfChangeAlertsDEPRECATED
    }

    // Ignore units as they are always specified
    var isEffectivelyEmpty: Bool {
        return firmwareVersion == nil &&
            hardwareVersion == nil &&
            manufacturers == nil &&
            model == nil &&
            name == nil &&
            serialNumber == nil &&
            softwareVersion == nil &&
            transmitterId == nil &&
            defaultAlerts == nil &&
            scheduledAlerts == nil &&
            highAlertsDEPRECATED == nil &&
            lowAlertsDEPRECATED == nil &&
            outOfRangeAlertsDEPRECATED == nil &&
            rateOfChangeAlertsDEPRECATED == nil
    }
}

extension TPumpSettingsDatum: EffectivelyEquivalent {

    // All TDatum properties can be ignored for this datum type
    func isEffectivelyEquivalent(to other: TPumpSettingsDatum) -> Bool {
        return self.activeScheduleName == other.activeScheduleName &&
            self.automatedDelivery == other.automatedDelivery &&
            self.basal == other.basal &&
            self.basalRateSchedule == other.basalRateSchedule &&
            self.basalRateSchedules == other.basalRateSchedules &&
            self.bloodGlucoseSafetyLimit == other.bloodGlucoseSafetyLimit &&
            self.bloodGlucoseTargetPhysicalActivity == other.bloodGlucoseTargetPhysicalActivity &&
            self.bloodGlucoseTargetPreprandial == other.bloodGlucoseTargetPreprandial &&
            self.bloodGlucoseTargetSchedule == other.bloodGlucoseTargetSchedule &&
            self.bloodGlucoseTargetSchedules == other.bloodGlucoseTargetSchedules &&
            self.bolus == other.bolus &&
            self.carbohydrateRatioSchedule == other.carbohydrateRatioSchedule &&
            self.carbohydrateRatioSchedules == other.carbohydrateRatioSchedules &&
            self.display == other.display &&
            self.firmwareVersion == other.firmwareVersion &&
            self.hardwareVersion == other.hardwareVersion &&
            self.insulinFormulation == other.insulinFormulation &&
            self.insulinModel == other.insulinModel &&
            self.insulinSensitivitySchedule == other.insulinSensitivitySchedule &&
            self.insulinSensitivitySchedules == other.insulinSensitivitySchedules &&
            self.manufacturers == other.manufacturers &&
            self.model == other.model &&
            self.name == other.name &&
            self.overridePresets == other.overridePresets &&
            self.scheduleTimeZoneOffset == other.scheduleTimeZoneOffset &&
            self.serialNumber == other.serialNumber &&
            self.softwareVersion == other.softwareVersion &&
            self.units == other.units
    }

    // Ignore units as they are always specified
    var isEffectivelyEmpty: Bool {
        return activeScheduleName == nil &&
            automatedDelivery == nil &&
            basal == nil &&
            basalRateSchedule == nil &&
            basalRateSchedules == nil &&
            bloodGlucoseSafetyLimit == nil &&
            bloodGlucoseTargetPhysicalActivity == nil &&
            bloodGlucoseTargetPreprandial == nil &&
            bloodGlucoseTargetSchedule == nil &&
            bloodGlucoseTargetSchedules == nil &&
            bolus == nil &&
            carbohydrateRatioSchedule == nil &&
            carbohydrateRatioSchedules == nil &&
            display == nil &&
            firmwareVersion == nil &&
            hardwareVersion == nil &&
            insulinFormulation == nil &&
            insulinModel == nil &&
            insulinSensitivitySchedule == nil &&
            insulinSensitivitySchedules == nil &&
            manufacturers == nil &&
            model == nil &&
            name == nil &&
            overridePresets == nil &&
            scheduleTimeZoneOffset == nil &&
            serialNumber == nil &&
            softwareVersion == nil
    }
}

extension TPumpSettingsOverrideDeviceEventDatum: EffectivelyEquivalent {

    // All TDatum properties can be ignored EXCEPT time for this datum type
    // Time is gather from the actual scheduled override and NOT the StoredSettings so it is valid and necessary for comparison
    func isEffectivelyEquivalent(to other: TPumpSettingsOverrideDeviceEventDatum) -> Bool {
        return self.time == other.time &&
            self.overrideType == other.overrideType &&
            self.overridePreset == other.overridePreset &&
            self.method == other.method &&
            self.duration == other.duration &&
            self.expectedDuration == other.expectedDuration &&
            self.bloodGlucoseTarget == other.bloodGlucoseTarget &&
            self.basalRateScaleFactor == other.basalRateScaleFactor &&
            self.carbohydrateRatioScaleFactor == other.carbohydrateRatioScaleFactor &&
            self.insulinSensitivityScaleFactor == other.insulinSensitivityScaleFactor &&
            self.units == other.units
    }

    var isEffectivelyEmpty: Bool {
        return overrideType == nil &&
            overridePreset == nil &&
            method == nil &&
            duration == nil &&
            expectedDuration == nil &&
            bloodGlucoseTarget == nil &&
            basalRateScaleFactor == nil &&
            carbohydrateRatioScaleFactor == nil &&
            insulinSensitivityScaleFactor == nil &&
            units == nil
    }

    func updateDuration(basedUpon endTime: Date?) -> Bool {
        guard let endTime = endTime, let time = time, endTime > time else {
            return false
        }

        let updatedDuration = time.distance(to: endTime)
        guard duration == nil || updatedDuration < duration! else {
            return false
        }

        self.expectedDuration = duration
        self.duration = updatedDuration
        return true
    }
}

fileprivate extension TDosingDecisionDatum {

    // Ignore reason and units as they are always specified
    var isEffectivelyEmpty: Bool {
        return originalFood == nil &&
            food == nil &&
            selfMonitoredBloodGlucose == nil &&
            carbohydratesOnBoard == nil &&
            insulinOnBoard == nil &&
            bloodGlucoseTargetSchedule == nil &&
            historicalBloodGlucose == nil &&
            forecastBloodGlucose == nil &&
            recommendedBasal == nil &&
            recommendedBolus == nil &&
            requestedBolus == nil &&
            warnings?.isEmpty != false &&
            errors?.isEmpty != false &&
            scheduleTimeZoneOffset == nil &&
            units == nil
    }
}

fileprivate extension TControllerStatusDatum {
    var isEffectivelyEmpty: Bool {
        return battery == nil
    }
}

fileprivate extension TPumpStatusDatum {
    var isEffectivelyEmpty: Bool {
        return basalDelivery == nil &&
            battery == nil &&
            bolusDelivery == nil &&
            deliveryIndeterminant == nil &&
            reservoir == nil
    }
}
