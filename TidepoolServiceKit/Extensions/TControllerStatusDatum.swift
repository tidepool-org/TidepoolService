//
//  TControllerStatusDatum.swift
//  TidepoolServiceKit
//
//  Created by Darin Krauss on 10/28/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import TidepoolKit

extension TControllerStatusDatum: TypedDatum {
    static var resolvedType: String { TDatum.DatumType.controllerStatus.rawValue }
}
