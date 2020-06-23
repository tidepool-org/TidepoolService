//
//  TidepoolServiceSetupViewController.swift
//  TidepoolServiceKitUI
//
//  Created by Darin Krauss on 7/24/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import LoopKitUI
import SwiftUI
import TidepoolKit
import TidepoolKitUI
import TidepoolServiceKit

final class TidepoolServiceSetupViewController: UIViewController, TLoginSignupDelegate {

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

        title = service.localizedTitle

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))

        var loginSignupViewController = service.tapi.loginSignupViewController()
        loginSignupViewController.delegate = self
        loginSignupViewController.view.frame = CGRect(origin: CGPoint(), size: view.frame.size)

        addChild(loginSignupViewController)
        view.addSubview(loginSignupViewController.view)

        loginSignupViewController.didMove(toParent: self)
    }

    @objc private func cancel() {
        notifyComplete()
    }

    func loginSignup(_ loginSignup: TLoginSignup, didCreateSession session: TSession, completion: @escaping (Error?) -> Void) {
        service.completeCreate(withSession: session) { error in
            guard error == nil else {
                completion(error)
                return
            }
            DispatchQueue.main.async {
                if let serviceViewController = self.navigationController as? ServiceViewController {
                    serviceViewController.notifyServiceCreated(self.service)
                }
                self.notifyComplete()
                completion(nil)
            }
        }
    }
    
    private func onboardIfNeeded() {
        if service.onboardingNeeded {
            let setupViewController = PrescriptionReviewUICoordinator()
            self.present(setupViewController, animated: true, completion: nil)
        }
    }

    private func notifyComplete() {
        if let serviceViewController = navigationController as? ServiceViewController {
            onboardIfNeeded()
            // ANNA TODO: revert, this will make the screen be dismissed
            //serviceViewController.notifyComplete()
        }
    }
}
