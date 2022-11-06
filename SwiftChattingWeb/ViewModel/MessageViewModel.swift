
import UIKit

class MessageViewModel {
    
    private let message: Message
    
    var messageBackgroundColor: UIColor {
        return message.isFromCurrentUser ? .systemCyan : .lightGray
    }
    
    var rightAnchorActive: Bool {
        return message.isFromCurrentUser
    }
    
    var leftAnchorActive: Bool {
        return !message.isFromCurrentUser
    }
    
    var sholudHideProfileImage: Bool {
        return message.isFromCurrentUser
    }
    
    var sholudHideNameLabel: Bool {
        return message.isFromCurrentUser
    }
            
    init(message: Message){
        self.message = message
    }
    
}
