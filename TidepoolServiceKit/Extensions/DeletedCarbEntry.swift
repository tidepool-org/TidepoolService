//
//  DeletedCarbEntry.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 4/1/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

extension DeletedCarbEntry {
    var selector: TDatum.Selector? {
        guard let syncIdentifier = syncIdentifier else {
            return nil
        }
        return TDatum.Selector(origin: TDatum.Selector.Origin(id: syncIdentifier))
    }
}

