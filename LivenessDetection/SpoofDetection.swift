//
//  SpoofDetection.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 08/03/2023.
//

import Foundation
import UIKit

/// Liveness detection using one or more spoof detectors
/// - Since: 1.1.0
public class SpoofDetection {
    
    /// Spoof detectors used for liveness detection
    /// - Since: 1.1.0
    public let spoofDetectors: [SpoofDetector]
    
    /// Initializer
    /// - Parameter spoofDetector: Spoof detectors to use for liveness detection
    public init(_ spoofDetector: SpoofDetector...) {
        self.spoofDetectors = spoofDetector
    }
    
    /// Detect a spoof in image
    /// - Parameters:
    ///   - image: Image in which to detect a spoof
    ///   - roi: Region of interest – may be interpreted differently by each spoof detector
    /// - Returns: Maximum confidence score returned by one of the spoof detectors
    /// - Since: 1.1.0
    public func detectSpoofInImage(_ image: UIImage, regionOfInterest roi: CGRect? = nil) throws -> Float {
        return try self.spoofDetectors.map { try $0.detectSpoofInImage(image, regionOfInterest: roi) }.max() ?? 0
    }
    
    /// Detect spoofs in image
    /// - Parameters:
    ///   - image: Image in which to detect spoofs
    ///   - roi: Region of interest – may be interpreted differently by each spoof detector
    /// - Returns: Confidence scores from each spoof detector
    /// - Since: 1.1.0
    public func detectSpoofsInImage(_ image: UIImage, regionOfInterest roi: CGRect? = nil) throws -> [String: Float] {
        let scores = try self.spoofDetectors.map { ($0.identifier, try $0.detectSpoofInImage(image, regionOfInterest: roi)) }
        return Dictionary(uniqueKeysWithValues: scores)
    }
    
    /// Find out if an image is spoofed
    /// - Parameters:
    ///   - image: Image in which to detect spoofs
    ///   - roi: Region of interest – may be interpreted differently by each spoof detector
    /// - Returns: `true` if the image is spoofed
    /// - Note: The function runs a spoof check on the spoof detectors until one of them returns `true`. The function returns `false` if it iterates over all the spoof detectors and none of them returns `true`.
    /// - Since: 1.1.0
    public func isSpoofedImage(_ image: UIImage, regionOfInterest roi: CGRect? = nil) throws -> Bool {
        for detector in spoofDetectors {
            if try detector.isSpoofedImage(image, regionOfInterest: roi) {
                return true
            }
        }
        return false
    }
}
