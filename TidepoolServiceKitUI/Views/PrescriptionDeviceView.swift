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

struct PrescriptionDeviceView: View, HorizontalSizeClassOverride {
    @State private var prescriptionCode: String = ""
    @ObservedObject var viewModel: PrescriptionCodeEntryViewModel

    let blueGray = Color(#colorLiteral(red: 0.4156862745, green: 0.4705882353, blue: 0.5529411765, alpha: 1))
    let lightGray = Color(#colorLiteral(red: 0.7019607843, green: 0.6980392157, blue: 0.6980392157, alpha: 1))
    let purple = Color(#colorLiteral(red: 0.3647058824, green: 0.4745098039, blue: 1, alpha: 1))
    
    var body: some View {
        // Option 1
        List {
            VStack(alignment: .leading, spacing: 25) {
                self.prescribedDeviceInfo
                self.devicesList
                self.disclaimer
            }
            .padding()
            VStack(alignment: .leading, spacing: 15) {
                self.approveDevicesButton
                self.editDevicesButton
            }
            .padding()
        }
        .environment(\.horizontalSizeClass, horizontalOverride)
        .navigationBarTitle(Text(LocalizedString("Review your settings", comment: "Navigation view title")))
        
        // Option 2
        /*GuidePage(content: {
                self.prescribedDeviceInfo
                .padding(.vertical)
                self.devicesList
                .padding(.vertical)
                self.disclaimer
                .padding(.vertical)
            }) {
                VStack(alignment: .leading, spacing: 15) {
                    self.approveDevicesButton
                    self.editDevicesButton
                }
                .padding()
            }
            .environment(\.horizontalSizeClass, horizontalOverride)
            .navigationBarTitle(Text(LocalizedString("Review your settings", comment: "Navigation view title")))*/
    }
    
    private var prescribedDeviceInfo: some View {
        Section {
            Text(LocalizedString("Since your provider included your recommended settings with your prescription, you'll have the chance to review and accept each of these settings now.", comment: "Text describing purpose of settings walk-through"))
            .foregroundColor(blueGray)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var devicesList: some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                Text(LocalizedString("Your prescription contains recommended settings for the following devices:", comment: "Title for devices prescribed section"))
                .foregroundColor(blueGray)
                .fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
                // TODO: support multiple devices
                pumpStack
                cgmStack
            }
        }
    }
    
    private var pumpStack: some View {
        HStack {
            dashIcon
            .padding(.horizontal)
            VStack (alignment: .leading) {
                Text(LocalizedString("Omnipod 5", comment: "Text describing insulin pump name"))
                Text(LocalizedString("Insulin Pump", comment: "Insulin pump label"))
                .font(.footnote)
                .foregroundColor(blueGray)
            }
            Spacer()
            
        }
    }
    
    private var dashIcon: some View {
        Image("dash", bundle: Bundle(for: PrescriptionReviewUICoordinator.self))
        .resizable()
        .aspectRatio(contentMode: ContentMode.fit)
        .frame(height: 50)
        .padding(5) // ANNA TODO: figure out better way to align
    }
    
    private var cgmStack: some View {
        HStack {
            dexcomIcon
            .padding(.horizontal)
            VStack (alignment: .leading) {
                Text(LocalizedString("Dexcom G6", comment: "Text describing CGM name"))
                Text(LocalizedString("Continuous Glucose Monitor", comment: "CGM label"))
                .font(.footnote)
                .foregroundColor(blueGray)
            }
            Spacer()
        }
    }
    
    private var dexcomIcon: some View {
        Image("dexcom", bundle: Bundle(for: PrescriptionReviewUICoordinator.self))
        .resizable()
        .aspectRatio(contentMode: ContentMode.fit)
        .frame(height: 25)
    }
    
    private var disclaimer: some View {
        Section {
            VStack (alignment: .leading) {
                Text(LocalizedString("Note", comment: "Title for disclaimer section"))
                .font(.headline)
                VStack (alignment: .leading, spacing: 10) {
                    Text(LocalizedString("Tidepool Loop does NOT automatically adjust or recommend changes to your settings", comment: "Text describing that Tidepool Loop doesn't automatically change settings"))
                    .italic()
                    .padding(.vertical)
                    Text(LocalizedString("Work with your healthcare provider to find the right settings for you", comment: "Text describing determining settings with your doctor"))
                    .italic()
                }
                .fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
                .foregroundColor(blueGray)
            }
        }
        
    }

    private var approveDevicesButton: some View {
        Button(action: {
            self.viewModel.didFinishStep()
        }) {
            Text(LocalizedString("Next: Review Settings", comment: "Button title for approving devices"))
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
