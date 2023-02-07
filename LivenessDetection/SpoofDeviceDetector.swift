//
//  SpoofDeviceDetector.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 03/02/2023.
//

import Foundation
import UIKit
import Vision
import CoreML

/// Spoof device detection
///
/// Detect spoof devices like smartphones, tablets or photographs
/// - Since: 1.0.0
public class SpoofDeviceDetector {
    
    /// If detected spoof device bounding box side exceeds the corresponding side of the image
    /// multiplied by this ratio add `largeBoxScoreAdjustment` to the score
    ///
    /// For example, say the submitted image is 200 pixels wide and the width bounding box of the
    /// detected spoof device is longer than 190 pixels. If `minDecrementedSpoofScoreBoxToSideRatio`
    /// is set to `0.9` and `largeBoxScoreAdjustment` is not equal to `0`, the
    /// `largeBoxScoreAdjustment` value will be added to the confidence score.
    ///
    /// ```
    /// let imageWidth = 200
    /// let spoofDeviceBoundingBoxWidth = 190
    /// if spoofDeviceBoundingBoxWidth > imageWidth * minDecrementedSpoofScoreBoxToSideRatio {
    ///     score += largeBoxScoreAdjustment
    /// }
    /// ```
    /// - Since: 1.0.0
    public var minDecrementedSpoofScoreBoxToSideRatio: CGFloat = 0.9
    /// Value to add to the score if either side of the detected spoof device's' bounding box exceeds the
    /// corresponding image side multiplied by `minDecrementedSpoofScoreBoxToSideRatio`.
    /// - SeeAlso: `minDecrementedSpoofScoreBoxToSideRatio`
    /// - Since: 1.0.0
    public var largeBoxScoreAdjustment: Float = 0.0
    /// Set to `true` to brighten the image if no spoof devices are found.
    ///
    /// In some cases, the spoof device struggles if an image is taken in a dark room. Setting this to
    /// `true` may help but it may also increase the false positive rate on images taken in bright conditions.
    /// - Since: 1.0.0
    public var shouldAdjustImageBrightnessIfNoSpoofsDetected: Bool = false
    
    let model: VNCoreMLModel
    lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy var request: VNCoreMLRequest = {
        let request = VNCoreMLRequest(model: self.model)
        request.imageCropAndScaleOption = .scaleFit
        return request
    }()
    
    /// Asynchronous constructor
    /// - Parameter modelURL: Model file URL
    /// - Since: 1.0.0
    @available(iOS 16, macOS 13, macCatalyst 16, *)
    public convenience init(modelURL: URL) async throws {
        let compiledModelURL = try await MLModel.compileModel(at: modelURL)
        try self.init(compiledModelURL: compiledModelURL)
    }
    
    /// Constructor
    /// - Parameter modelURL: Model file URL
    /// - Since: 1.0.0
    public convenience init(modelURL: URL) throws {
        let compiledModelURL = try MLModel.compileModel(at: modelURL)
        try self.init(compiledModelURL: compiledModelURL)
    }
    
    private init(compiledModelURL: URL) throws {
        let spoofDetector: MLModel = try MLModel(contentsOf: compiledModelURL)
        self.model = try VNCoreMLModel(for: spoofDetector)
    }
    
    /// Detect spoof devices in sample buffer
    /// - Parameters:
    ///   - sampleBuffer: Sample buffer
    ///   - orientation: Image orientation
    /// - Returns: Array of detected spoof devices
    /// - Since: 1.0.0
    @available(iOS 14, *)
    public func detectSpoofDevicesInSampleBuffer(_ sampleBuffer: CMSampleBuffer, orientation: CGImagePropertyOrientation) throws -> [DetectedSpoofDevice] {
        var results: [DetectedSpoofDevice] = []
        var err: Error?
        let op = BlockOperation {
            do {
                guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                    throw ImageProcessingError.pixelBufferInitializationError
                }
                CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
                let height = CVPixelBufferGetHeight(pixelBuffer)
                let width = CVPixelBufferGetWidth(pixelBuffer)
                CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
                let imageSize: CGSize
                if [CGImagePropertyOrientation.left, .leftMirrored, .right, .leftMirrored].contains(orientation) {
                    imageSize = CGSize(width: height, height: width)
                } else {
                    imageSize = CGSize(width: width, height: height)
                }
                try VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: orientation).perform([self.request])
                results = (self.request.results as? [VNRecognizedObjectObservation])?.map { DetectedSpoofDevice(observation: $0, imageSize: imageSize) } ?? []
            } catch {
                err = error
            }
        }
        self.queue.addOperations([op], waitUntilFinished: true)
        if let error = err {
            throw error
        }
        return results
    }
    
    /// Detect spoof devices in image
    /// - Parameter image: Image
    /// - Returns: Array of detected spoof devices
    /// - Since: 1.0.0
    public func detectSpoofDevicesInImage(_ image: UIImage) throws -> [DetectedSpoofDevice] {
        let operation = DetectionOperation(request: self.request, image: image, minDecrementedSpoofScoreBoxToSideRatio: self.minDecrementedSpoofScoreBoxToSideRatio, largeBoxScoreAdjustment: self.largeBoxScoreAdjustment)
        operation.shouldAdjustImageBrightnessIfNoSpoofsDetected = self.shouldAdjustImageBrightnessIfNoSpoofsDetected
        self.queue.addOperations([operation], waitUntilFinished: true)
        if let error = operation.error {
            throw error
        }
        return operation.results
    }
}

fileprivate class DetectionOperation: Operation {
    
    var image: UIImage
    let request: VNCoreMLRequest
    var error: Error?
    var maxSideLength: CGFloat = 4000
    var results: [DetectedSpoofDevice] = []
    var minDecrementedSpoofScoreBoxToSideRatio: CGFloat
    var largeBoxScoreAdjustment: Float
    var shouldAdjustImageBrightnessIfNoSpoofsDetected: Bool = false
    
    init(request: VNCoreMLRequest, image: UIImage, minDecrementedSpoofScoreBoxToSideRatio: CGFloat, largeBoxScoreAdjustment: Float) {
        self.request = request
        self.image = image
        self.minDecrementedSpoofScoreBoxToSideRatio = minDecrementedSpoofScoreBoxToSideRatio
        self.largeBoxScoreAdjustment = largeBoxScoreAdjustment
    }
    
    override func main() {
        do {
            let longerSide = max(image.size.width, image.size.height)
            var scaleTransform: CGAffineTransform = .identity
            if longerSide > self.maxSideLength {
                let scale = self.maxSideLength / longerSide
                scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
                let scaledSize = self.image.size.applying(scaleTransform)
                self.image = UIGraphicsImageRenderer(size: scaledSize).image { _ in
                    self.image.draw(in: CGRect(origin: .zero, size: scaledSize))
                }
            }
            guard let cgImage = self.image.cgImage else {
                throw ImageProcessingError.cgImageConversionError
            }
            let orientation = self.image.imageOrientation.cgImagePropertyOrientation
            try VNImageRequestHandler(cgImage: cgImage, orientation: orientation).perform([self.request])
            self.results = (self.request.results as? [VNRecognizedObjectObservation])?.map { DetectedSpoofDevice(observation: $0, imageSize: self.image.size) } ?? []
            if self.shouldAdjustImageBrightnessIfNoSpoofsDetected && self.results.isEmpty {
                guard let brighterImage = self.brightenImage(cgImage) else {
                    return
                }
                try VNImageRequestHandler(cgImage: brighterImage, orientation: orientation).perform([self.request])
                self.results = (self.request.results as? [VNRecognizedObjectObservation])?.map { DetectedSpoofDevice(observation: $0, imageSize: self.image.size) } ?? []
            }
            let invertedScaleTransform: CGAffineTransform
            if !scaleTransform.isIdentity {
                invertedScaleTransform = scaleTransform.inverted()
            } else {
                invertedScaleTransform = .identity
            }
            self.results = self.results.map { result in
                if self.largeBoxScoreAdjustment != 0.0 && (result.boundingBox.width >= self.image.size.width * self.minDecrementedSpoofScoreBoxToSideRatio || result.boundingBox.height >= self.image.size.height * self.minDecrementedSpoofScoreBoxToSideRatio) {
                    return DetectedSpoofDevice(boundingBox: result.boundingBox, confidence: result.confidence + self.largeBoxScoreAdjustment)
                }
                return result
            }.map { result in
                if !invertedScaleTransform.isIdentity {
                    return DetectedSpoofDevice(boundingBox: result.boundingBox.applying(invertedScaleTransform), confidence: result.confidence)
                }
                return result
            }.filter { $0.confidence > 0 }
        } catch {
            self.error = error
        }
    }
    
    func brightenImage(_ image: CGImage) -> CGImage? {
        let ciImage = CIImage(cgImage: image)
        let context = CIContext()
        guard let filter = CIFilter(name: "CIToneCurve") else {
            return nil
        }
        filter.setValue(CIVector(x: 0, y: 0), forKey: "inputPoint0")
        filter.setValue(CIVector(x: 0.25, y: 0.5), forKey: "inputPoint1")
        filter.setValue(CIVector(x: 0.5, y: 0.75), forKey: "inputPoint2")
        filter.setValue(CIVector(x: 0.75, y: 0.9), forKey: "inputPoint3")
        filter.setValue(CIVector(x: 1.0, y: 1.0), forKey: "inputPoint4")
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let result = filter.outputImage else {
            return nil
        }
        return context.createCGImage(result, from: result.extent)
    }
}

fileprivate extension UIImage.Orientation {
    
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch self {
        case .up:
            return .up
        case .down:
            return .down
        case .left:
            return .left
        case .right:
            return .right
        case .upMirrored:
            return .upMirrored
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        case .rightMirrored:
            return .rightMirrored
        @unknown default:
            return .up
        }
    }
    
    var isMirrored: Bool {
        switch self {
        case .upMirrored, .downMirrored, .leftMirrored, .rightMirrored:
            return true
        default:
            return false
        }
    }
}
