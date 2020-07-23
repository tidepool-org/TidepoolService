//
//  StoredCarbEntry.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/1/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

extension StoredCarbEntry {
    var datum: TDatum? {
        guard isActive, syncIdentifier != nil else {
            return nil
        }
        return TFoodDatum(time: datumTime, name: datumName, nutrition: datumNutrition).adorn(withOrigin: datumOrigin)
    }

    private var datumTime: Date { startDate }

    private var datumName: String? { foodType }

    private var datumNutrition: TFoodDatum.Nutrition {
        return TFoodDatum.Nutrition(carbohydrate: datumCarbohydrate, estimatedAbsorptionDuration: datumEstimatedAbsorptionDuration)
    }

    private var datumCarbohydrate: TFoodDatum.Nutrition.Carbohydrate {
        return TFoodDatum.Nutrition.Carbohydrate(net: quantity.doubleValue(for: .gram()), units: .grams)
    }

    private var datumEstimatedAbsorptionDuration: Int? {
        guard let absorptionTime = absorptionTime else {
            return nil
        }
        return Int(absorptionTime)
    }

    private var datumOrigin: TOrigin? {
        guard let syncIdentifier = syncIdentifier else {
            return nil
        }
        if !createdByCurrentApp {
            return TOrigin(id: syncIdentifier, name: "com.apple.HealthKit", type: .service)  // TODO: Use application once backend support is added
        }
        return TOrigin(id: syncIdentifier)
    }
}

extension StoredCarbEntry {
    var selector: TDatum.Selector? {
        guard !isActive, let syncIdentifier = syncIdentifier else {
            return nil
        }
        return TDatum.Selector(origin: TDatum.Selector.Origin(id: syncIdentifier))
    }
}
