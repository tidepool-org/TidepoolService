//
//  PrescriptionCodeEntryView.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 6/18/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import SwiftUI
import LoopKitUI

struct CodeEntry: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .keyboardType(.numberPad)
        .font(.body)
        .multilineTextAlignment(.leading)
        .padding()
    }
}

struct PrescriptionCodeEntryView: View, HorizontalSizeClassOverride {
    
    @State private var prescriptionCode: String = ""
    @ObservedObject var viewModel: PrescriptionCodeEntryViewModel

    let blueGray = Color(#colorLiteral(red: 0.4156862745, green: 0.4705882353, blue: 0.5529411765, alpha: 1))
    let lightGray = Color(#colorLiteral(red: 0.7019607843, green: 0.6980392157, blue: 0.6980392157, alpha: 1))
    let purple = Color(#colorLiteral(red: 0.3647058824, green: 0.4745098039, blue: 1, alpha: 1))
    
    var body: some View {
        /// option 1
        VStack {
            VStack(alignment: .leading, spacing: 25) {
                self.itemsNeededList
                self.codeEntryRequest
            }
            .padding()
            VStack(alignment: .leading, spacing: 15) {
                self.submitCodeButton
                self.requestPrescriptionButton
            }
            .padding()
            Spacer()
        }
        .environment(\.horizontalSizeClass, horizontalOverride)
        .navigationBarItems(trailing: cancelButton)
        .navigationBarTitle(Text(LocalizedString("Your Settings", comment: "Navigation view title")))
        
        /// option 2
        
        /*GuidePage(content: {
            self.itemsNeededList
            .padding(.vertical)
            self.codeEntryRequest
            .padding(.vertical)
            
        }) {
            VStack(alignment: .leading, spacing: 15) {
                self.submitCodeButton
                self.requestPrescriptionButton
            }
            .padding()
        }
        .environment(\.horizontalSizeClass, horizontalOverride)
        .navigationBarItems(trailing: cancelButton)
        .navigationBarTitle(Text(LocalizedString("Your Settings", comment: "Navigation view title")), displayMode: .large)
        */
         
    }

    private var cancelButton: some View {
        Button(action: {
            self.viewModel.didCancel?()
        }) {
            Text(LocalizedString("Cancel", comment: "Button text to exit the prescription code entry screen"))
            .foregroundColor(purple)
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
        .textFieldStyle(CodeEntry())
        .overlay(
            RoundedRectangle(cornerRadius: 10)
            .stroke(lightGray, lineWidth: 1)
        )
    }

    private var submitCodeButton: some View {
        Button(action: {
            self.viewModel.loadPrescriptionFromCode(prescriptionCode: self.prescriptionCode)
        }) {
            Text(LocalizedString("Submit activation code", comment: "Button title for submitting the prescription activation code to Tidepool"))
                .actionButtonStyle(.tidepoolPrimary)
        }
    }
        
    private var requestPrescriptionButton: some View {
        Button(action: {
            // TODO: contact prescriber window
            print("TODO")
        }) {
            Text(LocalizedString("Request activation code", comment:"Button title for requesting a prescription activation code from the prescriber"))
                .actionButtonStyle(.tidepoolSecondary)
        }
    }
}

struct PrescriptionCodeEntryView_Previews: PreviewProvider {
    static var previews: some View {
        PrescriptionCodeEntryView(viewModel: PrescriptionCodeEntryViewModel())
    }
}

