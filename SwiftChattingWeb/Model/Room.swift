
import Firebase

struct Room {
    
    let id: String?
    let createdBy: String
    var members: [String]
    var membersName: [String]
    var membersNickname: [String]
    let recentMessage: String
    let timestamp: Timestamp
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.createdBy = dictionary["createdBy"] as? String ?? ""
        self.members = dictionary["members"] as? [String] ?? []
        self.membersName = dictionary["membersName"] as? [String] ?? []
        self.membersNickname = dictionary["membersNickname"] as? [String] ?? []
        self.recentMessage = dictionary["recentMessage"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        
    }
    
}
