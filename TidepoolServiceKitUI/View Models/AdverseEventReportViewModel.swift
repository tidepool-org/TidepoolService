//
//  AdverseEventReportViewModel.swift
//  TidepoolServiceKitUI
//
//  Created by Nathaniel Hamming on 2020-10-02.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import UIKit
import HealthKit
import LoopKit
import LoopKitUI

public class AdverseEventReportViewModel {
    let supportInfoProvider: SupportInfoProvider

    let formURLString = "https://support.tidepool.org/hc/en-us/requests/new?ticket_form_id=360000551951"

    let subjectID = "request_subject"

    let subjectValue = "Tidepool Loop Adverse Event Report"

    let tidepoolLoopVersionID = "request_custom_fields_360035401592"

    let iOSVersionID = "request_custom_fields_360035987312"

    var iOSVersionValue: String {
        return  UIDevice.current.systemVersion
    }

    let deviceModelIdentifierID = "request_custom_fields_360035932211"

    var deviceModelIdentifierValue: String {
        return UIDevice.modelIdentifier
    }

    let timezoneID = "request_custom_fields_360035933391"

    var timezoneValue: String {
        return TimeZone.current.identifier
    }

    let pumpDetailsID = "request_custom_fields_360035987332"

    var pumpDetailsValue: String {
        guard let pumpStatus = supportInfoProvider.pumpStatus else { return "" }

        return String(describing: pumpStatus) + ", Pump Device Details: " + pumpStatus.device.details
    }

    let cgmDetailsID = "request_custom_fields_360035932231"

    var cgmDetailsValue: String {
        guard let cgmDevice = supportInfoProvider.cgmDevice else { return "" }

        return "CGM Device Details: " + cgmDevice.details
    }

    var reportURL: URL? {
        var urlString = formURLString
        urlString += "&\(subjectID)=\(subjectValue)"
        urlString += "&\(tidepoolLoopVersionID)=\(supportInfoProvider.localizedAppNameAndVersion)"
        urlString += "&\(iOSVersionID)=\(iOSVersionValue)"
        urlString += "&\(deviceModelIdentifierID)=\(deviceModelIdentifierValue)"
        urlString += "&\(timezoneID)=\(timezoneValue)"
        urlString += "&\(pumpDetailsID)=\(pumpDetailsValue)"
        urlString += "&\(cgmDetailsID)=\(cgmDetailsValue)"

        guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURLString) else
        {
            return nil
        }

        return url
    }

    init(supportInfoProvider: SupportInfoProvider)
    {
        self.supportInfoProvider = supportInfoProvider
    }
}

// based on https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model

public extension UIDevice {
    static let modelIdentifier: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()
}

extension HKDevice {
    var details: String {
        var details = "udiDeviceIdentifier: " + (self.udiDeviceIdentifier ?? "?") + ", "
        details += "firmwareVersion: " + (self.firmwareVersion ?? "?") + ", "
        details += "hardwareVersion: " + (self.hardwareVersion ?? "?") + ", "
        details += "localIdentifier: " + (self.localIdentifier ?? "?") + ", "
        details += "manufacturer: " + (self.manufacturer ?? "?") + ", "
        details += "model: " + (self.model ?? "?") + ", "
        details += "name: " + (self.name ?? "?") + ", "
        details += "softwareVersion: " + (self.softwareVersion ?? "?")

        return details
    }
}
