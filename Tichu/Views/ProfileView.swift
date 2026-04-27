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
    
    @AppStorage("testPic1") private var testPic1Data: Data?
    @AppStorage("testPic2") private var testPic2Data: Data?
    @AppStorage("testPic3") private var testPic3Data: Data?
    @AppStorage("testPic4") private var testPic4Data: Data?
    
    @AppStorage("testPic5") private var testPic5Data: Data?
    @AppStorage("testPic6") private var testPic6Data: Data?
    @AppStorage("testPic7") private var testPic7Data: Data?
    @AppStorage("testPic8") private var testPic8Data: Data?
     
    //Vars
    //Photo Logic
    @State private var showPhotoSheet: Bool = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    //Sheets and Alerts
    @State private var showNameSheet:Bool = false
    @State private var showFriendsSheet:Bool = false
    @State private var showPrivacyAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationStack{
            List {
                HStack{
                    Spacer()
                    VStack{
                        ZStack{
                            profileImage(selectedImage: selectedImage, size: 100)
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
                            /*Button(){
                                showNameSheet = true
                            }label:{
                                Image(systemName:"pencil").foregroundColor(.gray)
                                    .font(.system(size:25))
                            }.sheet(isPresented: $showNameSheet) {
                                NameSheetView(showNameSheet: $showNameSheet).presentationDetents([.medium])
                                
                            }*/
                        }
                            
                        
                        Text("Ranking: \(userElo)").foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .listRowBackground(Color.clear)
                
                Section{
                    HStack{
                        Image(systemName:"person").foregroundStyle(.accent)
                        
                        Button("Change Username"){
                            
                            showNameSheet = true
                            
                        }
                        .foregroundColor(.primary)
                        .sheet(isPresented: $showNameSheet) {
                            NameSheetView(showNameSheet: $showNameSheet).presentationDetents([.medium])
                            
                        }
                        
                    }
                    
                
                    HStack{
                        Image(systemName:"person.3").foregroundStyle(.accent).offset(x:-6)
                        
                        Button("Manage Friendlist"){
                            showFriendsSheet = true
                            
                            
                        }
                        .offset(x:-12)
                        .foregroundColor(.primary)
                        .sheet(isPresented: $showFriendsSheet) {
                        FriendsSheetView(showFriendsSheet: $showFriendsSheet).presentationDetents([.medium])
                            
                        }
                    }
                    
                        
                }
                    
                
                Section{
                    Button{
                        showDeleteAlert = true
                    }label: {
                        HStack{
                            Image(systemName:"trash").foregroundStyle(.red)
                            Text("Delete Account").foregroundColor(.primary)
                        }
                    }.alert("Do you really want to delete your Account?", isPresented: $showDeleteAlert, actions: {
                        Button(role: .destructive) {
                            } label: {
                                Text("Delete")
                            }
                            }, message: {
                                Text("All your data will be deleted and you won't have access to your Account anymore.")
                            })
                    
                    Button{
                        print("Log Out")
                    }label: {
                        HStack{
                            Image(systemName:"rectangle.portrait.and.arrow.right")
                            Text("Switch Account").foregroundColor(.primary)
                        }
                    }
                    Button{
                        print("Log out")
                    }label: {
                        HStack{
                            Image(systemName:"rectangle.portrait.and.arrow.right")
                            Text("Log Out").foregroundColor(.primary)
                        }
                    }
                    
                }
                Section{
                    HStack{
                        Image(systemName:"envelope").foregroundStyle(Color.accentColor)
                            .offset(x:-2)
                        Link("Contact", destination: URL(string: "mailto:straussl@student.ethz.ch")!).foregroundColor(.primary)
                        
                    }
                    
                    
                    
                    
                    HStack{
                        Image(systemName:"lock.shield.fill")
                            .foregroundStyle(.accent)
                          
                        Text("")
                        Button("Privacy"){
                            showPrivacyAlert = true
                        }
                        .foregroundColor(.primary)
                        .alert("Tichu App doesnt collect any Data!", isPresented: $showPrivacyAlert, actions: {
                            Button(role: .close) {
                            } label: {
                                Text("Cool!")
                            }
                        }, message: {
                            Text("We store only your Tichu Rounds and your Login data.")
                        })
                    }
                    HStack{
                        Image("github")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundStyle(Color.accentColor)
                            .offset(x:-2)
                        Link("Source Code", destination: URL(string: "https://github.com/LeonHTM/Tichu")!).foregroundColor(.primary)
                        
                    }
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
            .onAppear {
                selectedImage = dataToPhoto(data:userImageData)
                
                
            }
            
            
        }
                
        

    }
}

#Preview {
    ProfileView()
}
