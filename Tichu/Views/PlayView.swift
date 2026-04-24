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
    
    @State private var showAddPlayersSheet:Bool = false
    
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
                    if player2Elo != -69420 {
                        
                        HStack{
                            VStack(alignment:.leading){
                                
                                Text(player2Name)
                                Text("Elo: \(player2Elo)")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 16))
                                
                            }
                            Spacer()
                            profileImage(selectedImage: player2Image, size: 44)
                            
                        }
                    }else{
                        HStack{
                            Spacer()
                            Image(systemName:"plus.circle.fill")
                            
                            VStack(alignment:.leading){
                            
                                
                                Button("Add Player 2"){
                                    showAddPlayersSheet = true
                                }
                                .fontWeight(.bold).foregroundColor(.primary)
                                
                                
                               
                                
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
                    if player3Elo != -69420 {
                    
                    HStack{
                        VStack(alignment:.leading){
                            
                            Text(player3Name)
                            Text("Elo: \(player3Elo)")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 16))
                            
                        }
                        Spacer()
                        profileImage(selectedImage: player3Image, size: 44)
                        
                    }
                }else{
                    HStack{
                        Text("")
                        Spacer()
                        Image(systemName:"plus.circle.fill")
                        
                        VStack(alignment:.leading){
                            
                            
                            Button("Add Player 3"){showAddPlayersSheet = true}.fontWeight(.bold).foregroundColor(.primary)
                            
                            
                            
                        }.padding(.vertical,10.6)
                        
                        Spacer()
                        
                    }
                    
                }
                    if player4Elo != -69420 {
                                       
                                       HStack{
                                           VStack(alignment:.leading){
                                               
                                               Text(player4Name)
                                               Text("Elo: \(player4Elo)")
                                                   .foregroundStyle(.secondary)
                                                   .font(.system(size: 16))
                                               
                                           }
                                           Spacer()
                                           profileImage(selectedImage: player4Image, size: 44)
                                           
                                       }
                                   }else{
                                       HStack{
                                           Spacer()
                                           Image(systemName:"plus.circle.fill")
                                           
                                           VStack(alignment:.leading){
                                           
                                               
                                               Button("Add Player 4"){
                                                   showAddPlayersSheet = true
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
        .sheet(isPresented: $showAddPlayersSheet) {
            AddPlayersSheetView(showAddPlayersSheet:  $showAddPlayersSheet,showGuest:true).presentationDetents([.medium,.large])
            
        }
        
        .onAppear {
            userImage = dataToPhoto(data:userImageData)
        }
        
                    
                
            
            
        
        }
        
           
    }


#Preview {
    PlayView()
}
