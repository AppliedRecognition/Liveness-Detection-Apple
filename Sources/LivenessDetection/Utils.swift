//
//  Utils.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 24/07/2023.
//

import Foundation
import Accelerate

class Utils {
    
    static func softmax(_ vec: [Float]) -> [Float] {
        return vec.map({
            exp($0) / vec.map({ exp($0) }).reduce(0, +)
        })
    }
}
