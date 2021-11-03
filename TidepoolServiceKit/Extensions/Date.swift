//
//  Date.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 11/5/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

extension Date {
    var timeString: String {
        return Date.timeFormatter.string(from: self.roundedToTimeInterval(.millisecond))
    }

    private static let timeFormatter: ISO8601DateFormatter = {
        var timeFormatter = ISO8601DateFormatter()
        timeFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return timeFormatter
    }()

    private func roundedToTimeInterval(_ interval: TimeInterval) -> Date {
        guard interval != 0 else {
            return self
        }
        return Date(timeIntervalSinceReferenceDate: round(self.timeIntervalSinceReferenceDate / interval) * interval)
    }
}
