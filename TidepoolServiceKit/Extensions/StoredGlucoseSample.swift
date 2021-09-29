//
//  StoredGlucoseSample.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/2/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

extension StoredGlucoseSample {
    var datum: TDatum? {
        guard let origin = datumOrigin else {
            return nil
        }
        if isDisplayOnly {
            return TCalibrationDeviceEventDatum(time: datumTime, value: datumValue, units: datumUnits).adornWith(annotations: datumAnnotations, origin: origin)
        } else if wasUserEntered {
            return TSMBGDatum(time: datumTime, value: datumValue, units: datumUnits, subType: .manual).adornWith(annotations: datumAnnotations, origin: origin)
        } else {
            return TCBGDatum(time: datumTime, value: datumValue, units: datumUnits, trend: datumTrend, trendRate: datumTrendRate).adornWith(annotations: datumAnnotations, origin: origin)
        }
    }

    private var datumTime: Date { startDate }

    private var datumValue: Double {
        let value = quantity.doubleValue(for: .milligramsPerDeciliter)
        switch condition {
        case .none:
            return value
        case .belowRange:
            return value - 1
        case .aboveRange:
            return value + 1
        }
    }

    private var datumUnits: TBloodGlucose.Units { .milligramsPerDeciliter }

    private var datumTrend: TBloodGlucose.Trend? { trend?.datum }

    private var datumTrendRate: Double? { trendRate?.doubleValue(for: .milligramsPerDeciliterPerMinute) }

    private var datumAnnotations: [TDictionary]? {
        guard let condition = condition else {
            return nil
        }

        switch condition {
        case .belowRange:
            return [TDictionary([
                "code": "bg/out-of-range",
                "value": "low",
                "threshold": quantity.doubleValue(for: .milligramsPerDeciliter)
            ])]
        case .aboveRange:
            return [TDictionary([
                "code": "bg/out-of-range",
                "value": "high",
                "threshold": quantity.doubleValue(for: .milligramsPerDeciliter)
            ])]
        }
    }

    private var datumOrigin: TOrigin? {
        guard let syncIdentifier = syncIdentifier else {
            return nil
        }
        if !provenanceIdentifier.isEmpty, provenanceIdentifier != Bundle.main.bundleIdentifier {
            return TOrigin(id: syncIdentifier, name: provenanceIdentifier, type: .application)
        }
        return TOrigin(id: syncIdentifier)
    }
}

extension GlucoseTrend {
    var datum: TBloodGlucose.Trend {
        switch self {
        case .upUpUp:
            return .rapidRise
        case .upUp:
            return .moderateRise
        case .up:
            return .slowRise
        case .flat:
            return .constant
        case .down:
            return .slowFall
        case .downDown:
            return .moderateFall
        case .downDownDown:
            return .rapidFall
        }
    }
}
