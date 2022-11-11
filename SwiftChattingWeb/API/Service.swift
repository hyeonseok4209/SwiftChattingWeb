
import Firebase

struct Service {
    
    static func fetchUsers(completion: @escaping([User]) -> Void){
        var users = [User]()

        let currentUser = Auth.auth().currentUser
        let uid = Auth.auth().currentUser?.uid
        let currentQuery = COLLECTION_USERS.document(uid!)
        var friends: [String] = [] {
            didSet {
                for friend in friends {
                    COLLECTION_USERS.document(friend).getDocument { snapshot, error in
                        guard let dictionary = snapshot?.data() else { return }
                        let user = User(dictionary: dictionary)
                        if user.uid != currentUser?.uid {
                            users.append(user)
                            completion(users)
                        }
                    }
                }
            }
        }
                
        currentQuery.getDocument { snapshot, error in
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
                        
            friends = user.friends
            print("유저패치값 : \(friends)")
            
        }

    }
    
    static func addUser(textInput: String, completion: @escaping(((String,Bool)) -> Void)){
        
        var user:User = User(dictionary: ["": ""]) {
            didSet{
                print("친구추가 didSet : \(user.uid)")
                completion((user.uid, false))
            }
        }
                
        let query = COLLECTION_USERS.whereField("email", isEqualTo: textInput)
        
        query.getDocuments { snapshot, error in
            
            if let error = error {
                print("친구추가 에러 \(error.localizedDescription)")
            }
            
            let checkUsers = snapshot?.documents.count
            
            if checkUsers == 0 {
                completion(("", true))
            } else {
                snapshot?.documents.forEach ({ document in
                    let dictionary = document.data()
                    user = User(dictionary: dictionary)
                })
            }
        }
        
    }
    
    static func fetchCurrentUser(withUid uid: String, completion: @escaping(User) -> Void) {
            
        COLLECTION_USERS.document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("fetchUser 에러 : \(error.localizedDescription)")
                return
            }
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
  
        
    static func fetchMessages(roomID: String, completion: @escaping(([Message]) -> Void)){
        var messages = [Message]()
        
        let query = COLLECTION_MESSAGES.whereField("roomID", isEqualTo: roomID).order(by: "timestamp")
        
        query.addSnapshotListener{(snapshot, error) in
            if let error = error {
                print("DEBUG FethMessage Error : \(error.localizedDescription)")
            }
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let dictionary = change.document.data()
                    messages.append(Message(dictionary: dictionary))
                    completion(messages)
                }
            })
        }
        
    }
    
    static func fetchRooms(completion: @escaping([Room]) -> Void) {
        
        print("Fetch Rooms 시작")
        
        var rooms = [Room]()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_ROOMS.whereField("members", arrayContains: uid).order(by: "timestamp")
        
        query.getDocuments{ (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            }
            snapshot?.documents.forEach ({ document in
                let dictionary = document.data()
                let room = Room(dictionary:  dictionary)
                rooms.append(room)
                completion(rooms)
                print("Rooms is Fetched 패치된 룸 값: \(rooms)")
            })
        }
    }
    
    static func uploadRooms(currentUser: (User), members checkedUsers: [String], membersName: [String], membersNickName:[String],  completion: @escaping((Room) -> Void)){
        print("uploadRooms 시작")
        let id = COLLECTION_ROOMS.document().documentID

        let data = ["id": id,
                    "members": checkedUsers,
                    "createdBy": currentUser.uid,
                    "membersName" : membersName,
                    "membersNickname" : membersNickName,
                    "recentMessage" : "",
                    "timestamp": Timestamp(date: Date())] as [String : Any]
        
        COLLECTION_ROOMS.document(id).setData(data)
        
        let room = Room(dictionary: data)
        completion(room)

        print("uploadRooms 완료 채팅방 정보 : \(data)")
    }
    
    static func uploadMessage(roomID: String, message: String, user: User, unReadedMembers: [String],  completion:((Error?) -> Void)?){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let id = COLLECTION_MESSAGES.document().documentID
        
        let data = [
                    "id": id,
                    "roomID" : roomID,
                    "text": message,
                    "fromID": currentUid,
                    "userName": user.name,
                    "userNickname": user.nickname,
                    "imageURL" : "",
                    "unReadedMember" : unReadedMembers,
                    "timestamp": Timestamp(date: Date())] as [String : Any]
        
        COLLECTION_MESSAGES.document(id).setData(data)
    }
    
    static func uploadimageMessage(roomID: String, image: Data, message: String, user: User, completion:((Error?) -> Void)?){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let id = COLLECTION_MESSAGES.document().documentID
        
        let ref = Storage.storage().reference(withPath: "/images/\(id)")
        
        ref.putData(image, metadata: nil) {(meta, error) in
            ref.downloadURL { url, error in
                
                guard let imageURL = url?.absoluteString else { return }
                
                let data = ["id": id,
                            "roomID" : roomID,
                            "text": message,
                            "fromID": currentUid,
                            "userName": user.name,
                            "userNickname": user.nickname,
                            "imageURL": imageURL,
                            "timestamp": Timestamp(date: Date())] as [String : Any]
                COLLECTION_MESSAGES.document(id).setData(data)
            }
        }
    }
    
    static func removeReadedMember(messageID: String, userUID: String, completion:((Error?) -> Void)?){
        
        COLLECTION_MESSAGES.document(messageID).updateData([
            "unReadedMember" : FieldValue.arrayRemove([userUID])
        ])
        
    }
    
    static func readCheckedUserInfo(userDictionary user: (User) , completion:([String], [String]) -> Void) {
        
        var membersName: [String] = []
        var membersNickname: [String] = []
        
        var readUser = user
        
        membersName.append(readUser.name)
        membersNickname.append(readUser.nickname)
        print("추가된 멤버 이름 : \(membersName)")
        print("추가된 멤버 닉네임 : \(membersNickname)")
        completion(membersName, membersNickname)
        print("completed [String] 유저이름 : \(membersName), 유저닉네임 : \(membersNickname)")

    }
}
