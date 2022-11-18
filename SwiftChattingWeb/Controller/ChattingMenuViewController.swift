
import UIKit
import Firebase


private let reuseIdentifier = "ChatCell"

class ChattingMenuViewController: UIViewController {
    
    //MARK: Properties
    
    private let tableView = UITableView()
    private var rooms = [Room]()
    private var currentUser: User!
    private var filteredRooms = [Room]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var inSearchMode: Bool {
        return searchController.isActive &&
        !searchController.searchBar.text!.isEmpty
    }
    
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .systemBlue
        
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        return label
    }()
    
    //MARK: View Lifecylce
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        async {
            try await fetchRoomsInfo()
            fetchRooms()
            fetchCurrentUser()
        }
        
    }
    
    //MARK: Selectors
    
    @objc func showNewChatting(){
        let controller = NewChattingController()
        controller.delegate = self
        controller.rooms = rooms
     
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    //MARK: Firebase API
    func fetchRoomsInfo() async throws -> Void {
        
        let currentUser = CurrentUserInfo.shared
        let roomsInfo = RoomsInfo.shared
        
        var rooms = [Room]()
        
        guard let uid = currentUser.currentUserInfo?.uid else { return }
 
        let query = COLLECTION_ROOMS.whereField("members", arrayContains: uid).order(by: "timestamp")
        
        let snapshot = try await query.getDocuments()
        
        snapshot.documents.forEach { document in
            let dictionary = document.data()
            let room = Room(dictionary:  dictionary)
            rooms.append(room)
        }
        self.rooms = rooms
        roomsInfo.rooms = rooms
    }
    
    func fetchRooms() {
        let roomsInfo = RoomsInfo.shared
        guard let rooms = roomsInfo.rooms else { return }
        self.rooms = rooms
        self.tableView.reloadData()
    }
    
    func fetchCurrentUser() {
        let currentUserInfo = CurrentUserInfo.shared
        self.currentUser = currentUserInfo.currentUserInfo
        
        self.titleLabel.text = "\(self.currentUser.name)(\(self.currentUser.nickname))"
        self.emailLabel.text = self.currentUser.email
    }
    
    func fechtMemberInfo(indexPath: Int) async throws -> [String] {

        let members = rooms[indexPath].members
        print("인덱스 [ \(indexPath) ]의 룸 멤버스 : \(members) ")
        var usersName:[String] = []
        
        for member in members {
            let query = COLLECTION_USERS.document(member)
            let document = try await query.getDocument()
            guard let dictionary = document.data() else { return [] }
            let userInfo = User(dictionary: dictionary)
            usersName.append(userInfo.name)
        }
            
        return usersName
    }
    
//    func fechtMemberInfo(indexPath: Int) async throws -> [String] {
//        let members = rooms[indexPath].members
//        var usersName:[String] = []
//        for user in members {
//            let query = COLLECTION_USERS.document(user)
//            let document = try await query.getDocument()
//            guard let dictionary = document.data() else { return []}
//            let userInfo = User(dictionary: dictionary)
//            usersName.append(userInfo.name)
//        }
//
//        return usersName
//    }
            
    //MARK: Configures and Helpers
    
    
    func configureUI() {
        
        configureSearchController()
        
        view.backgroundColor = .white
        
        let vStack = UIStackView(arrangedSubviews: [titleLabel, emailLabel])
        vStack.axis = .vertical
        vStack.spacing = 0
        vStack.distribution = .fill
        view.addSubview(vStack)
        
        let hStack = UIStackView(arrangedSubviews: [vStack, newChattingButton])
        hStack.axis = .horizontal
        hStack.spacing = 16
        hStack.backgroundColor = .white
        view.addSubview(hStack)
        
//        hStack.setHeight(height: 80)
        hStack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 40, paddingRight: 40)
        hStack.distribution = .equalSpacing
        
        view.addSubview(containerView)
        containerView.anchor(top: hStack.bottomAnchor, left: view.leftAnchor,
                             bottom: view.safeAreaLayoutGuide.bottomAnchor,
                             right: view.rightAnchor, paddingTop: 10)
        
        configureTableView()
        
    }
    

    func configureTableView() {
        tableView.backgroundColor = UIColor.init(hexString: 0xfbfbfb)
        tableView.rowHeight = 85
        tableView.register(ChatCell.self, forCellReuseIdentifier: reuseIdentifier)
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
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Messages"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
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
}

extension ChattingMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        cell.backgroundColor = UIColor.init(hexString: 0xfbfbfb)
        async {
            cell.usersName = try await fechtMemberInfo(indexPath: indexPath.row)
            cell.room = rooms[indexPath.row]
        }

        return cell
    }
}

extension ChattingMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = rooms[indexPath.row]
        let controller = ChatController(room: room, currentUser: currentUser)
     
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
}

// MARK: NewChattingControllerDelegate

extension ChattingMenuViewController: NewChattingControllerDelegate {
    func controller(_ controller: NewChattingController, wantGoRoom room: Room, fromCurrentUser currentUser: User) {
        
        controller.dismiss(animated: true, completion: nil)

        let controller = ChatController(room: room, currentUser: currentUser)
        let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true, completion: nil)
    }
}

extension ChattingMenuViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        filteredRooms = rooms.filter({ room -> Bool in
            return (room.membersName.contains(searchText))
        })
        
        self.tableView.reloadData()
    }
}
