//
//  TidepoolService+UI.swift
//  TidepoolServiceKitUI
//
//  Created by Darin Krauss on 7/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import SwiftUI
import LoopKit
import LoopKitUI
import TidepoolServiceKit

extension TidepoolService: ServiceUI {
    public static var image: UIImage? {
        UIImage(named: "Tidepool Logo", in: Bundle(for: TidepoolServiceSetupViewController.self), compatibleWith: nil)!
    }

    public static func setupViewController(colorPalette: LoopUIColorPalette, pluginHost: PluginHost) -> SetupUIResult<ServiceViewController, ServiceUI> {
        let service = TidepoolService(hostIdentifier: pluginHost.hostIdentifier, hostVersion: pluginHost.hostVersion)
        return .userInteractionRequired(ServiceNavigationController(rootViewController: TidepoolServiceSetupViewController(service: service)))
    }

    public func settingsViewController(colorPalette: LoopUIColorPalette) -> ServiceViewController {

        let view = SettingsView(accountLogin: tapi.session?.email ?? "Unknown", didRequestDelete: {
            self.completeDelete()
        })
        let hostedView = DismissibleHostingController(rootView: view, colorPalette: colorPalette)
        let navVC = ServiceNavigationController(rootViewController: hostedView)

        return navVC
    }
}
