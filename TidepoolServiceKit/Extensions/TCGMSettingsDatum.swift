//
//  TCGMSettingsDatum.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 11/4/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import TidepoolKit

extension TCGMSettingsDatum: TypedDatum {
    static var resolvedType: String { TDatum.DatumType.cgmSettings.rawValue }
}
