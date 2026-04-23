//
//  NameSheetView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct NameSheetView: View {
    //Open/Close Sheet
    @Binding var showNameSheet:Bool
    
    //App Storage
    @AppStorage("userName") var userName: String = ""
    
    //Vars
    @State private var newName: String = ""
    
    
    //Calculated Vars
    //Valid Lenght
    private var isLengthValid: Bool {
        let count = newName.count
        return count >= 3 && count <= 20
    }
    //Valid Chars
   private var isCharsetValid: Bool {
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz0123456789_")
        return !newName.isEmpty && newName.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
    //Is Available
    private var isAvailable:Bool {
        return isLengthValid
    }
    
    private var isAllValid: Bool { isLengthValid && isCharsetValid && isAvailable }
    
    var body: some View {
        
        NavigationStack{
            
            List{
                VStack{
                    HStack{
                        
                        Text("Pick a unique username. This is required, so you can be added to matches.")
                            .padding(.vertical, 2)
                            
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                
                
                TextField("", text: $newName)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    
                
                VStack(spacing: 2){
                    HStack{
                        Text("Requirements:").fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.vertical, 2)

                    HStack{
                        Text("•").fontWeight(.bold)
                        Text("Between 3 and 20 Characters")
                        Spacer()
                    }
                    .foregroundStyle(isLengthValid ? Color.green : Color.red)
                    .padding(.vertical, 2)

                    HStack{
                        Text("•").fontWeight(.bold)
                        Text("Upper and Lowercase letters, numbers and Underscores only")
                        Spacer()
                    }
                    .foregroundStyle(isCharsetValid ? Color.green : Color.red)
                    .padding(.vertical, 2)
                    
                    HStack{
                        Text("•").fontWeight(.bold)
                        Text("Nobody else has the same Name")
                        Spacer()
                    }
                    .foregroundStyle(isAvailable ? Color.green : Color.red)
                    .padding(.vertical, 2)
                }
                .listRowBackground(Color.clear)
                
            }
            
            .listRowSpacing(2)
            
            .navigationTitle("Edit Username")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement:.confirmationAction){
                    Button("Done", systemImage: "checkmark"){
                        userName = newName
                        showNameSheet = false
                    }
                    .disabled(!isAllValid)
                }
                ToolbarItem(placement:.cancellationAction){
                    Button("Cancel",systemImage:"xmark"){
                        showNameSheet = false
                    }
                }
            }
        }.onAppear{
            newName = userName
        }
      
    }
}

#Preview {
    NameSheetView(showNameSheet: .constant(true))
}
