//
//  SpoofDetector4Test.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 24/07/2023.
//

import XCTest
@testable import LivenessDetection

final class SpoofDetector4Test: BaseTest<SpoofDetector4> {
    
    override var confidenceThreshold: Float {
        0.15
    }
    
    override var expectedSuccessRate: Float {
        0.85
    }
    
    override func createSpoofDetector() throws -> SpoofDetector4 {
        return try createSpoofDetector4()
    }

    func _test_detectSpoofInImages_outputCSV() throws {
        var csv = "Image,Positive,Score\n"
        try withEachImage(types: [.spoofDevice,.moire]) { (image, url, positive) in
            let faceRect = try FaceDetection.detectFacesInImage(image).first?.bounds
            let score = try self.spoofDetector.detectSpoofInImage(image, regionOfInterest: faceRect)
            csv.append(String(format: "\"%@\",\"%d\",\"%.03f\"\n", url.lastPathComponent, NSNumber(value: positive).intValue, score))
        }
        let attachment = XCTAttachment(string: csv)
        attachment.lifetime = .keepAlways
        attachment.name = "PSD004.csv"
        self.add(attachment)
    }
    
    func _test_detectSpoofInImagesUsingComponents_outputCSV() throws {
        let bundle = Bundle(for: type(of: self))
        guard let positiveImageURLs = bundle.urls(forResourcesWithExtension: "jpg", subdirectory: "positive")?.filter({ $0.lastPathComponent.contains("_scale4.0") }).map({ ($0,true) }) else {
            XCTFail()
            return
        }
        guard let negativeImageURLs = bundle.urls(forResourcesWithExtension: "jpg", subdirectory: "negative")?.filter({ $0.lastPathComponent.contains("_scale4.0") }).map({ ($0,false) }) else {
            XCTFail()
            return
        }
        guard let detector = self.spoofDetector.components.first(where: { $0.config.scale == 4.0 }) else {
            XCTFail()
            return
        }
        let imageURLs = positiveImageURLs + negativeImageURLs
        var csv = "Image,Positive,Score1,Score2,Score3\n"
        for (url, positive) in imageURLs {
            let data = try Data(contentsOf: url)
            guard let image = UIImage(data: data) else {
                continue
            }
            let prediction = try detector.predictionFromImage(image)
            csv.append(String(format: "\"%@\",%d,%.03f,%.03f,%.03f\n", url.lastPathComponent, NSNumber(value: positive).intValue, prediction[0], prediction[1], prediction[2]))
        }
        let attachment = XCTAttachment(string: csv)
        attachment.lifetime = .keepAlways
        attachment.name = "PSD004.csv"
        self.add(attachment)
    }
    
    func _test_detectSpoofInImagesUsingSuppliedCropRects() throws {
        let bundle = Bundle(for: type(of: self))
        guard let boxesJsonURL = bundle.url(forResource: "bounding_boxes", withExtension: "json") else {
            XCTFail()
            return
        }
        let data = try Data(contentsOf: boxesJsonURL)
        let boxes: [ImageCropRect] = try JSONDecoder().decode([ImageCropRect].self, from: data)
        var csv = "Image,Positive,Model,Score1,Score2,Score3\n"
        for box in boxes {
            guard let url = bundle.url(forResource: box.file, withExtension: nil) else {
                continue
            }
            let imgData = try Data(contentsOf: url)
            guard let image = UIImage(data: imgData) else {
                continue
            }
            for component in self.spoofDetector.components {
                let scores = try component.predictionFromImage(image, regionOfInterest: box.rect)
                csv.append(String(format: "\"%@\",%d,\"%@\",%.03f,%.03f,%.03f\n", url.lastPathComponent, NSNumber(value: box.file.contains("positive")).intValue, component.config.modelURL.lastPathComponent, scores[0], scores[1], scores[2]))
            }
        }
        let attachment = XCTAttachment(string: csv)
        attachment.lifetime = .keepAlways
        attachment.name = "PSD004_supplied_bbox.csv"
        self.add(attachment)
    }
}

struct ImageCropRect: Decodable {
    let file: String
    let left: Int
    let top: Int
    let right: Int
    let bottom: Int
    var rect: CGRect {
        CGRect(x: self.left, y: self.top, width: self.right-self.left, height: self.bottom-self.top)
    }
}
