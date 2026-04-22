//
//  NameSheetView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct NameSheetView: View {
    @Binding var showNameSheet:Bool
    @AppStorage("username") var userName: String = ""
    @State private var newName: String = ""
    var body: some View {
        
        NavigationStack{
            
            List{
                
                TextField("", text: $newName).textFieldStyle(.plain)
                    
            }
            .keyboardType(.emailAddress)
            .navigationTitle("Change Username")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement:.confirmationAction){
                    Button("Done",systemImage:"checkmark"){
                        userName = newName
                        showNameSheet = false
                    }
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
