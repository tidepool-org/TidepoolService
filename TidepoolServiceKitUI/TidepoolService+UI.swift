//
//  TidepoolService+UI.swift
//  TidepoolServiceKitUI
//
//  Created by Darin Krauss on 7/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import LoopKit
import LoopKitUI
import TidepoolServiceKit

extension TidepoolService: ServiceUI {

    public static func setupViewController() -> (UIViewController & ServiceSetupNotifying & CompletionNotifying)? {
        return ServiceViewController(rootViewController: TidepoolServiceSetupViewController(service: TidepoolService()))
    }

    public func settingsViewController() -> (UIViewController & ServiceSettingsNotifying & CompletionNotifying) {
      return ServiceViewController(rootViewController: TidepoolServiceSettingsViewController(service: self))
    }

}
