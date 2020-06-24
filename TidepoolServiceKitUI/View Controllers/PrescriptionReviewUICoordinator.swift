//
//  PrescriptionReviewUICoordinator.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 6/18/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import Foundation
import SwiftUI
import LoopKitUI

enum PrescriptionReviewScreen {
    case enterCode
    case reviewDevices
    
    func next() -> PrescriptionReviewScreen? {
        switch self {
        case .enterCode:
            return .reviewDevices
        case .reviewDevices:
            return nil
        }
    }
}

class PrescriptionReviewUICoordinator: UINavigationController, CompletionNotifying {
    var screenStack = [PrescriptionReviewScreen]()
    var completionDelegate: CompletionDelegate?
    
    let viewModel = PrescriptionCodeEntryViewModel()
    
    var currentScreen: PrescriptionReviewScreen {
        return screenStack.last!
    }
    
    // TODO: create delegate so we can add settings to LoopDataManager
    init() {
        super.init(navigationBarClass: UINavigationBar.self, toolbarClass: UIToolbar.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            return DismissibleHostingController(rootView: view)
        case .reviewDevices:
            viewModel.didCancel = { [weak self] in
                self?.setupCanceled()
            }
            viewModel.didFinishStep = { [weak self] in
                self?.stepFinished()
            }
            let view = PrescriptionDeviceView(viewModel: viewModel)
            return DismissibleHostingController(rootView: view)
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
    
    private func setupCanceled() {
        completionDelegate?.completionNotifyingDidComplete(self)
    }
    
    private func stepFinished() {
        if let nextStep = currentScreen.next() {
            navigate(to: nextStep)
        } else {
            completionDelegate?.completionNotifyingDidComplete(self)
        }
    }
    
    func navigate(to screen: PrescriptionReviewScreen) {
        screenStack.append(screen)
        let viewController = viewControllerForScreen(screen)
        self.pushViewController(viewController, animated: true)
    }
}
