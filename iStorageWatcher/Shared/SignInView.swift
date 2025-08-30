//
//  SignInView.swift
//  iStorageWatcher
//
//  Splash login using Sign in with Apple and iCloud status hint.
//

import SwiftUI
import AuthenticationServices
import CloudKit
#if os(macOS)
import AppKit
#endif

struct SignInView: View {
    @AppStorage("isSignedIn") private var isSignedIn = false
    @State private var iCloudStatus: CKAccountStatus = .couldNotDetermine
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to iStorageWatcher")
                .font(.title2).bold()
            Text("Sign in to sync your devices and storage info via iCloud.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: handleAppleSignIn(result:)
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 45)

            Group {
                switch iCloudStatus {
                case .available:
                    Label("iCloud: Available", systemImage: "icloud")
                        .foregroundColor(.green)
                case .noAccount:
                    VStack(spacing: 8) {
                        Label("iCloud: Not signed in", systemImage: "icloud.slash")
                            .foregroundColor(.orange)
                        Button("Open iCloud Settings", action: openICloudSettings)
                    }
                case .restricted:
                    Label("iCloud: Restricted", systemImage: "lock.icloud")
                        .foregroundColor(.orange)
                default:
                    Label("Checking iCloud status…", systemImage: "icloud")
                        .foregroundColor(.secondary)
                }
            }
            .font(.footnote)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }
        }
        .padding()
        .onAppear(perform: checkICloudStatus)
    }

    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success:
            isSignedIn = true
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    private func checkICloudStatus() {
        CKContainer.default().accountStatus { status, _ in
            DispatchQueue.main.async { self.iCloudStatus = status }
        }
    }

    private func openICloudSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.AppleID-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
        #endif
    }
}
