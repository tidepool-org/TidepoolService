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

    func loginSignup(_ loginSignup: TLoginSignup, didCreateSession session: TSession) -> Error? {
        service.completeCreate(withSession: session)
        if let serviceViewController = navigationController as? ServiceViewController {
            serviceViewController.notifyServiceCreated(service)
        }
        notifyComplete()
        return nil
    }

    private func notifyComplete() {
        if let serviceViewController = navigationController as? ServiceViewController {
            serviceViewController.notifyComplete()
        }
    }
}
