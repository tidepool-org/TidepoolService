//
//  PrescriptionReviewUICoordinator.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 6/18/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation
import SwiftUI
import LoopKitUI
import LoopKit

enum PrescriptionReviewScreen {
    case enterCode
    case reviewDevices
    case correctionRangeInfo
    case correctionRangeEditor
    case correctionRangeOverrideInfo
    case correctionRangeOverrideEditor
    case suspendThresholdInfo
    case suspendThresholdEditor
    case basalRatesInfo
    case basalRatesEditor
    case deliveryLimitsInfo
    case deliveryLimitsEditor
    case insulinModelInfo
    case insulinModelEditor
    
    func next() -> PrescriptionReviewScreen? {
        switch self {
        case .enterCode:
            return .reviewDevices
        case .reviewDevices:
            return .suspendThresholdInfo
        case .suspendThresholdInfo:
            return .suspendThresholdEditor
        case .suspendThresholdEditor:
            return .correctionRangeInfo
        case .correctionRangeInfo:
            return .correctionRangeEditor
        case .correctionRangeEditor:
            return .correctionRangeOverrideInfo
        case .correctionRangeOverrideInfo:
            return .correctionRangeOverrideEditor
        case .correctionRangeOverrideEditor:
            return .basalRatesInfo
        case .basalRatesInfo:
            return .basalRatesEditor
        case .basalRatesEditor:
            return .deliveryLimitsInfo
        case .deliveryLimitsInfo:
            return .deliveryLimitsEditor
        case .deliveryLimitsEditor:
            return .insulinModelInfo
        case .insulinModelInfo:
            return .insulinModelEditor
        case .insulinModelEditor:
            return nil
        }
    }
}

class PrescriptionReviewUICoordinator: UINavigationController, CompletionNotifying, UINavigationControllerDelegate {
    var screenStack = [PrescriptionReviewScreen]()
    var appName = "Tidepool Loop" // TODO: pull this from the environment
    weak var completionDelegate: CompletionDelegate?
    var onReviewFinished: ((TherapySettings) -> Void)?

    let prescriptionViewModel = PrescriptionReviewViewModel() // Used for retreving & keeping track of prescription
    private var therapySettingsViewModel: TherapySettingsViewModel? // Used for keeping track of & updating settings
    
    var currentScreen: PrescriptionReviewScreen {
        return screenStack.last!
    }

    init() {
        super.init(navigationBarClass: UINavigationBar.self, toolbarClass: UIToolbar.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        self.navigationBar.prefersLargeTitles = true // ensure nav bar text is displayed correctly
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func viewControllerForScreen(_ screen: PrescriptionReviewScreen) -> UIViewController {
        switch screen {
        case .enterCode:
            prescriptionViewModel.didCancel = { [weak self] in
                self?.setupCanceled()
            }
            prescriptionViewModel.didFinishStep = { [weak self] in
                if let prescription = self?.prescriptionViewModel.prescription {
                    var supportedBasalRates: [Double] {
                        switch prescription.pump {
                        case .dash:
                            return (0...600).map { round(Double($0) / Double(1/0.05) * 100) / 100 }
                        }
                    }

                    // TODO: don't hard-code these values
                    var maximumBasalScheduleEntryCount: Int {
                        switch prescription.pump {
                        case .dash:
                            return 24
                        }
                    }
                    
                    var supportedBolusVolumes: [Double] {
                        switch prescription.pump {
                        case .dash:
                            // TODO: don't hard-code this value
                            return (0...600).map { Double($0) / Double(1/0.05) }
                        }
                    }
                    
                    let pumpSupportedIncrements = PumpSupportedIncrements(
                        basalRates: supportedBasalRates,
                        bolusVolumes: supportedBolusVolumes,
                        maximumBasalScheduleEntryCount: maximumBasalScheduleEntryCount
                    )
                    let supportedInsulinModelSettings = SupportedInsulinModelSettings(fiaspModelEnabled: false, walshModelEnabled: false)
                    
                    self?.therapySettingsViewModel = TherapySettingsViewModel(
                        therapySettings: prescription.therapySettings,
                        supportedInsulinModelSettings: supportedInsulinModelSettings,
                        pumpSupportedIncrements: pumpSupportedIncrements,
                        syncPumpSchedule: { _, _ in
                            // Since pump isn't set up, this syncing shouldn't do anything
                            assertionFailure()
                        }
                    ) { [weak self] _, _ in
                        self?.stepFinished()
                    }
                }
                self?.stepFinished()
            }
            let view = PrescriptionCodeEntryView(viewModel: prescriptionViewModel)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.title = LocalizedString("Your Settings", comment: "Navigation view title")
            return hostedView
        case .reviewDevices:
            prescriptionViewModel.didFinishStep = { [weak self] in
                self?.stepFinished()
            }
            // We're using the prescription here because it has device info on it
            let view = PrescriptionDeviceView(viewModel: prescriptionViewModel, prescription: prescriptionViewModel.prescription!)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.title = LocalizedString("Review your settings", comment: "Navigation view title")
            return hostedView
        case .correctionRangeInfo:
            let onExit: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = CorrectionRangeInformationView(onExit: onExit)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.glucoseTargetRange.title
            return hostedView
        case .correctionRangeEditor:
            let view = CorrectionRangeReview(viewModel: therapySettingsViewModel!)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .correctionRangeOverrideInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = CorrectionRangeOverrideInformationView(onExit: exiting)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.correctionRangeOverrides.smallTitle
            return hostedView
        case .correctionRangeOverrideEditor:
            let view = CorrectionRangeOverrideReview(viewModel: therapySettingsViewModel!)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .suspendThresholdInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = SuspendThresholdInformationView(onExit: exiting)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.suspendThreshold.title
            return hostedView
        case .suspendThresholdEditor:
            let view = SuspendThresholdReview(viewModel: therapySettingsViewModel!)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .basalRatesInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = BasalRatesInformationView(onExit: exiting)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.basalRate.title
            return hostedView
        case .basalRatesEditor:
            precondition(prescriptionViewModel.prescription != nil)
            let view = BasalRatesReview(viewModel: therapySettingsViewModel!)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .deliveryLimitsInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = DeliveryLimitsInformationView(onExit: exiting)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.deliveryLimits.title
            return hostedView
        case .deliveryLimitsEditor:
            precondition(prescriptionViewModel.prescription != nil)
            let view = DeliveryLimitsReview(viewModel: therapySettingsViewModel!)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .insulinModelInfo:
            let onExit: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = InsulinModelInformationView(onExit: onExit)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.insulinModel.title
            return hostedView
        case .insulinModelEditor:
            precondition(prescriptionViewModel.prescription != nil)
            let view = InsulinModelReview(
                settingsViewModel: therapySettingsViewModel!,
                supportedModels: SupportedInsulinModelSettings(fiaspModelEnabled: false, walshModelEnabled: false),
                appName: appName
            )
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.insulinModel.title
            return hostedView
        }
    }
    
    public func navigationController(_ navigationController: UINavigationController,
                                     willShow viewController: UIViewController,
                                     animated: Bool) {
        // Pop the current screen from the stack if we're navigating back
        if viewControllers.count < screenStack.count {
            // Navigation back
            let _ = screenStack.popLast()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        screenStack = [.enterCode]
        let viewController = viewControllerForScreen(currentScreen)
        setViewControllers([viewController], animated: false)
    }
    
    // TODO: have separate flow for cancelling
    private func setupCanceled() {
        completionDelegate?.completionNotifyingDidComplete(self)
    }
    
    private func stepFinished() {
        if let nextStep = currentScreen.next() {
            navigate(to: nextStep)
        } else {
            if let onReviewFinished = onReviewFinished {
                onReviewFinished(therapySettingsViewModel!.therapySettings)
            }
            completionDelegate?.completionNotifyingDidComplete(self)
        }
    }
    
    func navigate(to screen: PrescriptionReviewScreen) {
        screenStack.append(screen)
        let viewController = viewControllerForScreen(screen)
        self.pushViewController(viewController, animated: true)
    }
}
