//
//  ProfileView.swift
//  Tichu
//
//  Created by Leon on 21.04.2026.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Namespace private var profileSpace

    // MARK: - Storage
    @AppStorage("userId") var userId: Int = -69420
    @AppStorage("userImageData") var userImageData: Data?
    @AppStorage("userName") var userName: String = "Storage - Unknown"
    @AppStorage("userElo") var userElo: Double = 404
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
        }.onReceive(NotificationCenter.default.publisher(for: .openFriendsSheet)) { _ in
            if socket.connected{
                showFriendsSheet = true
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeaderSection: some View {
        HStack {
            Spacer()
            VStack {
                ZStack {
                    ZStack{
                        ProfileImage(data: userImageData, size: 100)
                            .shadow(radius: 10)
                            .allowsHitTesting(false)
                        if isUploadingImage{
                            ProgressView().scaleEffect(2)
                        }
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
                                await network.uploadProfileImage(profileId: userId, imageData: data)
                            } else {
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
                Text("\(userName)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .allowsHitTesting(false)
                Text("\(Int(userElo))")
                    .foregroundStyle(.gray)
                    .fontWeight(.bold)
                    .allowsHitTesting(false)
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
                    if socket.connected {
                        showNameSheet = true
                    } else {
                        showOfflineAlert = true
                    }
                }
            } label: {
                HStack {
                    Label("Edit Username", systemImage: "person.fill")
                        .labelStyle(ColorfulIconLabelStyle(color: .gray, fontSize: 17))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.tertiary)
                            .padding(.trailing,1.2)
                        .rotationEffect(.degrees(showNameSheet ? 90 : 0))
                }
            }
            .foregroundColor(.primary)
            .sheet(isPresented: $showNameSheet) {
                NameSheetView(showNameSheet: $showNameSheet, email: "", editMode: true, done: .constant(true))
                    .presentationDetents([.large])
            }

            Button {
                withAnimation(.easeInOut(duration: 0.285)) {
                    if socket.connected {
                        showFriendsSheet = true
                    } else {
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
                        .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.tertiary)
                            .padding(.trailing,1.2)
                        .rotationEffect(.degrees(showFriendsSheet ? 90 : 0))
                }
            }
            .foregroundStyle(.primary)
            .sheet(isPresented: $showFriendsSheet) {
                EditFriendsSheetView(showFriendsSheet: $showFriendsSheet)
                    .presentationDetents([.medium, .large])
            }
            
            NavigationLink {
                GameSettingsView()
            } label: {
                Label("Game Settings", systemImage: "gamecontroller.fill")
                    .labelStyle(ColorfulIconLabelStyle(color: .accentColor, fontSize: 11))
            }
            .foregroundStyle(.primary)
            
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
                        .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.tertiary)
                            .padding(.trailing,1.2)
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
                let subject = "Tichu App Support"
                let osVersion = ProcessInfo.processInfo.operatingSystemVersion
                let iosVersion = "\(osVersion.majorVersion).\(osVersion.minorVersion)"
                let iosBuild = ProcessInfo.processInfo.operatingSystemVersionString
                    .components(separatedBy: " ")
                    .last?
                    .trimmingCharacters(in: CharacterSet(charactersIn: "()")) ?? "Unknown"
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

                let body = """
                    
                    
                    
                    App Version: \(appVersion) (\(buildNumber))
                    iOS: \(iosVersion) (\(iosBuild))
                    Device: \(deviceModelName())
                    User ID: \(userId)356af6d-ec96-49e1-a7e8-e372ce3c6363
                    """
                let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let url = URL(string: "mailto:leon@tichu.dev?subject=\(encodedSubject)&body=\(encodedBody)") {
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
            /*Button {
                withAnimation(.easeInOut(duration: 0.285)) {
                    if socket.connected {
                        Task {
                            await network.logout(profileId: userId)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            Task {
                                await network.login(userId: 2)
                            }
                        }
                    } else {
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
            }*/

            Button {
                withAnimation(.easeInOut(duration: 0.285)) {
                    if socket.connected {
                        Task {
                            await network.logout(profileId: userId)
                        }
                    } else {
                        showOfflineAlert = true
                    }
                }
            } label: {
                HStack {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right.fill")
                        .labelStyle(ColorfulIconLabelStyle(color: .accentColor, fontSize: 13))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.tertiary)
                            .padding(.trailing,1.2)
                      
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
                    if socket.connected {
                        showDeleteAlert = true
                    } else {
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
                        .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.tertiary)
                            .padding(.trailing,1.2)
                        .rotationEffect(.degrees(showFriendsSheet ? 90 : 0))
                }
            }
            .foregroundStyle(.secondary)
            .alert("Do you really want to delete your Account?", isPresented: $showDeleteAlert) {
                Button(role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.285)) {
                        Task {
                            await network.deleteProfile(profileId: userId)
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

// MARK: - Game Settings View
struct GameSettingsView: View {
    @AppStorage("defaultTarget") private var defaultTarget: Int = 1000
    @AppStorage("defaultAllowPingus") private var defaultAllowPingus: Bool = true
    @AppStorage("dragMode") var dragMode: Bool = false
    @AppStorage("userId") private var userId: Int = -69420
    @AppStorage("showAllPlayers") private var showAllPlayers: Bool = false
    private let network = NetworkService.shared

    var body: some View {
        List {
            Section {
                Picker("Default Target", selection: $defaultTarget) {
                    Text("250").tag(250)
                    Text("500").tag(500)
                    Text("1000").tag(1000)
                    Text("2000").tag(2000)
                    Text("10000").tag(10000)
                }
                Toggle("Show drunken Pingus", isOn: $defaultAllowPingus)
                Toggle("Drag Mode", isOn: $dragMode)
            } header: {
                Text("Game - Defaults")
            } footer: {
                Text("When adding a round instead of tapping on Players to set their order, drag them in a list.")
            }

            Section {
                Toggle("Show All Players", isOn: $showAllPlayers)
            } header: {
                Text("Players - Defaults")
            }footer: {
                Text("Always show all Players when viewing Players in the app, even when they are not avialable because they are in a game, being already compared or already a friend.")
            }

            Section("How to Play?") {
                NavigationLink {
                    TichuRulesPDFView()
                } label: {
                    Label("Official Tichu Rules", systemImage: "book.fill")
                        .labelStyle(ColorfulIconLabelStyle(color: .green, fontSize: 14))
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Game Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: defaultTarget) { _, newValue in
            Task {
                await network.updateProfileSettings(
                    profileId: userId,
                    target: newValue,
                    showPingu: defaultAllowPingus,
                    dragMode: dragMode,
                    showAllPlayers: showAllPlayers
                )
            }
        }
        .onChange(of: defaultAllowPingus) { _, newValue in
            Task {
                await network.updateProfileSettings(
                    profileId: userId,
                    target: defaultTarget,
                    showPingu: newValue,
                    dragMode: dragMode,
                    showAllPlayers: showAllPlayers
                )
            }
        }
        .onChange(of: dragMode) { _, newValue in
            Task {
                await network.updateProfileSettings(
                    profileId: userId,
                    target: defaultTarget,
                    showPingu: defaultAllowPingus,
                    dragMode: newValue,
                    showAllPlayers: showAllPlayers
                )
            }
        }
        
        .onChange(of: showAllPlayers) { _, newValue in
            Task {
                await network.updateProfileSettings(
                    profileId: userId,
                    target: defaultTarget,
                    showPingu: defaultAllowPingus,
                    dragMode: dragMode,
                    showAllPlayers: newValue
                )
            }
        }
    }
}

import SwiftUI
import PDFKit

struct TichuRulesPDFView: View {
    var body: some View {
        PDFKitView()
            .ignoresSafeArea(edges: .bottom)  // ← extend to bottom edge
            .navigationTitle("Tichu Rules")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PDFKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()

        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .systemBackground
        pdfView.displayBox = .cropBox

        if let url = Bundle.main.url(
            forResource: "spielregeln-tichu",
            withExtension: "pdf"
        ) {
            pdfView.document = PDFDocument(url: url)
        }

        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        DispatchQueue.main.async {
            let scale = pdfView.scaleFactorForSizeToFit

            pdfView.scaleFactor = scale
            pdfView.minScaleFactor = scale
            pdfView.maxScaleFactor = scale * 5
        }
    }
}

#Preview {
    ProfileView()
}

