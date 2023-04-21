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
import TidepoolKit
import TidepoolServiceKit

extension TidepoolService: ServiceUI {
    public static var image: UIImage? {
        UIImage(frameworkImage: "Tidepool Logo")
    }

    public static func setupViewController(colorPalette: LoopUIColorPalette, pluginHost: PluginHost) -> SetupUIResult<ServiceViewController, ServiceUI> {

        let navController = ServiceNavigationController()
        navController.isNavigationBarHidden = true

        Task {
            let service = TidepoolService(hostIdentifier: pluginHost.hostIdentifier, hostVersion: pluginHost.hostVersion)

            let settingsView = await SettingsView(service: service, login: { environment in
                try await service.tapi.login(environment: environment, presenting: navController)
                try await service.completeCreate()
                await navController.notifyServiceCreatedAndOnboarded(service)
                //await navController.notifyComplete()
            }, dismiss: {
                Task {
                    await navController.notifyComplete()
                }
            })

            let hostingController = await UIHostingController(rootView: settingsView)
            await navController.pushViewController(hostingController, animated: false)
        }
        
        return .userInteractionRequired(navController)
    }

    public func settingsViewController(colorPalette: LoopUIColorPalette) -> ServiceViewController {

        let navController = ServiceNavigationController()
        navController.isNavigationBarHidden = true

        Task {
            let settingsView = await SettingsView(service: self, login: { [weak self] environment in
                if let self {
                    try await self.tapi.login(environment: environment, presenting: navController)
                }
            }, dismiss: {
                Task {
                    await navController.notifyComplete()
                }
            })

            let hostingController = await UIHostingController(rootView: settingsView)
            await navController.pushViewController(hostingController, animated: false)
        }

        return navController
    }
}
