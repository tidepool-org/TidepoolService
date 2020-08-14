//
//  PrescriptionCodeEntryView.swift
//  TidepoolServiceKitUI
//
//  Created by Anna Quinlan on 6/18/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import SwiftUI
import LoopKitUI
import LoopKit

struct PrescriptionCodeEntryView: View, HorizontalSizeClassOverride {
    @ObservedObject var viewModel: PrescriptionReviewViewModel
    @State private var prescriptionCode: String = ""
    // Default to 35 years ago for birthdays, which is what the Apple Health app does
    @State private var birthday: Date = Calendar.current.date(byAdding: .year, value: -35, to: Date())!

    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 35) {
                itemsNeededDescription
                itemsNeededList
                codeEntrySection
                birthdayPickerSection
            }
            .padding(.vertical)
            submitCodeButton
            /* requestPrescriptionButton */ // Slated for post-510K
            Spacer()
        }
        .keyboardAware()
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
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedString("What you'll need", comment: "Title for section describing items needed to review settings"))
            .font(.headline)
            Text(LocalizedString("For the next section, you'll want to have the following:", comment: "Subheader for items-needed section"))
            .foregroundColor(.secondary)
            .fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
        }
    }
    
    private var itemsNeededList: some View {
        InstructionList(instructions: [
            LocalizedString("Prescription activation code", comment: "Label text for the first needed prescription activation item"),
            LocalizedString("Configuration settings for glucose targets and insulin delivery from your healthcare provider", comment: "Label text for the second needed prescription activation item")
            ]
        )
        .foregroundColor(.secondary)
    }

    private var codeEntrySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Text(LocalizedString("Enter your 6-digit prescription code", comment: "Title for section to enter prescription code"))
                .font(.headline)
                Text(LocalizedString("If you have a prescription activation code, please enter it now.", comment: "Text requesting entry of activation code"))
                .foregroundColor(.secondary)
                prescriptionCodeInputField
            }
        }
    }
    
    private var prescriptionCodeInputField: some View {
        DismissibleKeyboardTextField(
            text: $prescriptionCode,
            placeholder: LocalizedString("Activation code", comment: "Placeholder text before entering prescription code in text field"),
            keyboardType: .asciiCapable,
            autocapitalizationType: .allCharacters,
            autocorrectionType: .no
        )
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray, lineWidth: 1)
        )
    }
    
    private var birthdayPickerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 15) {
                Text(LocalizedString("Enter your birthdate", comment: "Title for section to select birthdate"))
                .font(.headline)
                Text(LocalizedString("In order for us to verify the prescription code, please enter the birthdate associated with your Tidepool account.", comment: "Text explaining need for birthdate"))
                .fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
                .foregroundColor(.secondary)
                birthdayPicker
                errorIfNeeded
            }
        }
        
    }
    
    private var birthdayPicker: some View {
        ExpandableDatePicker(
            with: $birthday,
            pickerRange: viewModel.validDateRange,
            placeholderText: viewModel.placeholderFieldText
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray, lineWidth: 1)
        )
    }
    
    private var errorIfNeeded: some View {
        Group {
            if viewModel.shouldDisplayError {
                Text(LocalizedString("The activation code and/or birthdate entered are incorrect. Please update or contact Tidepool Support.", comment: "Prescription validation error message"))
                .foregroundColor(Color.red)
                .fixedSize(horizontal: false, vertical: true) // prevent text from being cut off
            }
        }
    }

    private var submitCodeButton: some View {
        Button(action: {
            self.viewModel.loadPrescriptionFromCode(prescriptionCode: self.prescriptionCode, birthday: self.birthday)
        }) {
            Text(LocalizedString("Submit", comment: "Button title for submitting the prescription activation code to Tidepool"))
                .actionButtonStyle(submitButtonStyle(enabled: prescriptionCode.count == self.viewModel.prescriptionCodeLength))
                .disabled(prescriptionCode.count != viewModel.prescriptionCodeLength)
        }
    }
    
    private func submitButtonStyle(enabled: Bool) -> ActionButton.ButtonType {
        return enabled ? .primary : .deactivated
    }
        
    private var requestPrescriptionButton: some View {
        Button(action: {
            // TODO: open contact prescriber window
            print("Post 510K")
        }) {
            Text(LocalizedString("Request activation code", comment:"Button title for requesting a prescription activation code from the prescriber"))
                .actionButtonStyle(.secondary)
        }
    }
}

struct PrescriptionCodeEntryView_Previews: PreviewProvider {
    static var previews: some View {
        PrescriptionCodeEntryView(viewModel: PrescriptionReviewViewModel())
    }
}

