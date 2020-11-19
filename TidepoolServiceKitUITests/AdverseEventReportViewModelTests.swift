//
//  AdverseEventReportViewModelTests.swift
//  TidepoolServiceKitUITests
//
//  Created by Nathaniel Hamming on 2020-10-02.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import XCTest
import HealthKit
import LoopKit
import LoopKitUI
@testable import TidepoolServiceKitUI

class AdverseEventReportViewModelTests: XCTestCase {
    
    class MockSupportInfoProvider: SupportInfoProvider {
        var localizedAppNameAndVersion = "Tidepool Loop v1.2"
        
        var pumpStatus: PumpManagerStatus?
        var cgmDevice: HKDevice?
        
        func generateIssueReport(completion: (String) -> Void) {
            completion("Mock Issue Report")
        }
    }


    private let baseURL = "https://support.tidepool.org/hc/en-us/requests/new"
    private let ticketIDQueryParameter = "?ticket_form_id=360000551951"
    
    func testReportURLNoDeviceDetails() {
        
        let viewModel = AdverseEventReportViewModel(supportInfoProvider: MockSupportInfoProvider())
        let url = viewModel.reportURL
        
        XCTAssertTrue(url!.absoluteString.contains(baseURL))
        XCTAssertTrue(url!.absoluteString.contains(ticketIDQueryParameter))
        XCTAssertTrue(url!.absoluteString.contains("&\(viewModel.subjectID)=\(viewModel.subjectValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"))
        XCTAssertTrue(url!.absoluteString.contains("&\(viewModel.tidepoolLoopVersionID)=\(viewModel.supportInfoProvider.localizedAppNameAndVersion.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"))
        XCTAssertTrue(url!.absoluteString.contains("&\(viewModel.iOSVersionID)=\(viewModel.iOSVersionValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"))
        XCTAssertTrue(url!.absoluteString.contains("&\(viewModel.deviceModelIdentifierID)=\(viewModel.deviceModelIdentifierValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"))
        XCTAssertTrue(url!.absoluteString.contains("&\(viewModel.timezoneID)=\(viewModel.timezoneValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"))
        XCTAssertTrue(url!.absoluteString.contains("&\(viewModel.pumpDetailsID)=\(viewModel.pumpDetailsValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"))
        XCTAssertTrue(url!.absoluteString.contains("&\(viewModel.cgmDetailsID)=\(viewModel.cgmDetailsValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"))
    }

    func testReportURLWithDeviceDetails() {
        let cgmName = "test-CGM"
        let cgmManufacturer = "test-CGM-manufacturer"
        let cgmModel = "test-CGM-model"
        let cgmHardwareVersion = "test-CGM-hardware-version"
        let cgmFirmwareVersion = "test-CGM-firmware-version"
        let cgmSoftwareVersion = "test-CGM-software-version"
        let cgmLocalIdentifier = "test-CGM-local-identifier"
        let cgmUDIDevicIdentifier = "test-CGM-udi-device-identifier"
        let cgmDevice = HKDevice(name: cgmName,
                                 manufacturer: cgmManufacturer,
                                 model: cgmModel,
                                 hardwareVersion: cgmHardwareVersion,
                                 firmwareVersion: cgmFirmwareVersion,
                                 softwareVersion: cgmSoftwareVersion,
                                 localIdentifier: cgmLocalIdentifier,
                                 udiDeviceIdentifier: cgmUDIDevicIdentifier)
        
        let pumpName = "test-pump"
        let pumpManufacturer = "test-pump-manufacturer"
        let pumpModel = "test-pump-model"
        let pumpHardwareVersion = "test-pump-hardware-version"
        let pumpFirmwareVersion = "test-pump-firmware-version"
        let pumpSoftwareVersion = "test-pump-software-version"
        let pumpLocalIdentifier = "test-pump-local-identifier"
        let pumpUDIDevicIdentifier = "test-pump-udi-device-identifier"
        let pumpDevice = HKDevice(name: pumpName,
                                 manufacturer: pumpManufacturer,
                                 model: pumpModel,
                                 hardwareVersion: pumpHardwareVersion,
                                 firmwareVersion: pumpFirmwareVersion,
                                 softwareVersion: pumpSoftwareVersion,
                                 localIdentifier: pumpLocalIdentifier,
                                 udiDeviceIdentifier: pumpUDIDevicIdentifier)
    
        let pumpStatus = PumpManagerStatus(timeZone: TimeZone.current,
                                           device: pumpDevice,
                                           pumpBatteryChargeRemaining: 50,
                                           basalDeliveryState: .resuming,
                                           bolusState: .canceling)
        
        let supportInfoProvider = MockSupportInfoProvider()
        supportInfoProvider.pumpStatus = pumpStatus
        supportInfoProvider.cgmDevice = cgmDevice
        
        let viewModel = AdverseEventReportViewModel(supportInfoProvider: supportInfoProvider)
        let url = viewModel.reportURL
        
        XCTAssertTrue(url!.absoluteString.contains(cgmName))
        XCTAssertTrue(url!.absoluteString.contains(cgmManufacturer))
        XCTAssertTrue(url!.absoluteString.contains(cgmModel))
        XCTAssertTrue(url!.absoluteString.contains(cgmHardwareVersion))
        XCTAssertTrue(url!.absoluteString.contains(cgmFirmwareVersion))
        XCTAssertTrue(url!.absoluteString.contains(cgmSoftwareVersion))
        XCTAssertTrue(url!.absoluteString.contains(cgmLocalIdentifier))
        XCTAssertTrue(url!.absoluteString.contains(cgmUDIDevicIdentifier))
        XCTAssertTrue(url!.absoluteString.contains(pumpName))
        XCTAssertTrue(url!.absoluteString.contains(pumpManufacturer))
        XCTAssertTrue(url!.absoluteString.contains(pumpModel))
        XCTAssertTrue(url!.absoluteString.contains(pumpHardwareVersion))
        XCTAssertTrue(url!.absoluteString.contains(pumpFirmwareVersion))
        XCTAssertTrue(url!.absoluteString.contains(pumpSoftwareVersion))
        XCTAssertTrue(url!.absoluteString.contains(pumpLocalIdentifier))
        XCTAssertTrue(url!.absoluteString.contains(pumpUDIDevicIdentifier))
        XCTAssertTrue(url!.absoluteString.contains("50"))
        XCTAssertTrue(url!.absoluteString.contains("resuming"))
        XCTAssertTrue(url!.absoluteString.contains("canceling"))
    }
}
