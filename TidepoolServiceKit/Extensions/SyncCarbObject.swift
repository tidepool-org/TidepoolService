//
//  SyncCarbObject.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/1/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import CryptoKit
import LoopKit
import TidepoolKit

extension SyncCarbObject {
    var datum: TDatum? {
        guard let origin = datumOrigin else {
            return nil
        }
        return TFoodDatum(time: datumTime, name: datumName, nutrition: datumNutrition).adornWith(origin: origin)
    }

    private var datumTime: Date { startDate }

    private var datumName: String? { foodType }

    private var datumNutrition: TFoodDatum.Nutrition {
        return TFoodDatum.Nutrition(carbohydrate: datumCarbohydrate, estimatedAbsorptionDuration: absorptionTime)
    }

    private var datumCarbohydrate: TFoodDatum.Nutrition.Carbohydrate {
        return TFoodDatum.Nutrition.Carbohydrate(net: grams)
    }

    private var datumOrigin: TOrigin? {
        guard let resolvedSyncIdentifier = resolvedSyncIdentifier else {
            return nil
        }
        if let provenanceIdentifier = provenanceIdentifier, !provenanceIdentifier.isEmpty, provenanceIdentifier != Bundle.main.bundleIdentifier {
            return TOrigin(id: resolvedSyncIdentifier, name: provenanceIdentifier, type: .application)
        }
        return TOrigin(id: resolvedSyncIdentifier)
    }
}

extension SyncCarbObject {
    var selector: TDatum.Selector? {
        guard let resolvedSyncIdentifier = resolvedSyncIdentifier else {
            return nil
        }
        return TDatum.Selector(origin: TDatum.Selector.Origin(id: resolvedSyncIdentifier))
    }
}

fileprivate extension SyncCarbObject {
    var resolvedSyncIdentifier: String? {
        var resolvedString: String?

        // The Tidepool backend requires a unique identifier for each datum that does not change from creation
        // through updates to deletion. Since carb objects do not inherently have such a unique identifier,
        // we can generate one based upon the HealthKit provenance identifier (the unique source identifier of
        // the carb, namely the bundle identifier) plus the HealthKit sync identifier.
        //
        // However, while all carbs created within Loop are guaranteed to have a HealthKit sync identifier, this
        // is not true for carbs created outside of Loop. In this case, we fall back to using the HealthKit UUID.
        // This works because any HealthKit objects without a sync identifier CANNOT be updated, by definition,
        // (only created and deleted) and the UUID is constant for this use case.
        if let provenanceIdentifier = provenanceIdentifier {
            if let syncIdentifier = syncIdentifier {
                resolvedString = "provenanceIdentifier:\(provenanceIdentifier):syncIdentifier:\(syncIdentifier)"
            } else if let uuid = uuid {
                resolvedString = "provenanceIdentifier:\(provenanceIdentifier):uuid:\(uuid)"
            }
        } else {

            // DEPRECATED: Backwards compatibility (DIY)
            // For previously existing carbs created outside of Loop we do not have a provenance identifier and
            // we cannot rely on the sync identifier (since it is scoped by the provenance identifier). Therefore,
            // just fallback to use the UUID.
            if let uuid = uuid {
                resolvedString = "uuid:\(uuid)"
            }
        }

        // Finally, assuming we have a valid string, MD5 hash the string to yield a nice identifier
        return resolvedString?.md5hash
    }
}

fileprivate extension String {
    var md5hash: String? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
