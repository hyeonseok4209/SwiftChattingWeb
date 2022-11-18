
import UIKit
import Firebase
import Kingfisher

private let reuseIdentifier = "HomeMenuUserCell"

class MainViewController: UIViewController {
    
    //MARK: Properties
    
    private var users = [User]()
    private var filteredUsers = [User]()
    private var rooms = [Room]()
    private var currentUser:User?
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var inSearchMode: Bool {
        return searchController.isActive &&
        !searchController.searchBar.text!.isEmpty
    }
    
    private var topContainerView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private var containerView: UIView = {
        let view = UIView()
                
        return view
    }()
    
    private let searchUser: UITextField = {
        let textField = UITextField()
//        textField.borderStyle = .line
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 10
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.placeholder = "  친구검색"
        textField.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)

        return textField
    }()
    
    private let addUser: UIBarButtonItem = {
        let button =  UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.fill.badge.plus"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(addUserAlert))
        button.tintColor = .lightGray
     
        return button
    }()
    
    
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUser()
        fetchUsers()
        fetchRooms()
        configrueUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK: Selecters
    
    @objc func addUserAlert() {
        let alert = UIAlertController(title: "친구추가", message: nil, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "추가", style: .default) { (confirm) in
            var text:String? = alert.textFields?[0].text
            if text == nil { text = "" } else {
                self.addUserAction(textInput: text!)
            }
        }
        let cancel = UIAlertAction(title: "닫기", style: .cancel) { (cancel) in
            
        }
        alert.addTextField{ (addUserTextField) in
            addUserTextField.placeholder = "이메일을 입력해 주세요"
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func addUserAction(textInput: String) {
        Service.addUser(textInput: textInput) { adduserInfo in
            if adduserInfo.1 {
                self.alertMessage(message: "해당 유저가 없습니다")
            } else {
                if adduserInfo.0 == self.currentUser!.uid {
                    self.alertMessage(message: "자신 이외의 이메일 주소를 입력해 주세요")
                } else {
                    var checkUserExisit:Bool = false
                    for user in self.users {
                        if user.uid == adduserInfo.0 {
                            checkUserExisit = true
                            self.alertMessage(message: "이미 친구로 추가되어져 있습니다")
                            break
                        }
                    }
                    if !checkUserExisit {
                        COLLECTION_USERS.document(self.currentUser!.uid).updateData([
                            "friends": FieldValue.arrayUnion([adduserInfo.0])
                        ])
                        self.fetchUsers()
                        self.alertMessage(message: "친구가 추가되었습니다")}
                }
            }
        }
    }
    
    func alertMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

        let cancel = UIAlertAction(title: "확인", style: .cancel) { (cancel) in
            
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Firebase APIs
    
    func fetchCurrentUser() {
        let currentUserInfo = CurrentUserInfo.shared
        self.currentUser = currentUserInfo.currentUserInfo
    }
    
    func fetchUsers() {
        let usersInfo = UsersInfo.shared
        guard let users = usersInfo.users else { return }
        self.users = users
        self.tableView.reloadData()
    }

    func fetchRooms() {
        let roomsInfo = RoomsInfo.shared
        guard let rooms = roomsInfo.rooms else { return }
        self.rooms = rooms
    }
        
    //MARK: Configures and Helpers
    
    func configrueUI() {
        
        configureSearchController()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.fill.badge.plus"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(addUserAlert))
        
        self.navigationItem.rightBarButtonItem?.tintColor = .lightGray
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationItem.largeTitleDisplayMode = .never
                
        navigationController?.navigationBar.isHidden = false
        
        
        view.backgroundColor = .white
                        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                             bottom: view.safeAreaLayoutGuide.bottomAnchor,
                             right: view.rightAnchor, paddingTop: 0)
        
        configrueTableView()
        
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "친구 검색하기", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        
        if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            textField.textColor = .black
            if let clearButton = textField.value(forKey: "clearButton") as? UIButton {
                clearButton.tintColor = .black
            }
        }
    }
    
    
    func configrueTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(HomeMenuUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 80
        tableView.dataSource = self
        tableView.delegate = self
        
        containerView.addSubview(tableView)
        tableView.frame = view.frame
    }
}

extension MainViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! HomeMenuUserCell
            cell.user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
            return cell
    }
}

extension MainViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userForIndex = inSearchMode ? filteredUsers : users
        
        let roomCount:Int = rooms.count
        var count:Int = 0
        var userUID:[String] = []
        var userName:[String] = []
        var userNickname:[String] = []
        
        
        userUID.append(userForIndex[indexPath.row].uid)
        userName.append(userForIndex[indexPath.row].name)
        userName.append(currentUser!.name)
        userNickname.append(userForIndex[indexPath.row].nickname)
        userNickname.append(currentUser!.nickname) 
        
        for room in rooms {
            
            var roomMembers:[String] = room.members
                        
            if let index = roomMembers.firstIndex(of: currentUser!.uid) {
                roomMembers.remove(at: index)
            }
            
            if roomMembers == userUID {
                
                let controller = ChatController(room: room, currentUser: currentUser!)
             
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true, completion: nil)
                
                break
            } else {
                count += 1
                if roomCount == count {
                    userUID.append(currentUser!.uid)
                    Service.uploadRooms(currentUser: currentUser!, members: userUID, membersName: userName, membersNickName: userNickname) { room in
                        let controller = ChatController(room: room, currentUser: self.currentUser!)
                        let roomInfo = RoomsInfo.shared
                        guard var getRooms = roomInfo.rooms else { return }
                        getRooms.append(room)
                        roomInfo.rooms = getRooms
                     
                        let nav = UINavigationController(rootViewController: controller)
                        nav.modalPresentationStyle = .fullScreen
                        self.present(nav, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        filteredUsers = users.filter({ user -> Bool in
            return user.name.contains(searchText) || user.nickname.contains(searchText)
        })
        
        self.tableView.reloadData()
    }
}


