//
//  SpoofDetector3Test.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 03/03/2023.
//

import XCTest
import MobileCoreServices
import VerIDCore
import VerIDSDKIdentity
@testable import LivenessDetection

final class SpoofDetector3Test: BaseTest {
    
    var spoofDetector: SpoofDetector3!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.spoofDetector = try createSpoofDetector()
    }
    
    func test_detectSpoofs_succeedsOn80PercentOfImages() throws {
        let maxFailRatio: Float = 0.2
        let failRatio = try self.failRatioOfDetectionOnEachImage(self.spoofDetector, detectFace: false)
        NSLog("Fail ratio: %.02f%%", failRatio * 100)
        XCTAssertLessThanOrEqual(failRatio, maxFailRatio, String(format: "Fail ratio must be below %.0f%% but is %.02f%%", maxFailRatio * 100, failRatio * 100))
    }
    
    func test_detectSpoofsWithROI_succeedsOn80PercentOfImages() throws {
        let maxFailRatio: Float = 0.2
        let failRatio = try self.failRatioOfDetectionOnEachImage(self.spoofDetector, detectFace: true)
        NSLog("Fail ratio: %.02f%%", failRatio * 100)
        XCTAssertLessThanOrEqual(failRatio, maxFailRatio, String(format: "Fail ratio must be below %.0f%% but is %.02f%%", maxFailRatio * 100, failRatio * 100))
    }
    
    func test_detectSpoofsOnVariouslyCroppedImages_attachCSV() throws {
        let verID = try self.createVerID()
        var csv: String = "\"Image\",\"Positive\",\"Score\",\"Score (cropped to face)\",\"Score (cropped to eye region)\""
        try withEachImage(types: [.spoofDevice,.moire]) { (image, url, positive) in
            let confidence = try self.spoofDetector.detectSpoofInImage(image)
            csv.append(String(format: "\n\"%@\",%@,%.03f,", url.lastPathComponent, positive ? "1" : "0", confidence))
            if let face = try verID.faceDetection.detectFacesInImage(image, limit: 1, options: 0).first {
                let faceImage = self.image(image, croppedToFace: face)
                let eyeRegionImage = self.image(image, croppedToEyeRegionsOfFace: face)
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
