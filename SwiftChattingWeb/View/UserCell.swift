
import UIKit

class UserCell: UITableViewCell {
    
    //MARK: Properties
    
    var user: User? {
        didSet { configure() }
    }
    
    private var checkBoxButton: UIButton = {
        var button = UIButton()
        
        return button
    }()
    
    var isCheck: Bool = false {
        didSet {
            let imageName = isCheck ? "checkmark.square" : "checkmark.square.fill"
            checkBoxButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
        
    }
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.backgroundColor = .lightGray
        imageView.alpha = 0.5
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
       
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        return label
    }()
    
    //MARK: View LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        profileImageView.setDimensions(height: 55, width: 55)
        profileImageView.layer.cornerRadius = 15
        
        addSubview(nameLabel)
        nameLabel.centerY(inView: self, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
        
        addSubview(nicknameLabel)
        nicknameLabel.centerY(inView: self, leftAnchor: nameLabel.rightAnchor, paddingLeft: 5)
        
        addSubview(checkBoxButton)
        checkBoxButton.centerY(inView: self)
        checkBoxButton.anchor(right: rightAnchor, paddingRight: 10)
        checkBoxButton.setDimensions(height: 20, width: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configures and Helpers
    
    func configure() {
        guard let user = user else { return }
        nicknameLabel.text = user.nickname
        nameLabel.text = user.name
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        isCheck.toggle()
    }
}
