//
//  LivenessDetectionTests.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 03/02/2023.
//

import XCTest
import UIKit
import ZIPFoundation
import UniformTypeIdentifiers
import Accelerate
@testable import LivenessDetection

final class LivenessDetectionTests: BaseTest<SpoofDetection> {
    
    var detectorCombinations: [SpoofDetector] = []
    
    override var expectedSuccessRate: Float {
        0.83
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let psd001 = try self.createSpoofDeviceDetector()
        let psd002 = try self.createMoireDetector()
        let psd003 = try self.createSpoofDetector3()
        self.detectorCombinations = [
            SpoofDetection(psd001, psd002, psd003),
            SpoofDetection(psd001, psd002),
            SpoofDetection(psd001, psd003),
            SpoofDetection(psd002, psd003),
            SpoofDetection(psd001),
            SpoofDetection(psd002),
            SpoofDetection(psd003)
        ]
    }
        
    override func createSpoofDetector() throws -> SpoofDetection {
        try SpoofDetection(self.createSpoofDeviceDetector(), self.createMoireDetector(), self.createSpoofDetector3())
    }
    
    func test_detectSpoofInImages_outputCSV() throws {
        var csv = "\"File\",\"Is live\""
        for spoofDetector in self.detectorCombinations {
            csv.append(",\"\(spoofDetector.identifier)\"")
        }
        try self.withEachImage(types: [.moire, .spoofDevice]) { image, url, positive in
            let face = try FaceDetection.detectFacesInImage(image).first?.bounds
            csv += String(format: "\n\"%@\",%d", url.lastPathComponent, positive ? 0 : 1)
            for spoofDetector in self.detectorCombinations {
                let score = try spoofDetector.detectSpoofInImage(image, regionOfInterest: face)
                csv += String(format: ",%.03f", score)
            }
        }
        let attachment = XCTAttachment(data: csv.data(using: .utf8)!, uniformTypeIdentifier: UTType.commaSeparatedText.identifier)
        attachment.lifetime = .keepAlways
        attachment.name = "Scores.csv"
        self.add(attachment)
    }
    
    func test_outputScoresFromEachDetectorAsCSV() throws {
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: "ARC_PSD-001_1.1.122_bst_yl80201_NMS_ult201_cml70", withExtension: "mlmodelc") else {
            fatalError("Model package not found")
        }
        let spoofDeviceDetector = try SpoofDeviceDetector(compiledModelURL: modelURL, identifier: "ARC_PSD-001_1.1.122_bst_yl80201_NMS_ult201_cml70")
        let moireDetector = try self.createMoireDetector()
        let aenetDetector = try self.createSpoofDetector3()
        let detectors: [SpoofDetector] = [spoofDeviceDetector, moireDetector, aenetDetector]
        var csv = "\"File\",\"Is spoof\""+detectors.map { "\"\($0.identifier)\"" }.joined(separator: ",")
        let imageIterator = ImageIterator()
        while let (url, isSpoof, image) = imageIterator.next() {
            let face = try FaceDetection.detectFacesInImage(image).first?.bounds
            csv.append(String(format: "\n\"%@\",%@", url.lastPathComponent, isSpoof ? "true" : "false"))
            let scores = try detectors.map { try $0.detectSpoofInImage(image, regionOfInterest: face) }.map { String(format: ",%.03f", $0) }
            csv.append(scores.joined())
        }
        let attachment = XCTAttachment(data: csv.data(using: .utf8)!, uniformTypeIdentifier: UTType.commaSeparatedText.identifier)
        attachment.lifetime = .keepAlways
        attachment.name = "Scores.csv"
        self.add(attachment)
    }
    
    func test_compareSpoofDetectorCombinations() throws {
        guard let faceLoader = FaceLoader() else {
            XCTFail()
            return
        }
        let spoofDetectors: [String:[SpoofDetector]] = [
            "new": [SpoofDetection(try self.createSpoofDeviceDetector(), try self.createMoireDetector())],
            "old": [try self.createMoireDetector(), try self.createSpoofDetector3(), try self.createSpoofDetector4()]
        ]
        var fpCounts: [String:Int] = ["new":0, "old":0]
        var fnCounts: [String:Int] = ["new":0, "old":0]
        var totalSpoofCount: Int = 0
        var totalLiveCount: Int = 0
        let threshold: Float = 0.5
        let imageIterator = ImageIterator()
        var csv = "\"File\",\"Is live\""
        for spoofDetectorSet in spoofDetectors.values {
            csv += ",\"\(spoofDetectorSet.map({ $0.identifier }).joined(separator: ", "))\",\"FP\",\"FN\""
        }
        while let (url, isSpoof, image) = imageIterator.next() {
            let face = faceLoader.faceInImage(url.lastPathComponent)
            if isSpoof {
                totalSpoofCount += 1
            } else {
                totalLiveCount += 1
            }
            csv += "\n\"\(url.lastPathComponent)\",\(isSpoof ? "false" : "true")"
            for (name, spoofDetectorSet) in spoofDetectors {
                let scores = try spoofDetectorSet.map({ try $0.detectSpoofInImage(image, regionOfInterest: face) })
                let score = vDSP.mean(scores)
                let isFP = !isSpoof && score >= threshold
                let isFN = isSpoof && score < threshold
                if isFP {
                    fpCounts[name] = fpCounts[name]! + 1
                }
                if isFN {
                    fnCounts[name] = fnCounts[name]! + 1
                }
                csv += String(format: ",%.03f,%@,%@", score, isFP ? "true" : "false", isFN ? "true" : "false")
            }
        }
        let csvAttachment = XCTAttachment(data: csv.data(using: .utf8)!, uniformTypeIdentifier: UTType.commaSeparatedText.identifier)
        csvAttachment.lifetime = .keepAlways
        csvAttachment.name = "Comparison.csv"
        self.add(csvAttachment)
        
        var summary = String(format: "Total number of images: %d\nNumber of spoof images: %d\nNumber of live images: %d", totalLiveCount + totalSpoofCount, totalSpoofCount, totalLiveCount)
        summary += String(format: "\nOld models FP count: %d/%d (%.02f%%)", fpCounts["old"]!, totalLiveCount, Float(fpCounts["old"]!) / Float(totalLiveCount) * 100)
        summary += String(format: "\nOld models FN count: %d/%d (%.02f%%)", fnCounts["old"]!, totalSpoofCount, Float(fnCounts["old"]!) / Float(totalSpoofCount) * 100)
        summary += String(format: "\nNew models FP count: %d/%d (%.02f%%)", fpCounts["new"]!, totalLiveCount, Float(fpCounts["new"]!) / Float(totalLiveCount) * 100)
        summary += String(format: "\nNew models FN count: %d/%d (%.02f%%)", fnCounts["new"]!, totalSpoofCount, Float(fnCounts["new"]!) / Float(totalSpoofCount) * 100)
        
        let summaryAttachment = XCTAttachment(string: summary)
        summaryAttachment.lifetime = .keepAlways
        summaryAttachment.name = "Summary.txt"
        self.add(summaryAttachment)
    }
    
    func test_livenessDetection_attachAnnotatedImages() throws {
        let colours: [CGColor] = [UIColor.green.cgColor, UIColor.red.cgColor, UIColor.purple.cgColor, UIColor.cyan.cgColor]
        let archiveURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("zip")
        guard let archive = Archive(url: archiveURL, accessMode: .create) else {
            XCTFail("Failed to create zip archive")
            return
        }
        try self.withEachImage(types: [.moire, .spoofDevice]) { (image, url, positive) in
            guard let spoofs = try (self.spoofDetector.spoofDetectors.first(where: { $0 is SpoofDeviceDetector }) as? SpoofDeviceDetector)?.detectSpoofDevicesInImage(image) else {
                return
            }
            var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            for spoof in spoofs {
                imageRect = imageRect.union(spoof.boundingBox)
            }
            let addedHeight: CGFloat = 32
            let lineWidth: CGFloat = 4
            let padding: CGFloat = 8
            let paddingTransform = CGAffineTransform(translationX: padding, y: padding)
            imageRect.size.height += addedHeight
            let offset = CGAffineTransform(translationX: 0-imageRect.minX, y: 0-imageRect.minY)
            UIGraphicsBeginImageContext(imageRect.size)
            image.draw(at: .zero.applying(offset))
            guard let context = UIGraphicsGetCurrentContext() else {
                return
            }
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(x: 0, y: image.size.height, width: image.size.width, height: addedHeight))
            var colourIndex = 0
            for spoof in spoofs {
                if colourIndex >= colours.count {
                    colourIndex = 0
                }
                let spoofRect = spoof.boundingBox.applying(offset).insetBy(dx: lineWidth/2, dy: lineWidth/2)
                let scoreString = self.attributedString(String(format: "Spoof device: %.03f", spoof.confidence), colour: .black)
                var labelRectSize = scoreString.size()
                labelRectSize = CGSize(width: labelRectSize.width + padding * 2, height: labelRectSize.height + padding * 2)
                let labelRect = CGRect(origin: spoofRect.origin, size: labelRectSize)
                context.setFillColor(UIColor.white.cgColor)
                context.fill(labelRect)
                context.setStrokeColor(colours[colourIndex])
                context.setLineWidth(lineWidth)
                context.stroke(spoofRect)
                scoreString.draw(at: spoofRect.origin.applying(paddingTransform))
            }
            defer {
                UIGraphicsEndImageContext()
            }
            let spoofConfidence = try self.spoofDetector.detectSpoofInImage(image)
            let spoofConfidenceString = self.attributedString(String(format: "Spoof: %.03f", spoofConfidence), colour: .black)
            let stringSize = spoofConfidenceString.size()
            spoofConfidenceString.draw(at: CGPoint(x: imageRect.maxX - stringSize.width - padding, y: imageRect.maxY - addedHeight + padding))
            guard let confidence = try self.spoofDetector.spoofDetectors.first(where: { $0 is MoireDetector })?.detectSpoofInImage(image, regionOfInterest: nil) else {
                return
            }
            self.attributedString(String(format: "Moire: %.03f", confidence), colour: .black).draw(at: CGPoint(x: padding, y: imageRect.maxY - addedHeight + padding))
            if let annotatedImage = UIGraphicsGetImageFromCurrentImageContext() {
                guard let imageData = annotatedImage.jpegData(compressionQuality: 0.9) else {
                    XCTFail("Failed to encode image to JPEG")
                    return
                }
                try archive.addEntry(with: url.lastPathComponent, type: .file, uncompressedSize: Int64(imageData.count)) { (position: Int64, size: Int) in
                    return imageData[Int(position)..<Int(position)+size]
                }
                
            }
        }
        let attachment = XCTAttachment(contentsOfFile: archiveURL)
        attachment.lifetime = .keepAlways
        attachment.name = "results.zip"
        self.add(attachment)
        try? FileManager.default.removeItem(at: archiveURL)
    }
    
    private func attributedString(_ string: String, colour: UIColor) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 18)
        return NSAttributedString(string: string, attributes: [.foregroundColor: colour, .font: font])
    }
}
