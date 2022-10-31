
import Firebase

struct Service {
    
    static func fetchUsers(completion: @escaping([User]) -> Void){
        var users = [User]()
        COLLECTION_USERS.getDocuments { snapshot, error in
            snapshot?.documents.forEach({document in
                
                let dictionary = document.data()
                let user = User(dictionary: dictionary)
                users.append(user)
                completion(users)
            })
        }
    }
    
    static func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
            
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
    
    static func fetchConversation(completion: @escaping([Conversation]) -> Void) {
        var conversations = [Conversation]()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = COLLECTION_MESSAGES.document(uid).collection("recent-messages").order(by: "timestamp")
                        
        query.addSnapshotListener{ (snapshot, error) in
                snapshot?.documentChanges.forEach({ change in
                let dictionary = change.document.data()
                let message = Message(dictionary: dictionary)
                    
                self.fetchUser(withUid: message.toID) { user in
                    let conversation = Conversation(user: user, message: message)
                    conversations.append(conversation)
                    completion(conversations)
                }
            })
        }
    }
    
    static func fetchMessages(forUser user: User, completion: @escaping(([Message]) -> Void)){
        var messages = [Message]()
        
        guard let crrentUid = Auth.auth().currentUser?.uid else { return}
        
        let query = COLLECTION_MESSAGES.document(crrentUid).collection(user.uid).order(by: "timestamp")
        
        query.addSnapshotListener{(snapshot, error) in
            if let error = error {
                print("DEBUG FethMessage Error : \(error.localizedDescription)")
            }
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let dictionary = change.document.data()
                    messages.append(Message(dictionary: dictionary))
                    completion(messages)
                    print("Fetch Message 성공")
                }
            })
        }
        
    }
    
    static func uploadMessage(_ message: String, to user: User, completion:((Error?) -> Void)?){
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let data = ["text": message,
                    "fromID": currentUid,
                    "toID": user.uid,
                    "timestamp": Timestamp(date: Date())] as [String : Any]
        
        COLLECTION_MESSAGES.document(currentUid).collection(user.uid).addDocument(data: data) { _ in
            COLLECTION_MESSAGES.document(user.uid).collection(currentUid).addDocument(data: data, completion: completion)
            
            COLLECTION_MESSAGES.document(currentUid).collection("recent-messages").document(user.uid).setData(data)
            
            COLLECTION_MESSAGES.document(user.uid).collection("recent-messages").document(currentUid ).setData(data)
        }
    }
}
