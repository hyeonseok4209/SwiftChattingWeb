
import Firebase

struct Message {
    let id: String
    let roomID: String
    let text: String
    let fromID: String
    var userName: String
    var userNickname: String
    var unReadedMember: [String]
    var mediaURL: String
    var imageView: UIImageView?
    var timestamp: Timestamp!
    
    let isFromCurrentUser: Bool
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.roomID = dictionary["roomID"] as? String ?? ""
        self.text = dictionary["text"] as? String ?? ""
        self.fromID = dictionary["fromID"] as? String ?? ""
        self.userName = dictionary["userName"] as? String ?? ""
        self.userNickname = dictionary["userNickname"] as? String ?? ""
        self.unReadedMember = dictionary["unReadedMember"] as? [String] ?? []
        self.mediaURL = dictionary["mediaURL"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())

        self.isFromCurrentUser = fromID == Auth.auth().currentUser?.uid
    }
}
