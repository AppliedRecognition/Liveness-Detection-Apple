//
//  SpoofDetector.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 08/03/2023.
//

import Foundation
import UIKit

/// Spoof detector protocol
/// - Since: 1.1.0
public protocol SpoofDetector: AnyObject {
    
    /// String that identifies the detector
    /// - Since: 1.1.0
    var identifier: String { get }
    
    /// Confidence threshold used to filter results by the `isSpoofedImage(:regionOfInterest:)` method
    /// - Since: 1.1.0
    var confidenceThreshold: Float { get set }
    
    /// Detect spoof in image
    /// - Parameters:
    ///   - image: Image in which to detect a spoof
    ///   - roi: Region of interest to consider in the detection process – for example, a face boundary
    /// - Returns: Confidence score ranging from 0–1, where 1 is highest confidence that the image is spoofed
    /// - Since: 1.1.0
    func detectSpoofInImage(_ image: UIImage, regionOfInterest roi: CGRect?) throws -> Float
    
    /// Indicate whether an image is spoofed
    /// - Parameters:
    ///   - image: Image in which to detect a spoof
    ///   - roi: Region of interest to consider in the detection process – for example, a face boundary
    /// - Returns: `true` if the image is spoofed with confidence higher or equal to `confidenceThreshold`
    /// - Since: 1.1.0
    func isSpoofedImage(_ image: UIImage, regionOfInterest roi: CGRect?) throws -> Bool
}

public extension SpoofDetector {
    
    func isSpoofedImage(_ image: UIImage, regionOfInterest roi: CGRect?) throws -> Bool {
        let score = try self.detectSpoofInImage(image, regionOfInterest: roi)
        return score >= self.confidenceThreshold
    }
}
