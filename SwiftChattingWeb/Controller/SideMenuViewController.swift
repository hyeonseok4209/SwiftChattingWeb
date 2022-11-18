
import UIKit
import Firebase

private let reuseIdentifier = "SideMenuUserCell"

class SideMenuViewController: UIViewController {
    //MARK: Properties
    
    var room: Room?
    var users = [User]()
    var messages = [Message]()
    
    private let tableView = UITableView()
    
    private let exitButton:UIButton = {
        let button = UIButton()
        button.setTitle("채팅방 나가기", for: .normal)
        button.setHeight(height: 50)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(exitHandler), for: .touchUpInside)
        
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
    
    // MARK: Selectors
    
    @objc func exitHandler() {
        guard let roomInfo = room else { return }
        //채팅방 인원이 2명 이하인 경우
        if roomInfo.members.count <= 2 {
            removeRoom(room: roomInfo)
            removeMessages(room: roomInfo)
            
            let rootView = presentingViewController

            dismiss(animated: true, completion: {
                rootView?.dismiss(animated: true)
            })
        } else {
            removeMember(room: roomInfo)
            
            let rootView = presentingViewController

            dismiss(animated: true, completion: {
                rootView?.dismiss(animated: true)
            })
        }
    }
    
    func removeRoom(room:Room) {
        COLLECTION_ROOMS.document(room.id!).delete() { error in
            if let error = error { print("채팅방 나가기 및 해당 채팅방 삭제 에러: \(error.localizedDescription)")}

            let roomsInfo = RoomsInfo.shared
            var rooms = roomsInfo.rooms
            rooms = rooms?.filter({ room in
                room.id != room.id
            })
            roomsInfo.rooms = rooms
        }
    }
    
    func removeMessages(room:Room) {
        let query = COLLECTION_MESSAGES.whereField("roomID", isEqualTo: room.id!)
        query.getDocuments { snapshot, error in
            snapshot?.documents.forEach({ document in
                document.reference.delete()
            })
            if ((snapshot?.isEmpty) != nil) {

            }
        }
    }
    
    func removeMember(room:Room){
        
        
        
        var getRoom = room
        let currentUserInfo = CurrentUserInfo.shared
        guard let currentUser = currentUserInfo.currentUserInfo else { return }
        let roomsInfo = RoomsInfo.shared
        guard var rooms = roomsInfo.rooms else { return }
        
        let query = COLLECTION_ROOMS.document(room.id!)
        query.updateData([
            "members" : FieldValue.arrayRemove([currentUser.uid]),
            "membersName" : FieldValue.arrayRemove([currentUser.name]),
            "membersNickname" : FieldValue.arrayRemove([currentUser.nickname])
        ])
        
        
        rooms = rooms.filter({ getRoom in
            getRoom.id != getRoom.id
        })
                
        let filteredMembers = getRoom.members.filter { member in
            member != currentUser.uid
        }
        
        let filteredNames = getRoom.membersName.filter { name in
            name != currentUser.name
        }
        
        let filteredNicknames = getRoom.membersNickname.filter { nickname in
            nickname != currentUser.nickname
        }
        
        getRoom.members = filteredMembers
        getRoom.membersName = filteredNames
        getRoom.membersNickname = filteredNicknames
        
        rooms.append(getRoom)
        roomsInfo.rooms = rooms
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SideMenuUserCell
        
        cell.user = users[indexPath.row]
        
        return cell
    }
}

extension SideMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
