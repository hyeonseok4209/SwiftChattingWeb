
import UIKit

private let reuseIdentifier = "UserCell"

protocol NewChattingControllerDelegate: class {
    func controller(_ controller: NewChattingController, wantToStartChatWith user: User)
}

class NewChattingController: UITableViewController {
    
    //MARK: Properties
    
    private var users = [User]()
    weak var delegate: NewChattingControllerDelegate?
        
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchUsers()
    }
    
    //MARK: Selectors
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Firebase API
    
    func fetchUsers() {
        Service.fetchUsers{ users in
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    //MARK: Configures and Helpers
    
    func configureUI() {
        configurNavigationBar()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        
        tableView.tableFooterView = UIView()
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 80
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
        navigationItem.title = "새로운 채팅방"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
    }
}

extension NewChattingController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        cell.user = users[indexPath.row]
        return cell
    }
}

extension NewChattingController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("새로운 채팅방 Cell Tapped is \(indexPath.row)")
        delegate?.controller(self, wantToStartChatWith: users[indexPath.row])
    }
}
