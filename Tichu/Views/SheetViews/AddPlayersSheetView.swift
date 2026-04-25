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
    @Binding var addPlayer: Profile
    var showGuest: Bool
    @State private var friendsFilterActive: Bool = false
    @State private var playersFilterActive: Bool = false
    @State private var ascendingFriends: Bool = true
    @State private var ascendingPlayers: Bool = true
    
    
    var body: some View {
        
        NavigationStack{
            
            let sortedFriends: [Profile] = exampleProfiles
                .filter { $0.isFriend }
                .sorted { (lhs, rhs) in
                    let l = lhs.name ?? ""
                    let r = rhs.name ?? ""
                    return ascendingFriends ? (l.localizedCaseInsensitiveCompare(r) == .orderedAscending) : (l.localizedCaseInsensitiveCompare(r) == .orderedDescending)
                }

            let sortedPlayers: [Profile] = exampleProfiles
                .sorted { (lhs, rhs) in
                    let l = lhs.name ?? ""
                    let r = rhs.name ?? ""
                    return ascendingPlayers ? (l.localizedCaseInsensitiveCompare(r) == .orderedAscending) : (l.localizedCaseInsensitiveCompare(r) == .orderedDescending)
                }
            
            List{
                if showGuest == true{
                    Section{
                        HStack{
                            Button("Guest"){
                                addPlayer = guestProfile
                                showAddPlayersSheet = false
                            }.foregroundStyle(.white)
                            Spacer()
                            profileImage(selectedImage: nil, size: 44)
                        }
                    }
                }
                
              
                    Section(){
                        HStack{
                            Text("Friends").fontWeight(.bold)
                            Spacer()
                            Menu {
                                Button() {
                                    ascendingFriends = true
                                    friendsFilterActive = false
                                }label:{
                                    Image("ABC.down")
                                    Text("Alphabetical (A-Z)")
                                }
                                Button() {
                                    ascendingFriends = false
                                    friendsFilterActive = true
                                }label:{
                                    Image("ABC.up")
                                    Text("Alphabetical (Z-A)")
                                    
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 20))
                            }
                           .foregroundColor(friendsFilterActive ? .accentColor : .primary)
                        }.padding(.top,20)
                    }.listRowBackground(Color.clear)
                
                
                Section(){
                    ForEach(sortedFriends) { profile in
                        Button(){
                            addPlayer = profile
                            showAddPlayersSheet = false
                        }label:{
                            HStack{
                                Text(profile.name ?? "").foregroundColor(.primary)
                                Spacer()
                                if let data = profile.imageData,
                                   let uiImage = UIImage(data: data) {
                                    profileImage(selectedImage: uiImage, size: 44)
                                } else {
                                    profileImage(selectedImage: nil, size: 44)
                                }
                                
                            }
                        }.buttonStyle(.plain)
                        
                    }
                }
                    
                
                Section(){
                    HStack{
                        Text("All Players").fontWeight(.bold)
                        Spacer()
                        Menu {
                            Button() {
                                ascendingPlayers = true
                                playersFilterActive = false
                            }label:{
                                Image("ABC.down")
                                Text("Alphabetical (A-Z)")
                            }
                            Button() {
                                ascendingPlayers = false
                                playersFilterActive = true
                            }label:{
                                Image("ABC.up")
                                Text("Alphabetical (Z-A)")
                                
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 20))
                        }
                       .foregroundColor(playersFilterActive ? .accentColor : .primary)
                    }.padding(.top,20)
                }.listRowBackground(Color.clear)
                
                    ForEach(sortedPlayers) { profile in
                        Button(){
                            addPlayer = profile
                            showAddPlayersSheet = false
                        }label:{
                            HStack{
                                Text(profile.name ?? "").foregroundColor(.primary)
                                Spacer()
                                if let data = profile.imageData,
                                   let uiImage = UIImage(data: data) {
                                    profileImage(selectedImage: uiImage, size: 44)
                                } else {
                                    profileImage(selectedImage: nil, size: 44)
                                }
                            }
                        }
                        
                        
                    }
                
                
                
            }
            .listSectionSpacing(0)
            .navigationTitle("Add Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
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
    AddPlayersSheetView(showAddPlayersSheet: .constant(true),addPlayer:.constant(exampleProfile),showGuest:true)
}
