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
import HealthKit

extension TidepoolService: ServiceUI {
    public static var image: UIImage? {
        UIImage(named: "Tidepool Logo", in: Bundle(for: TidepoolServiceSettingsViewController.self), compatibleWith: nil)!
    }

    public static var providesOnboarding: Bool { true }

    public static func setupViewController(currentTherapySettings: TherapySettings, preferredGlucoseUnit: HKUnit, chartColors: ChartColorPalette, carbTintColor: Color, glucoseTintColor: Color, guidanceColors: GuidanceColors, insulinTintColor: Color) -> (UIViewController & ServiceSetupNotifying & CompletionNotifying)?
    {
        var navVC: ServiceViewController?
        let service = TidepoolService()
        let setupVC = TidepoolServiceSetupViewController(service: service) {
            if currentTherapySettings.isComplete {
                navVC?.notifyComplete()
            } else {
                // Need to do onboarding
                let settingsVC = TidepoolServiceSettingsViewController(service: service, currentTherapySettings: currentTherapySettings, preferredGlucoseUnit: preferredGlucoseUnit, chartColors: chartColors, carbTintColor: carbTintColor, glucoseTintColor: glucoseTintColor, guidanceColors: guidanceColors, insulinTintColor: insulinTintColor)
                navVC?.setViewControllers([settingsVC], animated: true)
            }
        }
        navVC = ServiceViewController(rootViewController: setupVC)
        return navVC!
    }

    public func settingsViewController(currentTherapySettings: TherapySettings, preferredGlucoseUnit: HKUnit, chartColors: ChartColorPalette, carbTintColor: Color, glucoseTintColor: Color, guidanceColors: GuidanceColors, insulinTintColor: Color) -> (UIViewController & ServiceSettingsNotifying & CompletionNotifying)
    {
        return ServiceViewController(rootViewController: TidepoolServiceSettingsViewController(service: self, currentTherapySettings: currentTherapySettings, preferredGlucoseUnit: preferredGlucoseUnit, chartColors: chartColors, carbTintColor: carbTintColor, glucoseTintColor: glucoseTintColor, guidanceColors: guidanceColors, insulinTintColor: insulinTintColor))
    }

    public func supportMenuItem(supportInfoProvider: SupportInfoProvider, urlHandler: @escaping (URL) -> Void) -> AnyView? {
        let viewModel = AdverseEventReportViewModel(supportInfoProvider: supportInfoProvider)
        return AnyView(AdverseEventReportButton(adverseEventReportViewModel: viewModel, urlHandler: urlHandler))
    }
}
