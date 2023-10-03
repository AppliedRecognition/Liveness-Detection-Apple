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
            let transform = CGAffineTransform(scaleX: image.size.width, y: image.size.height)
            let face = try self.detectFaceInImage(image)?.boundingBox.applying(transform)
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
