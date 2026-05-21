//
//  NetworkService.swift
//  Tichu
//
//  Created by Leon on 15.05.2026.
//

import Foundation
import Combine
import SwiftUI

class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    @ObservedObject var config = Config.shared
    
    var baseURL: String { Config.shared.baseURL }

    @AppStorage("userId") private var userId = -69420
    @AppStorage("userImageData") var userImageData: Data?
    @AppStorage("userName") var userName: String = "Unknown"
    @AppStorage("userElo") var userElo: Int = 1000
    @AppStorage("pendingDeviceToken") var pendingDeviceToken: String = ""

    @Published var profiles: [Profile] = []
    @Published var profileImages: [Int: Data] = [:]

    @Published var friends: [Friend] = []

    @Published var friendRequestProfiles: [Profile] = []
    @Published var friendRequestImages: [Int: Data] = [:]

    @Published var friendRequests: [(id: Int, senderId: Int)] = []
    @Published var sentRequests: [(id: Int, receiverId: Int)] = []

    private init() {}

    // MARK: - Profiles
    func resetClientData(){
     
        self.profiles = []
        self.friendRequestProfiles = []
        self.friends = []
        
        self.profileImages = [:]
        self.sentRequests = []
        
        
        self.friendRequestImages = [:]
        self.friendRequests = []
        self.sentRequests = []
    }


    func loadProfileImages() async {
        let snapshot = await MainActor.run { profiles }

        for profile in snapshot {
            guard let urlString = profile.profileImageUrl,
                  let filename = urlString.components(separatedBy: "/").last,
                  let url = URL(string: "\(baseURL)/uploads/profile_images/\(filename)") else { continue }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                await MainActor.run {
                    self.profileImages[profile.id] = data
                    // If is user also update the ProfileImage
                    if profile.id == self.userId {
                        userImageData = data
                    }
                }
            } catch {
                print("loadProfileImages error for profile \(profile.id): \(error)")
            }
        }
    }

    func fetchProfiles() async {
        guard let url = URL(string: "\(baseURL)/profilessimple") else { return }
        do {
            //Load Data
            let (data, _) = try await URLSession.shared.data(from: url)
            //Set Profiles as Data
            let decoded = try JSONDecoder().decode([Profile].self, from: data)
            await MainActor.run {
                withAnimation(.easeInOut) {
                    self.profiles = decoded
                }
            }
            await loadProfileImages()

        } catch {
            print("fetchProfiles error: \(error)")
        }
    }


    func fetchProfilesStats(profileId: Int) async {
        guard let url = URL(string: "\(baseURL)/profilesstats/\(profileId)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(Profile.self, from: data)
            await MainActor.run {
                if let index = self.profiles.firstIndex(where: { $0.id == decoded.id }) {
                    withAnimation(.easeInOut) {
                        self.profiles[index] = decoded
                    }
                }
            }
        } catch {
            print("fetchProfilesstats error: \(error)")
        }
    }

    func logout(profileId: Int) async {
        guard let url = URL(string: "\(baseURL)/logout/\(profileId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        do {
            try await URLSession.shared.data(for: request)
            await MainActor.run {
                self.pendingDeviceToken = ""
            }
        } catch {
            print("logout error: \(error)")
        }
    }

    func addProfile(email: String, name: String) async -> Int? {
        guard let url = URL(string: "\(baseURL)/add_profile") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "email": email,
            "name": name
        ])

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json?["id"] as? Int
        } catch {
            print("createAccount error: \(error)")
            return nil
        }
    }

    func deleteProfile(profileId: Int) async {
        guard let url = URL(string: "\(baseURL)/delete_profile/\(profileId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            try await URLSession.shared.data(for: request)
            await MainActor.run {
                self.profiles.removeAll { $0.id == profileId }
            }
        } catch {
            print("deleteProfile error: \(error)")
        }
    }

    func checkUsername(username: String) async -> Bool {
        guard let encoded = username.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(baseURL)/check_username/\(encoded)") else { return false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json?["available"] as? Bool ?? false
        } catch {
            print("checkUsername error: \(error)")
            return false
        }
    }

    func updateUsername(profileId: Int, name: String) async {
        guard let url = URL(string: "\(baseURL)/update_username/\(profileId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["name": name])

        do {
            try await URLSession.shared.data(for: request)
            await MainActor.run {
                if let index = self.profiles.firstIndex(where: { $0.id == profileId }) {
                    self.profiles[index].name = name
                }
            }
        } catch {
            print("updateUsername error: \(error)")
        }
    }

    func checkEmail(email: String) async -> Int? {
        guard let encoded = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(baseURL)/check_email/\(encoded)") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let existingId = json?["id"] as? Int
            return existingId
        } catch {
            print("checkEmail error: \(error)")
            return nil
        }
    }

    // MARK: - Friends

    func fetchFriends(profileId: Int) async {
        guard let url = URL(string: "\(baseURL)/friends/\(profileId)/") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let raw = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let fetchedFriends: [Friend] = raw.compactMap { dict in
                guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                      let profile = try? decoder.decode(Profile.self, from: jsonData) else { return nil }

                var date: Date? = nil
                if let dateStr = dict["friends_since"] as? String {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    date = formatter.date(from: dateStr)
                }

                return Friend(id: profile.id, profile: profile, friendsSince: date)
            }

            await MainActor.run {
                withAnimation(.easeInOut) {
                    self.friends = fetchedFriends
                }
            }
        } catch {
            print("fetchFriends error: \(error)")
        }
    }

    func registerDevice(profileId: Int, deviceToken: String) async {
        guard let url = URL(string: "\(baseURL)/register_device/\(profileId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["device_token": deviceToken])

        do {
            try await URLSession.shared.data(for: request)
            print("Device token registered successfully")
        } catch {
            print("registerDevice error: \(error)")
        }
    }

    func addFriend(profileId: Int, friendId: Int) async {
        guard let url = URL(string: "\(baseURL)/add_friendship/\(profileId)/friends/\(friendId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        do {
            try await URLSession.shared.data(for: request)
        } catch {
            print("addFriend error: \(error)")
        }
        removeFriendRequestNotification(fromSenderId: friendId)
    }

    func removeFriend(profileId: Int, friendId: Int) async {
        guard let url = URL(string: "\(baseURL)/delete_friendship/\(profileId)/friends/\(friendId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            try await URLSession.shared.data(for: request)
            await MainActor.run {
                self.friends.removeAll { $0.id == friendId }
            }
        } catch {
            print("removeFriend error: \(error)")
        }
    }

    func fetchSentRequests(profileId: Int) async {
        guard let url = URL(string: "\(baseURL)/sent_requests/\(profileId)/") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let raw = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []

            let parsed = raw.compactMap { dict -> (id: Int, receiverId: Int)? in
                guard let id = dict["id"] as? Int,
                      let receiverId = dict["receiver_id"] as? Int else { return nil }
                return (id: id, receiverId: receiverId)
            }

            await MainActor.run {
                self.sentRequests = parsed
            }
        } catch {
            print("fetchSentRequests error: \(error)")
        }
    }

    func sendFriendRequest(senderId: Int, receiverId: Int) async {
        guard let url = URL(string: "\(baseURL)/add_request/\(senderId)/request/\(receiverId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        do {
            try await URLSession.shared.data(for: request)
        } catch {
            print("sendFriendRequest error: \(error)")
        }
    }

    func respondToFriendRequest(receiverId: Int, senderId: Int, action: String) async {
        guard let url = URL(string: "\(baseURL)/manage_requests/\(receiverId)/from/\(senderId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "action": action
        ])

        do {
            try await URLSession.shared.data(for: request)

            await MainActor.run {
                self.friendRequests.removeAll { $0.senderId == senderId }
                self.friendRequestProfiles.removeAll { $0.id == senderId }
            }

            // Remove the friend request notification from this sender
            removeFriendRequestNotification(fromSenderId: senderId)

        } catch {
            print("respondToFriendRequest error: \(error)")
        }
    }

    // MARK: - Profile Image

    func uploadProfileImage(profileId: Int, imageData: Data) async {
        guard let url = URL(string: "\(baseURL)/add_image/\(profileId)/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"profile_\(profileId).jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        do {
            try await URLSession.shared.data(for: request)
        } catch {
            print("uploadProfileImage error: \(error)")
        }
    }

    func fetchProfileImage(profileId: Int, filename: String) async -> Data? {
        guard let url = URL(string: "\(baseURL)/uploads/profile_images/\(filename)") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            print("fetchProfileImage error: \(error)")
            return nil
        }
    }

    // MARK: - Friend Requests

    func fetchFriendRequests(profileId: Int) async {
        guard let url = URL(string: "\(baseURL)/requests/\(profileId)/") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let raw = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []

            let parsed = raw.compactMap { dict -> (id: Int, senderId: Int)? in
                guard let id = dict["id"] as? Int,
                      let senderId = dict["sender_id"] as? Int else { return nil }
                return (id: id, senderId: senderId)
            }

            let senderIds = parsed.map { $0.senderId }

            await MainActor.run {
                self.friendRequests = parsed
                self.friendRequestProfiles = self.profiles.filter { senderIds.contains($0.id) }
            }

            let snapshot = await MainActor.run { friendRequestProfiles }
            for profile in snapshot {
                guard let urlString = profile.profileImageUrl,
                      let filename = urlString.components(separatedBy: "/").last,
                      let imageUrl = URL(string: "\(baseURL)/uploads/profile_images/\(filename)") else { continue }
                do {
                    let (imageData, _) = try await URLSession.shared.data(from: imageUrl)
                    await MainActor.run {
                        self.friendRequestImages[profile.id] = imageData
                    }
                } catch {
                    print("fetchFriendRequestImages error for profile \(profile.id): \(error)")
                }
            }
        } catch {
            print("fetchFriendRequests error: \(error)")
        }
    }
    
    func fetch(isLoading: Binding<Bool>) async {
        let currentUserId = await MainActor.run { userId }

        await MainActor.run { isLoading.wrappedValue = true }

        await fetchProfiles()
        await fetchFriends(profileId: currentUserId)
        await fetchFriendRequests(profileId: currentUserId)

        await MainActor.run {
            if let imageData = self.profileImages[currentUserId] {
                self.userImageData = imageData
            }
            if let name = self.profiles.first(where: { $0.id == currentUserId })?.name {
                self.userName = name
            }
            if let elo = self.profiles.first(where: { $0.id == currentUserId })?.elo {
                self.userElo = elo
            }

            isLoading.wrappedValue = false
        }
    }
}

