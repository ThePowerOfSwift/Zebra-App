import Foundation
import UIKit

extension UIImage {
    convenience init?(contentsOfURL url: URL) {
        guard let rawImage = try? Data(contentsOf: url) else {
            return nil
        }
        
        self.init(data: rawImage)
    }
    
   // func resizeWithMaximumSize(_ maximumSize: CGSize) -> UIImage {
    //    return resizedImage
//    }
    
    func JPEGEncoded(_ quality: CGFloat = 1) -> Data? {
        return self.jpegData(compressionQuality: quality)
    }
    
    func resizeImage(_ image: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    func prepareImagedata() -> Data {
        var imageData = self.JPEGEncoded()
        // Resize the image if it exceeds the 2MB API limit
        if (imageData?.count)! > 2097152 {
            print("It's Exceeds 2MB")
            let oldSize = self.size
            let newSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            let newImage = self.resizeImage(self, size: newSize)
            imageData = newImage.JPEGEncoded()
        }
        return imageData!
    }
}

/*
extension UIImage {
    
    func resizedImage(with: CGSize, interpolationQuality: CGInterpolationQuality) {
        var drawTransposed: Bool
        switch self.imageOrientation {
        case .rightMirrored:
            drawTransposed = true
            break
        default:
            drawTransposed = false
        }
        
        let transform
    }
}
*/
