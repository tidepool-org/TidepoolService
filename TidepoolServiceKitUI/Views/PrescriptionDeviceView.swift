//
//  PrescriptionDeviceView.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 6/22/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import SwiftUI
import LoopKitUI
import TidepoolServiceKit

struct PrescriptionDeviceView: View, HorizontalSizeClassOverride {
    @ObservedObject var viewModel: PrescriptionReviewViewModel
    var prescription: MockPrescription
    static let imageWidth: CGFloat = 48
    
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 25) {
                prescribedDeviceInfo
                devicesList
                disclaimer
            }
            .padding(.vertical)
            approveDevicesButton
            editDevicesButton
            Spacer()
        }
        .buttonStyle(BorderlessButtonStyle()) // Fix for button click highlighting the whole cell
        .environment(\.horizontalSizeClass, horizontalOverride)
        .navigationBarTitle(Text(LocalizedString("Review your settings", comment: "Navigation view title")))
        .onAppear() {
            UITableView.appearance().separatorStyle = .none // Remove lines between sections
        }
    }
    
    private var prescribedDeviceInfo: some View {
        Section {
            Text(LocalizedString("Since your provider included your recommended settings with your prescription, you'll have the chance to review and accept each of these settings now.", comment: "Text describing purpose of settings walk-through"))
            .foregroundColor(.blueGray)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var devicesList: some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                Text(LocalizedString("Your prescription contains recommended settings for the following devices:", comment: "Title for devices prescribed section"))
                .foregroundColor(.blueGray)
                .fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
                // TODO: get images and descriptions from pump manager
                pumpStack
                cgmStack
            }
        }
    }
    
    private var pumpStack: some View {
        switch prescription.pump {
        case .dash:
            return dashStack
        }
    }
    
    private var dashStack: some View {
        HStack {
            dashIcon
            .padding(.horizontal)
            VStack(alignment: .leading) {
                Text(LocalizedString("Omnipod 5", comment: "Text describing insulin pump name"))
                Text(LocalizedString("Insulin Pump", comment: "Insulin pump label"))
                .font(.footnote)
                .foregroundColor(.blueGray)
            }
            Spacer()
        }
    }
    
    private var dashIcon: some View {
        Image("dash", bundle: Bundle(for: PrescriptionReviewUICoordinator.self))
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: ContentMode.fit)
        .frame(width: Self.imageWidth, height: 50)
        .foregroundColor(.accentColor)
    }
    
    private var cgmStack: some View {
        switch prescription.cgm {
        case .g6:
            return dexcomStack
        }
    }
    
    private var dexcomStack: some View {
        HStack {
            dexcomIcon
            .padding(.horizontal)
            VStack(alignment: .leading) {
                Text(LocalizedString("Dexcom G6", comment: "Text describing CGM name"))
                Text(LocalizedString("Continuous Glucose Monitor", comment: "CGM label"))
                .font(.footnote)
                .foregroundColor(.blueGray)
            }
            Spacer()
        }
    }
    
    private var dexcomIcon: some View {
        Image("dexcom", bundle: Bundle(for: PrescriptionReviewUICoordinator.self))
        .resizable()
        .aspectRatio(contentMode: ContentMode.fit)
        .frame(width: Self.imageWidth)
    }
    
    private var disclaimer: some View {
        Section {
            VStack(alignment: .leading) {
                Text(LocalizedString("Note", comment: "Title for disclaimer section"))
                .font(.headline)
                VStack(alignment: .leading, spacing: 10) {
                    Text(LocalizedString("Tidepool Loop does NOT automatically adjust or recommend changes to your settings", comment: "Text describing that Tidepool Loop doesn't automatically change settings"))
                    .italic()
                    .fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
                    .padding(.vertical)
                    Text(LocalizedString("Work with your healthcare provider to find the right settings for you", comment: "Text describing determining settings with your doctor"))
                    .italic()
                }
                .fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
                .foregroundColor(.blueGray)
            }
        }
    }

    private var approveDevicesButton: some View {
        Button(action: {
            self.viewModel.didFinishStep()
        }) {
            Text(LocalizedString("Next: Review Settings", comment: "Button title for approving devices"))
                .actionButtonStyle(.primary)
        }
    }
        
    private var editDevicesButton: some View {
        Button(action: {
            // TODO: open window to edit the devices
            print("TODO")
        }) {
            Text(LocalizedString("Edit devices", comment: "Button title for editing the prescribed devices"))
                .actionButtonStyle(.secondary)
        }
    }
}
