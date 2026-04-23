//
//  FriendsSheetView.swift
//  Tichu
//
//  Created by Leon on 23.04.2026.
//

import SwiftUI

struct FriendsSheetView: View {
    //Open/Close Sheet
    @Binding var showFriendsSheet:Bool
    
    //App Storage
    @AppStorage("userName") var userName: String = ""
    
    
    
    var body: some View {
        
        NavigationStack{
            
            List{
                Text("Placeholder")
            }
            
            .listRowSpacing(2)
            .navigationTitle("Manage Friendlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement:.confirmationAction){
                    Button("Done", systemImage: "checkmark"){
                        
                        showFriendsSheet = false
                    }
                    
                }
                ToolbarItem(placement:.cancellationAction){
                    Button("Cancel",systemImage:"xmark"){
                        showFriendsSheet = false
                    }
                }
            }
        }.onAppear{
            
        }
        
    }
}


#Preview {
    FriendsSheetView(showFriendsSheet: .constant(true))
}
