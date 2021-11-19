//
//  TPumpSettingsDatum.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 10/19/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import TidepoolKit

extension TPumpSettingsDatum: TypedDatum {
    static var resolvedType: String { TDatum.DatumType.pumpSettings.rawValue }
}
