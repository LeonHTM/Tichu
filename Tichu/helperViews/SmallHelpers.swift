//
//  SmallHelpers.swift
//  Tichu
//
//  Created by Leon on 25.04.2026.
//

import SwiftUI

//Used in NameSheet
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



func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "de_DE") // European style
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter.string(from: date)
}



import SwiftUI

struct ColorfulIconLabelStyle: LabelStyle {
    var color: Color
    var fontSize: CGFloat
    
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
                        // Depth shadow (important for “app icon” feel)
                        .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                )
        }
    }
}

struct NavigationProfileImage: View {
    @AppStorage("userImageData") var userImageData: Data?
    @AppStorage("selectedTab") var selectedTab: Int?
    @AppStorage("userId") var userId: Int?

    var body: some View {
        Button {
            selectedTab = 3
        } label: {
            ProfileImage(data: userImageData, size: 44)
                
                
        }.frame(width: 44, height: 44)
            .contentShape(.contextMenuPreview,.circle)
            .contextMenu{
            Button{
                if SocketService.shared.connected{
                    Task {
                        if let id = userId{
                            
                            
                            await NetworkService.shared.logout(profileId: id)
                        }
                    }
                }
            }label:{
                Image(systemName:"rectangle.portrait.and.arrow.right.fill")
                Text("Log out")
            }
        }
               
    }
} 


struct offlineView: View{
    @Binding  var showNavBar: Bool
    @ObservedObject private var network = NetworkService.shared
    @AppStorage("userId") private var userId = -69420
    var body: some View{
        NavigationStack{
            VStack(alignment:.center,spacing:10){
                
                
                Text("No Internet Connection").font(.title2).fontWeight(.bold)
                
                
                
                Text("Your Device is not connected to the internet. To connect, turn off Airplane Mode or connect to a Wi-Fi network.").foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal,40)
                
                
                
            }.toolbarTitleDisplayMode(.inlineLarge)
                .navigationTitle(showNavBar ? "History" : "" )
                .toolbar {
                    if showNavBar{
                        ToolbarItem {
                            
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            ProfileImage(data: network.profileImages[userId], size: 44)
                        }
                        .sharedBackgroundVisibility(.hidden)
                    }
                }
        }
            
        
    }
    static func offlineAlert() -> Alert {
        Alert(
            title: Text("No Internet Connection"),
            message: Text("Your Device is not connected to the internet."),
            dismissButton: .default(Text("OK"))
        )
    }
}

import UIKit

func deviceModelName() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return identifier // e.g. "iPhone14,5"
}

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
    
// Source - https://stackoverflow.com/a/65598711
// Posted by pawello2222
// Retrieved 2026-06-02, License - CC BY-SA 4.0

extension Array: RawRepresentable where Element: Codable {
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

extension Dictionary: RawRepresentable where Key == Int, Value == Int {
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








func isFriend(profileId: Int) -> Bool{
    if NetworkService.shared.friends.first(where:{$0.id == profileId}) == nil{
        return false
    }else{
        return true
    }
}

#Preview{
    offlineView(showNavBar: .constant(true))
}

