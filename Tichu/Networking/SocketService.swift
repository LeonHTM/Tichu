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
    //Force reconnect wont happen automatically
    func reconnect() {
        socket.disconnect()
        socket.removeAllHandlers()
        manager.disconnect()
        setupSocket()
        Task{
            await NetworkService.shared.fetchProfiles()
            await NetworkService.shared.fetchFriends(profileId: userId)
            await NetworkService.shared.fetchFriendRequests(profileId: userId)
        }
        
    }

    // MARK: - Setup Events

    private func setupHandlers() {

        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("Socket connected")
            DispatchQueue.main.async {
                self?.connected = true
            }
        }

        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("Socket disconnected")
            DispatchQueue.main.async {
                self?.connected = false
            }
        }

        socket.on(clientEvent: .error) { [weak self] data, ack in
            print("Socket error: \(data)")
            DispatchQueue.main.async {
                self?.connected = false
            }
        }

        socket.on(clientEvent: .statusChange) { data, ack in
            print("Status changed: \(data)")
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
                }
            }
        }

        // USERNAME EDITED
        socket.on("username_updated") { data, ack in
            guard let dict = data[0] as? [String: Any],
                  let profileId = dict["profile_id"] as? Int,
                  let name = dict["name"] as? String else { return }
            DispatchQueue.main.async {
                if let index = NetworkService.shared.profiles.firstIndex(where: { $0.id == profileId }) {
                    withAnimation(.easeInOut) {
                        NetworkService.shared.profiles[index].name = name
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
    }

    // MARK: - Disconnect

    func disconnect() {
        socket.disconnect()
    }
}
