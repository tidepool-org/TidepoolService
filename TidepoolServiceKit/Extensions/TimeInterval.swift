//
//  TimeInterval.swift
//  TidepoolServiceKit
//
//  Created by Anna Quinlan on 6/26/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation

extension TimeInterval {
    public static func minutes(_ minutes: Double) -> TimeInterval {
        return TimeInterval(minutes * 60 /* seconds in minute */)
    }

    public static func hours(_ hours: Double) -> TimeInterval {
        return TimeInterval(hours * 60 /* minutes in hr */ * 60 /* seconds in minute */)
    }
}
