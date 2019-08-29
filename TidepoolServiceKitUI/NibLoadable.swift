//
//  NibLoadable.swift
//  TidepoolServiceKitUI
//
//  Created by Darin Krauss on 7/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import UIKit

protocol NibLoadable: IdentifiableClass {

    static func nib() -> UINib

}

extension NibLoadable {

    static func nib() -> UINib {
        return UINib(nibName: className, bundle: Bundle(for: self))
    }

}
