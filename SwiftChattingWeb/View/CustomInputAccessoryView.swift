
import UIKit

protocol CustomInputAccessoryViewDelegate: class {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String)
}

class CustomInputAccessoryView: UIView {
    
    // MARK: Properties
    
    weak var delegate: CustomInputAccessoryViewDelegate?
    
    lazy var messageInputTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.backgroundColor = UIColor.init(hexString: 0xfbfbfb)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.isScrollEnabled = false
        
        return textView
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("전송", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.systemCyan, for: .normal)
        button.addTarget(self, action: #selector(handleSendMessage), for: .touchUpInside)
        
        return button
    }()
    
    private let placeHolderLabel: UILabel = {
        let label = UILabel()
        
        label.text = "메세지를 입력해주세요"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        
        return label
    }()
    
    // MARK: View Lifecycle

    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = .white
        autoresizingMask = .flexibleHeight
        
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 10
        layer.shadowOffset = .init(width: 0, height: -8)
        layer.shadowColor = UIColor.lightGray.cgColor
        
        addSubview(sendButton)
        sendButton.anchor(top: topAnchor, right: rightAnchor, paddingTop: 4, paddingRight: 8)
        sendButton.setDimensions(height: 50, width: 65)
        
        addSubview(messageInputTextView)
        messageInputTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 12, paddingLeft: 10, paddingBottom: 8, paddingRight: 8)
        
//        addSubview(placeHolderLabel)
//        placeHolderLabel.anchor(left: messageInputTextView.leftAnchor, paddingLeft: 4)
//        placeHolderLabel.centerY(inView: messageInputTextView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    // MARK: Selectors
    
    @objc func handleSendMessage() {
        guard let message = messageInputTextView.text else { return }
        delegate?.inputView(self, wantsToSend: message)
    }
    
    @objc func handleTextInputChange() {
        placeHolderLabel.isHighlighted = !self.messageInputTextView.text.isEmpty
    }
 
    // MARK: Configures and Helpers
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
