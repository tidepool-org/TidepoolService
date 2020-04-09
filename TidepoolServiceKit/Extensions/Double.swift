//
//  Double.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/2/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import HealthKit
import LoopKit

extension DoubleRange {
    func converted(from: HKUnit, to: HKUnit) -> DoubleRange {
        guard from != to else {
            return self
        }
        return DoubleRange(minValue: minValue.converted(from: from, to: to), maxValue: maxValue.converted(from: from, to: to))
    }
}

extension Double {
    func converted(from: HKUnit, to: HKUnit) -> Double {
        guard from != to else {
            return self
        }
        return HKQuantity(unit: from, doubleValue: self).doubleValue(for: to)
    }
}
