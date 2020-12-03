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
import HealthKit

enum PrescriptionReviewScreen: CaseIterable {
    case enterCode
    case reviewDevices
    case prescriptionTherapySettingsOverview
    case suspendThresholdInfo
    case suspendThresholdEditor
    case correctionRangeInfo
    case correctionRangeEditor
    case correctionRangePreMealOverrideInfo
    case correctionRangePreMealOverrideEditor
    case correctionRangeWorkoutOverrideInfo
    case correctionRangeWorkoutOverrideEditor
    case carbRatioInfo
    case carbRatioEditor
    case basalRatesInfo
    case basalRatesEditor
    case deliveryLimitsInfo
    case deliveryLimitsEditor
    case insulinModelInfo
    case insulinModelEditor
    case insulinSensitivityInfo
    case insulinSensitivityEditor
    case therapySettingsRecap
    
    func next() -> PrescriptionReviewScreen? {
        guard let thisIndex = Self.allCases.firstIndex(where: { $0 == self }) else { return nil }
        let nextIndex = thisIndex + 1
        guard nextIndex < Self.allCases.count else { return nil }
        return Self.allCases[nextIndex]
    }
}

class PrescriptionReviewUICoordinator: UINavigationController, CompletionNotifying, UINavigationControllerDelegate {
    var screenStack = [PrescriptionReviewScreen]()
    weak var completionDelegate: CompletionDelegate?
    var onReviewFinished: ((TherapySettings) -> Void)?
    
    private let preferredGlucoseUnit: HKUnit
    private let chartColors: ChartColorPalette
    private let carbTintColor: Color
    private let glucoseTintColor: Color
    private let guidanceColors: GuidanceColors
    private let insulinTintColor: Color

    
    let prescriptionViewModel = PrescriptionReviewViewModel() // Used for retreving & keeping track of prescription
    private var therapySettingsViewModel: TherapySettingsViewModel? // Used for keeping track of & updating settings
    
    var currentScreen: PrescriptionReviewScreen {
        return screenStack.last!
    }

    init(preferredGlucoseUnit: HKUnit, chartColors: ChartColorPalette, carbTintColor: Color, glucoseTintColor: Color, guidanceColors: GuidanceColors, insulinTintColor: Color) {
        self.preferredGlucoseUnit = preferredGlucoseUnit
        self.chartColors = chartColors
        self.carbTintColor = carbTintColor
        self.glucoseTintColor = glucoseTintColor
        self.guidanceColors = guidanceColors
        self.insulinTintColor = insulinTintColor
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
            let hostedView = hostingController(rootView: view)
            hostedView.title = LocalizedString("Your Settings", comment: "Navigation view title")
            return hostedView
        case .reviewDevices:
            prescriptionViewModel.didFinishStep = { [weak self] in
                self?.stepFinished()
            }
            // We're using the prescription here because it has device info on it
            let view = PrescriptionDeviceView(viewModel: prescriptionViewModel, prescription: prescriptionViewModel.prescription!)
            let hostedView = hostingController(rootView: view)
            hostedView.title = LocalizedString("Review your settings", comment: "Navigation view title")
            return hostedView
        case .prescriptionTherapySettingsOverview:
            let nextButtonString = LocalizedString("Continue", comment: "Therapy settings overview next button title")
            let actionButton = TherapySettingsView.ActionButton(localizedString: nextButtonString) { [weak self] in
                self?.stepFinished()
            }
            // The initial overview screen should _always_ show the prescription.
            let originalTherapySettingsViewModel = constructTherapySettingsViewModel()
            let view = TherapySettingsView(viewModel: originalTherapySettingsViewModel!, actionButton: actionButton)
            let hostedView = hostingController(rootView: view)
            hostedView.title = LocalizedString("Therapy Settings", comment: "Navigation view title")
            return hostedView
        case .correctionRangeInfo:
            let onExit: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = CorrectionRangeInformationView(onExit: onExit)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.glucoseTargetRange.title
            return hostedView
        case .correctionRangeEditor:
            let view = CorrectionRangeScheduleEditor(viewModel: therapySettingsViewModel!)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .correctionRangePreMealOverrideInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = CorrectionRangeOverrideInformationView(preset: .preMeal, onExit: exiting)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.preMealCorrectionRangeOverride.smallTitle
            return hostedView
        case .correctionRangePreMealOverrideEditor:
            let view = CorrectionRangeOverridesEditor(viewModel: therapySettingsViewModel!, preset: .preMeal)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .correctionRangeWorkoutOverrideInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = CorrectionRangeOverrideInformationView(preset: .workout, onExit: exiting)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.workoutCorrectionRangeOverride.smallTitle
            return hostedView
        case .correctionRangeWorkoutOverrideEditor:
            let view = CorrectionRangeOverridesEditor(viewModel: therapySettingsViewModel!, preset: .workout)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .suspendThresholdInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = SuspendThresholdInformationView(onExit: exiting)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.suspendThreshold.title
            return hostedView
        case .suspendThresholdEditor:
            let view = SuspendThresholdEditor(viewModel: therapySettingsViewModel!)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .basalRatesInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = BasalRatesInformationView(onExit: exiting)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.basalRate.title
            return hostedView
        case .basalRatesEditor:
            precondition(prescriptionViewModel.prescription != nil)
            let view = BasalRateScheduleEditor(viewModel: therapySettingsViewModel!)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .deliveryLimitsInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = DeliveryLimitsInformationView(onExit: exiting)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.deliveryLimits.title
            return hostedView
        case .deliveryLimitsEditor:
            precondition(prescriptionViewModel.prescription != nil)
            let view = DeliveryLimitsEditor(viewModel: therapySettingsViewModel!)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .insulinModelInfo:
            let onExit: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = InsulinModelInformationView(onExit: onExit)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.insulinModel.title
            return hostedView
        case .insulinModelEditor:
            precondition(prescriptionViewModel.prescription != nil)
            
            let view = InsulinModelSelection(viewModel: therapySettingsViewModel!)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.insulinModel.title
            return hostedView
        case .carbRatioInfo:
            let onExit: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = CarbRatioInformationView(onExit: onExit)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.carbRatio.title
            return hostedView
        case .carbRatioEditor:
            precondition(prescriptionViewModel.prescription != nil)
            let view = CarbRatioScheduleEditor(viewModel: therapySettingsViewModel!)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .insulinSensitivityInfo:
            let onExit: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = InsulinSensitivityInformationView(onExit: onExit)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = TherapySetting.insulinSensitivity.title
            return hostedView
        case .insulinSensitivityEditor:
            precondition(prescriptionViewModel.prescription != nil)
            let view = InsulinSensitivityScheduleEditor(viewModel: therapySettingsViewModel!)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        case .therapySettingsRecap:
            // Get rid of the "prescription" card because it should not be shown as part of the recap
            therapySettingsViewModel?.prescription = nil
            let nextButtonString = LocalizedString("Save Settings", comment: "Therapy settings save button title")
            let actionButton = TherapySettingsView.ActionButton(localizedString: nextButtonString) { [weak self] in
                self?.stepFinished()
            }
            let view = TherapySettingsView(viewModel: therapySettingsViewModel!, actionButton: actionButton)
            let hostedView = hostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .always // TODO: hack to fix jumping, will be removed once editors have titles
            hostedView.title = LocalizedString("Therapy Settings", comment: "Navigation view title")
            return hostedView
        }
    }
    
    private func hostingController<Content: View>(rootView: Content) -> DismissibleHostingController {
        return DismissibleHostingController(rootView: rootView.environment(\.appName, Bundle.main.bundleDisplayName),
                                            carbTintColor: carbTintColor,
                                            glucoseTintColor: glucoseTintColor,
                                            guidanceColors: guidanceColors,
                                            insulinTintColor: insulinTintColor)
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
            preferredGlucoseUnit: preferredGlucoseUnit,
            supportedInsulinModelSettings: supportedInsulinModelSettings,
            pumpSupportedIncrements: { pumpSupportedIncrements },
            syncPumpSchedule: {
                { _, _ in
                    // Since pump isn't set up, this syncing shouldn't do anything
                    assertionFailure()
                }
            },
            prescription: prescription,
            chartColors: chartColors
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

