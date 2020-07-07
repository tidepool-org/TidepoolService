//
//  UIColor.swift
//  TidepoolServiceKitUI
//
//  Created by Darin Krauss on 7/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import UIKit

extension UIColor {

    @nonobjc static let delete = UIColor.HIGRedColor()

    // MARK: - HIG colors
    // See: https://developer.apple.com/ios/human-interface-guidelines/visual-design/color/

    private static func HIGRedColor() -> UIColor {
        return UIColor(red: 1, green: 59 / 255, blue: 48 / 255, alpha: 1)
    }
    
    static let tidepoolGray: UIColor = {
        if #available(iOSApplicationExtension 13.0, iOS 13.0, *) {
            return UIColor(dynamicProvider: { (traitCollection) in
                switch traitCollection.userInterfaceStyle {
                case .dark: // use secondary color if in dark mode
                    return .secondaryLabel
                default: // otherwise use the Tidepool blue-gray
                    return UIColor(red: 106 / 255, green: 120 / 255, blue: 141 / 255, alpha: 1)
                }
            })
        } else {
            return UIColor(red: 106 / 255, green: 120 / 255, blue: 141 / 255, alpha: 1)
        }
    }()
}
