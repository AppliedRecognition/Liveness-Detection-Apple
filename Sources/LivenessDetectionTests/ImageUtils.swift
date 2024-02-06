//
//  ImageUtils.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 27/10/2023.
//

import Foundation
import UIKit

class ImageUtils {
    
    static func image(_ image: UIImage, croppedToEyeRegionsOfFace face: Face) -> UIImage {
        guard let rightEye = face.rightEye, let leftEye = face.leftEye else {
            return image
        }
        let distanceBetweenEyes = leftEye.distanceTo(rightEye)
        let cropRect = CGRect(x: leftEye.x - distanceBetweenEyes * 0.75, y: min(leftEye.y, rightEye.y) - distanceBetweenEyes * 0.5, width: distanceBetweenEyes * 2.5, height: distanceBetweenEyes)
        UIGraphicsBeginImageContext(cropRect.size)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(at: CGPoint(x: 0-cropRect.minX, y: 0-cropRect.minY))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    static func image(_ image: UIImage, croppedToRegion region: CGRect) -> UIImage {
        UIGraphicsBeginImageContext(region.size)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(at: CGPoint(x: 0-region.minX, y: 0-region.minY))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

extension CGPoint {
    
    func distanceTo(_ point: CGPoint) -> CGFloat {
        hypot(self.y - point.y, self.x - point.x)
    }
}
