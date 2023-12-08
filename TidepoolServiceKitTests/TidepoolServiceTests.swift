//
//  TidepoolServiceTests.swift
//  TidepoolServiceKitTests
//
//  Created by Darin Krauss on 11/15/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import XCTest
import HealthKit
import LoopKit
import TidepoolKit
@testable import TidepoolServiceKit

class TidepoolServiceTests: XCTestCase {
    var tidepoolService: TidepoolService!
    var userID: String!
    
    override func setUp() {
        super.setUp()
        
        tidepoolService = TidepoolService(hostIdentifier: "Loop", hostVersion: "1.2.3")
        userID = "1234567890"
    }

    func testCalculateDosingDecisionData() {
        let dosingDecisions = [StoredDosingDecision(reason: "Test",
                                                    controllerStatus: StoredDosingDecision.ControllerStatus(batteryLevel: 0.5),
                                                    pumpManagerStatus: PumpManagerStatus(timeZone: TimeZone(secondsFromGMT: TimeZone(identifier: "America/Phoenix")!.secondsFromGMT())!,
                                                                                         device: HKDevice(name: "Pump #1"),
                                                                                         pumpBatteryChargeRemaining: 0.75,
                                                                                         basalDeliveryState: nil,
                                                                                         bolusState: .noBolus,
                                                                                         insulinType: nil))]
        let created = tidepoolService.calculateDosingDecisionData(dosingDecisions, for: userID, hostIdentifier: "Loop", hostVersion: "1.2.3")
        XCTAssertEqual(created.count, 3)
        XCTAssertEqual((created[0] as! TDosingDecisionDatum).reason, "Test")
        XCTAssertEqual((created[0] as! TDosingDecisionDatum).associations!.count, 2)
        XCTAssertEqual((created[0] as! TDosingDecisionDatum).associations![0].id, created[1].id)
        XCTAssertEqual((created[0] as! TDosingDecisionDatum).associations![1].id, created[2].id)
        XCTAssertEqual((created[1] as! TControllerStatusDatum).battery!.remaining, 0.5)
        XCTAssertEqual((created[1] as! TControllerStatusDatum).associations!.count, 2)
        XCTAssertEqual((created[1] as! TControllerStatusDatum).associations![0].id, created[0].id)
        XCTAssertEqual((created[1] as! TControllerStatusDatum).associations![1].id, created[2].id)
        XCTAssertEqual((created[2] as! TPumpStatusDatum).battery!.remaining, 0.75)
        XCTAssertEqual((created[2] as! TPumpStatusDatum).associations!.count, 2)
        XCTAssertEqual((created[2] as! TPumpStatusDatum).associations![0].id, created[0].id)
        XCTAssertEqual((created[2] as! TPumpStatusDatum).associations![1].id, created[1].id)
    }
    
    func testCalculateSettingsDataIndividual() {
        let settings = [StoredSettings(controllerDevice: StoredSettings.ControllerDevice(name: "Controller #1"),
                                       cgmDevice: HKDevice(name: "CGM #1"),
                                       pumpDevice: HKDevice(name: "Pump #1"))]
        let (created, updated, lastControllerSettings, lastCGMSettings, lastPumpSettings) = tidepoolService.calculateSettingsData(settings, for: userID, hostIdentifier: "Loop", hostVersion: "1.2.3")
        XCTAssertEqual(created.count, 3)
        XCTAssertEqual((created[0] as! TControllerSettingsDatum).device!.name, "Controller #1")
        XCTAssertEqual((created[0] as! TControllerSettingsDatum).associations!.count, 2)
        XCTAssertEqual((created[0] as! TControllerSettingsDatum).associations![0].id, created[1].id)
        XCTAssertEqual((created[0] as! TControllerSettingsDatum).associations![1].id, created[2].id)
        XCTAssertEqual((created[1] as! TCGMSettingsDatum).name, "CGM #1")
        XCTAssertEqual((created[1] as! TCGMSettingsDatum).associations!.count, 2)
        XCTAssertEqual((created[1] as! TCGMSettingsDatum).associations![0].id, created[0].id)
        XCTAssertEqual((created[1] as! TCGMSettingsDatum).associations![1].id, created[2].id)
        XCTAssertEqual((created[2] as! TPumpSettingsDatum).name, "Pump #1")
        XCTAssertEqual((created[2] as! TPumpSettingsDatum).associations!.count, 2)
        XCTAssertEqual((created[2] as! TPumpSettingsDatum).associations![0].id, created[0].id)
        XCTAssertEqual((created[2] as! TPumpSettingsDatum).associations![1].id, created[1].id)
        XCTAssertTrue(updated.isEmpty)
        XCTAssertEqual(lastControllerSettings!.id, created[0].id)
        XCTAssertEqual(lastCGMSettings!.id, created[1].id)
        XCTAssertEqual(lastPumpSettings!.id, created[2].id)
    }
    
    func testCalculateSettingsDataUpdateControllerSettings() {
        let settings = [StoredSettings(controllerDevice: StoredSettings.ControllerDevice(name: "Controller #1"),
                                       cgmDevice: HKDevice(name: "CGM #1"),
                                       pumpDevice: HKDevice(name: "Pump #1")),
                        StoredSettings(controllerDevice: StoredSettings.ControllerDevice(name: "Controller #2"),
                                       cgmDevice: HKDevice(name: "CGM #1"),
                                       pumpDevice: HKDevice(name: "Pump #1"))]
        let (created, updated, lastControllerSettings, lastCGMSettings, lastPumpSettings) = tidepoolService.calculateSettingsData(settings, for: userID, hostIdentifier: "Loop", hostVersion: "1.2.3")
        XCTAssertEqual(created.count, 4)
        XCTAssertEqual((created[0] as! TControllerSettingsDatum).device!.name, "Controller #1")
        XCTAssertEqual((created[1] as! TCGMSettingsDatum).name, "CGM #1")
        XCTAssertEqual((created[2] as! TPumpSettingsDatum).name, "Pump #1")
        XCTAssertEqual((created[3] as! TControllerSettingsDatum).device!.name, "Controller #2")
        XCTAssertEqual((created[3] as! TControllerSettingsDatum).associations!.count, 2)
        XCTAssertEqual((created[3] as! TControllerSettingsDatum).associations![0].id, created[1].id)
        XCTAssertEqual((created[3] as! TControllerSettingsDatum).associations![1].id, created[2].id)
        XCTAssertTrue(updated.isEmpty)
        XCTAssertEqual(lastControllerSettings!.id, created[3].id)
        XCTAssertEqual(lastCGMSettings!.id, created[1].id)
        XCTAssertEqual(lastPumpSettings!.id, created[2].id)
    }
    
    func testCalculateSettingsDataUpdateCGMSettings() {
        let settings = [StoredSettings(controllerDevice: StoredSettings.ControllerDevice(name: "Controller #1"),
                                       cgmDevice: HKDevice(name: "CGM #1"),
                                       pumpDevice: HKDevice(name: "Pump #1")),
                        StoredSettings(controllerDevice: StoredSettings.ControllerDevice(name: "Controller #1"),
                                       cgmDevice: HKDevice(name: "CGM #2"),
                                       pumpDevice: HKDevice(name: "Pump #1"))]
        let (created, updated, lastControllerSettings, lastCGMSettings, lastPumpSettings) = tidepoolService.calculateSettingsData(settings, for: userID, hostIdentifier: "Loop", hostVersion: "1.2.3")
        XCTAssertEqual(created.count, 4)
        XCTAssertEqual((created[0] as! TControllerSettingsDatum).device!.name, "Controller #1")
        XCTAssertEqual((created[1] as! TCGMSettingsDatum).name, "CGM #1")
        XCTAssertEqual((created[2] as! TPumpSettingsDatum).name, "Pump #1")
        XCTAssertEqual((created[3] as! TCGMSettingsDatum).name, "CGM #2")
        XCTAssertEqual((created[3] as! TCGMSettingsDatum).associations!.count, 2)
        XCTAssertEqual((created[3] as! TCGMSettingsDatum).associations![0].id, created[0].id)
        XCTAssertEqual((created[3] as! TCGMSettingsDatum).associations![1].id, created[2].id)
        XCTAssertTrue(updated.isEmpty)
        XCTAssertEqual(lastControllerSettings!.id, created[0].id)
        XCTAssertEqual(lastCGMSettings!.id, created[3].id)
        XCTAssertEqual(lastPumpSettings!.id, created[2].id)
    }
    
    func testCalculateSettingsDataUpdatePumpSettings() {
        let settings = [StoredSettings(controllerDevice: StoredSettings.ControllerDevice(name: "Controller #1"),
                                       cgmDevice: HKDevice(name: "CGM #1"),
                                       pumpDevice: HKDevice(name: "Pump #1")),
                        StoredSettings(controllerDevice: StoredSettings.ControllerDevice(name: "Controller #1"),
                                       cgmDevice: HKDevice(name: "CGM #1"),
                                       pumpDevice: HKDevice(name: "Pump #2"))]
        let (created, updated, lastControllerSettings, lastCGMSettings, lastPumpSettings) = tidepoolService.calculateSettingsData(settings, for: userID, hostIdentifier: "Loop", hostVersion: "1.2.3")
        XCTAssertEqual(created.count, 4)
        XCTAssertEqual((created[0] as! TControllerSettingsDatum).device!.name, "Controller #1")
        XCTAssertEqual((created[1] as! TCGMSettingsDatum).name, "CGM #1")
        XCTAssertEqual((created[2] as! TPumpSettingsDatum).name, "Pump #1")
        XCTAssertEqual((created[3] as! TPumpSettingsDatum).name, "Pump #2")
        XCTAssertEqual((created[3] as! TPumpSettingsDatum).associations!.count, 2)
        XCTAssertEqual((created[3] as! TPumpSettingsDatum).associations![0].id, created[0].id)
        XCTAssertEqual((created[3] as! TPumpSettingsDatum).associations![1].id, created[1].id)
        XCTAssertTrue(updated.isEmpty)
        XCTAssertEqual(lastControllerSettings!.id, created[0].id)
        XCTAssertEqual(lastCGMSettings!.id, created[1].id)
        XCTAssertEqual(lastPumpSettings!.id, created[3].id)
    }
    
    func testCalculateSettingsDataUpdateMultipleOne() {
        let settings = [StoredSettings(controllerDevice: StoredSettings.ControllerDevice(name: "Controller #1"),
                                       cgmDevice: HKDevice(name: "CGM #1"),
                                       pumpDevice: HKDevice(name: "Pump #1")),
                        StoredSettings(controllerDevice: StoredSettings.ControllerDevice(name: "Controller #2"),
                                       cgmDevice: HKDevice(name: "CGM #2"),
                                       pumpDevice: HKDevice(name: "Pump #2"))]
        let (created, updated, lastControllerSettings, lastCGMSettings, lastPumpSettings) = tidepoolService.calculateSettingsData(settings, for: userID, hostIdentifier: "Loop", hostVersion: "1.2.3")
        XCTAssertEqual(created.count, 6)
        XCTAssertEqual((created[0] as! TControllerSettingsDatum).device!.name, "Controller #1")
        XCTAssertEqual((created[1] as! TCGMSettingsDatum).name, "CGM #1")
        XCTAssertEqual((created[2] as! TPumpSettingsDatum).name, "Pump #1")
        XCTAssertEqual((created[3] as! TControllerSettingsDatum).device!.name, "Controller #2")
        XCTAssertEqual((created[3] as! TControllerSettingsDatum).associations!.count, 2)
        XCTAssertEqual((created[3] as! TControllerSettingsDatum).associations![0].id, created[4].id)
        XCTAssertEqual((created[3] as! TControllerSettingsDatum).associations![1].id, created[5].id)
        XCTAssertEqual((created[4] as! TCGMSettingsDatum).name, "CGM #2")
        XCTAssertEqual((created[4] as! TCGMSettingsDatum).associations!.count, 2)
        XCTAssertEqual((created[4] as! TCGMSettingsDatum).associations![0].id, created[3].id)
        XCTAssertEqual((created[4] as! TCGMSettingsDatum).associations![1].id, created[5].id)
        XCTAssertEqual((created[5] as! TPumpSettingsDatum).name, "Pump #2")
        XCTAssertEqual((created[5] as! TPumpSettingsDatum).associations!.count, 2)
        XCTAssertEqual((created[5] as! TPumpSettingsDatum).associations![0].id, created[3].id)
        XCTAssertEqual((created[5] as! TPumpSettingsDatum).associations![1].id, created[4].id)
        XCTAssertTrue(updated.isEmpty)
        XCTAssertEqual(lastControllerSettings!.id, created[3].id)
        XCTAssertEqual(lastCGMSettings!.id, created[4].id)
        XCTAssertEqual(lastPumpSettings!.id, created[5].id)
    }
    
    func testCalculateSettingsDataUpdateMultipleMultiple() {
        let settings = [StoredSettings(controllerDevice: StoredSettings.ControllerDevice(name: "Controller #1"),
                                       cgmDevice: HKDevice(name: "CGM #1"),
                                       pumpDevice: HKDevice(name: "Pump #1")),
                        StoredSettings(controllerDevice: StoredSettings.ControllerDevice(name: "Controller #2"),
                                       cgmDevice: HKDevice(name: "CGM #1"),
                                       pumpDevice: HKDevice(name: "Pump #1")),
                        StoredSettings(controllerDevice: StoredSettings.ControllerDevice(name: "Controller #2"),
                                       cgmDevice: HKDevice(name: "CGM #2"),
                                       pumpDevice: HKDevice(name: "Pump #1")),
                        StoredSettings(controllerDevice: StoredSettings.ControllerDevice(name: "Controller #2"),
                                       cgmDevice: HKDevice(name: "CGM #2"),
                                       pumpDevice: HKDevice(name: "Pump #2"))]
        let (created, updated, lastControllerSettings, lastCGMSettings, lastPumpSettings) = tidepoolService.calculateSettingsData(settings, for: userID, hostIdentifier: "Loop", hostVersion: "1.2.3")
        XCTAssertEqual(created.count, 6)
        XCTAssertEqual((created[0] as! TControllerSettingsDatum).device!.name, "Controller #1")
        XCTAssertEqual((created[1] as! TCGMSettingsDatum).name, "CGM #1")
        XCTAssertEqual((created[2] as! TPumpSettingsDatum).name, "Pump #1")
        XCTAssertEqual((created[3] as! TControllerSettingsDatum).device!.name, "Controller #2")
        XCTAssertEqual((created[3] as! TControllerSettingsDatum).associations!.count, 2)
        XCTAssertEqual((created[3] as! TControllerSettingsDatum).associations![0].id, created[1].id)
        XCTAssertEqual((created[3] as! TControllerSettingsDatum).associations![1].id, created[2].id)
        XCTAssertEqual((created[4] as! TCGMSettingsDatum).name, "CGM #2")
        XCTAssertEqual((created[4] as! TCGMSettingsDatum).associations!.count, 2)
        XCTAssertEqual((created[4] as! TCGMSettingsDatum).associations![0].id, created[3].id)
        XCTAssertEqual((created[4] as! TCGMSettingsDatum).associations![1].id, created[2].id)
        XCTAssertEqual((created[5] as! TPumpSettingsDatum).name, "Pump #2")
        XCTAssertEqual((created[5] as! TPumpSettingsDatum).associations!.count, 2)
        XCTAssertEqual((created[5] as! TPumpSettingsDatum).associations![0].id, created[3].id)
        XCTAssertEqual((created[5] as! TPumpSettingsDatum).associations![1].id, created[4].id)
        XCTAssertTrue(updated.isEmpty)
        XCTAssertEqual(lastControllerSettings!.id, created[3].id)
        XCTAssertEqual(lastCGMSettings!.id, created[4].id)
        XCTAssertEqual(lastPumpSettings!.id, created[5].id)
    }
    
}

fileprivate extension StoredSettings.ControllerDevice {
    init(name: String) {
        self.init(name: name, systemName: "", systemVersion: "", model: "", modelIdentifier: "")
    }
}

fileprivate extension HKDevice {
    convenience init(name: String) {
        self.init(name: name, manufacturer: nil, model: nil, hardwareVersion: nil, firmwareVersion: nil, softwareVersion: nil, localIdentifier: nil, udiDeviceIdentifier: nil)
    }
}

