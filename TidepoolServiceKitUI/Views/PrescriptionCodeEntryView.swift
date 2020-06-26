//
//  PrescriptionCodeEntryView.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 6/18/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import SwiftUI
import LoopKitUI

struct PrescriptionCodeEntryView: View, HorizontalSizeClassOverride {
    
    @State private var prescriptionCode: String = ""
    @ObservedObject var viewModel: PrescriptionCodeEntryViewModel

    let blueGray = Color("blue gray", bundle: Bundle(for: PrescriptionReviewUICoordinator.self))
    
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 25) {
                itemsNeededList
                codeEntryRequest
            }
            .padding(.vertical)
            submitCodeButton
            requestPrescriptionButton
            Spacer()
        }
        .adaptiveKeyboardPadding() // To ensure the keyboard doesn't obstruct the TextField
        .buttonStyle(BorderlessButtonStyle()) // Fix for button click highlighting the whole cell
        .environment(\.horizontalSizeClass, horizontalOverride)
        .navigationBarItems(trailing: cancelButton)
        .navigationBarTitle(Text(LocalizedString("Your Settings", comment: "Navigation view title")))
        .onAppear() {
            UITableView.appearance().separatorStyle = .none // Remove lines between sections
        }
    }

    private var cancelButton: some View {
        Button(action: {
            self.viewModel.didCancel?()
        }) {
            Text(LocalizedString("Cancel", comment: "Button text to exit the prescription code entry screen"))
            .foregroundColor(.accentColor)
        }
    }
    
    private var itemsNeededDescription: some View {
        VStack (alignment: .leading, spacing: 10) {
            Text(LocalizedString("What you'll need", comment: "Title for section describing items needed to review settings"))
            .font(.headline)
            Text(LocalizedString("For the next section, you'll want to have the following:", comment: "Subheader for items-needed section"))
            .foregroundColor(blueGray)
            .fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
        }
        
    }
    
    private var itemsNeededList: some View {
        Section {
            VStack (alignment: .leading, spacing: 10) {
                itemsNeededDescription
                InstructionList(instructions: [
                    LocalizedString("Prescription activation code", comment: "Label text for the first needed prescription activation item"),
                    LocalizedString("Configuration settings for glucose targets and insulin delivery from your healthcare provider", comment: "Label text for the second needed prescription activation item")
                    ],
                    stepsColor: blueGray
                )
                .foregroundColor(blueGray)
            }
        }
    }

    private var codeEntryRequest: some View {
        Section {
            VStack (alignment: .leading, spacing: 10) {
                Text(LocalizedString("Enter your prescription code", comment: "Title for section to enter your prescription code"))
                .font(.headline)
                Text(LocalizedString("If you have a prescription activation code, please enter it now.", comment: "Text requesting entry of activation code"))
                .foregroundColor(blueGray)
                prescriptionCodeInputField
            }
        }
        
    }
    
    private var prescriptionCodeInputField: some View {
        TextField(LocalizedString("Activation code", comment: "Placeholder text before entering prescription code in text field"), text: $prescriptionCode)
        .keyboardType(.default)
        .disableAutocorrection(true)
        .font(.body)
        .multilineTextAlignment(.leading)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray, lineWidth: 1)

        )
    }

    private var submitCodeButton: some View {
        Button(action: {
            self.viewModel.loadPrescriptionFromCode(prescriptionCode: self.prescriptionCode)
        }) {
            Text(LocalizedString("Submit activation code", comment: "Button title for submitting the prescription activation code to Tidepool"))
                .actionButtonStyle(submitButtonStyle(enabled: prescriptionCode.count == self.viewModel.prescriptionCodeLength))
                .disabled(prescriptionCode.count != viewModel.prescriptionCodeLength)
        }
    }
    
    private func submitButtonStyle(enabled: Bool) -> ActionButton.ButtonType {
        if enabled {
            return .primary
        }
        return .deactivated
    }
        
    private var requestPrescriptionButton: some View {
        Button(action: {
            // TODO: open contact prescriber window
            print("TODO")
        }) {
            Text(LocalizedString("Request activation code", comment:"Button title for requesting a prescription activation code from the prescriber"))
                .actionButtonStyle(.secondary)
        }
    }
}

struct PrescriptionCodeEntryView_Previews: PreviewProvider {
    static var previews: some View {
        PrescriptionCodeEntryView(viewModel: PrescriptionCodeEntryViewModel())
    }
}

