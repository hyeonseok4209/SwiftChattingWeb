
import UIKit
import Firebase
import Kingfisher
import AVFoundation
import AVKit
import SideMenu

private let reuseIdentifier = "MessageCell"

class ChatController: UICollectionViewController {
    
    // MARK: Properties
    
    private var room: Room
    private let currentUser: User
    private var unReadedMembers: [String]
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
        self.unReadedMembers = room.members
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        navigationItem.largeTitleDisplayMode = .never
        
        if let index = unReadedMembers.firstIndex(of: currentUser.uid) {
            unReadedMembers.remove(at: index)
        }
                        
//        fecthUserInfofromMessage()
        configureUI()
//        configureSearchController()
        fechMessages()
//        fechMessagesInfo()
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
    
    @objc func handleSideMenu() {
 
        inputAccessoryView?.removeFromSuperview()

        var sideMenuSet = SideMenuSettings()
        sideMenuSet.presentationStyle = .menuSlideIn
        sideMenuSet.presentationStyle.backgroundColor = .clear

        let controller = SideMenuViewController()
        controller.room = self.room
        controller.messages = self.messages

        let sideMenu = SideMenuNavigationController(rootViewController: controller, settings: sideMenuSet)

        present(sideMenu, animated: true, completion: nil)
    }
    
    // MARK: Firebase API
    
    func fechMessages() {
        guard let index = MessagesInRoomInfo.shared.messagesInRoom?.firstIndex(where: { messagesInRoom in
            messagesInRoom.roomID == room.id
        }) else { return }
        
        guard var messagesinRoom = MessagesInRoomInfo.shared.messagesInRoom?[index].messages else { return }
        
        self.messages = messagesinRoom
           
        let query =  COLLECTION_MESSAGES.whereField("roomID", isEqualTo: room.id!).order(by: "timestamp")
        query.addSnapshotListener { querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            var snapshotCount = snapshot.documents.count - 1
            print("????????? ?????? ???????????? ??? \(snapshot.documents.count)")
            
            snapshot.documentChanges.forEach({ (change) in
                if (change.type == .added) {
                    
                    if snapshotCount == change.newIndex {
                        print("Add ????????? ?????? :\(change.newIndex)")
                        let dictionary = change.document.data()
                        let message = Message(dictionary: dictionary)
                        self.messages.append(message)
                        messagesinRoom = self.messages
                        self.collectionView.reloadData()
                        self.collectionView.scrollToItem(at: [0, self.messages.count - 1], at: .bottom, animated: false)
                    }
                }
                
                if (change.type == .modified) {
                    print("modified ????????? ??????")
                }
            })
        }
    }

    
    func fetchCurrentChatUsers() async throws -> [User]? {
        let members = room.members
        var setUsers = [User]()
        
        for member in members {
            let query = COLLECTION_USERS.document(member)
            let snapshot = try await query.getDocument()
            guard let dictionary = snapshot.data() else { return nil }
            let user = User(dictionary: dictionary)
            setUsers.append(user)
        }
        return setUsers
    }
    
    
    // MARK: Configures and Helpers
    
    func configureUI() {
        
        collectionView.bounces = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismiss))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action: #selector(handleSideMenu))
        
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
//        configureSearchController()
        configurNavigationBar()
        
//        let collectionViewLayout = CustumCollectionViewLayout()
        

        
        let collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewLayout.estimatedItemSize = CGSize(width: view.frame.width , height: 800)
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        (collectionView as UIScrollView).setContentOffset(.zero, animated: true)
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.keyboardDismissMode = .interactive
    }
    
//    func configureSideMenu() -> SideMenuNavigationController {
//
//
//        return sideMenu
//    }
//
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
        searchController.searchBar.placeholder = "????????? ????????????"
//        definesPresentationContext = false
    }
    
    func removeUnreadedMember() {
        var count: Int = 0
        for message in messages {
            var unReadedMember = message.unReadedMember
            if message.fromID != currentUser.uid {
                COLLECTION_MESSAGES.document(message.id).updateData([
                    "unReadedMember" : FieldValue.arrayRemove([currentUser.uid])
                ])
                if let index = unReadedMember.firstIndex(of: currentUser.uid){
                    unReadedMember.remove(at: index)
                    messages[count].unReadedMember = unReadedMember
                }
            }
            count += 1
        }
    }
    
    func fecthUserInfofromMessage() {
        let qurey = COLLECTION_USERS
        qurey.addSnapshotListener { snapshot, error in
            snapshot?.documentChanges.forEach({ change in
                if change.type == .modified {
                    let dictionary = change.document.data()
                    let userInfo = User(dictionary: dictionary)
                    var index:Int = 0
                    for message in self.messages {
                        if message.fromID == userInfo.uid{
                            
                            let messageQuery = COLLECTION_MESSAGES.document(message.id)
                            messageQuery.updateData(["userName" : userInfo.name])
                            messageQuery.updateData(["userNickname" : userInfo.nickname])
                            
                            self.messages[index].userName = userInfo.name
                            self.messages[index].userNickname = userInfo.nickname
                            index += 1
                        } else { index += 1 }
                    }
                }
            })
        }
    }
    
//    func fecthUserInfofromMessage(message: Message) async throws -> User? {
//        let qurey = COLLECTION_USERS.document(message.fromID)
//        let snapshot = try await qurey.getDocument()
//        guard let dictionary = snapshot.data() else { return nil }
//        let userInfo = User(dictionary: dictionary)
//
//        return userInfo
//    }
}

extension ChatController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
                
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        cell.backgroundColor = .white
        var message = messages[indexPath.row]
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleToFill
//        imageView.setDimensions(height: 90, width: 200)
//        imageView.image = UIImage(named: "imagePlaceholder")
        
        if message.mediaURL == "" {
            cell.message = message
        } else if message.mediaURL.contains(".mov") {
            //????????? ????????? ??????
            let urlString = message.mediaURL
            guard let url = URL(string: urlString) else { return cell }
            print("????????? URL : \(url)")
            let imageView = UIImageView()
            imageView.setDimensions(height: 150, width: 200)
            imageView.contentMode = .scaleAspectFill
            imageView.image = UIImage(named: "imagePlaceholder.jpeg")
            message.imageView = imageView
            message.imageView?.image = imageView.image
            
            let asset: AVAsset = AVAsset(url: url as URL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            do {
                let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
                message.imageView = UIImageView()
                message.imageView?.image = UIImage(cgImage: thumbnailImage)
                print("????????? ????????? ?????? ??????")
            } catch { print("????????? ????????? ??????") }
            
//            AVAsset(url: url).generateThumbnail { [weak self] (image) in
//                DispatchQueue.main.async {
//                    print("????????? ????????? ?????? ??????")
//                    guard let image = image else { return }
//                    message.imageView = UIImageView()
//                    message.imageView?.image = image
//                    print("????????? ????????? ?????? ??????")
//                }
//            }
            
            cell.message = message
        } else {
            //????????? ????????? ??????
            
            let urlString = message.mediaURL
            
            let imageView = UIImageView()
            imageView.setDimensions(height: 150, width: 200)
            imageView.contentMode = .scaleAspectFill
            imageView.image = UIImage(named: "imagePlaceholder.jpeg")
            message.imageView = imageView
            message.imageView?.image = imageView.image

            ImageCache.default.retrieveImage(forKey: urlString, options: nil) { result in
                switch result {
                case .success(let value):
                    if value.image != nil {
                        //????????? ???????????? ??????
                        message.imageView?.image = value.image
                    } else {
                        //????????? ???????????? ?????? ??????
                        let url = URL(string: urlString)
                        let resource = ImageResource(downloadURL: url!, cacheKey: urlString)
                        let imageView = UIImageView()
                                                
                        imageView.kf.setImage(
                            with: resource,
                            options: [.cacheMemoryOnly]) {
                            result in
                            switch result {
                            case .success(let value):
                                message.imageView = UIImageView()
                                message.imageView?.image = value.image
                                var indexPaths: [IndexPath] = []
                                indexPaths.append(indexPath)
                                self.collectionView.performBatchUpdates {
                                    self.collectionView.reloadItems(at: indexPaths)
                                }
                            case .failure(let error):
                                print("????????? ?????? ?????? \(error)")
                            }
                        }
                    }
                case .failure(let error):
                    print("????????? ?????? ?????? \(error)")
                }
            }
            
            cell.message = message
        }

        
//        cell.message = inSearchMode ? filteredMessages[indexPath.row] : messages[indexPath.row]
        
        cell.layoutIfNeeded()
        cell.layoutSubviews()
 
        return cell
    }
    
 
    func resizeImage(image: UIImage) -> UIImage  {
        
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        
        let scaleFactor = 250 / originalWidth
        let newHeight = originalHeight * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width: 200, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: 200, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
        
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if messages[indexPath.row].mediaURL.contains(".mov") {
            guard let url = URL(string: messages[indexPath.row].mediaURL) else { return }
            let playerController = AVPlayerViewController()
            let player = AVPlayer(url: url)
            playerController.player = player
            
            self.present(playerController, animated: true){
                player.play()
            }
        }
    }    
}

extension ChatController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 8, bottom: 16, right: 8)
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        <#code#>
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let estimatedHeight: CGFloat = 1000

        let frame = CGRect(x: 0 , y:0, width: view.frame.width, height: 80)
        let estimatedSizeCell = MessageCell(frame: frame)
        estimatedSizeCell.message = messages[indexPath.row]

        estimatedSizeCell.layoutIfNeeded()
//        estimatedSizeCell.setNeedsLayout()
        estimatedSizeCell.prepareForReuse()

        let targetSize = CGSize(width: view.frame.width, height: estimatedHeight)
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(targetSize)

        return CGSize(width: view.frame.width, height: estimatedSize.height)
    }

}

extension ChatController: CustomInputAccessoryViewDelegate {
     
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String) {
        
        // ????????? ????????? ?????????
   
        guard let roomID = self.room.id else { return }
                
        let id = COLLECTION_MESSAGES.document().documentID
        
        let data = [
                    "id": id,
                    "roomID" : roomID,
                    "text": message,
                    "fromID": currentUser.uid,
                    "userName": currentUser.name,
                    "userNickname": currentUser.nickname,
                    "mediaURL" : "",
                    "unReadedMember" :unReadedMembers,
                    "timestamp": Timestamp(date: Date())] as [String : Any]
        
        COLLECTION_MESSAGES.document(id).setData(data)
        COLLECTION_ROOMS.document(roomID).updateData(["recentMessage" : message])
              
        inputView.messageInputTextView.text = nil
    }
    
    func inputImageView(_ inputView: CustomInputAccessoryView, wantsToSend image: Data) {
        
        // ????????? ????????? ?????????
        
        guard let roomID = self.room.id else { return }
        let id = COLLECTION_MESSAGES.document().documentID
        let ref = Storage.storage().reference(withPath: "/images/\(id)")
        
        ref.putData(image, metadata: nil) {(meta, error) in
            ref.downloadURL { url, error in
                
                guard let imageURL = url?.absoluteString else { return }
                
                let data = [
                            "id": id,
                            "roomID" : roomID,
                            "text": "",
                            "fromID": self.currentUser.uid,
                            "userName": self.currentUser.name,
                            "userNickname": self.currentUser.nickname,
                            "mediaURL" : imageURL,
                            "unReadedMember" : self.unReadedMembers,
                            "timestamp": Timestamp(date: Date())] as [String : Any]
                
                COLLECTION_MESSAGES.document(id).setData(data)
                COLLECTION_ROOMS.document(roomID).updateData(["recentMessage" : "????????? ???????????????"])
                
            }
        }
    }
    
    func uploadVideo(_ inputView: CustomInputAccessoryView, wantsToSend videoURL: NSURL) {
        // ????????? ?????????
        guard let roomID = self.room.id else { return }
        let imageView = UIImageView()
        let id = COLLECTION_MESSAGES.document().documentID
        let ref = Storage.storage().reference(withPath: "/videos/\(id).mov")
        
        ref.putFile(from: videoURL as URL, metadata: nil) {(meta, error) in
            ref.downloadURL { url, error in
                
                guard let getURL = url else { return }
 
                let data = [
                            "id": id,
                            "roomID" : roomID,
                            "text": "",
                            "fromID": self.currentUser.uid,
                            "userName": self.currentUser.name,
                            "userNickname": self.currentUser.nickname,
                            "mediaURL" : "\(getURL)",
                            "unReadedMember" : self.unReadedMembers,
                            "timestamp": Timestamp(date: Date())] as [String : Any]
                
                COLLECTION_MESSAGES.document(id).setData(data)
                COLLECTION_ROOMS.document(roomID).updateData(["recentMessage" : "???????????? ???????????????"])
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

extension AVAsset {
    
    func generateThumbnail(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let imageGenerator = AVAssetImageGenerator(asset: self)
            let time = CMTime(seconds: 0.0, preferredTimescale: 600)
            let times = [NSValue(time: time)]
            imageGenerator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { _, image, _, _, _ in
                if let image = image {
                    completion(UIImage(cgImage: image))
                } else {
                    print("????????? ????????? ????????? ?????? ??????")
                    completion(nil)
                }
            })
        }
    }
}
