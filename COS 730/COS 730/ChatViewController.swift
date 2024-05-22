
import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseDatabase


class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {

    var messages: [Message] = []
    var currentSender: SenderType = Sender(senderId: UIDevice.current.name, displayName: UIDevice.current.name)
    private var databaseRef: DatabaseReference!
    var suggestions: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        databaseRef = Database.database().reference().child("messages")

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self

        fetchMessages()

    }

    private func fetchMessages() {
        databaseRef.observe(.childAdded) { [weak self] snapshot in
            guard let self = self,
                  let dictionary = snapshot.value as? [String: Any],
                  let message = Message(dictionary: dictionary) else {
                return
            }
            self.messages.append(message)
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem()
        }
    }

    // MARK: - MessagesDataSource
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    // MARK: - MessagesLayoutDelegate
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    // MARK: - MessagesDisplayDelegate
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .black
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .purple : .lightGray
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        avatarView.initials = String(sender.displayName.prefix(2))
    }

    // MARK: - InputBarAccessoryViewDelegate
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let currentSender = currentSender
        let message = Message(sender: currentSender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))
        save(message)
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToLastItem()
    }

    private func save(_ message: Message) {
        let messageRef = databaseRef.childByAutoId()
        messageRef.setValue(message.dictionary)
    }

}
