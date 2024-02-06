//
//  FaceDetection.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 27/10/2023.
//

import Foundation
import UIKit
import Vision

class FaceDetection {
    
    static func detectFacesInImage(_ image: UIImage) throws -> [Face] {
        let transform = CGAffineTransform(scaleX: image.size.width, y: 0-image.size.height).concatenating(CGAffineTransform(translationX: 0, y: image.size.height))
        let imageCentre = CGPoint(x: image.size.width/2, y: image.size.height/2)
        let cgImage = try FaceDetection.cgImage(from: image)
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: image.imageOrientation.cgImagePropertyOrientation, options: [:])
        let request = VNDetectFaceLandmarksRequest()
        request.usesCPUOnly = true
        try imageRequestHandler.perform([request])
        return request.results?.map { (obs: VNFaceObservation) -> Face in
            Face(bounds: obs.boundingBox.applying(transform), leftEye: obs.landmarks?.leftPupil?.pointsInImage(imageSize: image.size).first, rightEye: obs.landmarks?.rightPupil?.pointsInImage(imageSize: image.size).first)
        }.sorted { a, b in
                a.center.distanceTo(imageCentre) < b.center.distanceTo(imageCentre)
        } ?? []
    }
    
    private static func cgImage(from uiImage: UIImage) throws -> CGImage {
        if let image = uiImage.cgImage {
            return image
        } else if let ciImage = uiImage.ciImage {
            let context = CIContext(options: nil)
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                return cgImage
            }
        }
        throw NSError()
    }
}

struct Face {
    
    let leftEye: CGPoint?
    let rightEye: CGPoint?
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    var origin: CGPoint {
        CGPoint(x: self.x, y: self.y)
    }
    var size: CGSize {
        CGSize(width: self.width, height: self.height)
    }
    var midX: CGFloat {
        self.x + self.width / 2
    }
    var midY: CGFloat {
        self.y + self.height / 2
    }
    var bounds: CGRect {
        CGRect(origin: self.origin, size: self.size)
    }
    var center: CGPoint {
        CGPoint(x: self.midX, y: self.midY)
    }
    
    init(bounds: CGRect, leftEye: CGPoint?, rightEye: CGPoint?) {
        self.x = bounds.minX
        self.y = bounds.minY
        self.width = bounds.width
        self.height = bounds.height
        self.leftEye = leftEye
        self.rightEye = rightEye
    }
}
