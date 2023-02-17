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
}
