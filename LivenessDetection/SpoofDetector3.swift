//
//  SpoofDetector3.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 03/03/2023.
//

import Foundation
import UIKit
import CoreML
import Vision
import Accelerate
import AVFoundation

/// Generic spoof detector
/// - Since: 1.1.0
public class SpoofDetector3: SpoofDetector {
    
    let model: MLModel
    let width: Int = 224
    let height: Int = 224
    lazy var shape = [1, 3, width, height] as [NSNumber]
    lazy var strides = [width * height * 3, width * height, width, 1] as [NSNumber]
    
    @available(iOS 16, macOS 13, macCatalyst 16, *)
    /// Constructor
    /// - Parameter modelURL: Model file URL
    public convenience init(modelURL: URL) async throws {
        let compiledModelURL = try await MLModel.compileModel(at: modelURL)
        try self.init(compiledModelURL: compiledModelURL, identifier: modelURL.lastPathComponent)
    }
    
    /// Constructor
    /// - Parameter modelURL: Model file URL
    public convenience init(modelURL: URL) throws {
        let compiledModelURL = try MLModel.compileModel(at: modelURL)
        try self.init(compiledModelURL: compiledModelURL, identifier: modelURL.lastPathComponent)
    }
    
    private init(compiledModelURL: URL, identifier: String) throws {
        self.model = try MLModel(contentsOf: compiledModelURL)
        self.identifier = identifier
    }
    
    // MARK: - SpoofDetector
    
    public let identifier: String
    
    public var confidenceThreshold: Float = 0.3
    
    public func detectSpoofInImage(_ image: UIImage, regionOfInterest roi: CGRect? = nil) throws -> Float {
        let img: UIImage
        if let crop = roi {
            img = self.cropImage(image, toRect: crop)
        } else {
            img = image
        }
        let prediction = try self.model.prediction(from: self.featureProvider(img))
        return try self.softmaxFromFeatureProvider(prediction)[1]
    }
    
    // MARK: -
    
    func cropImage(_ image: UIImage, toRect rect: CGRect) -> UIImage {
        UIGraphicsBeginImageContext(rect.size)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(at: CGPoint(x: 0-rect.minX, y: 0-rect.minY))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func featureProvider(_ image: UIImage) throws -> MLDictionaryFeatureProvider {
        let multiArray = try self.prepareImage(image)
        return try MLDictionaryFeatureProvider(dictionary: ["x_1": multiArray])
    }
    
    func scaleImage(_ image: UIImage) throws -> CGImage {
        let destSize = CGSize(width: width, height: height)
        var rect = AVMakeRect(aspectRatio: destSize, insideRect: CGRect(origin: .zero, size: image.size))
        let scale = destSize.width / rect.width
        UIGraphicsBeginImageContext(destSize)
        defer {
            UIGraphicsEndImageContext()
        }
        rect = CGRect(x: 0-rect.minX*scale, y: 0-rect.minY*scale, width: image.size.width*scale, height: image.size.height*scale)
        image.draw(in: rect)
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            throw NSError()
        }
        return cgImage
    }
    
    func softmaxFromFeatureProvider(_ featureProvider: MLFeatureProvider) throws -> [Float] {
        guard let multiArray = (featureProvider as? MLDictionaryFeatureProvider)?["var_373"]?.multiArrayValue else {
            throw NSError()
        }
        let vec: [Float] = [multiArray[0].floatValue, multiArray[1].floatValue]
        return vec.map({
            exp($0) / vec.map({ exp($0) }).reduce(0, +)
        })
    }
    
    func prepareImage(_ image: UIImage) throws -> MLMultiArray {
        let cgImage = try self.scaleImage(image)
        let colourSpace: Unmanaged<CGColorSpace> = cgImage.colorSpace != nil ? Unmanaged.passRetained(cgImage.colorSpace!) : Unmanaged.passRetained(CGColorSpaceCreateDeviceRGB())
        var format = vImage_CGImageFormat(bitsPerComponent: UInt32(cgImage.bitsPerComponent), bitsPerPixel: UInt32(cgImage.bitsPerPixel), colorSpace: colourSpace, bitmapInfo: cgImage.bitmapInfo, version: 0, decode: nil, renderingIntent: .defaultIntent)
        let originalLength = cgImage.height * cgImage.bytesPerRow
        let originalBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: originalLength)
        var originalBuffer = vImage_Buffer(data: originalBytes, height:vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.bytesPerRow)
        defer {
            if #available(iOS 13, *) {
                originalBuffer.free()
            } else {
                originalBytes.deallocate()
            }
        }
        var error = vImageBuffer_InitWithCGImage(&originalBuffer, &format, nil, cgImage, numericCast(kvImageNoAllocate))
        guard error == kvImageNoError else {
            throw ImageProcessingError.cgImageFromBufferError
        }
        let trimmedBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: cgImage.width * cgImage.height * 4)
        var trimmedBuffer = vImage_Buffer(data: trimmedBytes, height: vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.width * 4)
        defer {
            if #available(iOS 13, *) {
                trimmedBuffer.free()
            } else {
                trimmedBytes.deallocate()
            }
        }
        error = vImageCopyBuffer(&originalBuffer, &trimmedBuffer, 4, numericCast(kvImageNoAllocate))
        guard error == kvImageNoError else {
            throw NSError()
        }
        
        let channelSize = cgImage.width * cgImage.height
        var offset = 0
        let input = UnsafeMutablePointer<Float32>.allocate(capacity: channelSize * 3)
        for i in 0..<3 {
            let channelBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: channelSize)
            var channelBuffer = vImage_Buffer(data: channelBytes, height: vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.width)
            defer {
                if #available(iOS 13, *) {
                    channelBuffer.free()
                } else {
                    channelBytes.deallocate()
                }
            }
            error = vImageExtractChannel_ARGB8888(&trimmedBuffer, &channelBuffer, i, numericCast(kvImageNoFlags))
            guard error == kvImageNoError else {
                throw NSError()
            }
            let floatBytes = UnsafeMutablePointer<Float32>.allocate(capacity: channelSize)
            var floatBuffer = vImage_Buffer(data: floatBytes, height: vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.width * 4)
            defer {
                if #available(iOS 13, *) {
                    floatBuffer.free()
                } else {
                    floatBytes.deallocate()
                }
            }
            error = vImageConvert_Planar8toPlanarF(&channelBuffer, &floatBuffer, 1.0, 0.0, numericCast(kvImageNoFlags))
            guard error == kvImageNoError else {
                throw NSError()
            }
            (input + offset).initialize(from: floatBytes, count: channelSize)
            offset += channelSize
        }
        return try MLMultiArray(dataPointer: input, shape: shape, dataType: .float32, strides: strides)
    }
}
