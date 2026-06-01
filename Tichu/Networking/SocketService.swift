//
//  SocketService.swift
//  Tichu
//
//  Created by Leon on 15.05.2026.
//

import Foundation
import SocketIO
import Combine
import SwiftUI

final class SocketService: ObservableObject {

    @AppStorage("userId") private var userId = -69420
    @AppStorage("userImageData") var userImageData: Data?
    @AppStorage("userName") var userName: String = "Unknown"
    @AppStorage("userElo") var userElo: Int = 1000
    static let shared = SocketService()

    private var manager: SocketManager!
    private var socket: SocketIOClient!

    @Published var connected = true
    var baseURL: String { Config.shared.baseURL }


    private init() {
        setupSocket()
    }

    // MARK: - Setup Socket

    private func setupSocket() {
        guard let url = URL(string: baseURL) else { return }

        manager = SocketManager(
            socketURL: url,
            config: [
                //.log(true),
                .compress,
                .reconnects(true),
                .reconnectWait(1)
            ]
        )

        socket = manager.defaultSocket
        setupHandlers()
        socket.connect()
    }

    // MARK: - Reconnect with new URL
    func reconnect() {
        socket.disconnect()
        socket.removeAllHandlers()
        manager.disconnect()
        setupSocket()
        Task {
            await NetworkService.shared.fetchProfiles()
            await NetworkService.shared.fetchFriends(profileId: userId)
            await NetworkService.shared.fetchFriendRequests(profileId: userId)
        }
    }

    // MARK: - Setup Events

    private func setupHandlers() {

        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("Socket connected")
            DispatchQueue.main.async { self?.connected = true }
        }

        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("Socket disconnected")
            DispatchQueue.main.async { self?.connected = false }
        }

        socket.on(clientEvent: .error) { [weak self] data, ack in
            print("Socket error: \(data)")
            DispatchQueue.main.async { self?.connected = false }
        }

        // PROFILE CREATED
        socket.on("profile_created") { data, ack in
            guard let dict = data[0] as? [String: Any],
                  let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                  let profile = try? JSONDecoder().decode(Profile.self, from: jsonData) else {
                print("profile_created: failed to parse \(data)")
                return
            }
            DispatchQueue.main.async {
                if !NetworkService.shared.profiles.contains(where: { $0.id == profile.id }) {
                    withAnimation(.easeInOut) {
                        NetworkService.shared.profiles.append(profile)
                    }
                }
            }
        }
        
        

        // PROFILE DELETED
        socket.on("profile_deleted") { data, ack in
            guard let dict = data[0] as? [String: Any],
                  let id = dict["id"] as? Int else {
                print("profile_deleted: failed to parse \(data)")
                return
            }
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    NetworkService.shared.profiles.removeAll { $0.id == id }
                    if id == self.userId {
                        self.userId = -69420
                    }
                }
            }
        }

        // REMOVE FRIENDSHIP NOTIFICATION
        socket.on("remove_friend_request_notification") { [weak self] data, _ in
            guard let dict = data.first as? [String: Any],
                  let userId = dict["user_id"] as? Int,
                  let senderId = dict["sender_id"] as? Int else { return }
            guard userId == (UserDefaults.standard.integer(forKey: "userId")) else {
                print("Wanted to delete Notification but couldn't")
                return
            }
            removeFriendRequestNotification(fromSenderId: senderId)
        }

        // USERNAME UPDATED
        socket.on("username_updated") { data, ack in
            guard let dict = data[0] as? [String: Any],
                  let profileId = dict["profile_id"] as? Int,
                  let name = dict["name"] as? String else { return }
            DispatchQueue.main.async {
                if let index = NetworkService.shared.profiles.firstIndex(where: { $0.id == profileId }) {
                    withAnimation(.easeInOut) {
                        NetworkService.shared.profiles[index].name = name
                        if profileId == self.userId {
                            self.userName = name
                        }
                    }
                }
            }
        }
    
        // FRIEND REQUEST SENT
        socket.on("friend_request_sent") { data, ack in
            Task {
                await NetworkService.shared.fetchSentRequests(profileId: self.userId)
                await NetworkService.shared.fetchFriendRequests(profileId: self.userId)
            }
        }

        // FRIEND REQUEST UPDATED
        socket.on("friend_request_updated") { data, ack in
            Task {
                await NetworkService.shared.fetchSentRequests(profileId: self.userId)
                await NetworkService.shared.fetchFriendRequests(profileId: self.userId)
                await NetworkService.shared.fetchFriends(profileId: self.userId)
            }
        }

        // FRIENDSHIP ADDED
        socket.on("friendship_added") { [weak self] data, ack in
            print("friendship_added: \(data)")
            Task { [weak self] in
                guard let self = self else { return }
                await NetworkService.shared.fetchSentRequests(profileId: self.userId)
                await NetworkService.shared.fetchFriends(profileId: self.userId)
            }
        }

        // FRIENDSHIP REMOVED
        socket.on("friendship_removed") { [weak self] data, ack in
            print("friendship_removed: \(data)")
            Task { [weak self] in
                guard let self = self else { return }
                await NetworkService.shared.fetchFriends(profileId: self.userId)
            }
        }

        // IMAGE UPDATED
        socket.on("profile_image_updated") { data, ack in
            print("profile_image_updated: \(data)")
            Task {
                await NetworkService.shared.fetchProfiles()
            }
        }

        // AUTH FAILED
        socket.on("auth_failed") { data, ack in
            
            Task {
                await NetworkService.shared.logout(profileId: self.userId)
            }
        }

        // MARK: - Game Events

        // GAME CREATED
        socket.on("game_created") { data, ack in
            guard let dict = data[0] as? [String: Any],
                  let jsonData = try? JSONSerialization.data(withJSONObject: dict) else {
                print("game_created: failed to parse \(data)")
                return
            }
            let decoder = NetworkService.shared.flexibleDateDecoder // make flexibleDateDecoder internal instead of private
            guard let game = try? decoder.decode(Game.self, from: jsonData) else {
                print("game_created: failed to decode Game")
                return
            }
            Task { @MainActor in
                if !NetworkService.shared.games.contains(where: { $0.id == game.id }) {
                    withAnimation(.easeInOut) {
                        NetworkService.shared.games.append(game)
                    }
                }
            }
        }

        // GAME DELETED
        socket.on("game_deleted") { data, ack in
            guard let dict = data[0] as? [String: Any],
                  let gameId = dict["game_id"] as? Int else {
                print("game_deleted: failed to parse \(data)")
                return
            }
            withAnimation(.easeInOut){
                Task{
                    print("Game Deleted: \(gameId)")
                    await NetworkService.shared.games.removeAll { $0.id == gameId }
                    await NetworkService.shared.roundsByGame.removeValue(forKey: gameId)
                }
            }
        }

        // MARK: - Round Events

        // ROUND CREATED
        // ROUND UPDATED
        socket.on("round_updated") { data, ack in
            guard let dict = data[0] as? [String: Any],
                  let jsonData = try? JSONSerialization.data(withJSONObject: dict) else { return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let updated = try? decoder.decode(Round.self, from: jsonData) else { return }
            DispatchQueue.main.async {
                let gameId = updated.gameId
                if var rounds = NetworkService.shared.roundsByGame[gameId],
                   let index = rounds.firstIndex(where: { $0.id == updated.id }) {
                    rounds[index] = updated
                    NetworkService.shared.roundsByGame[gameId] = rounds
                }
            }
            withAnimation(.easeInOut){
                Task { await NetworkService.shared.fetchProfileGames(profileId: self.userId) }
            }
        }

        // ROUND DELETED
        socket.on("round_deleted") { data, ack in
            guard let dict = data[0] as? [String: Any],
                  let roundId = dict["round_id"] as? Int,
                  let gameId = dict["game_id"] as? Int else { return }
            withAnimation(.easeInOut){
                Task{
                    await NetworkService.shared.reCalculate(gameId: gameId)
                }
            }
        }

        // ROUND CREATED
        socket.on("round_created") { data, ack in
            guard let dict = data[0] as? [String: Any],
                  let jsonData = try? JSONSerialization.data(withJSONObject: dict) else { return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let round = try? decoder.decode(Round.self, from: jsonData) else { return }
            let gameId = round.gameId
            DispatchQueue.main.async {
                var list = NetworkService.shared.roundsByGame[gameId] ?? []
                if !list.contains(where: { $0.id == round.id }) {
                    list.append(round)
                    list.sort { $0.roundOrder < $1.roundOrder }
                    NetworkService.shared.roundsByGame[gameId] = list
                }
            }
            withAnimation(.easeInOut){
                Task {
                    await NetworkService.shared.reCalculate(gameId: gameId)
                }
            }
        }
        
        // GAME RECALCULATED
        socket.on("game_recalculated") { data, ack in
            guard let dict = data.first as? [String: Any],
                  let gameId = dict["game_id"] as? Int else {
                print("game_recalculated: failed to parse \(data)")
                return
            }

            print("game_recalculated for game \(gameId)")
            withAnimation(.easeInOut){
                Task {
                    await NetworkService.shared.fetchGame(gameId: gameId)
                    await NetworkService.shared.fetchGameRounds(gameId: gameId)
                }
            }
        }
        
        
        // GAME PLAYER UPDATED
        socket.on("game_updated") { data, ack in
            guard let dict = data[0] as? [String: Any],
                  let jsonData = try? JSONSerialization.data(withJSONObject: dict) else {
                print("game_updated: failed to parse \(data)")
                return
            }
            let decoder = NetworkService.shared.flexibleDateDecoder
            guard let updated = try? decoder.decode(Game.self, from: jsonData) else {
                print("game_updated: failed to decode Game")
                return
            }
            Task { @MainActor in
                if let index = NetworkService.shared.games.firstIndex(where: { $0.id == updated.id }) {
                    withAnimation(.easeInOut) {
                        NetworkService.shared.games[index] = updated
                    }
                }
            }
        }
        
        
    }

    // MARK: - Disconnect

    func disconnect() {
        socket.disconnect()
    }
}
