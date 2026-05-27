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
    @AppStorage("authToken") var authToken: String = ""

    @Published var profiles: [Profile] = []
    @Published var profileImages: [Int: Data] = [:]

    @Published var friends: [Friend] = []

    @Published var friendRequestProfiles: [Profile] = []
    @Published var friendRequestImages: [Int: Data] = [:]

    @Published var friendRequests: [(id: Int, senderId: Int)] = []
    @Published var sentRequests: [(id: Int, receiverId: Int)] = []
    
    @Published var games: [Game] = []
    @Published var roundsByGame: [Int: [Round]] = [:]

    private init() {}

    // MARK: - Flexible Date Decoder

    var flexibleDateDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)

            let isoFormatter = ISO8601DateFormatter()

            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: str) { return date }

            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: str) { return date }

            let fallback = DateFormatter()
            fallback.locale = Locale(identifier: "en_US_POSIX")
            fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = fallback.date(from: str) { return date }

            fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            if let date = fallback.date(from: str) { return date }

            fallback.dateFormat = "yyyy-MM-dd"
            if let date = fallback.date(from: str) { return date }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date: \(str)"
            )
        }
        return decoder
    }
    // MARK: - Auth Header Helper

    private func authorizedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    // MARK: - Login

    func login(userId: Int) async -> Bool {
        guard let url = URL(string: "\(baseURL)/login") else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["id": userId])

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            if let token = json?["token"] as? String,
               let userId = json?["id"] as? Int {

                await MainActor.run {
                    self.authToken = token
                    self.userId = userId
                }

                if !pendingDeviceToken.isEmpty {
                    await registerDevice(profileId: userId, deviceToken: pendingDeviceToken)
                } else {
                    print("No device token available yet")
                }

                return true
            }

        } catch {
            print("login error: \(error)")
        }

        return false
    }

    // MARK: - Profiles

    func resetClientData() {
        self.profiles = []
        self.friendRequestProfiles = []
        self.friends = []
        self.profileImages = [:]
        self.sentRequests = []
        self.friendRequestImages = [:]
        self.friendRequests = []
        self.sentRequests = []
        self.authToken = ""
    }

    func loadProfileImages() async {
        let snapshot = await MainActor.run { profiles }

        for profile in snapshot {
            guard let urlString = profile.profileImageUrl,
                  let filename = urlString.components(separatedBy: "/").last,
                  let url = URL(string: "\(baseURL)/uploads/profile_images/\(filename)") else { continue }

            do {
                
                //THIS MAKES SURE PROFILE PICTURE GET ACTUALLY LOADED 
                var request = URLRequest(url: url)
                request.cachePolicy = .reloadIgnoringLocalCacheData
                request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

                let (data, _) = try await URLSession.shared.data(for: request)

                await MainActor.run {
                    self.profileImages[profile.id] = data
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
            let (data, _) = try await URLSession.shared.data(for: authorizedRequest(url: url))
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
            let (data, _) = try await URLSession.shared.data(for: authorizedRequest(url: url))
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

        let request = authorizedRequest(url: url, method: "POST")

        do {
            try await URLSession.shared.data(for: request)
            await MainActor.run {
                self.pendingDeviceToken = ""
                self.authToken = ""
                self.userId = -69420
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
            if let token = json?["token"] as? String {
                await MainActor.run { self.authToken = token }
            }
            return json?["id"] as? Int
        } catch {
            print("createAccount error: \(error)")
            return nil
        }
    }

    func deleteProfile(profileId: Int) async {
        guard let url = URL(string: "\(baseURL)/delete_profile/\(profileId)") else { return }

        let request = authorizedRequest(url: url, method: "DELETE")

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
            let (data, _) = try await URLSession.shared.data(for: authorizedRequest(url: url))
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json?["available"] as? Bool ?? false
        } catch {
            print("checkUsername error: \(error)")
            return false
        }
    }

    func updateUsername(profileId: Int, name: String) async {
        guard let url = URL(string: "\(baseURL)/update_username/\(profileId)") else { return }

        var request = authorizedRequest(url: url, method: "PATCH")
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
            return json?["id"] as? Int
        } catch {
            print("checkEmail error: \(error)")
            return nil
        }
    }

    // MARK: - Friends

    func fetchFriends(profileId: Int) async {
        guard let url = URL(string: "\(baseURL)/friends/\(profileId)/") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(for: authorizedRequest(url: url))
            let raw = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []

            let fetchedFriends: [Friend] = raw.compactMap { dict in
                guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                      let profile = try? JSONDecoder().decode(Profile.self, from: jsonData) else { return nil }

                var date: Date? = nil
                if let dateStr = dict["friends_since"] as? String {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    date = formatter.date(from: dateStr)
                }

                return Friend(id: profile.id,profile: profile,friendsSince: date)
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

        var request = authorizedRequest(url: url, method: "POST")
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

        let request = authorizedRequest(url: url, method: "POST")

        do {
            try await URLSession.shared.data(for: request)
        } catch {
            print("addFriend error: \(error)")
        }
        removeFriendRequestNotification(fromSenderId: friendId)
    }

    func removeFriend(profileId: Int, friendId: Int) async {
        guard let url = URL(string: "\(baseURL)/delete_friendship/\(profileId)/friends/\(friendId)") else { return }

        let request = authorizedRequest(url: url, method: "DELETE")

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
            let (data, _) = try await URLSession.shared.data(for: authorizedRequest(url: url))
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

        let request = authorizedRequest(url: url, method: "POST")

        do {
            try await URLSession.shared.data(for: request)
        } catch {
            print("sendFriendRequest error: \(error)")
        }
    }

    func respondToFriendRequest(receiverId: Int, senderId: Int, action: String) async {
        guard let url = URL(string: "\(baseURL)/manage_requests/\(receiverId)/from/\(senderId)") else { return }

        var request = authorizedRequest(url: url, method: "PATCH")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["action": action])

        do {
            try await URLSession.shared.data(for: request)
            await MainActor.run {
                self.friendRequests.removeAll { $0.senderId == senderId }
                self.friendRequestProfiles.removeAll { $0.id == senderId }
            }
            removeFriendRequestNotification(fromSenderId: senderId)
        } catch {
            print("respondToFriendRequest error: \(error)")
        }
    }

    // MARK: - Profile Image

    func uploadProfileImage(
        profileId: Int,
        imageData: Data,
        maxSize: CGFloat = 256,
        quality: CGFloat = 0.4
    ) async {

        guard let uiImage = UIImage(data: imageData) else {
            print("uploadProfileImage: invalid image data")
            return
        }

        let resized = uiImage.resized(to: maxSize)

        guard let compressedData = resized.jpegData(compressionQuality: quality) else {
            print("uploadProfileImage: compression failed")
            return
        }

        guard let url = URL(string: "\(baseURL)/add_image/\(profileId)/") else { return }

        var request = authorizedRequest(url: url, method: "POST")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"profile_\(profileId).jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(compressedData)
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
            let (data, _) = try await URLSession.shared.data(for: authorizedRequest(url: url))
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
        await fetchProfileGames(profileId: currentUserId)

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

    // MARK: - Games

    func addGame(
        target: Int,
        allowPingus: Bool,
        team1Player1Id: Int?,
        team1Player2Id: Int?,
        team2Player1Id: Int?,
        team2Player2Id: Int?
    ) async -> Game? {
        guard let url = URL(string: "\(baseURL)/add_game") else { return nil }

        var request = authorizedRequest(url: url, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "target": target,
            "allow_pingus": allowPingus,
            "team1_player1_id": team1Player1Id as Any,
            "team1_player2_id": team1Player2Id as Any,
            "team2_player1_id": team2Player1Id as Any,
            "team2_player2_id": team2Player2Id as Any
        ])

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = flexibleDateDecoder
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let game = try decoder.decode(Game.self, from: data)
            await MainActor.run { self.games.append(game) }
            return game
        } catch {
            print("addGame error: \(error)")
            return nil
        }
    }

    func deleteGame(gameId: Int) async {
        guard let url = URL(string: "\(baseURL)/delete_game/\(gameId)") else { return }

        let request = authorizedRequest(url: url, method: "DELETE")

        do {
            try await URLSession.shared.data(for: request)
            await MainActor.run {
                self.games.removeAll { $0.id == gameId }
                self.roundsByGame.removeValue(forKey: gameId)
            }
        } catch {
            print("deleteGame error: \(error)")
        }
    }

    func fetchProfileGames(profileId: Int) async {
        guard let url = URL(string: "\(baseURL)/profile/\(profileId)/games") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(for: authorizedRequest(url: url))
            struct Response: Decodable {
                let profileId: Int
                let games: [Game]
            }

            let decoded = try flexibleDateDecoder.decode(Response.self, from: data)

            await MainActor.run {
                self.games = decoded.games
            }
        } catch {
            print("fetchProfileGames error: \(error)")
            
        }
    }

    func fetchGame(gameId: Int) async {
        guard let url = URL(string: "\(baseURL)/game/\(gameId)") else { return }
        
        print("\(baseURL)/game/\(gameId)")
        do {
            let (data, _) = try await URLSession.shared.data(for: authorizedRequest(url: url))
            let game = try flexibleDateDecoder.decode(Game.self, from: data)
            await MainActor.run {
                if let index = self.games.firstIndex(where: { $0.id == gameId }) {
                    self.games[index] = game
                } else {
                    self.games.append(game)
                }
            }
        } catch {
            print("fetchGame error: \(error)")
        }
    }

    // MARK: - Rounds

    func addRound(
        gameId: Int,
        roundOrder: Int = 1,
        firstProfileId: Int? = nil,
        secondProfileId: Int? = nil,
        thirdProfileId: Int? = nil,
        fourthProfileId: Int? = nil,
        firstBombs: Int = 0,
        secondBombs: Int = 0,
        thirdBombs: Int = 0,
        fourthBombs: Int = 0,
        tichuPointsTeam1: Int = 50,
        tichuPointsTeam2: Int = 50,
        roundPointsTeam1: Int = 0,
        roundPointsTeam2: Int = 0,
        doubleWinTeam1: Bool = false,
        doubleWinTeam2: Bool = false,
        announcedTichu: [Int] = [],
        announcedBigTichu: [Int] = [],
        announcedPingu: [Int] = []
    ) async -> Round? {
        guard let url = URL(string: "\(baseURL)/add_round") else { return nil }

        var request = authorizedRequest(url: url, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "game_id": gameId,
            "round_order": roundOrder,
            "first_profile_id": firstProfileId as Any,
            "second_profile_id": secondProfileId as Any,
            "third_profile_id": thirdProfileId as Any,
            "fourth_profile_id": fourthProfileId as Any,
            "first_bombs": firstBombs,
            "second_bombs": secondBombs,
            "third_bombs": thirdBombs,
            "fourth_bombs": fourthBombs,
            "tichu_points_team1": tichuPointsTeam1,
            "tichu_points_team2": tichuPointsTeam2,
            "round_points_team1": roundPointsTeam1,
            "round_points_team2": roundPointsTeam2,
            "double_win_team1": doubleWinTeam1,
            "double_win_team2": doubleWinTeam2,
            "announced_tichu": announcedTichu,
            "announced_big_tichu": announcedBigTichu,
            "announced_pingu": announcedPingu
        ])

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let round = try flexibleDateDecoder.decode(Round.self, from: data)
            await MainActor.run {
                var list = self.roundsByGame[gameId] ?? []
                list.append(round)
                list.sort { $0.roundOrder < $1.roundOrder }
                self.roundsByGame[gameId] = list
            }
            return round
        } catch {
            print("addRound error: \(error)")
            return nil
        }
    }

    func fetchGameRounds(gameId: Int) async {
        guard let url = URL(string: "\(baseURL)/game/\(gameId)/rounds") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(for: authorizedRequest(url: url))

            struct Response: Decodable {
                let gameId: Int
                let rounds: [Round]
            }

            let decoded = try flexibleDateDecoder.decode(Response.self, from: data)

            await MainActor.run {
                self.roundsByGame[gameId] = decoded.rounds
            }
        } catch {
            print("fetchGameRounds error: \(error)")
        }
    }

    func editRound(roundId: Int, updates: [String: Any]) async {
        guard let url = URL(string: "\(baseURL)/edit_round/\(roundId)") else { return }

        var request = authorizedRequest(url: url, method: "PATCH")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: updates)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let updated = try flexibleDateDecoder.decode(Round.self, from: data)
            await MainActor.run {
                for (gameId, rounds) in self.roundsByGame {
                    if let index = rounds.firstIndex(where: { $0.id == roundId }) {
                        var updatedRounds = rounds
                        updatedRounds[index] = updated
                        self.roundsByGame[gameId] = updatedRounds
                        break
                    }
                }
            }
        } catch {
            print("editRound error: \(error)")
        }
    }

    func deleteRound(gameId: Int, roundId: Int) async {
        guard let url = URL(string: "\(baseURL)/delete_round/\(roundId)") else { return }

        let request = authorizedRequest(url: url, method: "DELETE")

        do {
            try await URLSession.shared.data(for: request)
            await MainActor.run {
                self.roundsByGame[gameId]?.removeAll { $0.id == roundId }
            }
        } catch {
            print("deleteRound error: \(error)")
        }
    }

    func reCalculate(gameId: Int) async {
        guard let url = URL(string: "\(baseURL)/recalculate_game/\(gameId)") else { return }

        let request = authorizedRequest(url: url, method: "POST")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            guard
                let responseGameId = json?["game_id"] as? Int,
                let team1 = json?["current_points_team1"] as? Int,
                let team2 = json?["current_points_team2"] as? Int
            else {
                print("reCalculate: invalid response format")
                return
            }

            await MainActor.run {
                if let index = self.games.firstIndex(where: { $0.id == responseGameId }) {
                    withAnimation(.easeInOut) {
                        print("team1: \(team1), team2: \(team2)")
                        self.games[index].currentPointsTeam1 = team1
                        self.games[index].currentPointsTeam2 = team2
                    }
                }
            }
        } catch {
            print("reCalculate error: \(error)")
        }
    }
}
