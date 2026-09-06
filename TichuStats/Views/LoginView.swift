//
//  LoginView.swift
//  Tichu
//
//  Created by Leon on 11.05.2026.
//

import SwiftUI
import AuthenticationServices


struct WelcomeView: View {
    @ObservedObject private var network = NetworkService.shared
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) var colorScheme
    @Binding var showLoginSheet: Bool
    @Binding var signIn: Bool
    @Binding var chosenName: String

    var body: some View {
        GlassEffectContainer {
            Spacer()
            VStack {
                Image("AppLogo")
                    .resizable()
                    .frame(width: 100, height: 100)

                Text(String(localized:"login.title"))
                    .font(.title)
                    .fontWeight(.bold)
            }
            Spacer()
            
            VStack{
                Text(String(localized:"login.description"))
                    .foregroundStyle(.secondary)
                NavigationButton(
                    title: String(localized:"login.getStarted"),
                    icon: nil,
                    primary:true,
                ) {
                    if network.isOnline {
                        EditNameSheetView(
                            editMode: false,
                            showLoginSheet: $showLoginSheet,
                            signIn: $signIn,
                            chosenName: $chosenName
                        )
                    } else {
                        OfflineView(
                            showNavBar: .constant(false)
                        )
                    }
                }
                Button{
                        signIn = true
                        showLoginSheet = true
                }label:{
                    HStack{
                        Spacer()
                        Text(String(localized:"login.alreadyHave"))
                        Spacer()
                    }
                    .fontWeight(.semibold)
                    .font(.system(size: 18))
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                    .glassEffect(.regular.tint(colorScheme == .dark ? Color.white : Color.primary).interactive())
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
}



struct LoginView: View{
    @State private var showLoginSheet: Bool = false
    @State private var signIn: Bool = true
    @State private var chosenName: String = ""
    var body: some View{
        NavigationStack{
            WelcomeView(showLoginSheet:$showLoginSheet,signIn: $signIn, chosenName: $chosenName)
                .navigationTitle(String(localized:"login.title"))
                .toolbar(.hidden, for: .navigationBar)
                .sheet(isPresented: $showLoginSheet) {
                LoginSheetView(showLoginSheet: $showLoginSheet,signIn: $signIn, chosenName: chosenName)
                    .presentationDetents([.height(250)])
                
                }.onChange(of:chosenName){
                    print(chosenName)
                }
                
            
        }
    }
}
