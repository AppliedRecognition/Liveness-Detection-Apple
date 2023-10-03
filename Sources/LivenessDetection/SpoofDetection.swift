//
//  SpoofDetection.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 08/03/2023.
//

import Foundation
import UIKit
import Accelerate

/// Liveness detection using one or more spoof detectors
/// - Since: 1.1.0
public class SpoofDetection: SpoofDetector {
    
    public lazy var identifier: String = {
        self.spoofDetectors.map({ $0.identifier }).joined(separator: ", ")
    }()
    
    public var confidenceThreshold: Float = 0.5
    
    
    /// Spoof detectors used for liveness detection
    /// - Since: 1.1.0
    public let spoofDetectors: [SpoofDetector]
    
    private let scoreFusionModel: LivenessModelScoreFusion?
    
    /// Initializer
    /// - Parameter spoofDetector: Spoof detectors to use for liveness detection
    /// - Since: 1.1.0
    public init(_ spoofDetector: SpoofDetector...) {
        self.spoofDetectors = spoofDetector
        self.scoreFusionModel = try? LivenessModelScoreFusion(configuration: .init())
    }
    
    /// Initializer
    /// - Parameter spoofDetectors: Spoof detectors to use for liveness detection
    /// - Since: 1.1.0
    public init(_ spoofDetectors: [SpoofDetector]) {
        self.spoofDetectors = spoofDetectors
        self.scoreFusionModel = try? LivenessModelScoreFusion(configuration: .init())
    }
    
    /// Detect a spoof in image
    /// - Parameters:
    ///   - image: Image in which to detect a spoof
    ///   - roi: Region of interest – may be interpreted differently by each spoof detector
    /// - Returns: Maximum confidence score returned by one of the spoof detectors
    /// - Since: 1.1.0
    public func detectSpoofInImage(_ image: UIImage, regionOfInterest roi: CGRect? = nil) throws -> Float {
        let scores = try self.detectSpoofsInImage(image, regionOfInterest: roi)
        return try self.fuseScores(scores)
    }
    
    /// Detect spoofs in image
    /// - Parameters:
    ///   - image: Image in which to detect spoofs
    ///   - roi: Region of interest – may be interpreted differently by each spoof detector
    /// - Returns: Confidence scores from each spoof detector
    /// - Since: 1.1.0
    public func detectSpoofsInImage(_ image: UIImage, regionOfInterest roi: CGRect? = nil) throws -> [String: Float] {
        var scores: [String:Float] = Dictionary(uniqueKeysWithValues: self.spoofDetectors.map { ($0.identifier, Float.nan) })
        var err: Error?
        DispatchQueue.concurrentPerform(iterations: self.spoofDetectors.count) { i in
            do {
                let score = try self.spoofDetectors[i].detectSpoofInImage(image, regionOfInterest: roi)
                scores[self.spoofDetectors[i].identifier] = score
            } catch {
                err = error
            }
        }
        if err != nil {
            throw err!
        }
        return scores
    }
    
    /// Find out if an image is spoofed
    /// - Parameters:
    ///   - image: Image in which to detect spoofs
    ///   - roi: Region of interest – may be interpreted differently by each spoof detector
    /// - Returns: `true` if the image is spoofed
    /// - Note: The function runs a spoof check on the spoof detectors until one of them returns `true`. The function returns `false` if it iterates over all the spoof detectors and none of them returns `true`.
    /// - Since: 1.1.0
    public func isSpoofedImage(_ image: UIImage, regionOfInterest roi: CGRect? = nil) throws -> Bool {
        try self.detectSpoofInImage(image, regionOfInterest: roi) >= self.confidenceThreshold
    }
    
    private func fuseScores(_ scores: [String: Float]) throws -> Float {
//        if #available(iOS 13, *), let scoreFusionModel = self.scoreFusionModel, self.spoofDetectors.count == 3 && self.spoofDetectors.contains(where: { $0 is SpoofDeviceDetector }) && self.spoofDetectors.contains(where: { $0 is MoireDetector }) && self.spoofDetectors.contains(where: { $0 is SpoofDetector3 }) {
//            let psd001 = scores[self.spoofDetectors.first(where: { $0 is SpoofDeviceDetector })!.identifier]!
//            let psd002 = scores[self.spoofDetectors.first(where: { $0 is MoireDetector })!.identifier]!
//            let psd003 = scores[self.spoofDetectors.first(where: { $0 is SpoofDetector3 })!.identifier]!
//            let prediction = try scoreFusionModel.prediction(PSD001: Double(psd001), PSD002: Double(psd002), PSD003: Double(psd003))
//            return Float(prediction.Is_liveProbability[0]!)
//        } else {
//            return scores.values.reduce(0, +) / Float(self.spoofDetectors.count)
//        }
//        if #available(iOS 13, *), self.spoofDetectors.count == 3, let psd001 = self.spoofDetectors.first(where: { $0 is SpoofDeviceDetector }) as? SpoofDeviceDetector, let psd002 = self.spoofDetectors.first(where: { $0 is MoireDetector }) as? MoireDetector, let psd003 = self.spoofDetectors.first(where: { $0 is SpoofDetector3 }) as? SpoofDetector3, let psd001Weigths = self.weights(for: psd001), let psd002Weigths = self.weights(for: psd002), let psd003Weights = self.weights(for: psd003) {
//            let psd001Score = scores[psd001.identifier]!
//            let psd002Score = scores[psd002.identifier]!
//            let psd003Score = scores[psd003.identifier]!
//            var inputScores = [psd001Score, psd002Score, psd003Score]
//            let mul = [psd001Weigths[0], psd002Weigths[0], psd003Weights[0]]
//            let add = [psd001Weigths[1], psd002Weigths[1], psd003Weights[1]]
//            let relu = [psd001Weigths[2], psd002Weigths[2], psd003Weights[2]]
//            inputScores = vDSP.multiply(inputScores, mul)
//            inputScores = vDSP.add(inputScores, add)
//            for i in 0..<inputScores.count {
//                if inputScores[i] < 0 {
//                    inputScores[i] *= relu[i]
//                }
//            }
//            let score = vDSP.sum(inputScores) - 2.8539
//            return score
//        }
        let weigths = self.weights
        if !weigths.isEmpty {
            return min(scores.compactMap { key, val in
                if let weight = weigths[key] {
                    return val * weight
                }
                return nil
            }.reduce(0, +), 1.0)
        }
        return scores.values.max() ?? 0
    }
    
    private var weights: [String:Float] {
        let psd001Identifier = self.spoofDetectors.first(where: { $0 is SpoofDeviceDetector })?.identifier
        let psd002Identifier: String?
        if #available(iOS 13, *) {
            psd002Identifier = self.spoofDetectors.first(where: { $0 is MoireDetector })?.identifier
        } else {
            psd002Identifier = nil
        }
        let psd003Identifier = self.spoofDetectors.first(where: { $0 is SpoofDetector3 })?.identifier
        if psd001Identifier != nil && psd002Identifier != nil && psd003Identifier != nil {
            return [
                psd001Identifier!: 0.95649,
                psd002Identifier!: 0.24230,
                psd003Identifier!: 0.94237
            ]
        }
        if psd001Identifier != nil && psd002Identifier != nil {
            return [
                psd001Identifier!: 4.99534,
                psd002Identifier!: 2.33671
            ]
        }
        if psd001Identifier != nil && psd003Identifier != nil {
            return [
                psd001Identifier!: 0.98543,
                psd003Identifier!: 0.98095
            ]
        }
        if psd002Identifier != nil && psd003Identifier != nil {
            return [
                psd002Identifier!: 0.48082,
                psd003Identifier!: 1.37421
            ]
        }
        return [:]
    }
    
    private func weights<S>(for spoofDetector: S) -> [Float]? where S: SpoofDetector {
        if spoofDetector is SpoofDeviceDetector {
            return [5.47163, 0.30951, -0.0840]
        }
        if #available(iOS 13, *), spoofDetector is MoireDetector {
            return [1.54904, 0.05709, -0.1398]
        }
        if spoofDetector is SpoofDetector3 {
            return [0.82332, 0.00906, 0.05322]
        }
        return nil
    }
}
