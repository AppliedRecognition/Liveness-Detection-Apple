//
//  SpoofDetector5Config.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 21/09/2023.
//

import Foundation

public struct SpoofDetector5Config {
    
    public let modelURL: URL
    public let blurThreshold: Float = 20
    public let shouldCheckForBlur: Bool = true
}
