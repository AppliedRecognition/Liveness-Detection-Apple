//
//  BaseTest.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 17/02/2023.
//

import XCTest
import UIKit
import Vision
@testable import LivenessDetection

class BaseTest: XCTestCase {
    
    private var moireDetectorModelURL: URL!
    private var spoofDeviceDetectorModelURL: URL!
    private var spoofDetectorModelURL: URL!
    private var imageURLs: [LivenessDetectionType:[Bool:[URL]]] = [:]
    private static let indexURL = URL(string: "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/index.json")!
    
    override class func setUp() {
        super.setUp()
        do {
            let cacheURL = try cacheURL(of: indexURL)
            try FileManager.default.removeItem(at: cacheURL)
        } catch {
        }
    }

    override func setUpWithError() throws {
        if let url = URL(string: "https://github.com/AppliedRecognition/Ver-ID-Models/raw/master/files/MoireDetectorModel_ep100_ntrn-627p-620n_02_res-98-99-96-0-5.mlmodel") {
            self.moireDetectorModelURL = try self.localURL(of: url)
        } else {
            throw NSError()
        }
        if let url = URL(string: "https://github.com/AppliedRecognition/Ver-ID-Models/raw/master/files/SpoofDetectorModel_1.0.7_bst_2022-11-26_yl61.mlmodel") {
            self.spoofDeviceDetectorModelURL = try self.localURL(of: url)
        } else {
            throw NSError()
        }
        if let url = URL(string: "https://github.com/AppliedRecognition/Ver-ID-Models/raw/master/files/ARC_PSD-003_1.0.16_TRCD.mlmodel") {
            self.spoofDetectorModelURL = try self.localURL(of: url)
        } else {
            throw NSError()
        }
        let indexData = try Data(contentsOf: self.localURL(of: BaseTest.indexURL))
        let index: [String:[String:[String]]] = try JSONDecoder().decode([String:[String:[String]]].self, from: indexData)
        self.imageURLs.removeAll()
        try index.forEach({ key, val in
            guard let type = LivenessDetectionType(rawValue: key) else {
                throw NSError()
            }
            self.imageURLs[type] = [:]
            for k in val.keys {
                let positive = k == "positive"
                self.imageURLs[type]?[positive] = []
                for urlString in val[k]! {
                    guard let url = URL(string: urlString) else {
                        throw NSError()
                    }
                    self.imageURLs[type]?[positive]?.append(url)
                }
            }
        })
    }
    
    static func cacheURL(of url: URL) throws -> URL {
        let cacheURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return cacheURL.appendingPathComponent(url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
    }
    
    func localURL(of url: URL) throws -> URL {
        let localURL = try BaseTest.cacheURL(of: url)
        if !FileManager.default.fileExists(atPath: localURL.path) {
            try FileManager.default.createDirectory(at: localURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try Data(contentsOf: url)
            try data.write(to: localURL, options: .atomic)
        }
        return localURL
    }
    
    func image(at url: URL) throws -> UIImage {
        let localURL = try self.localURL(of: url)
        let data = try Data(contentsOf: localURL)
        guard let image = UIImage(data: data) else {
            throw NSError()
        }
        return image
    }
    
    func cgImage(at url: URL) throws -> CGImage {
        let uiImage = try self.image(at: url)
        return try self.cgImage(from: uiImage)
    }
    
    func cgImage(from uiImage: UIImage) throws -> CGImage {
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
    
    func imageURLs(types: [LivenessDetectionType]) throws -> [(URL,Bool)] {
        var urls: Set<FlaggedURL> = []
        for t in types {
            guard let map = self.imageURLs[t] else {
                throw NSError()
            }
            for positive in map.keys {
                map[positive]!.map({ FlaggedURL(url: $0, flagged: positive) }).forEach({
                    urls.insert($0)
                })
            }
        }
        return urls.map({ ($0.url, $0.flagged) })
    }
    
    func withEachImage(types: [LivenessDetectionType], run: (UIImage,URL,Bool) throws -> Void) throws {
        let urls = try self.imageURLs(types: types)
        for url in urls {
            let image = try self.image(at: url.0)
            try run(image, url.0, url.1)
        }
    }
    
    func withEachCGImage(types: [LivenessDetectionType], run: (CGImage,URL,Bool) throws -> Void) throws {
        let urls = try self.imageURLs(types: types)
        for url in urls {
            let image = try self.cgImage(at: url.0)
            try run(image, url.0, url.1)
        }
    }
    
    func firstImage(type: LivenessDetectionType, positive: Bool) throws -> UIImage {
        guard let url = try self.imageURLs(types: [type]).first(where: { $0.1 == positive })?.0 else {
            throw NSError()
        }
        return try self.image(at: url)
    }
    
    func firstCGImage(type: LivenessDetectionType, positive: Bool) throws -> CGImage {
        guard let url = try self.imageURLs(types: [type]).first(where: { $0.1 == positive })?.0 else {
            throw NSError()
        }
        return try self.cgImage(at: url)
    }

    func createMoireDetector() throws -> MoireDetector {
        return try MoireDetector(modelURL: self.moireDetectorModelURL)
    }
    
    func createSpoofDeviceDetector() throws -> SpoofDeviceDetector {
        return try SpoofDeviceDetector(modelURL: self.spoofDeviceDetectorModelURL)
    }
    
    func createSpoofDetector() throws -> SpoofDetector3 {
        return try SpoofDetector3(modelURL: self.spoofDetectorModelURL)
    }
    
    func image(_ image: UIImage, croppedToEyeRegionsOfFace face: VNFaceObservation) -> UIImage {
        guard let rightEye = face.landmarks?.leftPupil?.pointsInImage(imageSize: image.size).first else {
            return image
        }
        guard let leftEye = face.landmarks?.rightPupil?.pointsInImage(imageSize: image.size).first else {
            return image
        }
        let distanceBetweenEyes = hypot(rightEye.y - leftEye.y, rightEye.x - leftEye.x)
        let cropRect = CGRect(x: leftEye.x - distanceBetweenEyes * 0.75, y: min(leftEye.y, rightEye.y) - distanceBetweenEyes * 0.5, width: distanceBetweenEyes * 2.5, height: distanceBetweenEyes)
        UIGraphicsBeginImageContext(cropRect.size)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(at: CGPoint(x: 0-cropRect.minX, y: 0-cropRect.minY))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func image(_ image: UIImage, croppedToFace face: VNFaceObservation) -> UIImage {
        UIGraphicsBeginImageContext(face.boundingBox.size)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(at: CGPoint(x: 0-face.boundingBox.minX, y: 0-face.boundingBox.minY))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func failRatioOfDetectionOnEachImage(_ detector: SpoofDetector, detectFace: Bool) throws -> Float {
        var detectionCount: Float = 0
        var failCount: Float = 0
        try withEachImage(types: [.spoofDevice]) { (image, url, positive) in
            let roi = try self.detectFaceInImage(image)?.boundingBox
            let isSpoof = try detector.isSpoofedImage(image, regionOfInterest: roi)
            let success = (positive && isSpoof) || (!positive && !isSpoof)
            detectionCount += 1
            if !success {
                failCount += 1
            }
        }
        return failCount / detectionCount
    }
    
    func falsePositiveAndNegativeRatiosOnEachImage(detectors: [SpoofDetector], detectFace: Bool) throws -> (Float, Float) {
        var fpCount: Float = 0
        var fnCount: Float = 0
        var totalCount: Float = 0
        try withEachImage(types: [.moire,.spoofDevice]) { (image, url, positive) in
            totalCount += 1
            let roi = try self.detectFaceInImage(image)?.boundingBox
            var isSpoof: Bool = false
            for detector in detectors {
                if try detector.isSpoofedImage(image, regionOfInterest: roi) {
                    isSpoof = true
                    break
                }
            }
            if positive && !isSpoof {
                fnCount += 1
            } else if !positive && isSpoof {
                fpCount += 1
            }
        }
        return (fpCount / totalCount, fnCount / totalCount)
    }
    
    func detectFaceInImage(_ image: UIImage) throws -> VNFaceObservation? {
        let cgImage = try self.cgImage(from: image)
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: image.imageOrientation.cgImagePropertyOrientation, options: [:])
        let request = VNDetectFaceRectanglesRequest()
        try imageRequestHandler.perform([request])
        return request.results?.first
    }
}

enum LivenessDetectionType: String, Decodable {
    case moire = "moire", spoofDevice = "spoof_device"
}

fileprivate struct FlaggedURL: Hashable {
    
    let url: URL
    let flagged: Bool
}

extension UIImage.Orientation {
    
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch self {
        case .up:
            return .up
        case .right:
            return .right
        case .down:
            return .down
        case .left:
            return .left
        case .upMirrored:
            return .upMirrored
        case .rightMirrored:
            return .rightMirrored
        case .downMirrored:
            return .downMirrored
        case .leftMirrored:
            return .leftMirrored
        default:
            return .up
        }
    }
}
