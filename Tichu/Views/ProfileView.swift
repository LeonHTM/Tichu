//
//  ProfileView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {

    // MARK: - Storage
    @AppStorage("userId") var userId: Int = -69420
    @AppStorage("userImageData") var userImageData: Data?
    @AppStorage("userName") var userName: String = "Unknown"
    @AppStorage("userElo") var userElo: Int = 1000
    @AppStorage("selectedTab") private var selectedTab = 0
    
    // MARK: - Photo Picker
    @State private var pickerItem: PhotosPickerItem?
    @State private var isUploadingImage: Bool = false
    
    @ObservedObject private var network = NetworkService.shared
    @StateObject private var socket = SocketService.shared


  
    
    // MARK: - Sheet & Alert Presentation
    @State private var showNameSheet: Bool = false
    @State private var showFriendsSheet: Bool = false
    @State private var showPrivacyAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showOfflineAlert: Bool = false
    @State private var showImageFailAlert: Bool = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                profileHeaderSection
                accountSection
                supportSection
                authSection
                deleteAccountSection
                footerSection
            }.alert(isPresented:$showOfflineAlert){
                offlineView.offlineAlert()
            }
            .padding(.top, -20)
            .navigationTitle("Profile")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
    }

    // MARK: - Profile Header
    private var profileHeaderSection: some View {
        HStack {
            Spacer()
            VStack {
                ZStack {
                    if socket.connected {
                        ZStack{
                            ProfileImage(data: network.profileImages[userId], size: 100)
                                .shadow(radius: 10)
                                .allowsHitTesting(false)
                            if isUploadingImage{
                                ProgressView().scaleEffect(2)
                            }
                        }
                    }else{
                        ProfileImage(data: userImageData, size: 100)
                            .shadow(radius: 10)
                            .allowsHitTesting(false)
                    }
                    
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Image(systemName: "camera.fill")
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                            .foregroundColor(.primary)
                            .glassEffect(.regular.interactive())
                            .offset(y: 32)
                    }.disabled(!socket.connected).onChange(of: pickerItem) {
                        isUploadingImage = true
                        Task {
                            guard let pickerItem else {
                                showImageFailAlert = true
                                isUploadingImage = false
                                return
                            }
                            
                            if let data = try? await pickerItem.loadTransferable(type: Data.self) {
                                
                                await network.uploadProfileImage(profileId: userId, imageData: UIImage(data: data)!.jpegData(compressionQuality: 0.7)!)
                                
                                
                            }else{
                                showImageFailAlert = true
                                isUploadingImage = false
                            }
                            isUploadingImage = false
                            
                        }
                    }.alert(isPresented:$showImageFailAlert){
                        Alert(
                            title: Text("Could not upload Profile Picture"),
                            message: Text("Please try again later"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                      
                }
                 
                if socket.connected{
                    Text(network.profiles.first { $0.id == userId }?.name ?? "Unknown")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .allowsHitTesting(false)
                    
                    Text("\(network.profiles.first { $0.id == userId }?.elo ?? 1000)")
                        .foregroundStyle(.gray)
                        .fontWeight(.bold)
                        .allowsHitTesting(false)
                }else{
                    Text(userName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .allowsHitTesting(false)
                    
                    Text("\(userElo)")
                        .foregroundStyle(.gray)
                        .fontWeight(.bold)
                        .allowsHitTesting(false)
                }
            }
            Spacer()
        }
        .listRowBackground(Color.clear)
    }

    // MARK: - Account Section
    private var accountSection: some View {
        Section {
            Button {
                withAnimation(.easeInOut(duration: 0.285)) {
                if socket.connected{
                    
                        showNameSheet = true
                        
                    }else{
                        showOfflineAlert = true
                    }
                }
            } label: {
                HStack {
                    Label("Edit Username", systemImage: "person.fill")
                        .labelStyle(ColorfulIconLabelStyle(color: .gray, fontSize: 17))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(showNameSheet ? 90 : 0))
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundColor(.primary)
            .sheet(isPresented: $showNameSheet) {
                NameSheetView(showNameSheet: $showNameSheet,email: "",editMode:true,done:.constant(true))
                    .presentationDetents([.large])
            }

            Button {
                withAnimation(.easeInOut(duration: 0.285)) {
                    if socket.connected{
                        showFriendsSheet = true
                    }else{
                        showOfflineAlert = true
                    }
                }
            } label: {
                HStack {
                    Label("Manage Friends", systemImage: "person.2.fill")
                        .labelStyle(ColorfulIconLabelStyle(color: .gray, fontSize: 13))
                    Spacer()
                    if network.friendRequestProfiles.count > 0 {
                        Text("\(network.friendRequestProfiles.count)")
                            .foregroundStyle(.white)
                            .background {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 24, height: 24)
                            }
                            .padding(.trailing)
                    }
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(showFriendsSheet ? 90 : 0))
                }
            }
            .foregroundStyle(.primary)
            .sheet(isPresented: $showFriendsSheet) {
                EditFriendsSheetView(
                    showFriendsSheet: $showFriendsSheet
                
                )
                .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - Support Section
    private var supportSection: some View {
        Section {
            Button {
                withAnimation(.easeInOut(duration: 0.285)) {
                    showPrivacyAlert = true
                }
            } label: {
                HStack {
                    Label("Privacy", systemImage: "hand.raised.fill")
                        .labelStyle(ColorfulIconLabelStyle(color: .blue, fontSize: 15))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(showPrivacyAlert ? 90 : 0))
                }
            }
            .foregroundColor(.primary)
            .alert("Tichu App doesnt collect any Data!", isPresented: $showPrivacyAlert) {
                Button(role: .cancel) {
                    withAnimation(.easeInOut(duration: 0.285)) {
                        
                        showPrivacyAlert = false
                    }
                } label: {
                    Text("Cool!")
                }
            } message: {
                Text("We store only your Tichu Rounds and your Login data.")
            }

            Button {
                if let url = URL(string: "mailto:straussl@student.ethz.ch") {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack {
                    Label("Contact", systemImage: "envelope.fill")
                        .labelStyle(ColorfulIconLabelStyle(color: .blue, fontSize: 14))
                }
                .foregroundStyle(Color.primary)
            }

            Button {
                if let url = URL(string: "https://github.com/LeonHTM/Tichu") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("Source Code", image: "github")
                    .labelStyle(ColorfulIconLabelStyle(color: .black, fontSize: 17))
            }
            .foregroundStyle(Color.primary)
        }
    }

    // MARK: - Auth Section
    private var authSection: some View {
        Section {
            Button {
                withAnimation(.easeInOut(duration: 0.285)) {
                    if socket.connected{
                        userId = -69420
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            userId = 15
                            selectedTab = -1
                            
                        }
                    }else{
                        showOfflineAlert = true
                    }
                }
            } label: {
                HStack {
                    Label("Switch Account", systemImage: "rectangle.portrait.and.arrow.right.fill")
                        .labelStyle(ColorfulIconLabelStyle(color: .accentColor, fontSize: 13))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(showFriendsSheet ? 90 : 0))
                }
                .foregroundStyle(Color.primary)
            }

            Button {
                withAnimation(.easeInOut(duration: 0.285)) {
                    if socket.connected{
                        userId = -69420
                    }else{
                        showOfflineAlert = true
                    }
                }
            } label: {
                HStack {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right.fill")
                        .labelStyle(ColorfulIconLabelStyle(color: .accentColor, fontSize: 13))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .foregroundColor(.primary)
            }
        }
    }

    // MARK: - Delete Account Section
    private var deleteAccountSection: some View {
        Section {
            Button {
                withAnimation(.easeInOut(duration: 0.285)) {
                    if socket.connected{
                        showDeleteAlert = true
                    }else{
                        showOfflineAlert = true
                    }
                }
            } label: {
                HStack {
                    Label("Delete Account", systemImage: "trash.fill")
                        .labelStyle(ColorfulIconLabelStyle(color: .red, fontSize: 14))
                        .foregroundStyle(.red)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(showDeleteAlert ? 90 : 0))
                }
            }
            .foregroundStyle(.secondary)
            .alert("Do you really want to delete your Account?", isPresented: $showDeleteAlert) {
                Button(role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.285)) {
                        Task{
                            await network.deleteProfile(profileId: userId)
                            userId = -69420
                        }
                        showDeleteAlert = false
                    
                    }
                } label: {
                    Text("Delete")
                }
                Button(role: .cancel) {
                    withAnimation(.easeInOut(duration: 0.285)) {
                        showDeleteAlert = false
                    }
                }
            } message: {
                Text("All your data will be deleted and you won't have access to your Account anymore.")
            }
        }
    }

    // MARK: - Footer
    private var footerSection: some View {
        HStack {
            Spacer()
            VStack {
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    Text("Made with ❤️ in Bern")
                    Text("Version \(version) Build \(build)")
                        .foregroundStyle(.gray)
                }
            }
            Spacer()
        }
        .listRowBackground(Color.clear)
    }
}

#Preview {
    ProfileView()
}
