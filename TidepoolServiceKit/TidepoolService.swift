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

    public let limit: Int = 2000

    public weak var remoteDataServiceDelegate: RemoteDataServiceDelegate?

    private let queue = DispatchQueue(label: "org.tidepool.TidepoolServiceQueue", qos: .utility)

    private let descriptorCache: RemoteDataDescriptorCache

    private let doseGroup: TidepoolDoseRemoteDataQueryGroup

    private let glucoseGroup: TidepoolGlucoseRemoteDataQueryGroup

    private let carbGroup: TidepoolCarbRemoteDataQueryGroup

    public let tidepoolKit: TidepoolKit = TidepoolKit(logger: TidepoolKitLog())

    private var session: TPSession?

    private var dataset: TPDataset?

    public var email: String? { return session?.user.userEmail }

    private let log = OSLog(category: "TidepoolService")

    public init() {
        self.descriptorCache = RemoteDataDescriptorCache()
        self.doseGroup = TidepoolDoseRemoteDataQueryGroup()
        self.glucoseGroup = TidepoolGlucoseRemoteDataQueryGroup()
        self.carbGroup = TidepoolCarbRemoteDataQueryGroup()
    }

    public init?(rawState: RawStateValue) {
        guard let descriptorCacheRawValue = rawState["descriptorCache"] as? RemoteDataDescriptorCache.RawValue,
            let descriptorCache = RemoteDataDescriptorCache(rawValue: descriptorCacheRawValue),
            let doseGroupRawValue = rawState["doseGroup"] as? TidepoolDoseRemoteDataQueryGroup.RawValue,
            let doseGroup = TidepoolDoseRemoteDataQueryGroup(rawValue: doseGroupRawValue),
            let glucoseGroupRawValue = rawState["glucoseGroup"] as? TidepoolGlucoseRemoteDataQueryGroup.RawValue,
            let glucoseGroup = TidepoolGlucoseRemoteDataQueryGroup(rawValue: glucoseGroupRawValue),
            let carbGroupRawValue = rawState["carbGroup"] as? TidepoolCarbRemoteDataQueryGroup.RawValue,
            let carbGroup = TidepoolCarbRemoteDataQueryGroup(rawValue: carbGroupRawValue) else {
                return nil
        }

        self.descriptorCache = descriptorCache
        self.doseGroup = doseGroup
        self.glucoseGroup = glucoseGroup
        self.carbGroup = carbGroup

        // TODO: Need to store session authentication token *SECURELY* in keychain, but store server in preferences.
        // TODO: The TPUser object should not be serialized with the TPSession object, it should be fetched dynamically

        if let sessionRawValue = rawState["session"] as? [String:Any],
            let session = TPSession(rawValue: sessionRawValue) {
            switch tidepoolKit.logIn(with: session) {
            case .failure:
            break   // TODO: Handle error here?
            case .success(let session):
                self.session = session
            }
        }
        if let datasetRawValue = rawState["dataset"] as? [String:Any],
            let dataset = TPDataset(rawValue: datasetRawValue) {
            self.dataset = dataset
        }
    }

    public var rawState: RawStateValue {
        var rawState: RawStateValue = [:]
        rawState["descriptorCache"] = descriptorCache.rawValue
        rawState["doseGroup"] = doseGroup.rawValue
        rawState["glucoseGroup"] = glucoseGroup.rawValue
        rawState["carbGroup"] = carbGroup.rawValue
        if let session = session {
            rawState["session"] = session.rawValue
        }
        if let dataset = dataset {
            rawState["dataset"] = dataset.rawValue
        }
        return rawState
    }

    public func completeCreate(withSession session: TPSession, completion: @escaping () -> Void) {
        self.session = session

        var name = Bundle.main.bundleIdentifier!
        var version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String

        name = "org.tidepool.loopkit.Loop"  // TODO: Fix this
        version = "1.2.3"   // TODO: Fix this

        let client = TPDatasetClient(name: name, version: version)
        let deduplicator = TPDeduplicator(type: .dataset_delete_origin)

        tidepoolKit.getDataset(for: session.user, matching: TPDataset(client: client, deduplicator: deduplicator)) { result in
            switch result {
            case .failure:
                // TODO: Report error here!
                break
            case .success(let dataset):
                self.dataset = dataset
            }

            completion()
        }
    }

    public func completeUpdate(completion: @escaping () -> Void) {
        completion()
    }

    public func completeDelete(completion: @escaping () -> Void) {
        tidepoolKit.logOut { result in
            completion()
        }
    }

}

extension TidepoolService: RemoteDataService {

    // TODO: Consider using .background queue

    public func synchronizeRemoteData(completion: @escaping (_ result: Result<Bool, Error>) -> Void)  {
        queue.async {
            let synchronizeTime = Date()

            self.log.debug("Synchronizing remote data")

            self.doseGroup.delegate = self.remoteDataServiceDelegate
            self.glucoseGroup.delegate = self.remoteDataServiceDelegate
            self.carbGroup.delegate = self.remoteDataServiceDelegate

            let groups: [TidepoolRemoteDataQueryGroupable] = [
                self.doseGroup
//                self.doseGroup,
//                self.glucoseGroup,
//                self.carbGroup
            ]

//            self.doseGroup.reset()

            print("STARTING")
            print(self.doseGroup)

            let uploader = TidepoolRemoteDataQueryGroupUploader(groups: groups, limit: self.limit, descriptorCache: self.descriptorCache, tidepoolKit: self.tidepoolKit, dataset: self.dataset!)

            uploader.upload { result in
                switch result {
                case .failure(let error):
                    self.log.debug("Failed to synchronize remote data: %{public}@", String(describing: error))
                    completion(.failure(error))
                case .success(let uploaded):
                    self.remoteDataServiceDelegate?.remoteDataServiceWasUpdated(self)
                    if uploaded {
                        self.log.debug("Continuing to synchronize remote data")
                        self.synchronizeRemoteData(completion: completion)
                    } else {
                        self.log.debug("Succeeded to synchronize remote data")
                        completion(.success(false))
                        print("ENDING")
                        print(self.doseGroup)
                    }
                }
            }

            self.log.debug("Synchronized remote data in %.3f seconds", -synchronizeTime.timeIntervalSinceNow)
        }
    }

    // DEPRECATED

    public func uploadSettings(_ settings: Settings, lastUpdated: Date) {}

    public func uploadStatus(insulinOnBoard: InsulinValue?, carbsOnBoard: CarbValue?, predictedGlucose: [GlucoseValue]?, recommendedTempBasal: (recommendation: TempBasalRecommendation, date: Date)?, recommendedBolus: Double?, lastReservoirValue: ReservoirValue?, pumpManagerStatus: PumpManagerStatus?, glucoseTargetRangeSchedule: GlucoseRangeSchedule?, scheduleOverride: TemporaryScheduleOverride?, glucoseTargetRangeScheduleApplyingOverrideIfActive: GlucoseRangeSchedule?, loopError: Error?) {}

    public func upload(pumpEvents events: [PersistedPumpEvent], fromSource source: String, completion: @escaping (Result<[URL], Error>) -> Void) {
        completion(.success(events.map({ $0.objectIDURL })))
    }

}

// TODO:
// Q: How do you get notified that you have access to HK again? Is it observers?
// If locked out of HK during an upload set of queries, just upload what we have and stop

// TODO:
// every new query (without an anchor will first return all delete objects from the beginning of time)
// So, even if retain cache permanently and never create another recent query we will always get two deleted (one from recent, one from historic; one from installed was filtered by recent)
// If we get a new recent query then we'll first get all of the deleted queries again (sheez).
