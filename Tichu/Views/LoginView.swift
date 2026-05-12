//
//  LoginView.swift
//  Tichu
//
//  Created by Leon on 11.05.2026.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    @AppStorage("loggedIn") var loggedIn: Bool = false
    @State private var userEmail:String = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack{
            GlassEffectContainer{
                Spacer()
                Image("AppLogo").resizable()
                    .frame(width: 100, height: 100)
                Text("Welcome to Tichu App").font(.title).fontWeight(.bold)
                Spacer()
                /*VStack{
                    HStack{
                        Text("Sign In").fontWeight(.bold)
                        Spacer()
                    }.padding(.horizontal)
                    HStack{
                        Button{}label:{
                            Text("Sign In")
                        }.padding()
                        Spacer()
                    }.foregroundStyle(Color.primary).glassEffect(.regular.tint(.accentColor).interactive()).padding(.horizontal)
                    SignInWithAppleButton(
                        .signUp,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                print("Success")
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    ).frame(height: 50).signInWithAppleButtonStyle(.white).clipShape(
                        RoundedRectangle(cornerRadius: 24)
                    ).glassEffect(.regular.interactive()).padding(.horizontal)
                }*/
                VStack{
                    HStack{
                        Text("Sign Up or Log In").fontWeight(.bold).font(.title2)
                        
                        Spacer()
                    }
                    Text("Play games with your Friends and get statistics about you Tichu Skilss.").foregroundStyle(Color.secondary)
                    HStack{
                      
                            HStack{
                                Image(systemName:"envelope.fill").foregroundColor(.secondary).padding(.leading)
                                TextField(
                                        "\("me@tichuplayer.com")",
                                        text: $userEmail
                                ).textInputAutocapitalization(.never)
                                    .multilineTextAlignment(.leading)
                                    .autocorrectionDisabled(true)
                                    .keyboardType(.emailAddress)
                                    .foregroundColor(.primary)
                             
                                //Text("Create Account").fontWeight(.bold)
                                Spacer()
                                Button{
                                    loggedIn = true
                                    print("djfasdf")
                                }label:{
                                    Image(systemName:"arrow.right.circle.fill").font(.system(size:24)).foregroundStyle(Color.accent)
                                }.disabled(userEmail.isEmpty)
                            
                            
                        }.padding(.vertical,13)
                        Spacer()
                    }.foregroundStyle(Color.primary).glassEffect(.regular.tint(.secondary.opacity(0.2)).interactive())
                    HStack{
                        Spacer()
                        Text("or").foregroundStyle(Color.secondary)
                        Spacer()
                    }
                    SignInWithAppleButton(
                        .signUp,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                print("Success")
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    ).frame(height: 50).signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black).clipShape(
                        RoundedRectangle(cornerRadius: 24)
                    ).glassEffect(.regular.interactive())
                }.padding(.horizontal).padding(.bottom,30)
                
            }
        }
    }
}

#Preview {
    LoginView()
}
