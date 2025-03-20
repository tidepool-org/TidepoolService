//
//  Double.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 10/4/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import LoopAlgorithm
import LoopKit

extension DoubleRange {
    func converted(from: LoopUnit, to: LoopUnit) -> DoubleRange {
        guard from != to else {
            return self
        }
        return DoubleRange(minValue: minValue.converted(from: from, to: to), maxValue: maxValue.converted(from: from, to: to))
    }
}

extension Double {
    func converted(from: LoopUnit, to: LoopUnit) -> Double {
        guard from != to else {
            return self
        }
        return LoopQuantity(unit: from, doubleValue: self).doubleValue(for: to)
    }
}
