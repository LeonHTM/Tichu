//
//  LoginView.swift
//  Tichu
//
//  Created by Leon on 11.05.2026.
//

import SwiftUI
import AuthenticationServices


struct LoginView: View {

    // MARK: - Storage
    @AppStorage("userId") var userId: Int = -69420
    @StateObject private var socket = SocketService.shared
    // MARK: - State
    @Binding var userEmail: String
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isEmailFocused: Bool


    // MARK: - Body
    var body: some View {
        GlassEffectContainer {
            Spacer()
            appLogoHeader
            Spacer()
            signInSection
        }
    }

    // MARK: - App Logo Header
    private var appLogoHeader: some View {
        VStack {
            Image("AppLogo")
                .resizable()
                .frame(width: 100, height: 100)

            Text("Welcome to Tichu App")
                .font(.title)
                .fontWeight(.bold)
        }
    }

    // MARK: - Sign In Section
    private var signInSection: some View {
        VStack {
            HStack {
                Text("Sign Up or Log In")
                    .fontWeight(.bold)
                    .font(.title2)
                Spacer()
            }

            Text("Play games with your Friends and get statistics about your Tichu skills.")
                .foregroundStyle(.secondary)

            emailField

            HStack {
                Spacer()
                Text("or").foregroundStyle(.secondary)
                Spacer()
            }

            appleSignInButton
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }

    // MARK: - Email Field (NOW NAVIGATES)
    private var emailField: some View {
        HStack {
            Image(systemName: "envelope.fill")
                .foregroundColor(.secondary)
                .padding(.leading)

            TextField("\("me@tichuplayer.com")", text: $userEmail)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.emailAddress)
                .foregroundColor(.primary)
                .focused($isEmailFocused)
                

            Spacer()

            NavigationLink {
                destinationView()
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.accentColor)
            }
            .simultaneousGesture(TapGesture().onEnded {
                isEmailFocused = false
            })
            .disabled(userEmail.isEmpty)
            .padding(.trailing,10)
        }
        .padding(.vertical, 13)
        .glassEffect(.regular.tint(.secondary.opacity(0.2)).interactive())
    }

    // MARK: - Destination Routing
    @ViewBuilder
    private func destinationView() -> some View {
        if socket.connected {
            NameSheetView(
                showNameSheet: .constant(true),
                email: userEmail,
                editMode: false,
                done: .constant(false)
            )
        } else {
            offlineView()
        }
    }

    // MARK: - Apple Sign In Button
    private var appleSignInButton: some View {
        SignInWithAppleButton(
            .signUp,
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success:
                    print("Success")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        )
        .frame(height: 50)
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .glassEffect(.regular.interactive())
    }
}

#Preview {
    LoginMainView()
}




struct LoginMainView: View {
    @StateObject private var socket = SocketService.shared
    @State private var userEmail: String = ""

    var body: some View {
        NavigationStack {
            LoginView(userEmail: $userEmail).navigationTitle("Login or Sign up").toolbar(.hidden, for: .navigationBar)
         
        }
    }
}
