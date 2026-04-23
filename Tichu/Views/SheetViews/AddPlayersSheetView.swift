//
//  FriendsSheetView.swift
//  Tichu
//
//  Created by Leon on 23.04.2026.
//

import SwiftUI

struct AddPlayersSheetView: View {
    //Open/Close Sheet
    @Binding var showAddPlayersSheet:Bool
    
    //App Storage
    @AppStorage("userName") var userName: String = ""
    
    
    
    var body: some View {
        
        NavigationStack{
            
            List{
                Section{
                    HStack{
                        Button("Guest"){
                            
                        }.foregroundStyle(.white)
                    }
                }
                Text("Friends")
            }
            
            .listRowSpacing(2)
            .navigationTitle("Add Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement:.confirmationAction){
                    Button("Done", systemImage: "checkmark"){
                        
                        showAddPlayersSheet = false
                    }
                    
                }
                ToolbarItem(placement:.cancellationAction){
                    Button("Cancel",systemImage:"xmark"){
                        showAddPlayersSheet = false
                    }
                }
            }
        }.onAppear{
            
        }
        
    }
}


#Preview {
    AddPlayersSheetView(showAddPlayersSheet: .constant(true))
}
