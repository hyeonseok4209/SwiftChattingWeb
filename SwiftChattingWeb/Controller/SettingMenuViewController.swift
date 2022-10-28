
import UIKit
import Firebase

class SettingMenuViewController: UIViewController {
    //MARK: Properties
    
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
        
    }
    
    //MARK: Configures and Helpers
    
    @objc func handleLogout() {
        logout()
    }
    
    func logout(){
        do {
            try Auth.auth().signOut()
            presentLoginScreen()
        } catch {
            print("DEBUG: Error signing out..")
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
        
        view.addSubview(logoutButton)
        logoutButton.centerX(inView: view)
        logoutButton.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                            left: view.leftAnchor, right: view.rightAnchor,
                            paddingTop: 10, paddingLeft: 32, paddingRight: 32)
        
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
