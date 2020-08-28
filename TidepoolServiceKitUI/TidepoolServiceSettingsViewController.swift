//
//  TidepoolServiceSettingsViewController.swift
//  TidepoolServiceKitUI
//
//  Created by Darin Krauss on 7/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import SwiftUI
import LoopKitUI
import TidepoolServiceKit
                                                                        /* Added to support prescription flow */
final class TidepoolServiceSettingsViewController: UITableViewController, CompletionDelegate {

    private let service: TidepoolService
    private let chartColors: ChartColorPalette
    private let carbTintColor: Color
    private let glucoseTintColor: Color
    private let guidanceColors: GuidanceColors
    private let insulinTintColor: Color

    init(service: TidepoolService, chartColors: ChartColorPalette, carbTintColor: Color, glucoseTintColor: Color, guidanceColors: GuidanceColors, insulinTintColor: Color) {
        self.service = service
        self.chartColors = chartColors
        self.carbTintColor = carbTintColor
        self.glucoseTintColor = glucoseTintColor
        self.guidanceColors = guidanceColors
        self.insulinTintColor = insulinTintColor

        super.init(style: .grouped)
        
        title = NSLocalizedString("Tidepool Service", comment: "The title of the Tidepool Service settings screen")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(TextButtonTableViewCell.self, forCellReuseIdentifier: TextButtonTableViewCell.className)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }

    @objc private func done() {
        service.completeUpdate()
        notifyComplete()
    }

    private func confirmDeletion(completion: (() -> Void)? = nil) {
        let alert = UIAlertController(serviceDeletionHandler: {
            self.service.completeDelete()
            if let serviceViewController = self.navigationController as? ServiceViewController {
                serviceViewController.notifyServiceDeleted(self.service)
            }
            self.notifyComplete()
        })

        present(alert, animated: true, completion: completion)
    }
    
    @objc private func startFlow() {
        let setupViewController = PrescriptionReviewUICoordinator(chartColors: chartColors, carbTintColor: carbTintColor, glucoseTintColor: glucoseTintColor, guidanceColors: guidanceColors, insulinTintColor: insulinTintColor)
        setupViewController.completionDelegate = self
        setupViewController.onReviewFinished = { [weak service] (settings) in
            service?.saveSettings(settings: settings)
        }
        self.present(setupViewController, animated: true, completion: nil)
    }
    
    /* Added to support prescription flow */
    func completionNotifyingDidComplete(_ object: CompletionNotifying) {
        if let vc = object as? UIViewController, presentedViewController === vc {
            dismiss(animated: true, completion: nil)
        }
    }

    private func notifyComplete() {
        if let serviceViewController = navigationController as? ServiceViewController {
            serviceViewController.notifyComplete()
        }
    }

    // MARK: - Data Source

    private enum Section: Int, CaseIterable {
        case startFlow
        case deleteService
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .startFlow:
            return 1
        case .deleteService:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .startFlow:
            return " " // Use an empty string for more dramatic spacing
        case .deleteService:
            return " " // Use an empty string for more dramatic spacing
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .startFlow:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextButtonTableViewCell.className, for: indexPath) as! TextButtonTableViewCell
            cell.textLabel?.text = "Start Acceptance Flow (under development)"
            cell.textLabel?.textAlignment = .center
            return cell
        case .deleteService:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextButtonTableViewCell.className, for: indexPath) as! TextButtonTableViewCell
            cell.textLabel?.text = LocalizedString("Delete Service", comment: "Button title to delete a service")
            cell.textLabel?.textAlignment = .center
            cell.tintColor = .systemRed
            return cell
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .startFlow:
            startFlow()
            tableView.deselectRow(at: indexPath, animated: true)
        case .deleteService:
            confirmDeletion {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

}

extension TextButtonTableViewCell: IdentifiableClass {}

fileprivate extension UIAlertController {

    convenience init(serviceDeletionHandler handler: @escaping () -> Void) {
        self.init(
            title: nil,
            message: LocalizedString("Are you sure you want to delete this service?", comment: "Confirmation message for deleting a service"),
            preferredStyle: .actionSheet
        )

        addAction(UIAlertAction(
            title: LocalizedString("Delete Service", comment: "Button title to delete a service"),
            style: .destructive,
            handler: { _ in
                handler()
        }
        ))

        let cancel = LocalizedString("Cancel", comment: "The title of the cancel action in an action sheet")
        addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
    }

}
