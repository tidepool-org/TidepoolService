//
//  TidepoolService+VersionCheckServiceUI.swift
//  TidepoolServiceKitUI
//
//  Created by Rick Pasetto on 10/11/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit
import LoopKitUI
import TidepoolServiceKit

extension TidepoolService: VersionCheckServiceUI {
    
    private static var alertCadence = TimeInterval(2 * 7 * 24 * 60 * 60) // every 2 weeks

    public func setAlertIssuer(alertIssuer: AlertIssuer?) {
        self.alertIssuer = alertIssuer
    }
    
    public func softwareUpdateView(guidanceColors: GuidanceColors,
                                   bundleIdentifier: String,
                                   currentVersion: String,
                                   openAppStoreHook: (() -> Void)?) -> AnyView? {
        let viewModel = SoftwareUpdateViewModel(versionCheckService: self, guidanceColors: guidanceColors, bundleIdentifier: bundleIdentifier, currentVersion: currentVersion)
        return AnyView(SoftwareUpdateView(softwareUpdateViewModel: viewModel))
    }

    private func maybeIssueAlert(_ versionUpdate: VersionUpdate) {
        guard versionUpdate >= .recommended else {
            noAlertNecessary()
            return
        }
        
        let alertIdentifier = Alert.Identifier(managerIdentifier: serviceIdentifier, alertIdentifier: versionUpdate.rawValue)
        let alertContent: LoopKit.Alert.Content
        if firstAlert {
            alertContent = Alert.Content(title: versionUpdate.localizedDescription,
                                         body: NSLocalizedString("""
                                                Your Tidepool Loop app is out of date. It will continue to work, but we recommend updating to the latest version.
                                                
                                                Go to Tidepool Loop Settings > Software Update to complete.
                                                """, comment: "Alert content body for first software update alert"),
                                         acknowledgeActionButtonLabel: NSLocalizedString("OK", comment: "default acknowledgement"),
                                         isCritical: versionUpdate == .required)
        } else if let lastVersionCheckAlertDate = lastVersionCheckAlertDate,
                  abs(lastVersionCheckAlertDate.timeIntervalSinceNow) > Self.alertCadence {
            alertContent = Alert.Content(title: NSLocalizedString("Update Reminder", comment: "Recurring software update alert title"),
                                         body: NSLocalizedString("""
                                                A software update is recommended to continue using the Tidepool Loop app.
                                                
                                                Go to Tidepool Loop Settings > Software Update to install the latest version.
                                                """, comment: "Alert content body for recurring software update alert"),
                                         acknowledgeActionButtonLabel: NSLocalizedString("OK", comment: "default acknowledgement"),
                                         isCritical: versionUpdate == .required)
        } else {
            return
        }
        alertIssuer?.issueAlert(Alert(identifier: alertIdentifier, foregroundContent: alertContent, backgroundContent: alertContent, trigger: .immediate))
        recordLastAlertDate()
    }
    
    private func noAlertNecessary() {
        lastVersionCheckAlertDate = nil
    }
    
    private var firstAlert: Bool {
        return lastVersionCheckAlertDate == nil
    }
    
    private func recordLastAlertDate() {
        lastVersionCheckAlertDate = Date()
    }

}

