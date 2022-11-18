
import UIKit
import Firebase

class SingUpViewController: UIViewController {
    
    // MARK: Properties
    
    private var viewModel = LoginViewModel()
    
    private var imageView = UIImageView()
    private var imageURL: String?
    
    private let profileImageView: UIButton = {
        let button = UIButton(type: .system)
        
        button.backgroundColor = .lightGray
        button.contentMode = .scaleToFill
        button.clipsToBounds = true
        button.imageView?.setDimensions(height: 100, width: 100)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleEditProfileImage), for: .touchUpInside)
        
        return button
    }()
    
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setHeight(height: 50)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return button
    }()
    
    private let emailTextField: CustomTextField = {
        let textField = CustomTextField(placeholder: "이메일을 입력해주세요 ")
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1
        textField.autocapitalizationType = .none
        
        return textField
    }()

    private let passwordTextField: CustomTextField = {
        let textField = CustomTextField(placeholder: "비밀번호를 입력해주세요")
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    private let nameTextField: CustomTextField = {
        let textField = CustomTextField(placeholder: "이름을 입력해주세요")
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1
        
        return textField
    }()
    
    private let nickNameTextField: CustomTextField = {
        let textField = CustomTextField(placeholder: "닉네임을 입력해주세요")
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1
        
        return textField
    }()
        
    //MARK: View Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: Selectors
    
    @objc func handleEditProfileImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        
        checkFormStatus()
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let name = nameTextField.text else { return }
        guard let nickName = nickNameTextField.text else { return }
        
        if imageURL == nil {
            imageURL = "https://firebasestorage.googleapis.com/v0/b/swiftchattingapp-7fa02.appspot.com/o/profiles%2Fkakao_11.jpeg?alt=media&token=2681d621-3b9f-47e7-9a14-9d1ce3d501ca"
        }
        
        let id = COLLECTION_USERS.document().documentID

        let data = ["uid": id,
                    "FCMtoken": "",
                    "email": email,
                    "name" : name,
                    "nickname" : nickName,
                    "friends" : [],
                    "profileImageURL": imageURL as Any]
        
        COLLECTION_ROOMS.document(id).setData(data)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            AuthService.shared.logUserIn(withEmail: email, password: password) { result, error in
                
                //로그인 에러 디버그
                if let error = error {
                    print("DEBUG: Failed to login with error \(error.localizedDescription)")
                    return
                }
                async {
                    try await TabBarViewController().authenticateUser()
                }
                let rootView = self.presentingViewController

                self.dismiss(animated: true, completion: {
                    rootView?.dismiss(animated: true)
                })
            }
        }

    }
    
    //MARK: Configures and Helpers
    
    
    func checkFormStatus() {
        if viewModel.formIsVaild{
            loginButton.isEnabled = true
            loginButton.backgroundColor = .systemBlue
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = .lightGray
        }
    }
    
    func configureUI() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
            
        configureGradientLayer()
        
        view.addSubview(profileImageView)
        profileImageView.centerX(inView: view)
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)

        
      
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,
                                                  passwordTextField,
                                                   nameTextField,
                                                   nickNameTextField,
                                                  loginButton])
        stack.axis = .vertical
        stack.spacing = 30
        
        view.addSubview(stack)
        stack.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
                
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        nickNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    func configureGradientLayer() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemCyan.cgColor]
        gradient.locations = [0, 1]
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
    }
    
}

extension SingUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            
            let ref = Storage.storage().reference(withPath: "/profiles/")
            guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
            
            
            ref.putData(imageData, metadata: nil) {(meta, error) in
                ref.downloadURL { url, error in

                    let imageURL = url?.absoluteString
                    self.imageURL = imageURL
                    self.imageView.kf.setImage(with: url) {
                        result in
                        switch result {
                        case .success(let value):
                            self.profileImageView.backgroundColor = .none
                            self.profileImageView.imageView?.image = value.image
                        case .failure(let error):
                            print("이미지 불러오기 실패: \(error.localizedDescription)")
                        }
                    }
                    picker.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
