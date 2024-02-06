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
    
    func test_detectSpoofInImagesFromS3() throws {
        let bundle = Bundle(for: type(of: self))
        guard let liveImageIndexURL = bundle.url(forResource: "live_images", withExtension: "txt") else {
            throw "Failed to read live image index file"
        }
        guard let spoofImageIndexURL = bundle.url(forResource: "spoof_images", withExtension: "txt") else {
            throw "Failed to read spoof image index file"
        }
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "ARC_PSD-001_1.1.122_bst_yl80201_NMS_ult201_cml70", withExtension: "mlmodelc") else {
            throw "Model package not found"
        }
        let spoofDetector = try SpoofDeviceDetector(compiledModelURL: modelURL, identifier: "ARC_PSD-001_1.1.122_bst_yl80201_NMS_ult201_cml70")
//        let moireDetector = try self.createMoireDetector()
//        let spoofDetection = SpoofDetection([spoofDetector, moireDetector])
        let exp = self.expectation(description: "Runs test")
        Task {
            var csv = "\"Image\",\"Live\",\"Score\""
            var spoofURLs: [(Bool,URL)] = []
            for try await line in liveImageIndexURL.lines.compactMap({ URL(string: $0) }).map({ (false, $0) }) {
                spoofURLs.append(line)
            }
            var liveURLs: [(Bool,URL)] = []
            for try await line in spoofImageIndexURL.lines.compactMap({ URL(string: $0) }).map({ (true, $0) }) {
                liveURLs.append(line)
            }
            let iterator = ImageIterator(urls: spoofURLs + liveURLs)
            while let (url, spoof, image) = iterator.next() {
                do {
                    let faces = try FaceDetection.detectFacesInImage(image)
                    let score = try spoofDetector.detectSpoofInImage(image, regionOfInterest: faces.first?.bounds)
                    csv.append(String(format: "\n\"%@\",%@,%.03f", url.path, spoof ? "FALSE" : "TRUE", score))
                } catch {
                    NSLog("Spoof detection failed on \(url)")
                }
            }
            let attachment = XCTAttachment(data: csv.data(using: .utf8)!, uniformTypeIdentifier: UTType.commaSeparatedText.identifier)
            attachment.lifetime = .keepAlways
            attachment.name = "ARC_PSD-001_1.1.122_bst_yl80201_NMS_ult201_cml70.csv"
            self.add(attachment)
            exp.fulfill()
        }
        self.wait(for: [exp])
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
            let faces = try FaceDetection.detectFacesInImage(image)
            let devices = try self.spoofDetector.detectSpoofDevicesInImage(image)
            for device in devices {
                var containsFace = 0
                for face in faces {
                    if device.boundingBox.contains(face.center) {
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
    
    func test_compareModels() throws {
        let imageIterator = ImageIterator()
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "ARC_PSD-001_1.1.122_bst_yl80201_NMS_ult201_cml70", withExtension: "mlmodelc") else {
            fatalError("Model package not found")
        }
        let newSpoofDetector = try SpoofDeviceDetector(compiledModelURL: modelURL, identifier: "ARC_PSD-001_1.1.122_bst_yl80201_NMS_ult201_cml70")
        var csv = """
"","",0.5,"=D2/COUNTIF(B,false)","=E2/COUNTIF(B,true)",0.5,"=G2/COUNTIF(B,false)","=H2/COUNTIF(B,true)"
"","","","=COUNTIF(D,true)","=COUNTIF(E,true)","","=COUNTIF(G,true)","=COUNTIF(H,true)"
"File","Is spoof","\(self.spoofDetector.identifier)","FP","FN","\(newSpoofDetector.identifier)","FP","FN"
"""
        var row = 3
        while let (url, isSpoof, image) = imageIterator.next() {
            row += 1
            let face = try FaceDetection.detectFacesInImage(image).first?.bounds
            let originalScore = try self.spoofDetector.detectSpoofInImage(image, regionOfInterest: face)
            let newScore = try newSpoofDetector.detectSpoofInImage(image, regionOfInterest: face)
            csv.append(String(format: "\n\"%@\",%@,%.03f,\"=AND(NOT(B%d),C%d>C1)\",\"=AND(B%d,C%d<=C1)\",%.03f,\"=AND(NOT(B%d),F%d>F1)\",\"=AND(B%d,F%d<=F1)\"", url.lastPathComponent, isSpoof ? "true" : "false", originalScore, row, row, row, row, newScore, row, row, row, row))
        }
        let attachment = XCTAttachment(data: csv.data(using: .utf8)!, uniformTypeIdentifier: UTType.commaSeparatedText.identifier)
        attachment.lifetime = .keepAlways
        attachment.name = "Comparison.csv"
        self.add(attachment)
    }
    
    func test_detectSpoofDevices_outputAnnotatedImages() throws {
        let imageIterator = ImageIterator()
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "ARC_PSD-001_1.1.122_bst_yl80201_NMS_ult201_cml70", withExtension: "mlmodelc") else {
            fatalError("Model package not found")
        }
        let spoofDetector = try SpoofDeviceDetector(compiledModelURL: modelURL, identifier: "ARC_PSD-001_1.1.122_bst_yl80201_NMS_ult201_cml70")
        while let (url, isSpoof, image) = imageIterator.next() {
            if (!isSpoof) {
                continue
            }
            let face = try FaceDetection.detectFacesInImage(image).first
            let score = try spoofDetector.detectSpoofInImage(image, regionOfInterest: face?.bounds)
            if score < 0.5 {
                let spoofDevices = try spoofDetector.detectSpoofDevicesInImage(image)
                UIGraphicsBeginImageContext(image.size)
                defer {
                    UIGraphicsEndImageContext()
                }
                image.draw(at: .zero)
                if !spoofDevices.isEmpty || face != nil, let context = UIGraphicsGetCurrentContext() {
                    let lineWidth: CGFloat = min(image.size.width, image.size.height) * 0.01
                    context.setLineWidth(lineWidth)
                    if !spoofDevices.isEmpty {
                        context.setStrokeColor(UIColor.red.cgColor)
                        context.addRects(spoofDevices.map { $0.boundingBox })
                        context.strokePath()
                    }
                    if let faceBounds = face?.bounds {
                        context.setStrokeColor(UIColor.green.cgColor)
                        context.addRect(faceBounds)
                        context.strokePath()
                        context.setFillColor(UIColor.green.cgColor)
                        context.fillEllipse(in: CGRect(x: faceBounds.midX-lineWidth, y: faceBounds.midY-lineWidth, width: lineWidth*2, height: lineWidth*2))
                    }
                }
                if let annotatedImage = UIGraphicsGetImageFromCurrentImageContext() {
                    let attachment = XCTAttachment(image: annotatedImage)
                    attachment.lifetime = .keepAlways
                    attachment.name = url.lastPathComponent
                    self.add(attachment)
                }
            }
        }
    }
}
