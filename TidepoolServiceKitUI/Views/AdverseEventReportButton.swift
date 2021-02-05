//
//  AdverseEventReportButton.swift
//  TidepoolServiceKitUI
//
//  Created by Pete Schwamb on 11/16/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation
import SwiftUI

struct AdverseEventReportButton: View {
    let adverseEventReportViewModel: AdverseEventReportViewModel
    let urlHandler: (URL) -> Void

    @State private var adverseEventReportURLInvalid = false

    var body: some View {
        Button(action: {
            guard let url = self.adverseEventReportViewModel.reportURL else {
                self.adverseEventReportURLInvalid = true
                return
            }

            urlHandler(url)
        }) {
            Text("Report an Adverse Event", comment: "The title text for the reporting of an adverse event menu item")
        }
        .alert(isPresented: $adverseEventReportURLInvalid) {
            invalidAdverseEventReportURLAlert
        }
    }

    private var invalidAdverseEventReportURLAlert: SwiftUI.Alert {
        Alert(title: Text("Invalid Adverse Event Report URL", comment: "Alert title when the adverse event report URL cannot be constructed properly."),
              message: Text("The adverse event report URL could not be constructed properly.", comment: "Alert message when the adverse event report URL cannot be constructed properly."),
              dismissButton: .default(Text("Dismiss", comment: "Dismiss button for the invalid adverse event report URL alert.")))
    }
}
