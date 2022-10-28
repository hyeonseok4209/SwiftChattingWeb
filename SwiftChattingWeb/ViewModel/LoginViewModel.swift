
import Foundation

struct LoginViewModel {
    var email: String?
    var password: String?
    
    var formIsVaild: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
    }
}
