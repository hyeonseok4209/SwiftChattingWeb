
import UIKit
import SDWebImage
import Kingfisher

class MessageCell: UICollectionViewCell {
    
    // MARK: Properties
    
    var userInfo: User?
    
    var message: Message? {
        didSet {
            configure()
        }
    }
    
    var bubbleLeftAnchor: NSLayoutConstraint!
    var bubbleRightAnchor: NSLayoutConstraint!
    
    var dateLabelLeftAnchor: NSLayoutConstraint!
    var dateLabelRightAnchor: NSLayoutConstraint!
    
    var readedLabelLeftAnchor: NSLayoutConstraint!
    var readedLabelRightAnchor: NSLayoutConstraint!
    
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private var pikedImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.setWidth(width: 200)
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = UIImage(named: "imagePlaceholder.jpeg")
        imageView.contentMode = .scaleAspectFill
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.textColor = .white
        
        return textView
    }()
    
    private let bubbleContainer: UIView = {
        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemCyan
        return view
    }()
    
    private let readedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemBlue
        label.text = "2"
        
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.text = "오후 00시 00분"
        
        return label
    }()
    
    
    // MARK: View Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
         
        addSubview(profileImageView)
        
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingLeft: 8)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 10
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.topAnchor,left: profileImageView.rightAnchor, paddingLeft: 10)
        
        addSubview(bubbleContainer)
        bubbleContainer.anchor(top: nameLabel.bottomAnchor,bottom: bottomAnchor, paddingTop: 5)
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        bubbleContainer.layer.cornerRadius = 10

        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 10)
        bubbleLeftAnchor.isActive = false

        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -10)
        bubbleRightAnchor.isActive = false

        bubbleContainer.addSubview(textView)
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 4,  paddingRight: 12)
        
                
        
        
        addSubview(dateLabel)
        dateLabel.anchor(bottom: bubbleContainer.bottomAnchor, paddingBottom: 2)
        
        dateLabelRightAnchor = dateLabel.rightAnchor.constraint(equalTo: bubbleContainer.leftAnchor, constant: -10)
        bubbleLeftAnchor.isActive = false
        
        dateLabelLeftAnchor = dateLabel.leftAnchor.constraint(equalTo: bubbleContainer.rightAnchor, constant: 10)
        bubbleLeftAnchor.isActive = false
        
        bubbleContainer.addSubview(pikedImageView)
        pikedImageView.tag = 100
        pikedImageView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor, bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 12,  paddingRight: 12)
        
        addSubview(readedLabel)
        readedLabel.anchor(bottom: dateLabel.topAnchor, paddingBottom: 5)
        
        readedLabelLeftAnchor = readedLabel.leftAnchor.constraint(equalTo: dateLabel.leftAnchor, constant: 0)
        readedLabelLeftAnchor.isActive = false
        
        readedLabelRightAnchor = readedLabel.rightAnchor.constraint(equalTo: dateLabel.rightAnchor, constant: 0)
        readedLabelRightAnchor.isActive = false
        
        textView.isHidden = true
        pikedImageView.isHidden = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        pikedImageView = UIImageView()
        pikedImageView.isHidden = true
        textView.isHidden = true
        
        pikedImageView.image = nil
//        message = nil
//        pikedImageView.removeFromSuperview()
//        textView.removeFromSuperview()
//        profileImageView.removeFromSuperview()
//        nameLabel.removeFromSuperview()
//        dateLabel.removeFromSuperview()

    }
    
    // MARK: Configrues and Helpers
    
    func configure() {
        guard let message = message else { return }
        let query = COLLECTION_USERS.document(message.fromID)

        query.getDocument { snapsot, error in
            guard let url = snapsot?.get("profileImageURL") else { return }
            let stringURL = String(describing: url)
            let imageURL = URL(string: stringURL)
            self.profileImageView.kf.setImage(with: imageURL)
        }
        
        let viewModel = MessageViewModel(message: message)
        
        bubbleContainer.backgroundColor = viewModel.messageBackgroundColor
        
//        if message.imageView == nil {
//            print("텍스트 메세지 입니다")
//            let imageViewWithTag = bubbleContainer.viewWithTag(100)
//            imageViewWithTag?.removeFromSuperview()
//
//            textView.isHidden = false
//            pikedImageView.isHidden = true
//
//            textView.text = message.text
//        } else {
//            print("미디어 메세지 입니다.")
//            textView.isHidden = true
//            pikedImageView.isHidden = false
//            bubbleContainer.backgroundColor = .none
//
//            let image = resizeImage(image: (message.imageView?.image)!)
//            pikedImageView.setDimensions(height: image.size.height, width: image.size.width)
//
//            pikedImageView.image = image
//
//            self.contentView.setNeedsLayout()
//            self.contentView.layoutIfNeeded()
//
//        }
                
        if message.mediaURL == "" {
            
            print("텍스트 메세지 입니다")
  
            textView.isHidden = false
            pikedImageView.isHidden = true
            
            textView.text = message.text
            

        } else if message.mediaURL != "" && !message.mediaURL.contains(".mov") {
            
            print("이미지 메세지 입니다")
            
            textView.isHidden = true
            pikedImageView.isHidden = false
            
            let urlString = message.mediaURL
            
            ImageCache.default.retrieveImage(forKey: urlString, options: nil) { result in
                switch result {
                case .success(let value):
                    if value.image != nil {
                        //캐시가 존재하는 경우
                        print("이미지 캐시 처리")
                        let image = self.resizeImage(image: value.image!)
                        self.pikedImageView.image = image
                        
                        self.contentView.setNeedsLayout()
                        self.contentView.layoutIfNeeded()
                    } else {
                        //캐시가 존재하지 않는 경우
                        print("이미지 캐시없이 직접 로드")
                        let url = URL(string: urlString)
                        let resource = ImageResource(downloadURL: url!, cacheKey: urlString)
                        let imageView = UIImageView()
                        
                        print("이미지 URL : \(urlString)")
                        
                        imageView.kf.setImage(
                            with: resource,
                            options: [.cacheMemoryOnly]) {
                            result in
                            switch result {
                            case .success(let value):
                                let image = self.resizeImage(image: value.image)
                                self.pikedImageView.image = image
                                
                                self.contentView.setNeedsLayout()
                                self.contentView.layoutIfNeeded()
                                
                            case .failure(let error):
                                print("이미지 로드 에러 \(error)")
                            }
                        }
                    }
                case .failure(let error):
                    print("이미지 로드 에러 \(error)")
                }
            }


        } else {
            print("동영상 메세지 입니다")
  
            textView.isHidden = false
            pikedImageView.isHidden = true
            
            textView.text = "동영상 메세지 입니다"
        }

        let date = message.timestamp.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a HH:mm"
        let dateString = dateFormatter.string(from: date)
        
        nameLabel.text = "\(message.userName)(\(message.userNickname))"
        dateLabel.text = dateString
        
        let unReadedCount = message.unReadedMember.count
        
        if unReadedCount == 0 {
            readedLabel.isHidden = true
        } else {
            readedLabel.text = String(unReadedCount)
        }

        bubbleLeftAnchor.isActive = viewModel.leftAnchorActive
        bubbleRightAnchor.isActive = viewModel.rightAnchorActive
        
        dateLabelLeftAnchor.isActive = viewModel.leftAnchorActive
        dateLabelRightAnchor.isActive = viewModel.rightAnchorActive
        
        readedLabelLeftAnchor.isActive = viewModel.leftAnchorActive
        readedLabelRightAnchor.isActive = viewModel.rightAnchorActive

        profileImageView.isHidden = viewModel.sholudHideProfileImage
        nameLabel.isHidden = viewModel.sholudHideNameLabel
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        var targetSize = targetSize
        targetSize.height = CGFloat.greatestFiniteMagnitude
        
        let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        return size
        
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

}

