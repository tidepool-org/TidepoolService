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
    
    func next() -> PrescriptionReviewScreen? {
        switch self {
        case .enterCode:
            return .reviewDevices
        case .reviewDevices:
            return .correctionRangeInfo
        case .correctionRangeInfo:
            return .correctionRangeEditor
        case .correctionRangeEditor:
            return .correctionRangeOverrideInfo
        case .correctionRangeOverrideInfo:
            return .correctionRangeOverrideEditor
        case .correctionRangeOverrideEditor:
            return .suspendThresholdInfo
        case .suspendThresholdInfo:
            return .suspendThresholdEditor
        case .suspendThresholdEditor:
            return .basalRatesInfo
        case .basalRatesInfo:
            return .basalRatesEditor
        case .basalRatesEditor:
            return .deliveryLimitsInfo
        case .deliveryLimitsInfo:
            return .deliveryLimitsEditor
        case .deliveryLimitsEditor:
            return nil
        }
    }
}

class PrescriptionReviewUICoordinator: UINavigationController, CompletionNotifying, UINavigationControllerDelegate {
    var screenStack = [PrescriptionReviewScreen]()
    weak var completionDelegate: CompletionDelegate?
    var onReviewFinished: ((TherapySettings) -> Void)?

    let viewModel = PrescriptionReviewViewModel(settings: TherapySettings())
    
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
            viewModel.didCancel = { [weak self] in
                self?.setupCanceled()
            }
            viewModel.didFinishStep = { [weak self] in
                self?.stepFinished()
            }
            let view = PrescriptionCodeEntryView(viewModel: viewModel)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.title = LocalizedString("Your Settings", comment: "Navigation view title")
            return hostedView
        case .reviewDevices:
            viewModel.didFinishStep = { [weak self] in
                self?.stepFinished()
            }
            guard let prescription = viewModel.prescription else {
                // Go back to code entry step if we don't have prescription
                return restartFlow()
            }
            let view = PrescriptionDeviceView(viewModel: viewModel, prescription: prescription)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.title = LocalizedString("Review your settings", comment: "Navigation view title")
            return hostedView
        case .correctionRangeInfo:
            let exiting: (() -> Void) = { [weak self] in
                self?.stepFinished()
            }
            let view = CorrectionRangeInformationView(onExit: exiting)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.title = LocalizedString("Correction Range", comment: "Title for correction range informational screen")
            return hostedView
        case .correctionRangeEditor:
            guard let prescription = viewModel.prescription else {
                // Go back to code entry step if we don't have prescription
                return restartFlow()
            }
            let view = CorrectionRangeReviewView(model: viewModel, prescription: prescription)
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
            hostedView.title = LocalizedString("Temporary Ranges", comment: "Title for temporary correction range informational screen") // TODO: make this title be "Temporary Correction Ranges" when SwiftUI supports multi-line titles
            return hostedView
        case .correctionRangeOverrideEditor:
            guard let prescription = viewModel.prescription else {
                // Go back to code entry step if we don't have prescription
                let view = PrescriptionCodeEntryView(viewModel: viewModel)
                return DismissibleHostingController(rootView: view)
            }
            
            let view = CorrectionRangeOverrideReview(model: viewModel, prescription: prescription)
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
            hostedView.title = LocalizedString("Suspend Threshold", comment: "Title for suspend threshold informational screen")
            return hostedView
        case .suspendThresholdEditor:
            guard let prescription = viewModel.prescription else {
                // Go back to code entry step if we don't have prescription
                return restartFlow()
            }
            let view = SuspendThresholdReview(model: viewModel, prescription: prescription)
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
            hostedView.title = LocalizedString("Basal Rates", comment: "Title for basal rates informational screen")
            return hostedView
        case .basalRatesEditor:
            guard let prescription = viewModel.prescription else {
                // Go back to code entry step if we don't have prescription
                return restartFlow()
            }
            
            let view = BasalRatesReview(model: viewModel, prescription: prescription)
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
            hostedView.title = LocalizedString("Delivery Limits", comment: "Title for delivery limits informational screen")
            return hostedView
        case .deliveryLimitsEditor:
            guard let prescription = viewModel.prescription else {
                // Go back to code entry step if we don't have prescription
                return restartFlow()
            }
            
            let view = DeliveryLimitsReviewView(model: viewModel, prescription: prescription)
            let hostedView = DismissibleHostingController(rootView: view)
            hostedView.navigationItem.largeTitleDisplayMode = .never // TODO: hack to fix jumping, will be removed once editors have titles
            return hostedView
        }
    }
    
    private func restartFlow() -> UIViewController {
        screenStack = [.enterCode]
        let view = PrescriptionCodeEntryView(viewModel: viewModel)
        return DismissibleHostingController(rootView: view)
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
    
    private func determineFirstScreen() -> PrescriptionReviewScreen {
        return .enterCode
    }
    
    override func viewWillAppear(_ animated: Bool) {
        screenStack = [determineFirstScreen()]
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
                onReviewFinished(viewModel.settings)
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
