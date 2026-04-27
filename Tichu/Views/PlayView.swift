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
    
    @State private var player2: profile = emptyProfile
    @State private var player3: profile  = emptyProfile
    @State private var player4: profile  = emptyProfile
    
    @State private var showAddPlayersSheet2:Bool = false
    @State private var showAddPlayersSheet3:Bool = false
    @State private var showAddPlayersSheet4:Bool = false
    
    @State private var showEditRoundsSheet: Bool = false
    @State private var showAddRoundSheet: Bool = false
    
    @State private var currentGame: tichuGame = exampleGame
    
    private var isGameReady:Bool{
        player2.id != emptyProfile.id && player3.id != emptyProfile.id && player4.id != emptyProfile.id
    }
    
    var body: some View {
        ZStack{
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
                                Text("Ranking: \(userElo)")
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
                                    if let elo = player2.elo {
                                        Text("Ranking: \(elo)")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }else{
                                        Text("Download Tichu App to get ranked")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }
                                 
                                    
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
                                    .padding(.vertical,10.6)
                                    .sheet(isPresented: $showAddPlayersSheet2) {
                                        AddPlayersSheetView(showAddPlayersSheet:  $showAddPlayersSheet2,addPlayer:$player2,alreadyAdded:[player3,player4],showGuest:true).presentationDetents([.medium,.large])
                                        
                                    }
                                    
                                    
                                    
                                    
                                }
                                
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
                            
                            Spacer()
                            
                        }.padding(.vertical,isGameReady ? 37 : 60)
                    }.listRowBackground(Color.clear)
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
                                    if let elo = player3.elo {
                                        Text("Ranking: \(elo)")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }else{
                                        Text("Download Tichu App to get ranked")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }
                                    
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
                                    
                                    
                                    
                                }.fontWeight(.bold).foregroundColor(.primary).padding(.vertical,10.6).sheet(isPresented: $showAddPlayersSheet3) {
                                    AddPlayersSheetView(showAddPlayersSheet:  $showAddPlayersSheet3,addPlayer:$player3,alreadyAdded:[player2,player4],showGuest:true).presentationDetents([.medium,.large])
                                    
                                }
                                
                                Spacer()
                                
                            }
                            
                        }
                        if let name4 = player4.name {
                            
                            HStack{
                                VStack(alignment:.leading){
                                    
                                    Text(name4).fontWeight(.bold)
                                    if let elo = player4.elo {
                                        Text("Ranking: \(elo)")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }else{
                                        Text("Download Tichu App to get ranked")
                                            .foregroundStyle(.secondary)
                                            .font(.system(size: 16))
                                    }
                                    
                                }
                                Spacer()
                                if let data = player4.imageData,
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
                                    .fontWeight(.bold).foregroundColor(.primary)
                                    .sheet(isPresented: $showAddPlayersSheet4) {
                                        AddPlayersSheetView(showAddPlayersSheet:  $showAddPlayersSheet4,addPlayer:$player4,alreadyAdded:[player2,player3],showGuest:true).presentationDetents([.medium,.large])
                                        
                                    }
                                    
                                    
                                    
                                }.padding(.vertical,10.6)
                                
                                Spacer()
                                
                            }
                            
                        }
                    }
                    
                }
                .scrollContentBackground(.hidden)
                .background(alignment: .center) {
                    HStack{
                Text("V")
                    .font(.system(size: 120, weight: .bold))
                    .offset(y:-3)
                        Text("S")
                    .font(.system(size: 120, weight: .bold))
                    .offset(x:-15,y:3)
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.red, Color.green],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .allowsHitTesting(false)
                }.background(Color(uiColor: .systemGroupedBackground))
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
        }.refreshable {
            
        }.safeAreaInset(edge:.bottom){
            if isGameReady == true{
                GlassEffectContainer{
                    HStack{
                        Button(){
                            showEditRoundsSheet = true
                        }label:{
                            Image(systemName: "list.bullet.badge.ellipsis")
                                .font(.system(size: 20)).foregroundColor(.primary)
                                .frame(width: 29, height: 29)
                                .clipShape(Circle())
                        }.padding(10).glassEffect(.regular.interactive()).padding(.leading,20).padding(.bottom,10)
                            .sheet(isPresented: $showEditRoundsSheet) {
                                EditRoundsSheetView(showEditRoundsSheet: $showEditRoundsSheet,currentGame:$currentGame).presentationDetents([.medium,.large])
                                
                            }
                        Spacer()
                        Button(){
                            
                        }label:{
                            
                            Image(systemName: "plus")
                                .font(.system(size: 20)).foregroundColor(.primary)
                            Text("Add Round").foregroundColor(.primary)
                        }.padding(13).glassEffect(.regular.interactive()).padding(.trailing,20).padding(.bottom,10)
                    }
                }
            }
        }.onAppear{
            userImage = dataToPhoto(data:userImageData)
        }
    }
       
       
 
        
        
                    
                
            
            
        
        }
        
           
    


#Preview {
    PlayView()
}

