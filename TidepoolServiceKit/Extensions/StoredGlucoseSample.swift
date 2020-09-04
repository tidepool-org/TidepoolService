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
    var datum: TDatum {
        if isDisplayOnly {
            return TCalibrationDeviceEventDatum(time: datumTime, value: datumValue, units: datumUnits).adorn(withOrigin: datumOrigin)
        } else if wasUserEntered {
            return TSMBGDatum(time: datumTime, value: datumValue, units: datumUnits, subType: .manual).adorn(withOrigin: datumOrigin)
        } else {
            return TCBGDatum(time: datumTime, value: datumValue, units: datumUnits).adorn(withOrigin: datumOrigin)
        }
    }

    private var datumTime: Date { startDate }

    private var datumValue: Double { quantity.doubleValue(for: .milligramsPerDeciliter) }

    private var datumUnits: TBloodGlucose.Units { .milligramsPerDeciliter }

    private var datumOrigin: TOrigin {
        if !provenanceIdentifier.isEmpty && provenanceIdentifier != Bundle.main.bundleIdentifier {
            return TOrigin(id: syncIdentifier, name: provenanceIdentifier, type: .service)  // TODO: Use application once backend support is added
        }
        return TOrigin(id: syncIdentifier)
    }
}
