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
    case prescriptionTherapySettingsOverview
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
    case carbRatioInfo
    case carbRatioEditor
    case insulinSensitivityInfo
    case insulinSensitivityEditor
    case therapySettingsRecap
    
    func next() -> PrescriptionReviewScreen? {
        switch self {
        case .enterCode:
            return .reviewDevices
        case .reviewDevices:
            return .prescriptionTherapySettingsOverview
        case .prescriptionTherapySettingsOverview:
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
            return .carbRatioInfo
        case .carbRatioInfo:
            return .carbRatioEditor
        case .carbRatioEditor:
            return .insulinSensitivityInfo
        case .insulinSensitivityInfo:
            return .insulinSensitivityEditor
        case .insulinSensitivityEditor:
            return .therapySettingsRecap
        case .therapySettingsRecap:
            return nil
        }
    }
}

class PrescriptionReviewUICoordinator: UINavigationController, CompletionNotifying, UINavigationControllerDelegate {
    var screenStack = [PrescriptionReviewScreen]()
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
                self?.therapySettingsViewModel = self?.constructTherapySettingsViewModel()
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
        case .prescriptionTherapySettingsOverview:
            let nextButtonString = LocalizedString("Next: Review settings", comment: "Therapy settings overview next button title")
            let actionButton = TherapySettingsView.ActionButton(localizedString: nextButtonString) { [weak self] in
                self?.stepFinished()
            }
            // The initial overview screen should _always_ show the prescription.
            let originalTherapySettingsViewModel = constructTherapySettingsViewModel()
            let view = TherapySettingsView(viewModel: originalTherapySettingsViewModel!, actionButton: actionButton)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.title = LocalizedString("Therapy Settings", comment: "Navigation view title")
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
            let view = CorrectionRangeScheduleEditor(viewModel: therapySettingsViewModel!)
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
            let view = CorrectionRangeOverridesEditor(viewModel: therapySettingsViewModel!)
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
            let view = SuspendThresholdEditor(viewModel: therapySettingsViewModel!)
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
            let view = BasalRateScheduleEditor(viewModel: therapySettingsViewModel!)
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
            let view = DeliveryLimitsEditor(viewModel: therapySettingsViewModel!)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .insulinModelInfo:
            let onExit: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = InsulinModelInformationView(onExit: onExit).environment(\.appName, Bundle.main.bundleDisplayName)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.insulinModel.title
            return hostedView
        case .insulinModelEditor:
            precondition(prescriptionViewModel.prescription != nil)
            
            let view = InsulinModelSelection(
                value: therapySettingsViewModel!.therapySettings.insulinModelSettings!,
                insulinSensitivitySchedule: therapySettingsViewModel!.therapySettings.insulinSensitivitySchedule,
                glucoseUnit: therapySettingsViewModel!.therapySettings.glucoseUnit!,
                supportedModelSettings: therapySettingsViewModel!.supportedInsulinModelSettings,
                mode: .acceptanceFlow, // don't wrap the view in a navigation view
                onSave: { [weak self] in
                    self?.therapySettingsViewModel?.saveInsulinModel(insulinModelSettings: $0)
                }
            ).environment(\.appName, Bundle.main.bundleDisplayName)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.insulinModel.title
            return hostedView
        case .carbRatioInfo:
            let onExit: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = CarbRatioInformationView(onExit: onExit)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.carbRatio.title
            return hostedView
        case .carbRatioEditor:
            precondition(prescriptionViewModel.prescription != nil)
            let view = CarbRatioScheduleEditor(
                schedule: therapySettingsViewModel!.therapySettings.carbRatioSchedule!,
                mode: .acceptanceFlow,
                onSave: { newSchedule in
                    self.therapySettingsViewModel!.saveCarbRatioSchedule(carbRatioSchedule: newSchedule)
                }
            )
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .insulinSensitivityInfo:
            let onExit: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = InsulinSensitivityInformationView(onExit: onExit)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.insulinSensitivity.title
            return hostedView
        case .insulinSensitivityEditor:
            precondition(prescriptionViewModel.prescription != nil)
            let view = InsulinSensitivityScheduleEditor(
                schedule: therapySettingsViewModel!.therapySettings.insulinSensitivitySchedule!,
                mode: .acceptanceFlow,
                glucoseUnit: therapySettingsViewModel!.therapySettings.glucoseUnit!,
                onSave: { newSchedule in
                    self.therapySettingsViewModel!.saveInsulinSensitivitySchedule(insulinSensitivitySchedule: newSchedule)
                }
            )
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .therapySettingsRecap:
            // Get rid of the "prescription" card because it should not be shown as part of the recap
            therapySettingsViewModel?.prescription = nil
            let nextButtonString = LocalizedString("Save settings", comment: "Therapy settings save button title")
            let actionButton = TherapySettingsView.ActionButton(localizedString: nextButtonString) { [weak self] in
                self?.stepFinished()
            }
            let view = TherapySettingsView(viewModel: therapySettingsViewModel!, actionButton: actionButton)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = LocalizedString("Therapy Settings", comment: "Navigation view title")
            return hostedView
        }
    }
    
    private func constructTherapySettingsViewModel() -> TherapySettingsViewModel? {
        guard let prescription = prescriptionViewModel.prescription else {
            return nil
        }
        var supportedBasalRates: [Double] {
            switch prescription.pump {
            case .dash:
                return (1...600).map { round(Double($0) / Double(1/0.05) * 100) / 100 }
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
                return (1...600).map { Double($0) / Double(1/0.05) }
            }
        }
        
        let pumpSupportedIncrements = PumpSupportedIncrements(
            basalRates: supportedBasalRates,
            bolusVolumes: supportedBolusVolumes,
            maximumBasalScheduleEntryCount: maximumBasalScheduleEntryCount
        )
        let supportedInsulinModelSettings = SupportedInsulinModelSettings(fiaspModelEnabled: false, walshModelEnabled: false)
        
        return TherapySettingsViewModel(
            mode: .acceptanceFlow,
            therapySettings: prescription.therapySettings,
            supportedInsulinModelSettings: supportedInsulinModelSettings,
            pumpSupportedIncrements: pumpSupportedIncrements,
            syncPumpSchedule: { _, _ in
                // Since pump isn't set up, this syncing shouldn't do anything
                assertionFailure()
            },
            prescription: prescription
        ) { [weak self] _, _ in
            self?.stepFinished()
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
            onReviewFinished?(therapySettingsViewModel!.therapySettings)
            completionDelegate?.completionNotifyingDidComplete(self)
        }
    }
    
    func navigate(to screen: PrescriptionReviewScreen) {
        screenStack.append(screen)
        let viewController = viewControllerForScreen(screen)
        self.pushViewController(viewController, animated: true)
    }
}

extension Bundle {

    var bundleDisplayName: String {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }
}

