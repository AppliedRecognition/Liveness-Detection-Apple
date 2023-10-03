//
//  SpoofDetector5.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 21/09/2023.
//

import Foundation
import UIKit
import Accelerate
import TensorFlowLite
import TensorFlowLiteCCoreML
import TensorFlowLiteCMetal

@available(iOS 13, *)
public class SpoofDetector5: SpoofDetector {
    
    private let interpreter: Interpreter
    let inputSize: CGSize = CGSize(width: 224, height: 224)
    public var blurThreshold: Float = 20
    public var shouldCheckForBlur: Bool = true
    
    public let identifier: String
    
    public var confidenceThreshold: Float = 0.5
    
    public init(configuration: SpoofDetector5Config) throws {
        let modelData = try Data(contentsOf: configuration.modelURL)
        var delegates: [Delegate] = []
        if let coremlDelegate = CoreMLDelegate() {
            delegates.append(coremlDelegate)
        } else {
            delegates.append(MetalDelegate())
        }
        self.interpreter = try Interpreter(modelData: modelData, delegates: delegates)
        self.blurThreshold = configuration.blurThreshold
        self.shouldCheckForBlur = configuration.shouldCheckForBlur
        self.identifier = configuration.modelURL.lastPathComponent
    }
    
    public func detectSpoofInImage(_ image: UIImage, regionOfInterest roi: CGRect?) throws -> Float {
        let cgImage = self.resizeImage(image)
        let data = try self.rgbDataFromImage(cgImage)
        if self.shouldCheckForBlur {
            let blur = try self.blur(in: data, width: cgImage.width, height: cgImage.height)
            if blur > self.blurThreshold {
                throw ImageProcessingError.imageIsBlurry
            }
        }
        try self.interpreter.copy(data, toInputAt: 0)
        try self.interpreter.invoke()
        let output: Tensor = try self.interpreter.output(at: 0)
        let score: Float = output.data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            let floats = ptr.assumingMemoryBound(to: Float.self)
            return floats[0]
        }
        return score
    }
    
    func resizeImage(_ image: UIImage) -> CGImage {
        UIGraphicsBeginImageContext(self.inputSize)
        defer {
            UIGraphicsEndImageContext()
        }
        image.draw(in: CGRect(origin: .zero, size: self.inputSize))
        return UIGraphicsGetImageFromCurrentImageContext()!.cgImage!
    }
    
    func rgbDataFromImage(_ cgImage: CGImage) throws -> Data {
        let colourSpace: Unmanaged<CGColorSpace> = cgImage.colorSpace != nil ? Unmanaged.passRetained(cgImage.colorSpace!) : Unmanaged.passRetained(CGColorSpaceCreateDeviceRGB())
        var format = vImage_CGImageFormat(bitsPerComponent: UInt32(cgImage.bitsPerComponent), bitsPerPixel: UInt32(cgImage.bitsPerPixel), colorSpace: colourSpace, bitmapInfo: cgImage.bitmapInfo, version: 0, decode: nil, renderingIntent: .defaultIntent)
        let originalLength = cgImage.height * cgImage.bytesPerRow
        let originalBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: originalLength)
        var originalBuffer = vImage_Buffer(data: originalBytes, height:vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.bytesPerRow)
        defer {
            originalBuffer.free()
        }
        var error = vImageBuffer_InitWithCGImage(&originalBuffer, &format, nil, cgImage, numericCast(kvImageNoAllocate))
        guard error == kvImageNoError else {
            throw ImageProcessingError.cgImageFromBufferError
        }
        let trimmedBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: cgImage.width * cgImage.height * 4)
        var trimmedBuffer = vImage_Buffer(data: trimmedBytes, height: vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.width * 4)
//        defer {
//            trimmedBuffer.free()
//        }
        error = vImageCopyBuffer(&originalBuffer, &trimmedBuffer, 4, numericCast(kvImageNoAllocate))
        guard error == kvImageNoError else {
            throw NSError()
        }
        let outWidth: UInt = UInt(cgImage.width)
        let outHeight: UInt = UInt(cgImage.height)
        let outBytesPerRow: Int = Int(outWidth * 4)
        var outBuffer = vImage_Buffer(data: trimmedBytes, height: outHeight, width: outWidth, rowBytes: outBytesPerRow)
        defer {
            outBuffer.free()
        }
        let rgbDataLength = Int(outWidth * 3) * Int(outHeight)
        let rgbData = UnsafeMutablePointer<UInt8>.allocate(capacity: rgbDataLength)
        var rgbBuffer = vImage_Buffer(data: rgbData, height: outHeight, width: outWidth, rowBytes: Int(outWidth * 3))
        defer {
            rgbBuffer.free()
        }
        error = vImageConvert_ARGB8888toRGB888(&outBuffer, &rgbBuffer, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else {
            throw ImageProcessingError.cgImageConversionError
        }
        var floatBuffer: [Float] = vDSP.integerToFloatingPoint(UnsafeBufferPointer(start: rgbData, count: rgbDataLength), floatingPointType: Float.self)
        floatBuffer = vDSP.divide(floatBuffer, 255.0)
        return floatBuffer.withUnsafeBytes {
            Data($0)
        }
    }
    
    func blur(in data: Data, width: Int, height: Int) throws -> Float {
        let laplacian: [Float] = [-1, -1, -1,
                                   -1,  8, -1,
                                   -1, -1, -1]
        var image = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            let buffer = ptr.assumingMemoryBound(to: Float.self)
            return Array<Float>(buffer)
        }
        vDSP.convolve(image, rowCount: height, columnCount: width, with3x3Kernel: laplacian, result: &image)
        var mean = Float.nan
        var stdDev = Float.nan
        vDSP_normalize(&image, 1, nil, 1, &mean, &stdDev, vDSP_Length(image.count))
        return stdDev * stdDev
    }
    
}
