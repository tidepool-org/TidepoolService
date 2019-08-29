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

final class TidepoolServiceSetupViewController: UIViewController, LoginSignupDelegate {

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

        let logInViewController = TidepoolKitUI(tpKit: service.tidepoolKit, logger: TidepoolKitLog()).logInViewController(loginSignupDelegate: self)
        logInViewController.view.frame = CGRect(origin: CGPoint(), size: view.frame.size)

        addChild(logInViewController)
        view.addSubview(logInViewController.view)

        logInViewController.didMove(toParent: self)
    }

    @objc public func cancel() {
        notifyComplete()
    }

    public func loginSignupComplete(_ session: TPSession) {
        service.completeCreate(withSession: session) {
            DispatchQueue.main.async {
                if let serviceViewController = self.navigationController as? ServiceViewController {
                    serviceViewController.notifyServiceCreated(self.service)
                }
                self.notifyComplete()
            }
        }
    }

    private func notifyComplete() {
        if let serviceViewController = navigationController as? ServiceViewController {
            serviceViewController.notifyComplete()
        }
    }

}
