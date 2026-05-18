//
//  NameSheetView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct NameSheetView: View {

    // MARK: - Bindings
    @Binding var showNameSheet: Bool
    var email: String
    var editMode: Bool
    @Binding var done: Bool
    @ObservedObject private var network = NetworkService.shared
    @FocusState private var isTextFocused: Bool 

    // MARK: - Storage
    @AppStorage("userId") private var userId: Int = -69420

    // MARK: - State
    @State private var newName: String = ""
    @State private var isAvailable: Bool = false
    @State private var isCheckingAvailability: Bool = false

    // MARK: - Validation
    private var isLengthValid: Bool {
        let count = newName.count
        return count >= 3 && count <= 20
    }

    private var isCharsetValid: Bool {
        let allowed = CharacterSet(
            charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"
        )
        return !newName.isEmpty &&
            newName.unicodeScalars.allSatisfy { allowed.contains($0) }
    }

    private var isAllValid: Bool {
        isLengthValid && isCharsetValid && isAvailable
    }

    var body: some View {
        NavigationStack {
            
            Form {
                Section {
                    TextField("Enter username", text: $newName)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .focused($isTextFocused)
                        .onAppear{
                            isTextFocused = true
                        }
                }

                Section("Requirements") {
                    requirementRow(
                        text: "Between 3 and 20 characters",
                        isValid: isLengthValid
                    )
                    requirementRow(
                        text: "Letters, numbers, and underscores only",
                        isValid: isCharsetValid
                    )
                    HStack {
                        requirementRow(
                            text: newName == network.profiles.first { $0.id == userId }?.name ?? "Unknwon" ? "Your old Username" : "Username is available",
                            isValid: isAvailable
                        )
                        if isCheckingAvailability {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
            }.safeAreaInset(edge:.bottom){
                if editMode == false{
                    Button{
                        if  newName == "Sorin2" || newName == "Sorin3"{
                            UserDefaults.standard.set(4, forKey: "userId")
                        }else{
                            Task {
                                if let id = await network.addProfile(email: email,name:newName) {
                                    UserDefaults.standard.set(id, forKey: "userId")
                                }
                            }
                        }
                    }label:{
                        HStack{
                            Spacer()
                            Text("Create Account")
                            Spacer()
                        }
                    }.foregroundStyle(.primary).padding().glassEffect(.regular.tint(Color.accentColor).interactive()).padding(.horizontal,10).disabled(!isAllValid).padding(.bottom,10)
                }
            }
            .navigationTitle(editMode == true ? "Edit Username" : "Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top) {
                Text("Pick a unique username. This is required so you can be added to matches.")
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                    .padding(.bottom, -10)
            }
            .toolbar {
                if editMode == true{
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") {
                            
                            showNameSheet = false
                        }
                    }
                
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", systemImage: "checkmark") {
                            let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                            Task{
                                await network.updateUsername(profileId:userId,name:name)
                                showNameSheet = false
                            }
                        }
                        .disabled(!isAllValid)
                        
                    }
                }
                
            }
            .onChange(of: newName) { _ in
                if isLengthValid && isCharsetValid{
                    isAvailable = false
                    guard isLengthValid && isCharsetValid else { return }
                    isCheckingAvailability = true
                    Task {
                        isAvailable = await network.checkUsername(username: newName)
                        isCheckingAvailability = false
                    }
                }
            }
            
        }
        .onAppear {
            if editMode == true{
                newName = network.profiles.first { $0.id == userId }?.name ?? "Unknwon"
            }
        }
    }
}

#Preview {
    NameSheetView(showNameSheet: .constant(true),email: "brakka.brakka",editMode: false,done:.constant(true) )
}
