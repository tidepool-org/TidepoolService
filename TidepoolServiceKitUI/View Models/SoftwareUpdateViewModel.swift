//
//  SoftwareUpdateViewModel.swift
//  TidepoolServiceKitUI
//
//  Created by Rick Pasetto on 10/4/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import Combine
import Foundation
import LoopKit
import LoopKitUI
import SwiftUI

public class SoftwareUpdateViewModel: ObservableObject {
    
    @Published var versionUpdate: VersionUpdate?

    var softwareUpdateAvailable: Bool {
        update()
        return versionUpdate?.softwareUpdateAvailable ?? false
    }
    
    @ViewBuilder
    var icon: some View {
        switch versionUpdate {
        case .required, .recommended:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(warningColor)
        default:
            EmptyView()
        }
    }
    
    var warningColor: Color {
        switch versionUpdate {
        case .required: return guidanceColors.critical
        case .recommended: return guidanceColors.warning
        default: return .primary
        }
    }
    
    lazy private var cancellables = Set<AnyCancellable>()

    private weak var versionCheckService: VersionCheckServiceUI?
    private let guidanceColors: GuidanceColors
    private let openAppStoreHook: (() -> Void)?
    private let bundleIdentifier: String
    private let currentVersion: String
    
    init(versionCheckService: VersionCheckServiceUI? = nil,
         guidanceColors: GuidanceColors,
         openAppStoreHook: (() -> Void)? = nil,
         bundleIdentifier: String,
         currentVersion: String) {
        self.versionCheckService = versionCheckService
        self.guidanceColors = guidanceColors
        self.bundleIdentifier = bundleIdentifier
        self.currentVersion = currentVersion
        self.openAppStoreHook = openAppStoreHook
        
        NotificationCenter.default.publisher(for: .SoftwareUpdateAvailable)
            .sink { [weak self] _ in
                self?.update()
            }
            .store(in: &cancellables)
        
        update()
    }
    
    public func update() {
        versionCheckService?.checkVersion(bundleIdentifier: bundleIdentifier, currentVersion: currentVersion) {
            if case .success(let versionUpdate) = $0 {
                self.versionUpdate = versionUpdate
            }
        }
    }
    
    func gotoAppStore() {
        openAppStoreHook?()
    }

}


extension SoftwareUpdateViewModel {
    static var preview: SoftwareUpdateViewModel {
        return SoftwareUpdateViewModel(versionCheckService: nil,
                                       guidanceColors: GuidanceColors(),
                                       bundleIdentifier: "",
                                       currentVersion: "")
    }
}
