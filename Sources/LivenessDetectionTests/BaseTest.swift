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

let indexURL = URL(string: "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/index.json")!

class BaseTest<T: SpoofDetector>: XCTestCase {
    
    let live = [
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-01T20-29-14.131Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-13T13-34-23.450Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T09-46-57.964Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T09-55-29.921Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T10-57-40.653Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T11-05-53.110Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T20-57-56.798Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T20-58-44.778Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T20-59-02.381Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-04-33.179Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-07-10.656Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-07-35.971Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-14-34.617Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-15-26.848Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-29-28.729Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-29-28.729Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-29-40.494Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-29-40.494Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-39-29.553Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-39-29.553Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-39-40.345Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-39-40.345Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-14T21-42-04.984Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-15T14-28-20.851Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-19T08-00-20.215Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-19T08-00-29.286Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-19T15-42-47.277Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-19T15-42-58.411Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-20T16-03-23.367Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-20T16-43-44.309Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-20T16-45-30.455Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-34-30.885Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-34-54.572Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-35-02.925Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-35-16.475Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-35-53.080Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-36-31.026Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-08.692Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-17.289Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-28.766Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-28.766Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-43.000Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-43.000Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-55.415Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-37-55.415Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-44-39.236Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-44-51.144Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-45-29.640Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-46-36.742Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-46-36.742Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-51-10.917Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-51-25.718Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-51-40.860Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-51-40.860Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-52-23.149Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-52-23.149Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-55-32.877Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-55-43.754Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-55-56.455Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-56-30.948Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-56-50.931Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T06-56-50.931Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T09-51-36.194Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T09-59-48.082Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-00-02.568Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-00-25.281Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-00-42.186Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-00-59.073Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-01-19.637Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-01-38.682Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-02-24.051Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T10-02-39.326Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T13-59-05.961Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-05-01.416Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-05-34.824Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-07-13.116Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-07-56.827Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-15-45.803Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-16-20.316Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-31-03.393Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T14-31-03.393Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T17-01-54.315Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/live/2023-09-22T17-02-09.474Z.zip-1.jpg"
    ]
    let spoof = [
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T09-56-30.522Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T09-56-48.121Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T09-56-57.524Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T21-28-48.956Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T21-28-48.956Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T21-29-17.737Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-14T21-29-17.737Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-18T19-39-22.309Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-18T19-39-44.146Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-18T19-48-48.012Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-12-03.335Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-17-02.753Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-17-26.568Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-17-54.816Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-18-22.918Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-19-04.998Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-19-31.318Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-19-55.663Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-19-55.663Z.zip-2.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-29-57.963Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-30-09.090Z.zip-1.jpg",
        "https://ver-id.s3.amazonaws.com/test_images/liveness-detection/ADP/spoof/2023-09-22T14-30-36.658Z.zip-1.jpg"
    ]
    
    private var moireDetectorModelURL: URL!
    private var spoofDeviceDetectorModelURL: URL!
    private var spoofDetectorModelURL: URL!
    private var spoofDetector4ModelURLs: [URL] = []
    private var spoofDetector5ModelURL: URL!
    private var imageURLs: [LivenessDetectionType:[Bool:[URL]]] = [:]
    var spoofDetector: T!
    var expectedSuccessRate: Float {
        0.9
    }
    var confidenceThreshold: Float {
        0.45
    }
    let expectedFPRate: Float = 0.1
    let expectedFNRate: Float = 0.1
    
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
        if let url = URL(string: "https://github.com/AppliedRecognition/Ver-ID-Models/raw/master/files/ARC_PSD-001_1.1.29_bst_yl80_NMS_ult145_cml620.mlmodel") {
            self.spoofDeviceDetectorModelURL = try self.localURL(of: url)
        } else {
            throw NSError()
        }
        if let url = URL(string: "https://github.com/AppliedRecognition/Ver-ID-Models/raw/master/files/ARC_PSD-003_1.0.16_TRCD.mlmodel") {
            self.spoofDetectorModelURL = try self.localURL(of: url)
        } else {
            throw NSError()
        }
        self.spoofDetector4ModelURLs = []
        if let url = URL(string: "https://github.com/AppliedRecognition/Ver-ID-Models/raw/master/files/ARC_PSD-004_2.7_80x80.mlmodel") {
            self.spoofDetector4ModelURLs.append(try self.localURL(of: url))
        } else {
            throw NSError()
        }
        if let url = URL(string: "https://github.com/AppliedRecognition/Ver-ID-Models/raw/master/files/ARC_PSD-004_4_80x80.mlmodel") {
            self.spoofDetector4ModelURLs.append(try self.localURL(of: url))
        } else {
            throw NSError()
        }
        if let url = URL(string: "https://ver-id.s3.amazonaws.com/ml-models/mobilenetv2-epoch_10.tflite") {
            self.spoofDetector5ModelURL = try self.localURL(of: url)
        } else {
            throw NSError()
        }
        self.imageURLs.removeAll()
        self.imageURLs[LivenessDetectionType.moire] = [
            false: self.live.compactMap { URL(string: $0) },
            true: self.spoof.compactMap { URL(string: $0) }
        ]
        self.imageURLs[LivenessDetectionType.spoofDevice] = [
            false: self.live.compactMap { URL(string: $0) },
            true: self.spoof.compactMap { URL(string: $0) }
        ]
//        let indexData = try Data(contentsOf: self.localURL(of: indexURL))
//        let index: [String:[String:[String]]] = try JSONDecoder().decode([String:[String:[String]]].self, from: indexData)
//        try index.forEach({ key, val in
//            guard let type = LivenessDetectionType(rawValue: key) else {
//                throw NSError()
//            }
//            self.imageURLs[type] = [:]
//            for k in val.keys {
//                let positive = k == "positive"
//                self.imageURLs[type]?[positive] = []
//                for urlString in val[k]! {
//                    guard let url = URL(string: urlString) else {
//                        throw NSError()
//                    }
//                    self.imageURLs[type]?[positive]?.append(url)
//                }
//            }
//        })
        self.spoofDetector = try self.createSpoofDetector()
        self.spoofDetector.confidenceThreshold = self.confidenceThreshold
    }
    
    func createSpoofDetector() throws -> T {
        fatalError("Method not implemented")
    }
    
    func test_detectSpoofInImages_succeedsWithExpectedSuccessRate() throws {
        var liveCount = 0
        var spoofCount = 0
        var fpCount = 0
        var fnCount = 0
        try self.withEachImage(types: [.moire,.spoofDevice]) { image, url, positive in
            let roi = try self.detectFaceInImage(image)?.boundingBox
            let isSpoof = try self.spoofDetector.isSpoofedImage(image, regionOfInterest: roi)
            if positive && !isSpoof {
                fnCount += 1
            } else if !positive && isSpoof {
                fpCount += 1
            }
            if positive {
                spoofCount += 1
            } else {
                liveCount += 1
            }
        }
        let fpRate = Float(fpCount) / Float(liveCount)
        let fnRate = Float(fnCount) / Float(spoofCount)
        XCTAssertLessThanOrEqual(fpRate, self.expectedFPRate)
        XCTAssertLessThanOrEqual(fnRate, self.expectedFNRate)
    }
    
    func test_measureInferenceSpeed() throws {
        let image = try self.firstImage(type: .spoofDevice, positive: true)
        let measureOptions = XCTMeasureOptions.default
        measureOptions.invocationOptions = [.manuallyStart, .manuallyStop]
        self.measure(options: measureOptions) {
            do {
                let roi = try self.detectFaceInImage(image)?.boundingBox
                self.startMeasuring()
                _ = try self.spoofDetector.detectSpoofInImage(image, regionOfInterest: roi)
                self.stopMeasuring()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
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
    
    @available(iOS 14, *)
    func createSpoofDeviceDetector() throws -> SpoofDeviceDetector {
        return try SpoofDeviceDetector(modelURL: self.spoofDeviceDetectorModelURL)
    }
    
    func createSpoofDetector3() throws -> SpoofDetector3 {
        return try SpoofDetector3(modelURL: self.spoofDetectorModelURL)
    }
    
    func createSpoofDetector4() throws -> SpoofDetector4 {
        return try SpoofDetector4(modelURL1: self.spoofDetector4ModelURLs[0], modelURL2: self.spoofDetector4ModelURLs[1])
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
        request.usesCPUOnly = true
        try imageRequestHandler.perform([request])
        return request.results?.first
    }
    
    func detectFacesInImage(_ image: UIImage) throws -> [CGRect] {
        let cgImage = try self.cgImage(from: image)
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: image.imageOrientation.cgImagePropertyOrientation, options: [:])
        let request = VNDetectFaceRectanglesRequest()
        request.usesCPUOnly = true
        try imageRequestHandler.perform([request])
        return request.results?.map { obs in
            obs.boundingBox
        } ?? []
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
