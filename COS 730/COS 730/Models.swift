import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseDatabase

// Sender Model
struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

// Message Model
struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind

    var kindString: String {
        switch kind {
        case .text(let text):
            return text
        default:
            return ""
        }
    }

    var dictionary: [String: Any] {
        return [
            "senderId": sender.senderId,
            "displayName": sender.displayName,
            "messageId": messageId,
            "sentDate": sentDate.timeIntervalSince1970,
            "kind": kindString
        ]
    }

    init?(dictionary: [String: Any]) {
        guard let senderId = dictionary["senderId"] as? String,
              let displayName = dictionary["displayName"] as? String,
              let messageId = dictionary["messageId"] as? String,
              let sentDate = dictionary["sentDate"] as? TimeInterval,
              let kindString = dictionary["kind"] as? String else {
            return nil
        }
        self.sender = Sender(senderId: senderId, displayName: displayName)
        self.messageId = messageId
        self.sentDate = Date(timeIntervalSince1970: sentDate)
        self.kind = .text(kindString)
    }

    init(sender: SenderType, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
}
