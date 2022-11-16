
import UIKit

//protocol CustomInputAccessoryViewDelegate: class {
//    func inputView(_ inputView: CustomInputAccessoryView, sendAsText message: String, sendAsImage image: UIImage)
//}

protocol CustomInputAccessoryViewDelegate: class {
    func inputView(_ inputView: CustomInputAccessoryView, wantsToSend message: String)
    
    func inputImageView(_ inputView: CustomInputAccessoryView, wantsToSend image: Data)
    
    func uploadVideo(_ inputView: CustomInputAccessoryView, wantsToSend videoURL: NSURL)
}

class CustomInputAccessoryView: UIView {
    
    // MARK: Properties
    
    weak var chatControllerDelegate: ChatController?
    
    weak var delegate: CustomInputAccessoryViewDelegate?
    
    private var pikedImage: UIImage?
        
    private let pikedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let imageViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .red

        return view
    }()
    
    private let addMediaButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.app"), for: .normal)
        button.setTitleColor(.systemCyan, for: .normal)
        button.imageView?.setDimensions(height: 25, width: 30)
        button.addTarget(self, action: #selector(handleSendMedia), for: .touchUpInside)
        
        return button
    }()
    
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
        button.setWidth(width: 50)
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
        
        addSubview(addMediaButton)
        addMediaButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 10, paddingLeft: 8)
        
        addSubview(sendButton)
        sendButton.anchor(top: topAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingRight: 12)
        
        addSubview(messageInputTextView)
        messageInputTextView.anchor(top: topAnchor, left: addMediaButton.rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 4, paddingRight: 8)
    }
    
    // MARK: Selectors
    
    @objc func handleSendMessage() {
        print("handleSendMessage tapped")
        guard let message = messageInputTextView.text else { return }

        delegate?.inputView(self, wantsToSend: message)
    }
    
//    @objc func handleTextInputChange() {
//        placeHolderLabel.isHighlighted = !self.messageInputTextView.text.isEmpty
//    }
    
    @objc func handleSendMedia() {

        presentInputActionSheet()
    }
 
    // MARK: Configures and Helpers
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentInputActionSheet() {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let videoPicker = UIImagePickerController()
        videoPicker.mediaTypes = ["public.movie"]
        videoPicker.delegate = self
        videoPicker.videoQuality = .typeMedium
        
        let actionSheet = UIAlertController(title: "미디어 전송",
                                            message: nil,
                                            preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "사진", style: .default, handler: { [weak self] _ in
            //사진 선택 실행 코드
            self?.window?.rootViewController?.present(imagePicker, animated: true, completion: nil)
 
        }))

        actionSheet.addAction(UIAlertAction(title: "동영상", style: .default, handler: { [weak self] _ in
            //동영상 선택 실행 코드
            self?.window?.rootViewController?.present(videoPicker, animated: true, completion: nil)
        }))

        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

        self.window?.rootViewController?.present(actionSheet, animated: true, completion: nil)
    }
    
    func presentPhotoInputActionsheet() {
        
    }
    
    func presentVideoInputActionsheet() {
        
    }
}


extension CustomInputAccessoryView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            pikedImage = image
            
            guard let imageData = pikedImage?.jpegData(compressionQuality: 0.4) else { return }
            delegate?.inputImageView(self, wantsToSend: imageData)
            
            picker.dismiss(animated: true, completion: nil)
        } else if let videoURL = info[.mediaURL] as? NSURL {
            delegate?.uploadVideo(self, wantsToSend: videoURL.filePathURL! as NSURL)
            picker.dismiss(animated: true, completion: nil)
        }

    }
}
