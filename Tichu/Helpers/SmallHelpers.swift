//
//  SmallHelpers.swift
//  Tichu
//
//  Created by Leon on 25.04.2026.
//

import SwiftUI

//MARK: - RequirementRow used in EditNameSheet
@ViewBuilder
func requirementRow(
    text: String,
    isValid: Bool
) -> some View {
    HStack(spacing: 10) {
        Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
        Text(text)
        Spacer()
    }
    .foregroundStyle(isValid ? .green : .red)
}

//MARK: - LabelStyle used in ProfilesView
struct ColorfulIconLabelStyle: LabelStyle {
    //MARK: Varibles
    var color: Color
    var fontSize: CGFloat
    //MARK: Function
    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            configuration.icon
                .font(.system(size: fontSize))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(color)
                        // Top light gloss
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.45),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .blendMode(.overlay)
                            )
                        )
                        // Subtle glossy border
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.15),
                                            .clear,
                                            .clear,
                                            .white.opacity(0.15)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                        // Depth shadow
                        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                )
        }
    }
}




//MARK: - OfflineView. The View that gets Shown when the socket is not connected.
//Shown in LoginView,and MainView for StatsView and HistoryView
//Alert is Used in ChipsView, ShareStatsView, LoginView, MainView, PlayeView, ProfileView and StatsView
struct OfflineView: View{
    //MARK: Variables
    @Binding  var showNavBar: Bool
    @ObservedObject private var network = NetworkService.shared
    @AppStorage("userId") private var userId = -69420
    
    //MARK: Body
    var body: some View{
        NavigationStack{
            VStack(alignment:.center,spacing:10){
                //Offline Text
                Text("No Internet Connection").font(.title2).fontWeight(.bold)
                Text("Your Device is not connected to the internet. To connect, turn off Airplane Mode or connect to a Wi-Fi network.").foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal,40)
            
            }.toolbarTitleDisplayMode(.inlineLarge)
                .navigationTitle(showNavBar ? "History" : "" )
                .toolbar {
                    //Shows NavBar everywhere except LoginView
                    if showNavBar{
                        ToolbarItem(placement: .topBarTrailing) {
                            ProfileImage(data: network.profileImages[userId], size: 44)
                        }
                        .sharedBackgroundVisibility(.hidden)
                    }
                }
            }
        }
    //Alert that is used
    static func offlineAlert() -> Alert {
        Alert(
            title: Text("No Internet Connection"),
            message: Text("Your Device is not connected to the internet."),
            dismissButton: .default(Text("OK"))
        )
    }
}

import UIKit

//MARK: - DeviceModelName used in Contact Form to send the Device Model Name for exmaple iPhone 14,5
func DeviceModelName() -> String {
    //Mark: Vars
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    //Mark: Build Identifier
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return identifier
}


//MARK: - BombView used in GameSummaryListView and EditRoundsShettView to show the little Grpahic for the bomb and the counter
func bombView(bomb: Int) -> some View {
    Group {
        if bomb > 0 {
            HStack {
                Image("bomb.fill")
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(.secondary)
                    .frame(width: 18, height: 16)
                    .offset(x: 52)
                Text("\(bomb)").font(.system(size: 15)).offset(x: 41, y: 7).foregroundStyle(Color.secondary)
            }
        }
    }
}
  
//MARK: - Extension to save Array in AppStorage used to Store the List of Players in StatsView
// Source - https://stackoverflow.com/a/65598711
extension Array: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}


//MARK: - Extension to save Dictionaries in AppStorage
extension Dictionary: @retroactive RawRepresentable where Key == Int, Value == Int {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Int: Int].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return result
    }
}


//MARK: - Function to check if user isFriend user in contextMenus in AddPlayersSheetView and PlayView
func isFriend(profileId: Int) -> Bool{
    if NetworkService.shared.friends.first(where:{$0.id == profileId}) == nil{
        return false
    }else{
        return true
    }
}

