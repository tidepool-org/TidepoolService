//
//  StoredGlucoseSample.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/2/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import HealthKit
import LoopKit
import TidepoolKit

/*
 StoredGlucoseSample
 
 Properties:
 - uuid                     UUID?                  .id, .origin.id, .payload["uuid"]
 - provenanceIdentifier     String                 .id, .origin.id, .origin.name (if not this app)
 - syncIdentifier           String?                .id, .origin.id, .payload["syncIdentifier"]
 - syncVersion              Int?                   .payload["syncVersion"]
 - device                   HKDevice?              .deviceId
 - healthKitEligibleDate    Date?                  (N/A - internal implementation detail only)
 - startDate                Date                   .time
 - quantity                 HKQuantity             .value
 - isDisplayOnly            Bool                   (N/A - implicit in datum type)
 - wasUserEntered           Bool                   (N/A - implicit in datum type)
 - condition                GlucoseCondition?      .annotations
 - trend                    GlucoseTrend?          .trend
 - trendRate                HKQuantity?            .trendRate
 */

extension StoredGlucoseSample: IdentifiableHKDatum {
    func datum(for userId: String, hostIdentifier: String, hostVersion: String) -> TDatum? {
        guard let id = datumId(for: userId) else {
            return nil
        }

        var datum: TDatum
        if isDisplayOnly {
            datum = TCalibrationDeviceEventDatum(time: datumTime, value: datumValue, units: datumUnits)
        } else if wasUserEntered {
            datum = TSMBGDatum(time: datumTime, value: datumValue, units: datumUnits, subType: .manual)
        } else {
            datum = TCBGDatum(time: datumTime, value: datumValue, units: datumUnits, trend: datumTrend, trendRate: datumTrendRate)
        }

        let origin = datumOrigin(for: resolvedIdentifier, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        return datum.adornWith(id: id, deviceId: datumDeviceId, annotations: datumAnnotations, payload: datumPayload, origin: origin)
    }

    private var datumTime: Date { startDate }

    private var datumValue: Double {
        let value = quantity.doubleValue(for: .milligramsPerDeciliter)
        switch condition {
        case .none:
            return value
        case .belowRange:
            return value - 1    // Tidepool Loop stores last in-range value while Tidepool backend expects first out-of-range value
        case .aboveRange:
            return value + 1    // Tidepool Loop stores last in-range value while Tidepool backend expects first out-of-range value
        }
    }

    private var datumUnits: TBloodGlucose.Units { .milligramsPerDeciliter }

    private var datumTrend: TBloodGlucose.Trend? { trend?.datum }

    private var datumTrendRate: Double? { trendRate?.doubleValue(for: .milligramsPerDeciliterPerMinute) }

    private var datumDeviceId: String? { device?.datumDeviceId }

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

    private var datumPayload: TDictionary? {
        var dictionary = TDictionary()
        dictionary["uuid"] = uuid?.uuidString
        dictionary["syncIdentifier"] = syncIdentifier
        dictionary["syncVersion"] = syncVersion
        return !dictionary.isEmpty ? dictionary : nil
    }
}

fileprivate extension GlucoseTrend {
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

fileprivate extension HKDevice {
    var datumDeviceId: String? {
        return [manufacturer, model, localIdentifier].compactMap({ $0 }).joined(separator: "_")
    }
}
