//
//  SingleQuantitySchedule.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/2/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import HealthKit
import LoopKit

extension SingleQuantitySchedule {
    func items(for unit: HKUnit) -> [RepeatingScheduleValue<Double>] {
        guard unit != self.unit else {
            return items
        }
        return items.map { RepeatingScheduleValue<Double>(startTime: $0.startTime, value: $0.value.converted(from: self.unit, to: unit)) }
    }
}
