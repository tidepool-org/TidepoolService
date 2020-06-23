//
//  PrescriptionDeviceView.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 6/22/20.
//  Copyright © 2020 LoopKit Authors. All rights reserved.
//

import Foundation
import SwiftUI
import LoopKitUI

struct PrescriptionDeviceView: View {
    @State private var prescriptionCode: String = ""
    @ObservedObject var viewModel: PrescriptionCodeEntryViewModel

    let blueGray = Color(#colorLiteral(red: 0.4156862745, green: 0.4705882353, blue: 0.5529411765, alpha: 1))
    let lightGray = Color(#colorLiteral(red: 0.7019607843, green: 0.6980392157, blue: 0.6980392157, alpha: 1))
    let purple = Color(#colorLiteral(red: 0.3647058824, green: 0.4745098039, blue: 1, alpha: 1))
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing: 20) {
                    self.prescribedDeviceInfo
                }
                .padding()
                VStack(alignment: .leading, spacing: 10) {
                    self.itemsNeededList
                    //self.prescribedDevices
                }
                .padding()
                VStack(alignment: .leading, spacing: 15) {
                    self.approveDevicesButton
                    self.editDevicesButton
                }
                .padding()
            }
            .listStyle(GroupedListStyle())
            .navigationBarBackButtonHidden(false)
            .navigationBarTitle(Text(LocalizedString("Review your settings", comment: "Navigation view title")))
            .navigationBarItems(trailing: cancelButton)
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            self.viewModel.didCancel?()
        }) {
            Text(LocalizedString("Cancel", comment: "Button text to exit the device review screen"))
            .foregroundColor(purple)
        }
    }
    
    private var prescribedDeviceInfo: some View {
        VStack (alignment: .leading, spacing: 10) {
            Text(LocalizedString("Since your provider included your recommended settings with your prescription, you'll have the chance to review and accept each of these settings now.", comment: "Text describing purpose of settings walk-through"))
            //.fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
            Text(LocalizedString("Your prescription contains recommended settings for the following devices:", comment: "Title for devices prescribed section"))
            
            .fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
        }
        .foregroundColor(blueGray)
    }
    
    private var itemsNeededList: some View {
        InstructionList(instructions: [
            LocalizedString("Prescription activation code", comment: "Label text for the first needed prescription activation item"),
            LocalizedString("Configuration settings for glucose targets and insulin delivery from your healthcare provider", comment: "Label text for the second needed prescription activation item")
            ],
            stepsColor: blueGray
        )
        .foregroundColor(blueGray)
    }

    private var codeEntryRequest: some View {
        VStack (alignment: .leading, spacing: 15) {
            Text(LocalizedString("Enter your prescription code", comment: "Title for section to enter your prescription code"))
            .font(.headline)
            Text(LocalizedString("If you have a prescription activation code, please enter it now.", comment: "Text requesting entry of activation code"))
            .foregroundColor(blueGray)
        }
        
    }

    private var approveDevicesButton: some View {
        Button(action: {
            self.viewModel.loadPrescriptionFromCode(prescriptionCode: self.prescriptionCode)
        }) {
            Text(LocalizedString("Next: review your settings", comment: "Button title for approving devices"))
                .actionButtonStyle(.tidepoolPrimary)
        }
    }
        
    private var editDevicesButton: some View {
        Button(action: {
            // TODO: contact prescriber window
            print("TODO")
        }) {
            Text(LocalizedString("Edit devices", comment:"Button title for editing the prescribed devices"))
                .actionButtonStyle(.tidepoolSecondary)
        }
    }
}
