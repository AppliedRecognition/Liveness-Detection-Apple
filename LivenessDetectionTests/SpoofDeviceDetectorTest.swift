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
        let maxFailRatio: Float = 0.2
        let failRatio = try self.failRatioOfDetectionOnEachImage(self.spoofDeviceDetector, detectFace: false)
        NSLog("Fail ratio: %.02f%%", failRatio * 100)
        XCTAssertLessThanOrEqual(failRatio, maxFailRatio, String(format: "Fail ratio must be below %.0f%% but is %.02f%%", maxFailRatio * 100, failRatio * 100))
    }
    
    func test_detectSpoofDevicesWithROI_succeedsOn80PercentOfImages() throws {
        let maxFailRatio: Float = 0.2
        let failRatio = try self.failRatioOfDetectionOnEachImage(self.spoofDeviceDetector, detectFace: true)
        NSLog("Fail ratio: %.02f%%", failRatio * 100)
        XCTAssertLessThanOrEqual(failRatio, maxFailRatio, String(format: "Fail ratio must be below %.0f%% but is %.02f%%", maxFailRatio * 100, failRatio * 100))
    }
}
