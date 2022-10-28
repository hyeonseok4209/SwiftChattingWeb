
import Foundation

struct User {
    let uid: String
    let email: String
    let name: String
    let nickname: String
    
    init(dictionary: [String: Any]) {
        
        self.uid = dictionary["uid"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.nickname = dictionary["nickname"] as? String ?? ""
        
    }
    
}
