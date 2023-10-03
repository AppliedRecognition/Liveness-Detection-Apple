//
//  SpoofDetector4.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 21/07/2023.
//

import Foundation
import UIKit
import CoreML
import Accelerate

public class SpoofDetector4: SpoofDetector {
    
    public var identifier: String
    
    public var confidenceThreshold: Float = 0.45
    
    let components: [SpoofDetector4Component]
    
    public init(configs: [SpoofDetector4Config]) throws {
        self.components = try configs.map({ try SpoofDetector4Component(configuration: $0) })
        self.identifier = configs.map({ $0.modelURL.lastPathComponent }).joined(separator: ", ")
    }
    
    public convenience init(modelURL1: URL, modelURL2: URL) throws {
        let configs = [
            SpoofDetector4Config(modelURL: modelURL1, scale: 2.7, shiftX: 0, shiftY: 0, width: 80, height: 80),
            SpoofDetector4Config(modelURL: modelURL2, scale: 4.0, shiftX: 0, shiftY: 0, width: 80, height: 80)
        ]
        try self.init(configs: configs)
    }
    
    public func detectSpoofInImage(_ image: UIImage, regionOfInterest roi: CGRect?) throws -> Float {
        var sum: Float = 0
        try self.components.forEach {
            let scores = try $0.predictionFromImage(image, regionOfInterest: roi)
            sum += scores[1]
        }
        let score = sum / Float(self.components.count)
        return 1 - score
    }
}
