
import UIKit
import Firebase
import Kingfisher

class SettingMenuViewController: UIViewController {
    //MARK: Properties
    
    private var currentUser:User?
        
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.setDimensions(height: 80, width: 80)
        imageView.layer.cornerRadius = 10
        
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
    
    let editNickNameButton: UIButton = {
        let button = UIButton()
        button.setTitle("수정",for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(editNicknameAlert), for: .touchUpInside)
        
        return button
    }()
    
    let editProfileImageButton: UIButton = {
        let button = UIButton()
        button.setTitle("수정",for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(editProfileImageAlert), for: .touchUpInside)

        
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
        
        let url = URL(string: user.profileImageURL)
        profileImageView.kf.setImage(with: url)
        
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
    
    @objc func editProfileImageAlert() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func editNicknameAlert() {
        let alert = UIAlertController(title: "변경할 이름", message: nil, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) { (confirm) in
            var text:String? = alert.textFields?[0].text
            if text == nil { text = "" } else {
                self.editNicknameAction(textInput: text!)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel) { (cancel) in
            
        }
        alert.addTextField{ (addUserTextField) in
            addUserTextField.placeholder = "변경할 이름을 입력해주세요"
        }
        alert.addAction(confirm)
        alert.addAction(cancel)

        self.present(alert, animated: true, completion: nil)
    }
    
    func editNicknameAction(textInput: String) {
        let currentUserInfo = CurrentUserInfo.shared
        guard let uid = currentUserInfo.currentUserInfo?.uid else { return }
 
        let query = COLLECTION_USERS.document(uid)
        query.updateData(["nickname" : textInput])
        currentUserInfo.currentUserInfo?.nickname = textInput
        self.nicknameLabel.text = textInput
    }
        
    func configureUI() {
        view.backgroundColor = .white
        configurNavigationBar()
        
        
        
//        let profileImageViewHstack = UIStackView(arrangedSubviews: [profileImageView, editProfileImageButton])
//        profileImageViewHstack.axis = .horizontal
//        profileImageViewHstack.distribution = .fill
//
//        let nicknameLableHstack = UIStackView(arrangedSubviews: [nicknameLabel, editNickNameButton])
//        nicknameLableHstack.axis = .horizontal
//        profileImageViewHstack.distribution = .fill
        
        let Vstack = UIStackView(arrangedSubviews: [profileImageView, emailLabel, nameLabel, nicknameLabel])
        Vstack.axis = .vertical
        Vstack.alignment = .leading
        Vstack.spacing = 16
        
        view.addSubview(Vstack)
        Vstack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(editProfileImageButton)
        editProfileImageButton.anchor(left: profileImageView.rightAnchor, bottom: profileImageView.bottomAnchor, paddingLeft: 10)
        
        view.addSubview(editNickNameButton)
        editNickNameButton.anchor(left: nicknameLabel.rightAnchor, bottom: nicknameLabel.bottomAnchor, paddingLeft: 10)
        
        view.addSubview(logoutButton)
        logoutButton.centerX(inView: view)
        logoutButton.anchor(top: Vstack.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
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

extension SettingMenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            
            let currentUserInfo = CurrentUserInfo.shared
            let id = COLLECTION_MESSAGES.document().documentID
            let ref = Storage.storage().reference(withPath: "/profiles/\(id)")
            guard let user = currentUserInfo.currentUserInfo else { return }
            guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
            
            
            ref.putData(imageData, metadata: nil) {(meta, error) in
                ref.downloadURL { url, error in
                    let query = COLLECTION_USERS.document(user.uid)
                    let imageURL = url?.absoluteString
                    
                    query.updateData(["profileImageURL" : imageURL!])
                    
                    self.profileImageView.kf.setImage(with: url)
                    picker.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
