//
//  SpoofDeviceDetectorTest.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 17/02/2023.
//

import XCTest
import UniformTypeIdentifiers
@testable import LivenessDetection

final class SpoofDeviceDetectorTest: BaseTest<SpoofDeviceDetector> {
    
    override var expectedSuccessRate: Float {
        0.4
    }
    
    override func createSpoofDetector() throws -> SpoofDeviceDetector {
        try self.createSpoofDeviceDetector()
    }
    
    @available(iOS 14.0, *)
    func test_detectSpoofInImages_outputCSV() throws {
        var csv = "Image,Live,Score\n"
        try withEachImage(types: [.spoofDevice,.moire]) { (image, url, positive) in
            let score = try self.spoofDetector.detectSpoofInImage(image, regionOfInterest: nil)
            csv.append(String(format: "\"%@\",%d,%.03f\n", "\(url)", NSNumber(value: !positive).intValue, score))
        }
        let attachment = XCTAttachment(data: csv.data(using: .utf8)!, uniformTypeIdentifier: UTType.commaSeparatedText.identifier)
        attachment.lifetime = .keepAlways
        attachment.name = "PSD001.csv"
        self.add(attachment)
    }
    
    func test_detectSpoofDevices_outputCSV() throws {
        var csv = "\"File name\",\"Is live\",\"Image width\",\"Image height\""
        for i in 1...10 {
            csv.append(",\"Spoof device \(i) confidence\",\"Spoof device \(i) contains face\",\"Spoof device \(i) x\",\"Spoof device \(i) y\",\"Spoof device \(i) width\",\"Spoof device \(i) height\"")
        }
        csv += "\n"
        try withEachImage(types: [.spoofDevice,.moire]) { image, url, positive in
            csv += String(format: "\"%@\",%d,%.0f,%.0f", url.lastPathComponent, positive ? 0 : 1, image.size.width, image.size.height)
            let faces = try self.detectFacesInImage(image)
            let devices = try self.spoofDetector.detectSpoofDevicesInImage(image)
            let faceTransform = CGAffineTransform(scaleX: image.size.width, y: image.size.height)
            for device in devices {
                var containsFace = 0
                for face in faces {
                    let faceCentre = CGPoint(x: face.midX, y: face.midY).applying(faceTransform)
                    if device.boundingBox.contains(faceCentre) {
                        containsFace = 1
                        break
                    }
                }
                csv += String(format: ",%.03f,%d,%.01f,%.01f,%.01f,%.01f", device.confidence, containsFace, device.boundingBox.minX, device.boundingBox.minY, device.boundingBox.width, device.boundingBox.height)
            }
            csv += "\n"
        }
        let attachment = XCTAttachment(data: csv.data(using: .utf8)!, uniformTypeIdentifier: UTType.commaSeparatedText.identifier)
        attachment.lifetime = .keepAlways
        attachment.name = "PSD001_detected_devices.csv"
        self.add(attachment)
    }
}
