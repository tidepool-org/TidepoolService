//
//  SyncCarbObject.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/1/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

/*
 SyncCarbObject
 
 Properties:
 - absorptionTime          TimeInterval?       .nutrition.estimatedAbsorptionDuration
 - createdByCurrentApp     Bool                (N/A - implied by SyncCarbObject.provenanceIdentifier)
 - foodType                String?             .name
 - grams                   Double              .nutrition.carbohydrate.net
 - startDate               Date                .time
 - uuid                    UUID?               .id, .origin.id, .payload["uuid"]
 - provenanceIdentifier    String              .id, .origin.id, .origin.name (if not this app)
 - syncIdentifier          String?             .id, .origin.id, .payload["syncIdentifier"]
 - syncVersion             Int?                .payload["syncVersion"]
 - userCreatedDate         Date?               .payload["userCreatedDate"]
 - userUpdatedDate         Date?               .payload["userUpdatedDate"]
 - userDeletedDate         Date?               .payload["userDeletedDate"]
 - operation               Operation           (N/A - implied by RemoteDataService.uploadCarbData API)
 - addedDate               Date?               .payload["addedDate"]
 - supercededDate          Date?               .payload["supercededDate"]
 */

// TODO: Consider adding syncVersion to new update backend API (or just keep in payload)

extension SyncCarbObject: IdentifiableHKDatum {
    func datum(for userId: String, hostIdentifier: String, hostVersion: String) -> TFoodDatum? {
        guard let id = datumId(for: userId) else {
            return nil
        }
        let origin = datumOrigin(for: resolvedIdentifier, hostIdentifier: hostIdentifier, hostVersion: hostVersion)
        return TFoodDatum(time: datumTime, name: datumName, nutrition: datumNutrition).adornWith(id: id, payload: datumPayload, origin: origin)
    }

    private var datumTime: Date { startDate }

    private var datumName: String? { foodType }

    private var datumNutrition: TFoodDatum.Nutrition {
        return TFoodDatum.Nutrition(carbohydrate: datumCarbohydrate, estimatedAbsorptionDuration: absorptionTime)
    }

    private var datumCarbohydrate: TFoodDatum.Nutrition.Carbohydrate {
        return TFoodDatum.Nutrition.Carbohydrate(net: quantity.doubleValue(for: .gram()), units: .grams)
    }

    private var datumPayload: TDictionary? {
        var dictionary = TDictionary()
        dictionary["uuid"] = uuid?.uuidString
        dictionary["syncIdentifier"] = syncIdentifier
        dictionary["syncVersion"] = syncVersion
        dictionary["userCreatedDate"] = userCreatedDate?.timeString
        dictionary["userUpdatedDate"] = userUpdatedDate?.timeString
        dictionary["userDeletedDate"] = userDeletedDate?.timeString
        dictionary["addedDate"] = addedDate?.timeString
        dictionary["supercededDate"] = supercededDate?.timeString
        return !dictionary.isEmpty ? dictionary : nil
    }
}

extension SyncCarbObject {
    var selector: TDatum.Selector? { datumSelector }
}
