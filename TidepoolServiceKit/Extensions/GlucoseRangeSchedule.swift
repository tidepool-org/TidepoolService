//
//  GlucoseRangeSchedule.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 10/4/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import LoopAlgorithm
import LoopKit

extension GlucoseRangeSchedule {
    func items(for unit: LoopUnit) -> [RepeatingScheduleValue<DoubleRange>] {
        guard unit != self.unit else {
            return items
        }
        return items.map { RepeatingScheduleValue<DoubleRange>(startTime: $0.startTime, value: $0.value.converted(from: self.unit, to: unit)) }
    }
}
