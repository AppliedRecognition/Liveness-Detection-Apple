//
//  LivenessDetectionTests.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 03/02/2023.
//

import XCTest
import UIKit
import ZIPFoundation
@testable import LivenessDetection

final class LivenessDetectionTests: BaseTest {
    
    var spoofDeviceDetector: SpoofDeviceDetector!
    var moireDetector: MoireDetector!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.spoofDeviceDetector = try createSpoofDeviceDetector()
        self.moireDetector = try createMoireDetector()
    }
    
    func test_livenessDetection_succeedsOn80PercentOfImages() throws {
        let threshold: Float = 0.5
        let maxFailRatio: Float = 0.2
        var detectionCount: Float = 0
        var failCount: Float = 0
        let imageURLs = try self.imageURLs(types: [.moire, .spoofDevice])
        for (url, positive) in imageURLs {
            let moireConfidence = try self.moireDetector.detectMoireInImage(self.cgImage(at: url))
            let spoofDeviceConfidence = try self.spoofDeviceDetector.detectSpoofDevicesInImage(self.image(at: url)).sorted(by: { $0.confidence > $1.confidence }).first?.confidence ?? 0.0
            let success: Bool
            if positive {
                success = moireConfidence >= threshold || spoofDeviceConfidence >= threshold
            } else {
                success = moireConfidence < threshold && spoofDeviceConfidence < threshold
            }
            let prefix = positive ? "positive" : "negative"
            if !success {
                failCount += 1
                NSLog("%@/%@ failed", prefix, url.lastPathComponent)
            } else {
                NSLog("%@/%@ succeeded", prefix, url.lastPathComponent)
            }
            detectionCount += 1
        }
        let failRatio = failCount / detectionCount
        NSLog("Fail ratio: %.02f%%", failRatio * 100)
        XCTAssertLessThanOrEqual(failRatio, maxFailRatio, String(format: "Fail ratio must be below %.0f%% but is %.02f%%", maxFailRatio * 100, failRatio * 100))
    }
    
    func test_livenessDetection_attachAnnotatedImages() throws {
        let colours: [CGColor] = [UIColor.green.cgColor, UIColor.red.cgColor, UIColor.purple.cgColor, UIColor.cyan.cgColor]
        let archiveURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("zip")
        guard let archive = Archive(url: archiveURL, accessMode: .create) else {
            XCTFail("Failed to create zip archive")
            return
        }
        try self.withEachImage(types: [.moire, .spoofDevice]) { (image, url, positive) in
            let spoofs = try self.spoofDeviceDetector.detectSpoofDevicesInImage(image)
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
            if let cgImage = image.cgImage {
                let confidence = try self.moireDetector.detectMoireInImage(cgImage)
                self.attributedString(String(format: "Moire: %.03f", confidence), colour: .black).draw(at: CGPoint(x: padding, y: imageRect.maxY - addedHeight + padding))
            }
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
