
import UIKit
import Firebase

class TabBarViewController: UITabBarController {
    
    //MARK: Properties
    
    let center = UNUserNotificationCenter.current()
    
    let mainMenuView: UIViewController = {
        let controller = UINavigationController (rootViewController: MainViewController())
        controller.tabBarItem.title = "Home"
        controller.tabBarItem.image = UIImage(systemName: "house")
        
        return controller
    }()
    
    let chattingMenuView: UIViewController = {
        let controller = UINavigationController(rootViewController: ChattingMenuViewController())
        controller.tabBarItem.title = "Message"
        controller.tabBarItem.image = UIImage(systemName: "message")
        
        return controller
    }()
    
    let settingMenuView: UIViewController = {
        let controller = UINavigationController(rootViewController: SettingMenuViewController())
        controller.tabBarItem.title = "Setting"
        controller.tabBarItem.image = UIImage(systemName: "ellipsis")
       
        return controller
    }()
    
    
    
    //MARK: View LifeCycle
    
    override func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = .white
        
        async {
            try await authenticateUser()
            configureUI()
//            UsersInfo.shared.delegate = self
//            RoomsInfo.shared.delegate = self
//            MessageInfo.shared.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        messagesAddListender()
        navigationController?.navigationBar.isHidden = true
        
    }
    
    //MARK: Firebase Authenfication API
    @MainActor
    func authenticateUser() async throws {
        if Auth.auth().currentUser?.uid == nil {
            presentLoginScreen()
        } else {
                try await fetchCurrentUserInfo()
                try await fetchUsersInfo()
                try await fetchRoomsInfo()
                try await FetchMessagesInfo()
        }
    }
    
    //MARK: Get Infos form API
    
    //?????? ?????? ?????? ??????
    func fetchCurrentUserInfo() async throws -> Void {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_USERS.document(uid)
        let currentUser = CurrentUserInfo.shared
                
        let snapshot = try await query.getDocument()
        guard let dictionary = snapshot.data() else { return }
        
        currentUser.currentUserInfo = User(dictionary: dictionary)
        guard let currentUserInfo = currentUser.currentUserInfo else { return }
        
        print("?????? ???????????? | ?????????: \(currentUserInfo.email),??????: \(currentUserInfo.name), ?????????:\(currentUserInfo.nickname)")
    }
    
    //?????? ????????? ????????? ?????? ?????? ??????
    func fetchUsersInfo() async throws -> Void {
        let currentUser = CurrentUserInfo.shared
        let usersInfo = UsersInfo.shared
        var users = [User]()
        
        guard let friends = currentUser.currentUserInfo?.friends else { return }
        
        
        
        for friend in friends {
            let query = COLLECTION_USERS.document(friend)
            let snapshot = try await query.getDocument()
            guard let dictionary = snapshot.data() else { return }
            let user = User(dictionary: dictionary)
            users.append(user)
        }
        
        usersInfo.users = users
    }
    
    // ??????????????? ????????? ????????? ????????? ??????
    func fetchRoomsInfo() async throws -> Void {
        print("????????? ???????????? ??????")
        let currentUser = CurrentUserInfo.shared
        let roomsInfo = RoomsInfo.shared
        
        var rooms = [Room]()
        
        guard let uid = currentUser.currentUserInfo?.uid else { return }
 
        let query = COLLECTION_ROOMS.whereField("members", arrayContains: uid).order(by: "timestamp")
        
        let snapshot = try await query.getDocuments()
        
        snapshot.documents.forEach { document in
            let dictionary = document.data()
            let room = Room(dictionary:  dictionary)
            rooms.append(room)
        }
        
        roomsInfo.rooms = rooms
        print("????????? ???????????? ??????")
    }
    
    // ?????? ????????? ????????? ???????????? ?????? ????????? ??????
    
    func FetchMessagesInfo() async throws {
        print("????????? ???????????? ??????")
        let roomsInfo = RoomsInfo.shared
        var messagesInRoomsInfo = MessagesInRoomInfo.shared
        var messagesInRooms = [MessagesInRoom]()
        guard let rooms = roomsInfo.rooms else { return }
        
        for (index, room) in rooms.enumerated() {
   
            var currentMessages = [Message]()
            let query = COLLECTION_MESSAGES.whereField("roomID", isEqualTo: room.id!)
            let snapshot = try await query.getDocuments()
            
            snapshot.documents.forEach { document in
                let dictionary = document.data()
                let message = Message(dictionary: dictionary)
                currentMessages.append(message)
            }
            
            let data = [ "roomID" : room.id!,
                         "messages" : currentMessages ] as [String : Any]
            
            let messageInfoInit = MessagesInRoom(dictionary: data)
            messagesInRooms.append(messageInfoInit)
        }
        
        messagesInRoomsInfo.messagesInRoom = messagesInRooms
        
        print("????????? ???????????? ??????")
    }
 
    //?????? ?????? ??????
    
    func fetchUsers() {
        let usersInfo = UsersInfo.shared
        guard let users = usersInfo.users else { return }
        usersInfo.users = users
    }

    //????????? ?????? ??????
    func fetchRooms() {
        let roomsInfo = RoomsInfo.shared
        guard let rooms = roomsInfo.rooms else { return }
        roomsInfo.rooms = rooms
    }
    
    //????????? ?????? ??????
    func fetchMessages() {
        let messagesInfo = MessagesInfo.shared
        guard let messages = messagesInfo.messages else { return }
        messagesInfo.messages = messages
    }
        
    //MARK: Configures and Helpers
    
    func presentLoginScreen() {
        DispatchQueue.main.async {
            let controller = LoginViewController()
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: false, completion: nil)
        }
    }
    
    func configureUI() {

        self.tabBar.backgroundColor = .white
        self.tabBar.tintColor = .systemBlue
        self.tabBar.unselectedItemTintColor = .lightGray
        
        viewControllers = [mainMenuView,chattingMenuView, settingMenuView]
    }
}


extension TabBarViewController: UsersInfoDelegate {
    func usersDidChanges() {
        fetchUsers()
    }
}

extension TabBarViewController: RoomsInfoDelegate {
    func roomsDidChanges() {
        fetchRooms()
    }
}

extension TabBarViewController: MessagesInfoDelegate {
    func messagesDidChanges() {
    }
}

