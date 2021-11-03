//
//  TimeInterval.swift
//  TidepoolServiceKitTests
//
//  Created by Darin Krauss on 10/29/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import Foundation

extension TimeInterval {
    static let day = days(1)
    static let hour = hours(1)
    static let minute = minutes(1)
    static let second = seconds(1)
    static let millisecond = milliseconds(1)

    static func days(_ days: Double) -> Self {
        return Self(days: days)
    }

    static func days(_ days: Int) -> Self {
        return Self(days: days)
    }

    static func hours(_ hours: Double) -> Self {
        return Self(hours: hours)
    }

    static func hours(_ hours: Int) -> Self {
        return Self(hours: hours)
    }

    static func minutes(_ minutes: Double) -> Self {
        return Self(minutes: minutes)
    }

    static func minutes(_ minutes: Int) -> Self {
        return Self(minutes: minutes)
    }

    static func seconds(_ seconds: Double) -> Self {
        return Self(seconds: seconds)
    }

    static func seconds(_ seconds: Int) -> Self {
        return Self(seconds: seconds)
    }

    static func milliseconds(_ milliseconds: Double) -> Self {
        return Self(milliseconds: milliseconds)
    }

    static func milliseconds(_ milliseconds: Int) -> Self {
        return Self(milliseconds: milliseconds)
    }

    init(days: Double) {
        self.init(hours: days * 24)
    }

    init(days: Int) {
        self.init(hours: days * 24)
    }

    init(hours: Double) {
        self.init(minutes: hours * 60)
    }

    init(hours: Int) {
        self.init(minutes: hours * 60)
    }

    init(minutes: Double) {
        self.init(seconds: minutes * 60)
    }

    init(minutes: Int) {
        self.init(seconds: minutes * 60)
    }

    init(seconds: Double) {
        self.init(seconds)
    }

    init(seconds: Int) {
        self.init(seconds)
    }

    init(milliseconds: Double) {
        self.init(seconds: milliseconds / 1000)
    }

    init(milliseconds: Int) {
        self.init(seconds: Double(milliseconds) / 1000)
    }

    var days: Double {
        return hours / 24
    }

    var hours: Double {
        return minutes / 60
    }

    var minutes: Double {
        return seconds / 60
    }

    var seconds: Double {
        return self
    }

    var milliseconds: Double {
        return seconds * 1000
    }
}
