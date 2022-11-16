
import UIKit
import Firebase

class SettingMenuViewController: UIViewController {
    //MARK: Properties
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.backgroundColor = .lightGray
        imageView.alpha = 0.5
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
       
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        return label
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setHeight(height: 50)
        
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        
        return button
    }()
    
    
    // MARK: View Lifecyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchCurrentUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    // MARK: Firebase API
    
    func fetchCurrentUserInfo(){
        
        let currentUserInfo = CurrentUserInfo.shared
        
        guard let user = currentUserInfo.currentUserInfo else { return }
        
        self.emailLabel.text = "이메일 : \(user.email)"
        self.nameLabel.text = "이름 : \(user.name)"
        self.nicknameLabel.text = "별명 : \(user.nickname)"
        
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        Service.fetchCurrentUser(withUid: uid) { user in
//            self.user = user
//            self.emailLabel.text = "이메일 : \(user.email)"
//            self.nameLabel.text = "이름 : \(user.name)"
//            self.nicknameLabel.text = "별명 : \(user.nickname)"
//        }
    }
    
    //MARK: Configures and Helpers
    
    @objc func handleLogout() {
        logout()
        self.tabBarController?.selectedIndex = 0
    }
    
    func logout(){
        do {
            try Auth.auth().signOut()
            let currentUserInfo = CurrentUserInfo.shared
            let usersInfo = UsersInfo.shared
            currentUserInfo.currentUserInfo = nil
            usersInfo.users = nil
            
            presentLoginScreen()
        } catch {
            print("[Error] 로그아웃 에러 : \(error.localizedDescription)")
        }
    }
    
    func presentLoginScreen() {
        DispatchQueue.main.async {
            let controller = LoginViewController()
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
        
    func configureUI() {
        view.backgroundColor = .white
        configurNavigationBar()
        
        let stack = UIStackView(arrangedSubviews: [emailLabel, nameLabel, nicknameLabel])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(logoutButton)
        logoutButton.centerX(inView: view)
        logoutButton.anchor(top: stack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
    }
    
    func configurNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = .systemBlue
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Setting"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
    }
    
}
