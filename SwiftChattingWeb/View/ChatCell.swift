
import UIKit

class ChatCell: UITableViewCell {
       
    // MARK: Properties
    
    var room: Room? {
        didSet { configure() }
    }
    private let roomNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
                
        return label
    }()
    
    private let recentMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
                
        return label
    }()
    
    //View LifeCycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(roomNameLabel)
        roomNameLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 20, paddingLeft: 20)
        
        addSubview(recentMessageLabel)
        recentMessageLabel.anchor(top: roomNameLabel.bottomAnchor, left: leftAnchor, paddingTop: 5, paddingLeft: 20)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configures and Helpers
    
    func configure() {
        guard let room = room else { return }
        
        roomNameLabel.text = room.membersName.joined(separator: ", ")
        recentMessageLabel.text = room.recentMessage
        
    }
    
    
    
}
