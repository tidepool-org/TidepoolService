//
//  SoftwareUpdateView.swift
//  TidepoolServiceKitUI
//
//  Created by Rick Pasetto on 10/4/21.
//  Copyright © 2021 LoopKit Authors. All rights reserved.
//

import LoopKitUI
import SwiftUI

struct SoftwareUpdateView: View {
    
    private let padding: CGFloat = 5
    
    var softwareUpdateViewModel: SoftwareUpdateViewModel

    var body: some View {
        List {
            softwareUpdateSection
            supportSection
        }
        .insetGroupedListStyle()
        .navigationBarTitle(Text("Software Update", comment: "Software update view title"))
    }
    
    private var softwareUpdateSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    softwareUpdateViewModel.icon
                    updateHeader
                }
                .padding(.vertical, padding)
                
                DescriptiveText(label: updateBody)
                    .padding(.bottom, padding)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: false)

                Divider()
                appStoreButton
            }
        }
    }
    
    @ViewBuilder
    private var updateHeader: some View {
        Text(softwareUpdateViewModel.versionUpdate?.localizedDescription ?? "")
            .bold()
    }
    
    private var updateBody: String {
        switch softwareUpdateViewModel.versionUpdate {
        case .required,  // for now...
                .recommended:
            return NSLocalizedString("Your Tidepool Loop app is out of date. It will continue to work, but we recommend updating to the new version.", comment: "Body for supported update needed")
        case .available:
            return NSLocalizedString("Tidepool Loop has a new version ready for you. Please update through the App Store.", comment: "Body for information update needed")
        default:
            return ""
        }
    }
    
    private var appStoreButton: some View {
        Button( action: { softwareUpdateViewModel.gotoAppStore() } ) {
            HStack {
                Text(NSLocalizedString("App Store to Download and Install", comment: "App Store to Download and Install button text"))
                Spacer()
                Image(systemName: "chevron.right").foregroundColor(.gray).font(.footnote)
            }
        }
        .accentColor(.primary)
        .padding(.vertical, padding)
    }
    
    private var supportSection: some View {
        Section(header: SectionHeader(label: NSLocalizedString("Support", comment: "The title of the support section in software update")),
                footer: Text("Have a question about an update? Let us know.", comment: "The footer of the support section in software update")) {
            NavigationLink(destination: Text("Get Help"))
            {
                Text(NSLocalizedString("Get Help", comment: "The title of the support item in settings"))
            }
        }
    }

}

struct SoftwareUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        SoftwareUpdateView(softwareUpdateViewModel: SoftwareUpdateViewModel.preview)
    }
}
