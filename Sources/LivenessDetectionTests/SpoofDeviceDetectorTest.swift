//
//  SpoofDeviceDetectorTest.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 17/02/2023.
//

import XCTest
@testable import LivenessDetection

final class SpoofDeviceDetectorTest: BaseTest<SpoofDeviceDetector> {
    
    override var expectedSuccessRate: Float {
        0.4
    }
    
    override func createSpoofDetector() throws -> SpoofDeviceDetector {
        try self.createSpoofDeviceDetector()
    }
}
