//
//  UIImage.swift
//  TidepoolServiceKitUI
//
//  Created by Pete Schwamb on 4/19/23.
//  Copyright © 2023 LoopKit Authors. All rights reserved.
//

import Foundation
import UIKit

private class FrameworkBundle {
    static let main = Bundle(for: FrameworkBundle.self)
}

extension UIImage {
    convenience init(frameworkImage name: String) {
        self.init(named: name, in: FrameworkBundle.main, compatibleWith: nil)!
    }
}
