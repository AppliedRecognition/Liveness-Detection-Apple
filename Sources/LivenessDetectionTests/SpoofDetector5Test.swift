//
//  SpoofDetector5Test.swift
//  LivenessDetectionTests
//
//  Created by Jakub Dolejs on 21/09/2023.
//

import XCTest
import UniformTypeIdentifiers
@testable import LivenessDetection

final class SpoofDetector5Test: BaseTest<SpoofDetector5> {
    
    override func createSpoofDetector() throws -> SpoofDetector5 {
        let detector = try self.createSpoofDetector5()
        detector.shouldCheckForBlur = false
        return detector
    }
    
    @available(iOS 14, *)
    func test_detectSpoofInImages_outputCSV() throws {
        var csv = "Image,Positive,Score\n"
        try withEachImage(types: [.spoofDevice,.moire]) { (image, url, positive) in
            let score = try self.spoofDetector.detectSpoofInImage(image, regionOfInterest: nil)
            csv.append(String(format: "\"%@\",%d,%.03f\n", "\(url)", NSNumber(value: positive).intValue, score))
        }
        let attachment = XCTAttachment(data: csv.data(using: .utf8)!, uniformTypeIdentifier: UTType.commaSeparatedText.identifier)
        attachment.lifetime = .keepAlways
        attachment.name = "PSD005.csv"
        self.add(attachment)
    }
}
