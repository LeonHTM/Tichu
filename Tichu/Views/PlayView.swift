//
//  PlayView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI

struct PlayView: View {
    //Storage Usernames
    @AppStorage("userName") var userName: String = "Unknown"
    @AppStorage("player2Name") var player2Name: String = "Add Player 2"
    @AppStorage("player3Name") var player3Name: String = "Add Player 3"
    @AppStorage("player4Name") var player4Name: String = "Add Player 4"
    
    //Sotrages Images
    @AppStorage("userImageData") private var userImageData: Data?
    @AppStorage("player2ImageData") private var player2ImageData: Data?
    @AppStorage("player3ImageData") private var player3ImageData: Data?
    @AppStorage("player4ImageData") private var player4ImageData: Data?
    
    //Storage Elos
    @AppStorage("userElo") var userElo: Int = 1000
    @AppStorage("player2Elo") var player2Elo: Int = -69420
    @AppStorage("player3Elo") var player3Elo: Int = -69420
    @AppStorage("player4Elo") var player4Elo: Int = -69420
    
    //Vars
    @State private var userImage: UIImage?
    @State private var player2Image: UIImage?
    @State private var player3Image: UIImage?
    @State private var player4Image: UIImage?
    
    @State private var player2: Profile = emptyProfile
    @State private var player3: Profile  = emptyProfile
    @State private var player4: Profile  = emptyProfile
    
    @State private var showAddPlayersSheet2:Bool = false
    @State private var showAddPlayersSheet3:Bool = false
    @State private var showAddPlayersSheet4:Bool = false
    
    var body: some View {
        NavigationStack{
            
            List{
                Section{Text("Team 1")
                        .font(.title2)
                        .fontWeight(.bold)
                        .listRowBackground(Color.clear)}
                Section{
                    HStack{
                    VStack(alignment:.leading){
                        Text(userName)
                            .fontWeight(.bold)
                        Text("Elo: \(userElo)")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16))
                    }
                    Spacer()
                    profileImage(selectedImage: userImage, size: 44)
                }
                    if let name2 = player2.name {
                        
                        HStack{
                            VStack(alignment:.leading){
                                
                                Text(name2).fontWeight(.bold)
                                Text("Elo: \(player2Elo)")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 16))
                                
                            }
                            Spacer()
                            if let data = player2.imageData,
                               let uiImage = UIImage(data: data) {
                                profileImage(selectedImage: uiImage, size: 44)
                            } else {
                                profileImage(selectedImage: nil, size: 44)
                            }
                            
                        }
                    }else{
                        HStack{
                            Spacer()
                            Image(systemName:"plus.circle.fill")
                            
                            VStack(alignment:.leading){
                            
                                
                                Button("Add Player 2"){
                                    showAddPlayersSheet2 = true
                                }
                                .fontWeight(.bold).foregroundColor(.primary)
                                .sheet(isPresented: $showAddPlayersSheet2) {
                                    AddPlayersSheetView(showAddPlayersSheet:  $showAddPlayersSheet2,addPlayer:$player2,showGuest:true).presentationDetents([.medium,.large])
                                    
                                }
                                
                                
                               
                                
                            }.padding(.vertical,10.6)
                            
                            Spacer()
                            
                        }
                        
                    }
                    
                    
                    
                }
                Section{
                    Spacer()
                }.listRowBackground(Color.clear)
                Section{
                    HStack{
                    Spacer()
                    Text("VS").font(.title2).fontWeight(.bold)
                    Spacer()
                        
                }.padding(.vertical,50)}
                Section{
                    Spacer()
                }.listRowBackground(Color.clear)
                
                Section{Text("Team 2")
                        .font(.title2)
                        .fontWeight(.bold)
                        .listRowBackground(Color.clear)}
                Section{
                    if let name3 = player3.name  {
                    
                    HStack{
                        VStack(alignment:.leading){
                            
                            Text(name3).fontWeight(.bold)
                            Text("Elo: \(player3Elo)")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 16))
                            
                        }
                        Spacer()
                        if let data = player3.imageData,
                           let uiImage = UIImage(data: data) {
                            profileImage(selectedImage: uiImage, size: 44)
                        } else {
                            profileImage(selectedImage: nil, size: 44)
                        }
                        
                    }
                }else{
                    HStack{
                        Text("")
                        Spacer()
                        Image(systemName:"plus.circle.fill")
                        
                        VStack(alignment:.leading){
                            
                            
                            Button("Add Player 3"){showAddPlayersSheet3 = true}.fontWeight(.bold).foregroundColor(.primary)
                            
                            
                            
                        }.padding(.vertical,10.6).sheet(isPresented: $showAddPlayersSheet3) {
                            AddPlayersSheetView(showAddPlayersSheet:  $showAddPlayersSheet3,addPlayer:$player3,showGuest:true).presentationDetents([.medium,.large])
                            
                        }
                        
                        Spacer()
                        
                    }
                    
                }
                    if let name4 = player4.name {
                                       
                                       HStack{
                                           VStack(alignment:.leading){
                                               
                                               Text(name4).fontWeight(.bold)
                                               Text("Elo: \(player4Elo)")
                                                   .foregroundStyle(.secondary)
                                                   .font(.system(size: 16))
                                               
                                           }
                                           Spacer()
                                           if let data = player2.imageData,
                                              let uiImage = UIImage(data: data) {
                                               profileImage(selectedImage: uiImage, size: 44)
                                           } else {
                                               profileImage(selectedImage: nil, size: 44)
                                           }
                                           
                                       }
                                   }else{
                                       HStack{
                                           Spacer()
                                           Image(systemName:"plus.circle.fill")
                                           
                                           VStack(alignment:.leading){
                                           
                                               
                                               Button("Add Player 4"){
                                                   showAddPlayersSheet4 = true
                                               }
                                               .sheet(isPresented: $showAddPlayersSheet4) {
                                                   AddPlayersSheetView(showAddPlayersSheet:  $showAddPlayersSheet4,addPlayer:$player4,showGuest:true).presentationDetents([.medium,.large])
                                                   
                                               }.fontWeight(.bold).foregroundColor(.primary)
                                               
                                              
                                               
                                           }.padding(.vertical,10.6)
                                           
                                           Spacer()
                                           
                                       }
                                       
                                   }
                }
                
            }
            .listSectionSpacing(0)
            .padding(.top,-40)
                .navigationTitle("Play")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar{
                        ToolbarItem(placement:.topBarTrailing){
                            profileImage(selectedImage: userImage, size: 44)
                                
                        }.sharedBackgroundVisibility(.hidden)
                            
                    }
            
            
               
        }
       
        
        .onAppear {
            userImage = dataToPhoto(data:userImageData)
        }
        
                    
                
            
            
        
        }
        
           
    }


#Preview {
    PlayView()
}
