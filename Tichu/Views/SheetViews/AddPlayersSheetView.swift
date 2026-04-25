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
    @State private var searchText: String = ""
    
    
    var body: some View {
        
        NavigationStack{
            
            let sortedFriends: [Profile] = exampleProfiles
                .filter { $0.isFriend }
                .sorted { (lhs, rhs) in
                    let l = lhs.name ?? ""
                    let r = rhs.name ?? ""
                    return ascendingFriends ? (l.localizedCaseInsensitiveCompare(r) == .orderedAscending) : (l.localizedCaseInsensitiveCompare(r) == .orderedDescending)
                }
                .filter { profile in
                    let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !query.isEmpty else { return true }
                    let name = profile.name ?? ""
                    return name.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
                }

            let sortedPlayers: [Profile] = exampleProfiles
                .sorted { (lhs, rhs) in
                    let l = lhs.name ?? ""
                    let r = rhs.name ?? ""
                    return ascendingPlayers ? (l.localizedCaseInsensitiveCompare(r) == .orderedAscending) : (l.localizedCaseInsensitiveCompare(r) == .orderedDescending)
                }
                .filter { profile in
                    let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !query.isEmpty else { return true }
                    let name = profile.name ?? ""
                    return name.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
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
                
                if !sortedFriends.isEmpty{
                    Section(){
                        HStack{
                            Text("Friends").fontWeight(.bold)
                            Spacer()
                            if sortedFriends.count != 1 {
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
                            }
                            
                        }.padding(.top,20)
                    }.listRowBackground(Color.clear)
                }
                
                
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
                    
                if !sortedPlayers.isEmpty{
                    Section(){
                        HStack{
                            Text("All Players").fontWeight(.bold)
                            Spacer()
                            if sortedPlayers.count != 1 {
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
                            }
                        }.padding(.top,20)
                    }.listRowBackground(Color.clear)
                }
                
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
            .safeAreaInset(edge:.bottom){
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search players by name", text: $searchText)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                    if !searchText.isEmpty {
                        Button {
                            withAnimation { searchText = "" }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Clear search")
                    }
                }
                .padding(.vertical, 15)
                .padding(.horizontal,15)
                .glassEffect(.regular.interactive())
                .padding(.horizontal,10)
                .padding(.bottom,10)
            }
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

