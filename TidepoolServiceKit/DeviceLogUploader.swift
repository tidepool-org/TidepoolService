//
//  DeviceLogUploader.swift
//  TidepoolServiceKit
//
//  Created by Pete Schwamb on 5/28/24.
//  Copyright © 2024 LoopKit Authors. All rights reserved.
//

import Foundation
import os.log
import LoopKit
import TidepoolKit

/// Periodically uploads device logs in hourly chunks to backend
actor DeviceLogUploader {
    private let log = OSLog(category: "DeviceLogUploader")

    private let api: TAPI

    private var delegate: RemoteDataServiceDelegate?

    private var logChunkDuration = TimeInterval(hours: 1)

    func setDelegate(_ delegate: RemoteDataServiceDelegate?) {
        self.delegate = delegate
    }

    init(api: TAPI) {
        self.api = api

        Task {
            await main()
        }
    }

    func main() async {
        let backfillLimitInterval = TimeInterval(days: 2)
        // Default start uploading logs from 2 days ago
        var nextUploadStart = Date().addingTimeInterval(-backfillLimitInterval).dateFlooredToTimeInterval(logChunkDuration)

        // Fetch device log metadata records
        while true {
            do {
                // TODO: fetching logs is not implemented on the backend yet: awaiting https://tidepool.atlassian.net/browse/BACK-3011
                // For now, we expect this to error, so the catch has been modified to break out of the loop. Once this is implemented,
                // We will want to retry on error, so the break should eventually be removed.

                var uploadMetadata = try await api.listDeviceLogs(start: Date().addingTimeInterval(-backfillLimitInterval), end: Date())
                uploadMetadata.sort { a, b in
                    return a.endAtTime > b.endAtTime
                }
                if let lastEnd = uploadMetadata.last?.endAtTime {
                    nextUploadStart = lastEnd.dateFlooredToTimeInterval(logChunkDuration)
                }
                break
            } catch {
                log.error("Unable to fetch device log metadata: %@", String(describing: error))
                try? await Task.sleep(nanoseconds: TimeInterval(minutes: 1).nanoseconds)
                break // TODO: Remove when backend has implemented device log metadata fetching (see above)
            }
        }
        // Start upload loop
        while true {
            let nextUploadEnd = nextUploadStart.addingTimeInterval(logChunkDuration)
            let timeUntilNextUpload = nextUploadEnd.timeIntervalSinceNow
            if timeUntilNextUpload > 0 {
                log.debug("Waiting %@s until next upload", String(timeUntilNextUpload))
                try? await Task.sleep(nanoseconds: timeUntilNextUpload.nanoseconds)
            }
            await upload(from: nextUploadStart, to: nextUploadEnd)
            nextUploadStart = nextUploadEnd
        }
    }

    func upload(from start: Date, to end: Date) async {
        log.default("Uploading from %@ to %@", String(describing: start), String(describing: end))
        do {
            if let logs = try await delegate?.fetchDeviceLogs(startDate: start, endDate: end) {
                log.default("Fetched %d logs", logs.count)
                if logs.count > 0 {
                    let data = logs.map({
                        entry in
                        TDeviceLogEntry(
                            type: entry.type.tidepoolType,
                            managerIdentifier: entry.managerIdentifier,
                            deviceIdentifier: entry.deviceIdentifier ?? "unknown",
                            timestamp: entry.timestamp,
                            message: entry.message
                        )
                    })
                    do {
                        let metatdata = try await api.uploadDeviceLogs(logs: data, start: start, end: end)
                        log.default("metadata: %@", String(describing: metatdata))
                    } catch {
                        log.error("error uploading device logs:: %@", String(describing: error))
                    }
                }
            }
        } catch {
            log.error("Upload failed: %@", String(describing: error))
        }
    }
}

extension TimeInterval {
    var nanoseconds: UInt64 {
        return UInt64(self * 1e+9)
    }
}

extension DeviceLogEntryType {
    var tidepoolType: TDeviceLogEntry.TDeviceLogEntryType {
        switch self {
        case .send:
            return .send
        case .receive:
            return .receive
        case .error:
            return .error
        case .delegate:
            return .delegate
        case .delegateResponse:
            return .delegateResponse
        case .connection:
            return .connection
        }
    }
}
