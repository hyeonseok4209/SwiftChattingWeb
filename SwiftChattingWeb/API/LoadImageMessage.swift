//
//import UIKit
//import Kingfisher
//
//extension UIImageView {
//    func setImage(with urlString: String) {
//        ImageCache.default.retrieveImage(forKey: urlString, options: nil) { result in
//            switch result {
//            case .success(let value):
//                if let image = value.image {
//                    //캐시가 존재하는 경우
//                    print("이미지 캐시 로드")
//                    self.image = image
//                } else {
//                    //캐시가 존재하지 않는 경우
//                    print("이미지 캐시 없음")
//                    let url = URL(string: urlString)
////                    let resource = ImageResource(downloadURL: url!, cacheKey: urlString)
//                    self.kf.indicatorType = .activity
//                    self.kf.setImage(
//                        with: url!,
//                        options: [
//                            .cacheMemoryOnly,
//                            .transition(.fade(1.2)),
//                            .forceTransition
//                        ]
//                    )
//                }
//            case .failure(let error):
//                print("이미지 로드 에러 \(error)")
//            }
//        }
//    }
//}
