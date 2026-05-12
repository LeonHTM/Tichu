//
//  ProfileView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    //Storage
    @AppStorage("userName") var userName: String = "Unknown"
    @AppStorage("userImageData") private var userImageData: Data?
    @AppStorage("userElo") var userElo: Int = 1000
    @AppStorage("dragMode") var dragMode: Bool = false
    @AppStorage("loggedIn") var loggedIn: Bool = true
    @Environment(\.openURL) var openURL
    //Vars
    //Photo Logic
    @State private var selectedPlayer: Profile?
    @State private var showPhotoSheet: Bool = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    //Sheets and Alerts
    @State private var showNameSheet:Bool = false
    @State private var showFriendsSheet:Bool = false
    @State private var showPrivacyAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var friendList: [Profile] = exampleFriends
    @State private var requestedFriendsList: [Profile] = [exampleGring]
    
    var body: some View {
        NavigationStack{
            List {
                HStack{
                    Spacer()
                    VStack{
                        ZStack{
                            ProfileImage(data:userImageData, size: 100)
                                .shadow(radius: 10)
                            
                            PhotosPicker(selection: $pickerItem,
                                         matching: .images) {
                                Image(systemName:"camera.fill")
                                  
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    .foregroundColor(.primary)
                                    
                                    .glassEffect(.regular.interactive())
                                    .offset(y:32)
                                
                            }.onChange(of: pickerItem) { _, newItem in
                                guard let newItem else { return }
                                Task {
                                    if let data = try? await newItem.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        await MainActor.run {
                                            self.selectedImage = uiImage
                                            self.userImageData = uiImage.jpegData(compressionQuality: 1)
                                        }
                                    }

                                }
                            }
                            
                            
                        }
                        
                        HStack{
                            Text(userName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                         
                        }
                            
                        
                        Text("Ranking: \(userElo)").foregroundStyle(.gray).fontWeight(.bold)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
                
                Section{
                    HStack{
                        Button{
                            withAnimation(.easeInOut(duration: 0.285)) {
                                showNameSheet = true
                            }
                        }label:{
                            HStack{
                                Label("Edit Username",systemImage:"person.fill").labelStyle(ColorfulIconLabelStyle(color: .gray, fontSize: 17))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(showNameSheet ? 90 : 0))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                        .sheet(isPresented: $showNameSheet) {
                            NameSheetView(showNameSheet: $showNameSheet).presentationDetents([.medium])
                            
                        }.animation(.easeInOut(duration: 0.285), value: showNameSheet)
                        
                    }
                    
        
                        
                        Button{
                            withAnimation(.easeInOut(duration: 0.285)) {
                                showFriendsSheet = true
                            }
                            
                        }label:{
                            HStack{
                                Label("Manage Friends",systemImage:"person.2.fill").labelStyle(ColorfulIconLabelStyle(color: .gray, fontSize: 13))
                                Spacer()
                                if requestedFriendsList.count > 0{
                                    
                                    Text("\(requestedFriendsList.count)").foregroundStyle(.white).background{
                                        
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 24, height: 24)
                                        
                                        
                                    }.padding(.trailing)
                                }
                              
                                Image(systemName:"chevron.right").foregroundStyle(.secondary)
                                    .rotationEffect(.degrees(showFriendsSheet ? 90 : 0))
                            }
                            
                        }.foregroundStyle(Color.primary)
                        .sheet(isPresented: $showFriendsSheet) {
                            EditFriendsSheetView(showFriendsSheet: $showFriendsSheet, friendsList: $friendList,requestedFriendsList: $requestedFriendsList).presentationDetents([.medium,.large])
                            
                            
                        }.animation(.easeInOut(duration: 0.285), value: showFriendsSheet)
                        
                    
                    
                        
                }
                /*Section{
                   
                    HStack{
                        Image("exclamationmark.3.circle").foregroundStyle(Color.accentColor)
                        Toggle(isOn:$dragMode){
                            Text("Drag-Mode")
                        }
                    }
                }*/
                
                
                Section{
                    
                    
                    
                    
                    
                    HStack{
                        
        
                        Button{
                            withAnimation(.easeInOut(duration: 0.285)) {
                                showPrivacyAlert = true
                            }
                        }label:{
                            HStack{
                                Label("Privacy", systemImage: "hand.raised.fill").labelStyle(ColorfulIconLabelStyle(color: .blue, fontSize: 15))
                                Spacer()
                                Image(systemName:"chevron.right").foregroundStyle(.secondary)
                                    .rotationEffect(.degrees(showPrivacyAlert ? 90 : 0))
                                
                               
                            }
                        }
                        .foregroundColor(.primary)
                        .alert("Tichu App doesnt collect any Data!", isPresented: $showPrivacyAlert, actions: {
                            Button(role: .cancel) {
                                withAnimation(.easeInOut(duration: 0.285)) {
                                    showPrivacyAlert = false
                                    print("Privacy alert dismissed")
                                }
                            } label: {
                                Text("Cool!")
                            }
                        }, message: {
                            Text("We store only your Tichu Rounds and your Login data.")
                        })
                    }
                    Button{
                        if let url = URL(string: "mailto:straussl@student.ethz.ch") {
                            UIApplication.shared.open(url)
                                    }
                    }label:{
                        HStack{
                            Label("Contact",systemImage:"envelope.fill").labelStyle(ColorfulIconLabelStyle(color: .blue, fontSize: 14))
                          
                        }.foregroundStyle(Color.primary)
                    }
                    Button{
                        if let url = URL(string: "https://github.com/LeonHTM/Tichu") {
                                        UIApplication.shared.open(url)
                                    }
                    }label:{
                        HStack{
                            
                            Label("Source Code",image:"github").labelStyle(ColorfulIconLabelStyle(color: .black, fontSize: 17))
                            
                        
                        }
                    }.foregroundStyle(.primary)
                }
                Section{
                    
                    
                    Button{
                        withAnimation(.easeInOut(duration: 0.285)) {
                            print("Log Out")
                        }
                    }label: {
                        HStack{
                            Label("Switch Account",systemImage:"rectangle.portrait.and.arrow.right.fill").labelStyle(ColorfulIconLabelStyle(color: .accentColor, fontSize: 13))
                            Spacer()
                            Image(systemName:"chevron.right").foregroundStyle(.secondary)
                                .rotationEffect(.degrees(showFriendsSheet ? 90 : 0))
                        }.foregroundStyle(Color.primary)
                    }
                    Button{
                        withAnimation(.easeInOut(duration: 0.285)) {
                            print("Log out")
                        }
                    }label: {
                        HStack{
                            Label("Log Out",systemImage:"rectangle.portrait.and.arrow.right.fill").labelStyle(ColorfulIconLabelStyle(color: .accentColor, fontSize: 13))
                            Spacer()
                            Image(systemName:"chevron.right").foregroundStyle(.secondary)
                        }.foregroundColor(.primary)
                    }
                    
                    
                }
                Section{
                    Button{
                        withAnimation(.easeInOut(duration: 0.285)) {
                            showDeleteAlert = true
                        }
                    }label: {
                        HStack{
                            Label("Delete Account",systemImage:"trash.fill").labelStyle(ColorfulIconLabelStyle(color: .red, fontSize: 14)).foregroundStyle(Color.red)
                            Spacer()
                            Image(systemName:"chevron.right")
                                .rotationEffect(.degrees(showDeleteAlert ? 90 : 0)).foregroundStyle(.secondary)
                        }
                    }.foregroundStyle(.secondary).alert("Do you really want to delete your Account?",
                            isPresented: $showDeleteAlert,
                            actions: {
                        
                        Button(role: .destructive) {
                            // perform delete
                            withAnimation(.easeInOut(duration: 0.285)) {
                                showDeleteAlert = false
                                loggedIn = false
                                print("Alert dismissed")
                            }
                        } label: {
                            Text("Delete")
                        }

                        Button(role: .cancel) {
                            withAnimation(.easeInOut(duration: 0.285)) {
                                showDeleteAlert = false
                                print("Alert dismissed")
                            }
                        }

                    }, message: {
                        Text("All your data will be deleted and you won't have access to your Account anymore.")
                    })
                }
                HStack{
                    Spacer()
                    VStack{
                        Text("Made with ❤️ in Bern")
                        Text("Version 0.1 Build 1")
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                }.listRowBackground(Color.clear)
            }
            .padding(.top,-20)
            .navigationTitle("Profile")
            .toolbarTitleDisplayMode(.inlineLarge)
            
            
            
        }
                
        

    }
}

#Preview {
    ProfileView()
}

