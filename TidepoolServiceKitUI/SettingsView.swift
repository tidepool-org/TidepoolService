//
//  SettingsView.swift
//  TidepoolServiceKitUI
//
//  Created by Pete Schwamb on 1/27/23.
//  Copyright © 2023 LoopKit Authors. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismissAction) private var dismiss

    var accountLogin: String
    var didRequestDelete: () -> Void

    @State private var showingAlert = false

    var body: some View {
        VStack {
            Text("Tidepool ")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Image(frameworkImage: "Tidepool Logo", decorative: true)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)


            VStack(spacing: 0) {
                HStack {
                    Text("Account")
                    Spacer()
                    Text(accountLogin)
                }
                .padding()
            }

            Button(action: {
                showingAlert = true
            } ) {
                Text("Delete Service").padding(.top, 20)
            }
            Spacer()
        }
        .padding([.leading, .trailing])
        .navigationBarTitle("")
        .navigationBarItems(trailing: dismissButton)
        .alert(LocalizedString("Are you sure you want to delete this service?", comment: "Confirmation message for deleting a service"), isPresented: $showingAlert)
        {
            Button(LocalizedString("Delete Service", comment: "Button title to delete a service"), role: .destructive) {
                didRequestDelete()
                dismiss()
            }
        }
    }

    private var dismissButton: some View {
        Button(action: dismiss) {
            Text("Done").bold()
        }
    }}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(accountLogin: "test@test.com") {
            print("Delete Service!")
        }
    }
}
