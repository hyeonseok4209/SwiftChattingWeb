
import UIKit
import Firebase

private let reuseIdentifier = "SideMenuUserCell"

class SideMenuViewController: UIViewController {
    //MARK: Properties
    
    var room: Room?
    var users = [User]()
    
    private let tableView = UITableView()
    
    private let exitButton:UIButton = {
        let button = UIButton()
        button.setTitle("채팅방 나가기", for: .normal)
        button.setHeight(height: 50)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        return button
    }()
    
    private var containerView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        fechCurrentChatusers()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: Configure and Helpers
    
    func configureUI() {
        view.addSubview(exitButton)
        exitButton.anchor( left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingRight: 10)
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: exitButton.topAnchor, right: view.rightAnchor, paddingRight: 10)
    }
    
    func configureTableView() {
        
                
        tableView.tableFooterView = UIView()
        tableView.register(SideMenuUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 85
        tableView.delegate = self
        tableView.dataSource = self
        
        containerView.addSubview(tableView)
        tableView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor)
//        tableView.frame = view.frame
    }
 
    func fechCurrentChatusers() {
        let members = room!.members
         
        for member in members {
            let query = COLLECTION_USERS.document(member)
            query.getDocument { snapshot, error in
                guard let dictionary = snapshot?.data() else { return }
                let user = User(dictionary: dictionary)
                self.users.append(user)
                
                self.tableView.reloadData()
            }
        }
    }
}

extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                
        let usersCount = users.count
        
        return usersCount
    }
    
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
//        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! HomeMenuUserCell
//        cell.backgroundColor = .white
//        cell.selectionStyle = .none
//        guard let getUsers = users else { return cell }
//        print("현재 유저 정보 \(getUsers)")
//        cell.user = getUsers[indexPath.row]
//
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("cell 설정 시작")
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SideMenuUserCell
        
        cell.user = users[indexPath.row]
        
        return cell
    }
}

extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
