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

    // MARK: - State
    @Binding var userEmail: String
    @Binding var done: Bool
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Body
    var body: some View {
        NavigationStack {
            GlassEffectContainer {
                Spacer()
                appLogoHeader
                Spacer()
                signInSection
            }
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
            Text("Play games with your Friends and get statistics about you Tichu Skilss.")
                .foregroundStyle(Color.secondary)

            emailField
            HStack {
                Spacer()
                Text("or").foregroundStyle(Color.secondary)
                Spacer()
            }
            appleSignInButton
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }

    // MARK: - Email Field
    private var emailField: some View {
        HStack {
            Image(systemName: "envelope.fill")
                .foregroundColor(.secondary)
                .padding(.leading)
            TextField(
                "\("me@tichuplayer.com")",
                text: $userEmail
            )
                .textInputAutocapitalization(.never)
                .multilineTextAlignment(.leading)
                .autocorrectionDisabled(true)
                .keyboardType(.emailAddress)
                .foregroundColor(.primary)
            Spacer()
            Button {
                withAnimation(.easeInOut) {
                    done = true
                }
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.accent)
                    
            }.padding(.trailing,10)
            .disabled(userEmail.isEmpty)
        }
        .padding(.vertical, 13)
        .foregroundStyle(Color.primary)
        .glassEffect(.regular.tint(.secondary.opacity(0.2)).interactive())
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
    @State private var userEmail: String = ""
    @State private var done: Bool = false

    var body: some View {
        ZStack {
            if !done {
                LoginView(userEmail: $userEmail, done: $done)
                    .transition(.move(edge: .leading))
            } else {
                NameSheetView(showNameSheet: .constant(true),email:userEmail,editMode:false)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: done)
    }
}
