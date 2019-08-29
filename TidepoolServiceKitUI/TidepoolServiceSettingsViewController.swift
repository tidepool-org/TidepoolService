//
//  TidepoolServiceSettingsViewController.swift
//  TidepoolServiceKitUI
//
//  Created by Darin Krauss on 7/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import UIKit
import LoopKit
import LoopKitUI
import TidepoolServiceKit

final class TidepoolServiceSettingsViewController: UITableViewController, UITextFieldDelegate {

    private let service: TidepoolService

    init(service: TidepoolService) {
        self.service = service

        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.className)
        tableView.register(TextButtonTableViewCell.self, forCellReuseIdentifier: TextButtonTableViewCell.className)

        title = service.localizedTitle

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }

    @objc private func cancel() {
        view.endEditing(true)

        notifyComplete()
    }

    @objc private func done() {
        view.endEditing(true)

        service.completeUpdate {
            if let serviceViewController = self.navigationController as? ServiceViewController {
                serviceViewController.notifyServiceUpdated(self.service)
            }
            self.notifyComplete()
        }
    }

    private func confirmDeletion(completion: (() -> Void)? = nil) {
        view.endEditing(true)

        let alert = UIAlertController(serviceDeletionHandler: {
            self.service.completeDelete {
                if let serviceViewController = self.navigationController as? ServiceViewController {
                    serviceViewController.notifyServiceDeleted(self.service)
                }
                self.notifyComplete()
            }
        })

        present(alert, animated: true, completion: completion)
    }

    private func notifyComplete() {
        if let serviceViewController = navigationController as? ServiceViewController {
            serviceViewController.notifyComplete()
        }
    }

    // MARK: - Data Source

    private enum Section: Int, CaseIterable {
        case details
        case deleteService
    }

    private enum Details: Int, CaseIterable {
        case email
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .details:
            return Details.allCases.count
        case .deleteService:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .details:
            return nil
        case .deleteService:
            return " " // Use an empty string for more dramatic spacing
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .details:
            switch Details(rawValue: indexPath.row)! {
            case .email:
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.className, for: indexPath) as! SettingsTableViewCell
                cell.textLabel?.text = "Email"
                cell.detailTextLabel?.text = service.email
                return cell
            }
        case .deleteService:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextButtonTableViewCell.className, for: indexPath) as! TextButtonTableViewCell
            cell.textLabel?.text = LocalizedString("Delete Service", comment: "Button title to delete a service")
            cell.textLabel?.textAlignment = .center
            cell.tintColor = .delete
            return cell
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .details:
            break
        case .deleteService:
            confirmDeletion {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

}

extension SettingsTableViewCell: IdentifiableClass {}

extension TextButtonTableViewCell: IdentifiableClass {}

fileprivate extension UIAlertController {

    convenience init(serviceDeletionHandler handler: @escaping () -> Void) {
        self.init(
            title: nil,
            message: NSLocalizedString("Are you sure you want to delete this service?", comment: "Confirmation message for deleting a service"),
            preferredStyle: .actionSheet
        )

        addAction(UIAlertAction(
            title: NSLocalizedString("Delete Service", comment: "Button title to delete a service"),
            style: .destructive,
            handler: { _ in
                handler()
        }
        ))

        let cancel = NSLocalizedString("Cancel", comment: "The title of the cancel action in an action sheet")
        addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
    }

}
