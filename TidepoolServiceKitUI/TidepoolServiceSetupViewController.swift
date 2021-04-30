//
//  TidepoolServiceSetupViewController.swift
//  TidepoolServiceKitUI
//
//  Created by Darin Krauss on 7/24/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import LoopKitUI
import TidepoolKit
import TidepoolKitUI
import TidepoolServiceKit

final class TidepoolServiceSetupViewController: UIViewController {

    private let service: TidepoolService

    init(service: TidepoolService) {
        self.service = service

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)

        var loginSignupViewController = service.tapi.loginSignupViewController()
        loginSignupViewController.loginSignupDelegate = self
        loginSignupViewController.view.frame = CGRect(origin: CGPoint(), size: view.frame.size)

        addChild(loginSignupViewController)
        view.addSubview(loginSignupViewController.view)

        loginSignupViewController.didMove(toParent: self)
    }
}

extension TidepoolServiceSetupViewController: TLoginSignupDelegate {
    func loginSignupDidComplete(completion: @escaping (Error?) -> Void) {
        service.completeCreate { error in
            guard error == nil else {
                completion(error)
                return
            }
            DispatchQueue.main.async {
                if let serviceNavigationController = self.navigationController as? ServiceNavigationController {
                    serviceNavigationController.notifyServiceCreatedAndOnboarded(self.service)
                    serviceNavigationController.notifyComplete()
                }
                completion(nil)
            }
        }
    }

    func loginSignupCancelled() {
        DispatchQueue.main.async {
            if let serviceNavigationController = self.navigationController as? ServiceNavigationController {
                serviceNavigationController.notifyComplete()
            }
        }
    }
}
