//
//  NotificationService.swift
//  TichuNotificationService
//
//  Created by Leon on 19.05.2026.
//

import UserNotifications
import Intents
import UIKit

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler:
        @escaping (UNNotificationContent) -> Void
    ) {

        self.contentHandler = contentHandler

        guard let bestAttemptContent =
            (request.content.mutableCopy()
             as? UNMutableNotificationContent) else {

            contentHandler(request.content)
            return
        }

        self.bestAttemptContent = bestAttemptContent

        let userInfo = request.content.userInfo

        let senderName =
            userInfo["sender_name"] as? String ?? "Unknown"

        let imageURLString =
            userInfo["image_url"] as? String

        guard let imageURLString,
              let imageURL = URL(string: imageURLString) else {

            contentHandler(bestAttemptContent)
            return
        }

        downloadImage(from: imageURL) { image in

            let avatar: INImage?

            if let imageData = image?.pngData() {
                avatar = INImage(imageData: imageData)
            } else {
                avatar = nil
            }

            let sender = INPerson(
                personHandle: INPersonHandle(
                    value: senderName,
                    type: .unknown
                ),
                nameComponents: nil,
                displayName: senderName,
                image: avatar,
                contactIdentifier: nil,
                customIdentifier: nil
            )

            let intent = INSendMessageIntent(
                recipients: nil,
                outgoingMessageType: .outgoingMessageText,
                content: bestAttemptContent.body,
                speakableGroupName: nil,
                conversationIdentifier: "chat",
                serviceName: nil,
                sender: sender,
                attachments: nil
            )

            let interaction = INInteraction(
                intent: intent,
                response: nil
            )

            interaction.direction = .incoming

            interaction.donate(completion: nil)

            do {
                let updatedContent =
                    try bestAttemptContent.updating(from: intent)

                contentHandler(updatedContent)
            } catch {
                contentHandler(bestAttemptContent)
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        guard let contentHandler = contentHandler,
              let bestAttemptContent = bestAttemptContent else {
            return
        }

        contentHandler(bestAttemptContent)
    }

    private func downloadImage(
        from url: URL,
        completion: @escaping (UIImage?) -> Void
    ) {

        URLSession.shared.dataTask(with: url) {
            data, _, _ in

            guard let data = data,
                  let image = UIImage(data: data) else {

                completion(nil)
                return
            }

            completion(image)

        }.resume()
    }
}
