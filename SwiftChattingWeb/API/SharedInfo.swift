
import Foundation
import Firebase

protocol UsersInfoDelegate: class {
    func usersDidChanges()
}

protocol RoomsInfoDelegate: class {
    func roomsDidChanges()
}

protocol MessagesInfoDelegate: class {
    func messagesDidChanges()
}

class CurrentUserInfo {
    static let shared = CurrentUserInfo()
    
    var currentUserInfo:User?
  
    private init() { }
    
}

class UsersInfo {
    static let shared = UsersInfo()
    weak var delegate: UsersInfoDelegate?
    
    var users:[User]? {
        didSet{
            delegate?.usersDidChanges()
        }
    }
    
    private init() { }
}

class RoomsInfo {
    static let shared = RoomsInfo()
    weak var delegate: RoomsInfoDelegate?
    
    var rooms:[Room]? {
        didSet{
            delegate?.roomsDidChanges()
        }
    }
    
    private init() { }
}

class MessageInfo {
    static let shared = MessageInfo()
    weak var delegate: MessagesInfoDelegate?
    
    var messages:[Message]? {
        didSet{
            delegate?.messagesDidChanges()
        }
    }
    
    private init() { }
    
}
