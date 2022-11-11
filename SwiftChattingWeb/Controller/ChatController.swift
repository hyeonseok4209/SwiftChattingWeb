
import UIKit
import Firebase


private let reuseIdentifier = "MessageCell"

class ChatController: UICollectionViewController {
    
    // MARK: Properties
    
    private var room: Room
    private let currentUser: User
    private var messages = [Message]()
    private var filteredMessages = [Message]()
    private let searchController = UISearchController(searchResultsController: nil)
    
    var fromCurrentUser = false
    
    private lazy var customInputView: CustomInputAccessoryView = {
        let inputView = CustomInputAccessoryView(frame: CGRect(x: 0, y: 0,
                                                        width: view.frame.width, height: 50))
        inputView.delegate = self
        return inputView
    }()
    
    private var inSearchMode: Bool {
        return searchController.isActive &&
        !searchController.searchBar.text!.isEmpty
    }
    
    // MARK: View Lifecycle

    init(room: Room, currentUser: User) {
        self.room = room
        self.currentUser = currentUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        navigationItem.largeTitleDisplayMode = .never
        
//        print("전달받은 데이터값 | 채팅방 정보 : \(self.room) | 현재 유저 정보 : \(self.currentUser)")
        
        configureUI()
        configureSearchController()
        fechMessages()
    }
    
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: Selectors
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Firebase API
    
    func fechMessages() {
        Service.fetchMessages(roomID: room.id!) { messages in
            
            let indexPath = messages.count - 1
            
            let members = messages[indexPath].unReadedMember
   
            
            if members.count != 0 {
                for member in members {
                    if member == self.currentUser.uid {
                        Service.removeReadedMember(messageID: messages[indexPath].id, userUID: member) { error in
                            self.messages = messages
                            self.collectionView.reloadData()
                            self.collectionView.scrollToItem(at: [0, self.messages.count - 1], at: .bottom, animated: true)
                        }
                    } else if member != self.currentUser.uid && member == members[members.count-1] {
                        self.messages = messages
                        self.collectionView.reloadData()
                        self.collectionView.scrollToItem(at: [0, self.messages.count - 1], at: .bottom, animated: true)
                    }
                }
            } else {
                self.messages = messages
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: [0, self.messages.count - 1], at: .bottom, animated: true)
            }
        }
    }
    
    
    
    
    // MARK: Configures and Helpers
    
    func configureUI() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        
        collectionView.backgroundColor = .white
        configureSearchController()
        configurNavigationBar()
        
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
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
        navigationItem.title = room.membersName.joined(separator: ", ")
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
        searchController.searchBar.placeholder = "메세지 검색하기"
//        definesPresentationContext = false
    }
}

extension ChatController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inSearchMode ? filteredMessages.count : messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.message = inSearchMode ? filteredMessages[indexPath.row] : messages[indexPath.row]
        return cell
    }
}

extension ChatController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 8, bottom: 16, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0 , y:0, width: view.frame.width, height: 80)
        let estimatedSizeCell = MessageCell(frame: frame)
        estimatedSizeCell.message = messages[indexPath.row]
        estimatedSizeCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(targetSize)
        
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
}

extension ChatController: CustomInputAccessoryViewDelegate {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String) {
        
        if let index = room.members.firstIndex(of: currentUser.uid) {
            room.members.remove(at: index)
        }
        
        guard let roomID = self.room.id else { return }
        
        print("업로드 메세지: 현재 룸아이디 : \(roomID)")
        
        COLLECTION_ROOMS.document(roomID).updateData(["recentMessage" : message])
        
        Service.uploadMessage(roomID: room.id!, message: message, user: currentUser, unReadedMembers: room.members) { error in
            if let error = error{
                print("DEBUG: Failed to upload message with error \(error.localizedDescription)")
                return
            }
            
            print("업로드 메세지: 현재 룸아이디 : \(roomID)")
            
            COLLECTION_ROOMS.document(roomID).updateData(["recentMessage" : message])
        }
        inputView.messageInputTextView.text = nil
        print("메세지 업로드 성공")
    }
    
    func inputImageView(_ inputView: CustomInputAccessoryView, wantsToSend image: Data) {
        Service.uploadimageMessage(roomID: room.id!, image: image, message: "", user: currentUser) {
            error in
            if let error = error {
                print("DEBUG: Failed to upload message with error \(error.localizedDescription)")
                return
            }
        }

    }
}

extension ChatController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        filteredMessages = messages.filter({ message -> Bool in
            return message.text.contains(searchText)
        })
        
        self.collectionView.reloadData()
    }
}
