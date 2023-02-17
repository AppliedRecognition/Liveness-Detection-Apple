//
//  SpoofDeviceDetectorTest.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 17/02/2023.
//

import XCTest
@testable import LivenessDetection

final class SpoofDeviceDetectorTest: BaseTest {
    
    var spoofDeviceDetector: SpoofDeviceDetector!

    override func setUpWithError() throws {
        try super.setUpWithError()
        self.spoofDeviceDetector = try self.createSpoofDeviceDetector()
    }
    
    func test_measureSpoofDeviceDetectionSpeed() throws {
        let image = try self.firstImage(type: .spoofDevice, positive: true)
        self.measure {
            _ = try! self.spoofDeviceDetector.detectSpoofDevicesInImage(image)
        }
    }
    
    func test_detectSpoofDevices_succeedsOn80PercentOfImages() throws {
        let threshold: Float = 0.5
        let maxFailRatio: Float = 0.2
        var detectionCount: Float = 0
        var failCount: Float = 0
        try withEachImage(types: [.spoofDevice]) { (image, url, positive) in
            let spoofDevices = try self.spoofDeviceDetector.detectSpoofDevicesInImage(image)
            let score = spoofDevices.sorted(by: { $0.confidence > $1.confidence }).first?.confidence ?? 0.0
            let prefix = positive ? "positive" : "negative"
            if (positive && score >= threshold) || (!positive && score < threshold) {
                NSLog("%@/%@ succeeded: spoof device confidence %.04f", prefix, url.lastPathComponent, score)
            } else {
                NSLog("%@/%@ failed: spoof device confidence %.04f", prefix, url.lastPathComponent, score)
                failCount += 1
            }
            detectionCount += 1
        }
        let failRatio = failCount / detectionCount
        NSLog("Fail ratio: %.02f%%", failRatio * 100)
        XCTAssertLessThanOrEqual(failRatio, maxFailRatio, String(format: "Fail ratio must be below %.0f%% but is %.02f%%", maxFailRatio * 100, failRatio * 100))
    }
}
