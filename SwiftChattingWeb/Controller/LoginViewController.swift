
import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    private var viewModel = LoginViewModel()
    
    private let iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bubble.right")
        imageView.tintColor = .white
        
        return imageView
    }()
    
    private let titleText: UILabel = {
        let label = UILabel()
        label.text = "F. Talk"
        label.font = UIFont.systemFont(ofSize: 48)
        label.textColor = UIColor(ciColor: .white)
        return label
    }()
    
    private lazy var emailContainerView: UIView = {
        let containerView = InputContainerView(image: UIImage(systemName: "envelope")!,
                                               textField: emailTextField)
        return containerView
    }()
    
    private lazy var passwordContainerView: InputContainerView = {
        let containerView = InputContainerView(image: UIImage(systemName: "lock")!,
                                               textField: passwordTextField)
        return containerView
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
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
        let textField = CustomTextField(placeholder: "Email")
        textField.autocapitalizationType = .none
        
        return textField
    }()

    private let passwordTextField: CustomTextField = {
        let textField = CustomTextField(placeholder: "Password")
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    private let singUpButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "아직 계정이 없으세요?  ",
                                                        attributes:
                                                            [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string:"회원가입",
                                                  attributes:
                                                    [.font: UIFont.boldSystemFont(ofSize: 16), .foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    //MARK: View Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: Selectors
    
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
        
        AuthService.shared.logUserIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Failed to login with error \(error.localizedDescription)")
                return
            }
        }
        self.dismiss(animated: true, completion: nil)
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
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        iconImage.setDimensions(height: 100, width: 120)
        
        view.addSubview(titleText)
        titleText.centerX(inView: view)
        titleText.anchor(top: iconImage.bottomAnchor, paddingTop: 10)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                  passwordContainerView,
                                                  loginButton])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.anchor(top: titleText.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(singUpButton)
        singUpButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,
                            right: view.rightAnchor, paddingLeft: 32, paddingRight: 32)
        
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    func configureGradientLayer() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemBlue.cgColor, UIColor.systemCyan.cgColor]
        gradient.locations = [0, 1]
        view.layer.addSublayer(gradient)
        gradient.frame = view.frame
    }
    
}
