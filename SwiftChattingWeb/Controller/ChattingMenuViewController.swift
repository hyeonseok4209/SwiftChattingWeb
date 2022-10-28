
import UIKit


private let reuseIdentifier = "ChatCell"

class ChattingMenuViewController: UIViewController {
    
    //MARK: Properties
    
    private let tableView = UITableView()
    
    private var containerView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private let newChattingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "message.badge.circle.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.imageView?.setDimensions(height: 40, width: 45)
        
        button.addTarget(self, action: #selector(showNewChatting), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: View Lifecylce
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: Seletors
    
    @objc func showNewChatting(){
        let controller = NewChattingController()
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
        
    //MARK: Configures and Helpers
    
    
    func configureUI() {
        view.backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [newChattingButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.backgroundColor = .white
        
        view.addSubview(stack)
        stack.setHeight(height: 80)
        stack.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 50)
        
        view.addSubview(containerView)
        containerView.anchor(top: stack.bottomAnchor, left: view.leftAnchor,
                             bottom: view.safeAreaLayoutGuide.bottomAnchor,
                             right: view.rightAnchor, paddingTop: 10)
        newChattingButton.anchor(left: stack.leftAnchor ,paddingLeft: 300)
                
        configureTableView()
        
    }
    

    func configureTableView() {
        tableView.backgroundColor = UIColor.init(hexString: 0xfbfbfb)
        tableView.rowHeight = 80
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        containerView.addSubview(tableView)
        tableView.frame = view.frame
    }
       
    
    func configurNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = .systemBlue
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
//        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Messages"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
    }
}

extension ChattingMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = "Test Cell"
        cell.backgroundColor = UIColor.init(hexString: 0xfbfbfb)
        return cell
    }
}

extension ChattingMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Taped \(indexPath.row)")
    }
    
}

// MARK: NewChattingControllerDelegate

extension ChattingMenuViewController: NewChattingControllerDelegate {
    func controller(_ controller: NewChattingController, wantToStartChatWith user: User) {
        
        controller.dismiss(animated: true, completion: nil)
        let chat = ChatController(user: user)
        navigationController?.pushViewController(chat, animated: true)
    }
}
