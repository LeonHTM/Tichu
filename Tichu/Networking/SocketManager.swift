//
//  SocketManager.swift
//  Tichu
//
//  Created by Leon on 15.05.2026.
//

import Foundation
import SocketIO
internal import Combine

final class SocketService: ObservableObject {

    static let shared = SocketService()

    private var manager: SocketManager!
    private var socket: SocketIOClient!

    @Published var connected = false

    private init() {

        guard let url = URL(
            string: "http://192.168.1.84:5001"
        ) else {
            return
        }

        manager = SocketManager(
            socketURL: url,
            config: [
                .log(true),
                .compress,
                .reconnects(true),
                .reconnectWait(1)
            ]
        )

        socket = manager.defaultSocket

        setupHandlers()

        socket.connect()
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
            print("profile_created")
            print(data)
        }

        // PROFILE DELETED
        socket.on("profile_deleted") { data, ack in
            print("profile_deleted")
            print(data)
        }

        // FRIEND REQUEST
        socket.on("friend_request_sent") { data, ack in
            print("friend_request_sent")
            print(data)
        }

        // FRIENDSHIP ADDED
        socket.on("friendship_added") { data, ack in
            print("friendship_added")
            print(data)
        }

        // IMAGE UPDATED
        socket.on("profile_image_updated") { data, ack in
            print("profile_image_updated")
            print(data)
        }
    }

    // MARK: - Disconnect

    func disconnect() {
        socket.disconnect()
    }
}
