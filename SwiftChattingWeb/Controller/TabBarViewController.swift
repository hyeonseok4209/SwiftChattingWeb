
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
        
        requestAuthNotification()

        requestSendNotification(seconds: 3)

        
        async {
            try await authenticateUser()
            configureUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        }
    }
    
    //MARK: Get Infos form API
        
    func fetchCurrentUserInfo() async throws -> Void {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_USERS.document(uid)
        let currentUser = CurrentUserInfo.shared
        
        let snapshot = try await query.getDocument()
        guard let dictionary = snapshot.data() else { return }
        
        currentUser.currentUserInfo = User(dictionary: dictionary)
        guard let currentUserInfo = currentUser.currentUserInfo else { return }
        
        print("현재 접속유저 | 이메일: \(currentUserInfo.email),이름: \(currentUserInfo.name), 닉네임:\(currentUserInfo.nickname)")
    }
    
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
    
    func fetchRoomsInfo() async throws -> Void {
        
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
    
    func requestAuthNotification() {
        let notificationAuthOptions = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
        center.requestAuthorization(options: notificationAuthOptions) { success, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func requestSendNotification(seconds: Double) {
        let content = UNMutableNotificationContent()
        content.title = "알림 제목"
        content.body = "알림 내용"
            
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
            
        center.add(request) { error in
            if let error = error {
            print("Error: \(error.localizedDescription)")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
