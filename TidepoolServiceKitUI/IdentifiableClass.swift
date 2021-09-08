//
//  IdentifiableClass.swift
//  TidepoolServiceKitUI
//
//  Created by Darin Krauss on 7/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

protocol IdentifiableClass: AnyObject {

    static var className: String { get }

}

extension IdentifiableClass {

    static var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }

}
