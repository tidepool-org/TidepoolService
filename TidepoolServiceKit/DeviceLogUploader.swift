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

    private let backfillLimitInterval = TimeInterval(days: 2)


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
        var nextLogStart: Date?

        // Start upload loop
        while true {
            if nextLogStart == nil {
                do {
                    nextLogStart = try await getMostRecentUploadEndTime()
                } catch {
                    log.error("Unable to fetch device log metadata: %{public}@", String(describing: error))
                }
            }

            if nextLogStart != nil {
                let nextLogEnd = nextLogStart!.addingTimeInterval(logChunkDuration)
                let timeUntilNextUpload = nextLogEnd.timeIntervalSinceNow
                if timeUntilNextUpload > 0 {
                    log.debug("Waiting %{public}@s until next upload", String(timeUntilNextUpload))
                    try? await Task.sleep(nanoseconds: timeUntilNextUpload.nanoseconds)
                }
                do {
                    try await upload(from: nextLogStart!, to: nextLogEnd)
                    nextLogStart = nextLogEnd
                } catch {
                    log.error("Upload failed: %{public}@", String(describing: error))
                    // Upload failed, retry in 5 minutes.
                    try? await Task.sleep(nanoseconds: TimeInterval(minutes: 5).nanoseconds)
                }
            } else {
                // Haven't been able to talk to backend to find any previous log uploads. Retry in 15 minutes.
                try? await Task.sleep(nanoseconds: TimeInterval(minutes: 15).nanoseconds)
            }
        }
    }

    func getMostRecentUploadEndTime() async throws -> Date {
        var uploadMetadata = try await api.listDeviceLogs(start: Date().addingTimeInterval(-backfillLimitInterval), end: Date())
        uploadMetadata.sort { a, b in
            return a.endAtTime < b.endAtTime
        }
        if let lastEnd = uploadMetadata.last?.endAtTime {
            return lastEnd
        } else {
            // No previous uploads found in last two days
            return Date().addingTimeInterval(-backfillLimitInterval).dateFlooredToTimeInterval(logChunkDuration)
        }
    }

    func upload(from start: Date, to end: Date) async throws {
        if let logs = try await delegate?.fetchDeviceLogs(startDate: start, endDate: end) {
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
                let metatdata = try await api.uploadDeviceLogs(logs: data, start: start, end: end)
                log.debug("Uploaded %d entries from %{public}@ to %{public}@", logs.count, String(describing: start), String(describing: end))
                log.debug("metadata: %{public}@", String(describing: metatdata))
            } else {
                log.debug("No device log entries from %{public}@ to %{public}@", String(describing: start), String(describing: end))
            }
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
