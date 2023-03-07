//
//  SpoofDetector3Test.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 03/03/2023.
//

import XCTest
import MobileCoreServices
@testable import LivenessDetection

final class SpoofDetector3Test: BaseTest {
    
    var spoofDetector: SpoofDetector3!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.spoofDetector = try createSpoofDetector()
    }
    
    func test_detectSpoofs_succeedsOn80PercentOfImages() throws {
        var fpCount: Float = 0
        var fnCount: Float = 0
        var positiveCount: Float = 0
        var negativeCount: Float = 0
        let threshold: Float = 0.5
        let maxFailRate: Float = 0.2
        try withEachImage(types: [.spoofDevice,.moire]) { (image, url, positive) in
            let confidence = try self.spoofDetector.detectSpoofInImage(image)
            if positive {
                positiveCount += 1
                if confidence < threshold {
                    fnCount += 1
                }
            } else {
                negativeCount += 1
                if confidence >= threshold {
                    fpCount += 1
                }
            }
        }
        NSLog("False positive rate = %.02f%%", fpCount / negativeCount * 100)
        NSLog("False negative rate = %.02f%%", fnCount / positiveCount * 100)
        XCTAssertLessThanOrEqual(fpCount / negativeCount, maxFailRate, String(format: "False positive rate is less than %.0f%%", maxFailRate * 100))
        XCTAssertLessThanOrEqual(fnCount / positiveCount, maxFailRate, String(format: "False negative rate is less than %.0f%%", maxFailRate * 100))
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
