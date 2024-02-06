//
//  SpoofDetector3Test.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 03/03/2023.
//

import XCTest
import MobileCoreServices
import UniformTypeIdentifiers
import CoreML
@testable import LivenessDetection

final class SpoofDetector3Test: BaseTest<SpoofDetector3> {
    
    override var confidenceThreshold: Float {
        0.95
    }
    
    override var expectedSuccessRate: Float {
        0.47
    }
    
    override func createSpoofDetector() throws -> SpoofDetector3 {
        try self.createSpoofDetector3()
    }
    
    func test_softmaxCalculation_returnsExpectedValues() throws {
        let input: [Float] = [1.0, 2.0, 3.0, 4.0, 1.0, 2.0, 3.0]
        let expectedOutput: [Float] = [0.02364054, 0.06426166, 0.1746813, 0.474833, 0.02364054, 0.06426166, 0.1746813]
        let output = Utils.softmax(input)
        XCTAssertEqual(output.count, expectedOutput.count)
        for i in 0..<output.count {
            XCTAssertEqual(output[i], expectedOutput[i], accuracy: 0.01)
        }
    }
    
    @available(iOS 15.4, *)
    func test_prepareImage_attachOutput() throws {
        let image = try self.firstImage(type: .moire, positive: true)
        let array = try self.spoofDetector.prepareImage(image).withUnsafeBytes { ptr in
            let floatBufferPtr = ptr.bindMemory(to: Float32.self)
            return Array(floatBufferPtr)
        }
        let json = try JSONEncoder().encode(array)
        let attachment = XCTAttachment(data: json, uniformTypeIdentifier: UTType.json.identifier)
        attachment.lifetime = .keepAlways
        attachment.name = "image.json"
        add(attachment)
    }
    
    @available(iOS 14, *)
    func test_outputOnRawInput_matchesExpectedValue() throws {
        guard let inputURL = Bundle(for: type(of: self)).url(forResource: "test_input", withExtension: "json") else {
            XCTFail()
            return
        }
        let inputData = try Data(contentsOf: inputURL)
        let inputArray: [Float32] = try JSONDecoder().decode([Float32].self, from: inputData)
        let input = UnsafeMutablePointer<Float32>.allocate(capacity: inputArray.count)
        input.initialize(from: inputArray, count: inputArray.count)
        let multiArray = try MLMultiArray(dataPointer: input, shape: self.spoofDetector.shape, dataType: .float32, strides: self.spoofDetector.strides)
        let featureProvider = try MLDictionaryFeatureProvider(dictionary: ["x_1": multiArray])
        let prediction = try self.spoofDetector.model.prediction(from: featureProvider)
        guard let outputMultiArray = (prediction as? MLDictionaryFeatureProvider)?["var_373"]?.multiArrayValue else {
            throw NSError()
        }
        let output: [Float] = [outputMultiArray[0].floatValue, outputMultiArray[1].floatValue]
        let json = try JSONEncoder().encode(output)
        let attachment = XCTAttachment(data: json, uniformTypeIdentifier: UTType.json.identifier)
        attachment.lifetime = .keepAlways
        attachment.name = "output.json"
        add(attachment)
    }
    
    func test_detectSpoofsOnVariouslyCroppedImages_attachCSV() throws {
        var csv: String = "\"Image\",\"Positive\",\"Score\",\"Score (cropped to face)\",\"Score (cropped to eye region)\""
        try withEachImage(types: [.spoofDevice,.moire]) { (image, url, positive) in
            let confidence = try self.spoofDetector.detectSpoofInImage(image)
            csv.append(String(format: "\n\"%@\",%@,%.03f,", url.lastPathComponent, positive ? "1" : "0", confidence))
            if let face = try FaceDetection.detectFacesInImage(image).first {
                let faceImage = ImageUtils.image(image, croppedToRegion: face.bounds)
                let eyeRegionImage = ImageUtils.image(image, croppedToEyeRegionsOfFace: face)
                let faceCropConfidence = try self.spoofDetector.detectSpoofInImage(faceImage)
                let eyeRegionCropConfidence = try self.spoofDetector.detectSpoofInImage(eyeRegionImage)
                csv.append(String(format: "%.03f,%.03f", faceCropConfidence, eyeRegionCropConfidence))
            } else {
                csv.append("\"n/a\",\"n/a\"")
            }
        }
        let attachment = XCTAttachment(string: csv)
        attachment.lifetime = .keepAlways
        attachment.name = "Spoof detector.csv"
        self.add(attachment)
    }
    
    func test_detectSpoofs_attachCSV() throws {
        var csv: String = "\"Image\",\"Positive\",\"Score\""
        var failCount: Float = 0
        var totalCount: Float = 0
        let threshold: Float = 0.5
        try withEachImage(types: [.spoofDevice,.moire]) { (image, url, positive) in
            let confidence = try self.spoofDetector.detectSpoofInImage(image)
            totalCount += 1
            if (positive && confidence < threshold) || (!positive && confidence >= threshold) {
                failCount += 1
            }
            csv.append(String(format: "\n\"%@\",\"%@\",%.04f", url.lastPathComponent, positive ? "positive" : "negative", confidence))
        }
        NSLog("Failure rate = %.02f%%", failCount / totalCount * 100)
        let attachment = XCTAttachment(string: csv)
        attachment.lifetime = .keepAlways
        attachment.name = "Scores.csv"
        add(attachment)
    }
}
