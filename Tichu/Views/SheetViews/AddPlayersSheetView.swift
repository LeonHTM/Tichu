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
    @Binding var addPlayer: Profile?
    var alreadyAdded: [Profile]
    var showGuest: Bool
    var showPlayers: Bool
    var showFriends: Bool
    var guestIndex: Int
    @State private var friendsFilterActive: Bool = false
    @State private var playersFilterActive: Bool = false
    @State private var ascendingFriends: Bool = true
    @State private var ascendingPlayers: Bool = true
    @State private var searchText: String = ""
    @State private var showAddPlayerSheet2: Bool = false
    @State private var selectedPlayer: Profile?
    @State private var profileList: [Profile] = exampleProfiles
    
    private var sortedFriends: [Profile] {
        profileList
            .filter { $0.isFriend }
            .sorted {
                let l = $0.name ?? ""
                let r = $1.name ?? ""

                return ascendingFriends
                    ? l.localizedCaseInsensitiveCompare(r) == .orderedAscending
                    : l.localizedCaseInsensitiveCompare(r) == .orderedDescending
            }
            .filter {
                let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !query.isEmpty else { return true }

                return ($0.name ?? "")
                    .range(of: query,
                           options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
    }
    
    var body: some View {
        
        NavigationStack{
            
          
            let sortedPlayers: [Profile] = profileList
                .sorted { (lhs, rhs) in
                    let l = lhs.name ?? ""
                    let r = rhs.name ?? ""
                    return ascendingPlayers ? (l.localizedCaseInsensitiveCompare(r) == .orderedAscending) : (l.localizedCaseInsensitiveCompare(r) == .orderedDescending)
                }
                .filter { Profile in
                    let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !query.isEmpty else { return true }
                    let name = Profile.name ?? ""
                    return name.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
                }
            
            List{
                if showGuest == true{
                    Section{
                        HStack{
                            Button("Guest"){
                                if guestIndex == 2{
                                    addPlayer = guest2Profile
                                }else if guestIndex == 3{
                                    addPlayer = guest3Profile
                                }else{
                                    addPlayer = guest4Profile
                                }
                                showAddPlayersSheet = false
                            }.foregroundColor(.primary)
                            Spacer()
                            ProfileImage(selectedImage: nil, size: 44)
                        }
                    }
                }
                if showFriends == true{
                    if !sortedFriends.isEmpty{
                        Section(){
                            HStack{
                                Text("Friends").fontWeight(.bold)
                                Spacer()
                                if sortedFriends.count != 1 {
                                    Menu {
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                ascendingFriends = true
                                                friendsFilterActive = false
                                            }
                                        } label: {
                                            if ascendingFriends == true {
                                                Image(systemName:"checkmark")
                                            }else{
                                                Image("ABC.down")
                                            }
                                            Text("Alphabetical (A-Z)")
                                        }
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                ascendingFriends = false
                                                friendsFilterActive = true
                                            }
                                        } label: {
                                            if ascendingFriends == true {
                                                Image("ABC.up")
                                            }else{
                                                Image(systemName:"checkmark")
                                            }
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
                        ForEach(sortedFriends) { Profile in
                            Button(){
                                addPlayer = Profile
                                showAddPlayersSheet = false
                            }label:{
                                HStack{
                                    Text(Profile.name ?? "Unknown")
                                    Spacer()
                                    if let data = Profile.imageData,
                                       let uiImage = UIImage(data: data) {
                                        ProfileImage(selectedImage: uiImage, size: 44)
                                    } else {
                                        ProfileImage(selectedImage: nil, size: 44)
                                    }
                                    
                                }
                            }.disabled(alreadyAdded.contains(where: { $0.id == Profile.id }))
                                .foregroundColor(alreadyAdded.contains(where: { $0.id == Profile.id }) ? .secondary : .primary)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            
                        }
                    }
                }
                if showPlayers == true{
                    if !sortedPlayers.isEmpty{
                        Section(){
                            HStack{
                                Text("All Players").fontWeight(.bold)
                                Spacer()
                                if sortedPlayers.count != 1 {
                                    Menu {
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                ascendingPlayers = true
                                                playersFilterActive = false
                                            }
                                        } label: {
                                            if ascendingPlayers == true {Image(systemName:"checkmark")
                                                
                                            }else{
                                                Image("ABC.down")
                                            }
                                            Text("Alphabetical (A-Z)")
                                        }
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                ascendingPlayers = false
                                                playersFilterActive = true
                                            }
                                        } label: {
                                            if ascendingPlayers == true {
                                                
                                                Image("ABC.up")
                                                
                                            }else{
                                                Image(systemName:"checkmark")
                                            }
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
                    
                    ForEach(sortedPlayers) { Profile in
                        Button(){
                            if showPlayers == true{
                                addPlayer = Profile
                                showAddPlayersSheet = false
                            }
                        }label:{
                            HStack{
                                Text(Profile.name ?? "Unknown")
                                Spacer()
                                if let data = Profile.imageData,
                                   let uiImage = UIImage(data: data) {
                                    ProfileImage(selectedImage: uiImage, size: 44)
                                } else {
                                    ProfileImage(selectedImage: nil, size: 44)
                                }
                            }
                        }
                        .disabled(alreadyAdded.contains(where: { $0.id == Profile.id }))
                        .foregroundColor(alreadyAdded.contains(where: { $0.id == Profile.id }) ? .secondary : .primary)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                        
                    }
                }
                
                
            }.searchable(text: $searchText)
            .padding(.top,showGuest==true ? 0 : -45)
            .listSectionSpacing(0)
            .animation(.easeInOut, value: ascendingFriends)
            .animation(.easeInOut, value: ascendingPlayers)
            .animation(.easeInOut, value: searchText)
            .navigationTitle(
                showPlayers == true && showFriends == true ? "Add Players" :
                    showFriends == false ? "Add Friend" :
                             "Edit Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                                ToolbarItem(placement:.cancellationAction){
                    Button("Cancel",systemImage:"xmark"){
                        showAddPlayersSheet = false
                    }
                }
            }
            
        }
        
    }
}


#Preview {
    AddPlayersSheetView(showAddPlayersSheet: .constant(true),addPlayer:.constant(exampleProfiles[0]),alreadyAdded:[],showGuest:false,showPlayers:false,showFriends: true,guestIndex:2)
}

