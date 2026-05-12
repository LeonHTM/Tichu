//
//  FriendsSheetView.swift
//  Tichu
//
//  Created by Leon on 23.04.2026.
//

import SwiftUI

struct AddPlayersSheetView: View {
    //Bindings
    @Binding var showAddPlayersSheet:Bool
    @Binding var addPlayer: Profile?
    var alreadyAdded: [Profile]
    var showGuest: Bool
    var showPlayers: Bool
    var showFriends: Bool
    var guestIndex: Int
    
    //Vars
    @State private var searchText: String = ""
    @State private var selectedPlayer: Profile?
    @State private var profileList: [Profile] = exampleProfiles
    @State private var sortByFriends: sortBy.sortBy = .nameDown
    @State private var sortByPlayers: sortBy.sortBy = .nameDown
    
    //Computed Vars
    var friendsFilterActive: Bool {
        return sortByFriends != .nameDown
    }
    
    var playersFilterActive: Bool {
        return sortByPlayers != .nameDown
    }
    
    var query: String{
        return searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var sortedFriends: [Profile] {
        return makeItems(from:profileList.filter { $0.isFriend }.filter {

            guard !query.isEmpty else { return true }

            return ($0.name ?? "")
                .range(of: query,
                       options: [.caseInsensitive, .diacriticInsensitive]) != nil
        },
                         stat:.elo,
                         sortBy:sortByFriends)
    }
   var sortedPlayers: [Profile] {
        return makeItems(from:profileList.filter {
            guard !query.isEmpty else { return true }
            return ($0.name ?? "")
                .range(of: query,
                       options: [.caseInsensitive, .diacriticInsensitive]) != nil
        },
                         stat:.elo,
                         sortBy:sortByPlayers)
    }
    
    var body: some View {
        
        NavigationStack{
            List{
                if query.isEmpty{
                    if showGuest == true{
                    Section{
                        HStack{
                            ProfileImage(data: nil, size: 44)
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
                            
                        }
                    }
                    }
                }else if !query.isEmpty && sortedFriends.isEmpty && sortedPlayers.isEmpty {
                    
                    VStack(alignment:.center) {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Could not find '\(query)'")
                        }
                        
                        Spacer()
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
                                                sortByFriends = .nameDown
                                               
                                            }
                                        } label: {
                                            if sortByFriends == .nameDown {
                                                Image(systemName:"checkmark")
                                            }else{
                                                Image("ABC.down")
                                            }
                                            Text("Alphabetical (A-Z)")
                                        }
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                sortByFriends = .nameUp
                                               
                                            }
                                        } label: {
                                            if sortByFriends != .nameUp {
                                                Image("ABC.up")
                                            }else{
                                                Image(systemName:"checkmark")
                                            }
                                            Text("Alphabetical (Z-A)")
                                            
                                        }
                                        Divider()
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                sortByFriends = .valueDown
                                            }
                                        }label:{
                                            if sortByFriends == .valueDown{
                                                Image(systemName:"checkmark")
                                            }else{
                                                Image("123.down")
                                            }
                                            Text("By Value (High-Low)")
                                            
                                        }
                                        
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                sortByFriends = .valueUp
                                            }
                                        }label:{
                                            if sortByFriends == .valueUp{
                                                Image(systemName:"checkmark")
                                            }else{
                                                Image("123.up")
                                            }
                                            Text("By Value (Low-High)")
                                            
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
                                    ProfileImage(data: Profile.imageData, size: 44)
                                    Text(Profile.name ?? "Unknown")
                                    Spacer()
                                    if let elo = Profile.elo{
                                        Text("\(elo)").foregroundStyle(.secondary)
                                            .font(.system(size: 16))
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
                                                sortByPlayers = .nameDown
                                                
                                            }
                                        } label: {
                                            if sortByPlayers == .nameDown {Image(systemName:"checkmark")
                                                
                                            }else{
                                                Image("ABC.down")
                                            }
                                            Text("Alphabetical (A-Z)")
                                        }
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                sortByPlayers = .nameUp
                                            }
                                        } label: {
                                            if sortByPlayers != .nameUp {
                                                
                                                Image("ABC.up")
                                                
                                            }else{
                                                Image(systemName:"checkmark")
                                            }
                                            Text("Alphabetical (Z-A)")
                                            
                                        }
                                        Divider()
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                sortByPlayers = .valueDown
                                            }
                                        }label:{
                                            if sortByPlayers == .valueDown{
                                                Image(systemName:"checkmark")
                                            }else{
                                                Image("123.down")
                                            }
                                            Text("By Value (High-Low)")
                                            
                                        }
                                        
                                        Button() {
                                            withAnimation(.easeInOut) {
                                                sortByPlayers = .valueUp
                                            }
                                        }label:{
                                            if sortByPlayers == .valueUp{
                                                Image(systemName:"checkmark")
                                            }else{
                                                Image("123.up")
                                            }
                                            Text("By Value (Low-High)")
                                            
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
                                ProfileImage(data: Profile.imageData, size: 44)
                                Text(Profile.name ?? "Unknown")
                                Spacer()
                                if let elo = Profile.elo{
                                    Text("\(elo)").foregroundStyle(.secondary)
                                        .font(.system(size: 16))
                                }
                                
                            }
                        }
                        .disabled(alreadyAdded.contains(where: { $0.id == Profile.id }))
                        .foregroundColor(alreadyAdded.contains(where: { $0.id == Profile.id }) ? .secondary : .primary)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                        
                    }
                }
                
                
            }
            .padding(.top,showGuest==true ? 0 : -45)
            .listSectionSpacing(0)
           
            .animation(.easeInOut, value: searchText)
            .navigationTitle(
                showPlayers == true && showFriends == true ? "Add Players" :
                    showFriends == false ? "Request Friend" :
                             "Edit Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                                ToolbarItem(placement:.cancellationAction){
                    Button("Cancel",systemImage:"xmark"){
                        showAddPlayersSheet = false
                    }
                }
            }
            
            
        }.searchable(text: $searchText)
        
    }
}


#Preview {
    AddPlayersSheetView(showAddPlayersSheet: .constant(true),addPlayer:.constant(exampleProfiles[0]),alreadyAdded:[],showGuest:true,showPlayers:true,showFriends: true,guestIndex:2)
}

