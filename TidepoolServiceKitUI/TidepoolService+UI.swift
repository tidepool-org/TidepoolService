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
        UIImage(named: "Tidepool Logo", in: Bundle(for: TidepoolServiceSettingsViewController.self), compatibleWith: nil)!
    }

    public static func setupViewController(colorPalette: LoopUIColorPalette) -> SetupUIResult<ServiceViewController, ServiceUI> {
        return .userInteractionRequired(ServiceNavigationController(rootViewController: TidepoolServiceSetupViewController(service: TidepoolService())))
    }

    public func settingsViewController(colorPalette: LoopUIColorPalette) -> ServiceViewController {
        return ServiceNavigationController(rootViewController: TidepoolServiceSettingsViewController(service: self))
    }
}

extension TidepoolService: SupportUI {
    public var supportIdentifier: String { serviceIdentifier }

    public func supportMenuItem(supportInfoProvider: SupportInfoProvider, urlHandler: @escaping (URL) -> Void) -> AnyView? {
        let viewModel = AdverseEventReportViewModel(supportInfoProvider: supportInfoProvider)
        return AnyView(AdverseEventReportButton(adverseEventReportViewModel: viewModel, urlHandler: urlHandler))
    }
}
