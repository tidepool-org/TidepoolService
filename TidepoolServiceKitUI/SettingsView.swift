//
//  SettingsView.swift
//  TidepoolServiceKitUI
//
//  Created by Pete Schwamb on 1/27/23.
//  Copyright © 2023 LoopKit Authors. All rights reserved.
//

import SwiftUI
import TidepoolKit
import TidepoolServiceKit

public struct SettingsView: View {

    @State private var isEnvironmentActionSheetPresented = false
    @State private var showingDeletionConfirmation = false

    @State private var error: Error?
    @State private var isLoggingIn = false
    @State private var selectedEnvironment: TEnvironment
    @State private var environments: [TEnvironment] = [TEnvironment.productionEnvironment]
    @State private var environmentFetchError: Error?

    @ObservedObject private var service: TidepoolService

    private let login: ((TEnvironment) async throws -> Void)?
    private let dismiss: (() -> Void)?

    var isLoggedIn: Bool {
        return service.session != nil
    }

    public init(service: TidepoolService, login: ((TEnvironment) async throws -> Void)?, dismiss: (() -> Void)?)
    {
        let tapi = service.tapi
        self.service = service
        let defaultEnvironment = tapi.defaultEnvironment
        self._selectedEnvironment = State(initialValue: service.session?.environment ?? defaultEnvironment ?? TEnvironment.productionEnvironment)
        self.login = login
        self.dismiss = dismiss
    }

    public var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
                .edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        HStack() {
                            Spacer()
                            closeButton
                                .padding()
                        }
                        Spacer()
                        logo
                            .padding(.horizontal, 30)
                            .padding(.bottom)
                        if selectedEnvironment != TEnvironment.productionEnvironment {
                            VStack {
                                Text(LocalizedString("Environment", comment: "Label title for displaying selected Tidepool server environment."))
                                    .bold()
                                Text(selectedEnvironment.description)

                                if isLoggedIn {
                                    Button(LocalizedString("Revoke token", comment: "Button title to revoke oauth tokens"), action: {
                                        Task {
                                            do {
                                                try await service.tapi.revokeTokens()
                                            } catch {
                                                self.error = error
                                            }
                                        }
                                    })
                                }
                            }
                        }
                        if let username = service.session?.username {
                            VStack {
                                Text(LocalizedString("Logged in as", comment: "LoginViewModel description text when logged in"))
                                    .bold()
                                Text(username)
                            }
                        } else {
                            Text(LocalizedString("You are not logged in.", comment: "LoginViewModel description text when not logged in"))
                                .padding()
                        }

                        if let error {
                            VStack(alignment: .leading) {
                                Text(error.localizedDescription)
                                    .font(.callout)
                                    .foregroundColor(.red)
                            }
                            .padding()
                        }
                        Spacer()
                        if isLoggedIn {
                            deleteServiceButton
                        } else {
                            loginButton
                        }
                    }
                    .padding()
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .alert(LocalizedString("Are you sure you want to delete this service?", comment: "Confirmation message for deleting a service"), isPresented: $showingDeletionConfirmation)
        {
            Button(LocalizedString("Delete Service", comment: "Button title to delete a service"), role: .destructive) {
                service.deleteService()
                dismiss?()
            }
        }
        .task {
            do {
                environments = try await TEnvironment.fetchEnvironments()
            } catch {

            }
        }

    }

    private var logo: some View {
        Image(frameworkImage: "Tidepool Logo", decorative: true)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 150)
            .onLongPressGesture(minimumDuration: 2) {
                if !isLoggedIn {
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                    isEnvironmentActionSheetPresented = true
                }
            }
            .actionSheet(isPresented: $isEnvironmentActionSheetPresented) { environmentActionSheet }
    }

    private var environmentActionSheet: ActionSheet {
        var buttons: [ActionSheet.Button] = environments.map { environment in
            .default(Text(environment.description)) {
                error = nil
                selectedEnvironment = environment
            }
        }
        buttons.append(.cancel())


        return ActionSheet(title: Text(LocalizedString("Environment", comment: "Tidepool login environment action sheet title")),
                           message: Text(selectedEnvironment.description), buttons: buttons)
    }

    private var loginButton: some View {
        Button(action: {
            loginButtonTapped()
        }) {
            if isLoggingIn {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Text(LocalizedString("Login", comment: "Tidepool login button title"))
            }
        }
        .buttonStyle(ActionButtonStyle())
        .disabled(isLoggingIn)
    }


    private var deleteServiceButton: some View {
        Button(action: {
            showingDeletionConfirmation = true
        }) {
            Text(LocalizedString("Delete Service", comment: "Delete Tidepool service button title"))
        }
        .buttonStyle(ActionButtonStyle(.secondary))
        .disabled(isLoggingIn)
    }

    private func loginButtonTapped() {
        guard !isLoggingIn else {
            return
        }

        error = nil
        isLoggingIn = true

        Task {
            do {
                try await login?(selectedEnvironment)
                isLoggingIn = false
            } catch {
                self.error = error
                isLoggingIn = false
            }
        }
    }

    private var closeButton: some View {
        Button(action: {
            dismiss?()
        }) {
            Text(closeButtonTitle)
                .fontWeight(.regular)
        }
    }

    private var closeButtonTitle: String { LocalizedString("Close", comment: "Close navigation button title of an onboarding section page view") }
}

struct SettingsView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        SettingsView(service: TidepoolService(hostIdentifier: "Previews", hostVersion: "1.0"), login: nil, dismiss: nil)
    }
}
