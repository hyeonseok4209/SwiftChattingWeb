
import Foundation

struct User {
    let uid: String
    let FCMtoken: String
    let email: String
    let name: String
    var nickname: String
    let friends : [String]
    var profileImageURL : String
    
    init(dictionary: [String: Any]) {
        
        self.uid = dictionary["uid"] as? String ?? ""
        self.FCMtoken = dictionary["FCMtoken"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.nickname = dictionary["nickname"] as? String ?? ""
        self.friends = dictionary["friends"] as? [String] ?? []
        self.profileImageURL = dictionary["profileImageURL"] as? String ?? ""
    }
}
