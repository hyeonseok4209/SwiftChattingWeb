
import UIKit
import Firebase

class TabBarViewController: UITabBarController {
    
    //MARK: Properties
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUser()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
    }
    
    //MARK: Firebase Authenfication API
    func authenticateUser() {
        if Auth.auth().currentUser?.uid == nil {
            presentLoginScreen()
        } else {
            print("DEBUG: User User id is \(Auth.auth().currentUser?.uid)")
        }
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
