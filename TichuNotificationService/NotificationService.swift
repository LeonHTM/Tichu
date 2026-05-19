//
//  NotificationService.swift
//  TichuNotificationService
//
//  Created by Leon on 19.05.2026.
//

import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent,
              let imageURLString = request.content.userInfo["image_url"] as? String,
              let imageURL = URL(string: imageURLString) else {
            contentHandler(request.content)
            return
        }

        downloadImage(from: imageURL) { attachment in
            if let attachment = attachment {
                bestAttemptContent.attachments = [attachment]
            }
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    private func downloadImage(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        URLSession.shared.downloadTask(with: url) { location, _, error in
            guard let location = location, error == nil else {
                completion(nil)
                return
            }

            let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
            let tmpFile = tmpDir.appendingPathComponent(url.lastPathComponent)

            try? FileManager.default.moveItem(at: location, to: tmpFile)

            let attachment = try? UNNotificationAttachment(identifier: "image", url: tmpFile, options: nil)
            completion(attachment)
        }.resume()
    }
}
