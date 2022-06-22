//
//  InsulinType.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 1/7/22.
//  Copyright © 2022 LoopKit Authors. All rights reserved.
//

import LoopKit
import TidepoolKit

extension InsulinType {
    var datum: TInsulinDatum.Formulation {
        switch self {
        case .novolog:
            return TInsulinDatum.Formulation(simple: TInsulinDatum.Formulation.Simple(actingType: .rapid, brand: "NovoLog"))
        case .humalog:
            return TInsulinDatum.Formulation(simple: TInsulinDatum.Formulation.Simple(actingType: .rapid, brand: "Humalog"))
        case .apidra:
            return TInsulinDatum.Formulation(simple: TInsulinDatum.Formulation.Simple(actingType: .rapid, brand: "Apidra"))
        case .fiasp:
            return TInsulinDatum.Formulation(simple: TInsulinDatum.Formulation.Simple(actingType: .rapid, brand: "Fiasp"))
        case .lyumjev:
            return TInsulinDatum.Formulation(simple: TInsulinDatum.Formulation.Simple(actingType: .rapid, brand: "Lyumjev"))
        case .afrezza:
            return TInsulinDatum.Formulation(simple: TInsulinDatum.Formulation.Simple(actingType: .rapid, brand: "Afrezza"))
        }
    }
}
