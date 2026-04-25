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
    
    // MARK: - Storage
    
    @AppStorage("userName") private var userName: String = ""
    
    // MARK: - State
    
    @State private var newName: String = ""
    
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
    
    // TODO: DARF NICHT UNKNOWN SEIN!!!!
    private var isAvailable: Bool {
        true
    }
    
    private var isAllValid: Bool {
        isLengthValid && isCharsetValid && isAvailable
    }
    
    var body: some View {
        
        NavigationStack {
            Form {
                
                Section() {
                    
                    TextField("Enter username", text: $newName)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
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
                    
                    requirementRow(
                        text: "Username is available",
                        isValid: isAvailable
                    )
                }
            }
            .navigationTitle("Edit Username")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top) {
                Text("Pick a unique username. This is required so you can be added to matches.")
                    .padding(.horizontal,25)
                    .padding(.top,10)
                    .padding(.bottom,-10)
            }
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        showNameSheet = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        userName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                        showNameSheet = false
                    }
                    .disabled(!isAllValid)
                }
            }
        }
        .onAppear {
            newName = userName
        }
    }
    
}

#Preview {
    NameSheetView(showNameSheet: .constant(true))
}
