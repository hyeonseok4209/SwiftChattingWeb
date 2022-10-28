
import Firebase

struct AuthService {
    static let shared = AuthService()
    
    func logUserIn(withEmail email: String, password: String, completion: @escaping (AuthDataResult?, Error?)->Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
}
