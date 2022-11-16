
import UIKit
import Firebase

private let reuseIdentifier = "UserCell"

protocol NewChattingControllerDelegate: class {
    func controller(_ controller: NewChattingController, wantGoRoom room: Room, fromCurrentUser currentUser: User)
}


class NewChattingController: UITableViewController {
    
    //MARK: Properties
    var rooms = [Room]()
    private var users = [User]()
    private var currentUser: User!
    private var indexPaths: [IndexPath] = []
    weak var delegate: NewChattingControllerDelegate?
    
    
        
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureUI()
        fetchCurrentUser()
        fetchUsers()
    }

    
    //MARK: Selectors
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleConfirm() {
        checkRoomExist()
    }
        
    //MARK: Firebase API
    
    func fetchUsers() {
        let usersInfo = UsersInfo.shared
        guard let users = usersInfo.users else { return }
        self.users = users
        self.tableView.reloadData()
    }
    
    func uploadRooms() {
        let roomsInfo = RoomsInfo.shared
                
        let readCheckedUserInfo = readCheckedUserInfo()
        let membersName = readCheckedUserInfo.0
        let membersNickName = readCheckedUserInfo.1
        let checkedUsers = checkedUsers()
        let currentUser = currentUser
        
        Service.uploadRooms(currentUser: currentUser!, members: checkedUsers, membersName: membersName, membersNickName: membersNickName) { room in
            guard var getRooms = roomsInfo.rooms else { return }
            getRooms.append(room)
            roomsInfo.rooms = getRooms
            self.delegate?.controller(self, wantGoRoom: room, fromCurrentUser: self.currentUser)
        }
    }
        
    func fetchCurrentUser() {
        let currentUserInfo = CurrentUserInfo.shared
        self.currentUser = currentUserInfo.currentUserInfo
    }
    
    //MARK: Configures and Helpers
    
    func configureUI() {
        configurNavigationBar()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleConfirm))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        
        tableView.tableFooterView = UIView()
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 80
        tableView.allowsMultipleSelection = true
        
        updatedSelectedCell()
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
    
    func checkRoomExist() {
        
        var isExist: Bool = false
        
        let rooms = self.rooms
        for membersFromRooms in rooms {
            var members = membersFromRooms
            var checkedUsers = checkedUsers()
            
            members.members.sort()
            checkedUsers.sort()
            
            if members.members == checkedUsers {
                
                isExist = true
                
                print("중복된 방이 있습니다, RoomId: \(members.id)")
                self.delegate?.controller(self, wantGoRoom: members, fromCurrentUser: self.currentUser)
            }
        }
        if !isExist { uploadRooms() }
    }
    
    func checkedUsers() -> [String] {
        var start:Int = 0
        let end:Int = self.indexPaths.count
        var checkedUsers: [String] = []
        
        guard let currentUser = Auth.auth().currentUser?.uid else { return [] }
        
        while start < end {
            checkedUsers.append(self.users[self.indexPaths[start].row].uid)
            start += 1
        }
        
        checkedUsers.append(currentUser)
        print("선택된 유저 불러오기 완료 | 선택된 유저 : \(checkedUsers)")
        return checkedUsers
    }
    
    func readCheckedUserInfo() -> ([String], [String]){
        
        let checkedUser = checkedUsers()
        let indexPaths = self.indexPaths
        let currentUser = self.currentUser
        
        var membersName:[String] = []
        var membersNickName:[String] = []
        
       
        
        for indexPath in indexPaths {
            membersName.append(self.users[indexPath.row].name)
            membersNickName.append(self.users[indexPath.row].nickname)
        }
        
        membersName.append(currentUser!.name)
        membersNickName.append(currentUser!.nickname)
        
        return (membersName, membersNickName)
    }
}

extension NewChattingController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        cell.user = users[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}

extension NewChattingController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("새로운 채팅방 Cell Tapped is \(indexPath.row)")
        updatedSelectedCell()
//        delegate?.controller(self, wantToStartChatWith: users[indexPath.row], fromCurrentUser: currentUser)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updatedSelectedCell()
    }
    
    func updatedSelectedCell() {
        indexPaths = tableView.indexPathsForSelectedRows ?? []
        if indexPaths == [] { navigationItem.rightBarButtonItem?.isEnabled = false } else { navigationItem.rightBarButtonItem?.isEnabled = true }
    }
}



