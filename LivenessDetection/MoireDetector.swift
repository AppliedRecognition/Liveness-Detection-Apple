//
//  MoireDetector.swift
//  LivenessDetection
//
//  Created by Jakub Dolejs on 03/02/2023.
//

import Foundation
import UIKit
import CoreML
import Accelerate

/// Moire detector
///
/// Detects moire pattern artifacts in image
/// - Since: 1.0.0
public class MoireDetector {
    
    let imageLongerSideLength: Int = 1000
    let imageShorterSideLength: Int = 750
    let waveletDecomposition: WaveletDecomposition
    let model: MLModel
    
    /// Asynchronous constructor
    /// - Parameter modelURL: Model file URL
    /// - Since: 1.0.0
    @available(iOS 16, macOS 13, macCatalyst 16, *)
    public convenience init(modelURL: URL) async throws {
        let compiledModelURL = try await MLModel.compileModel(at: modelURL)
        try self.init(compiledModelURL: compiledModelURL)
    }
    
    /// Constructor
    /// - Parameter modelURL: Model file URL
    public convenience init(modelURL: URL) throws {
        let compiledModelURL = try MLModel.compileModel(at: modelURL)
        try self.init(compiledModelURL: compiledModelURL)
    }
    
    private init(compiledModelURL: URL) throws {
        self.waveletDecomposition = WaveletDecomposition()
        self.model = try MLModel(contentsOf: compiledModelURL)
    }
    
    /// Detect moire pattern interference artifacts in image
    /// - Parameter image: Image
    /// - Returns: Confidence score between `0.0` and `1.0` where `0` means 100% confidence that the image
    /// does not contain moire artifacts and `1` means 100% confidence that it does.
    /// - Since: 1.0.0
    public func detectMoireInImage(_ image: CGImage) throws -> Float {
        let wavelet: Array2D<UInt8> = try self.processImage(image)
        let (imgLL, imgLH, imgHL, imgHH) = try self.waveletDecomposition.haarTransformArray(wavelet)
        let multiArrays = ["input_1": imgLL, "input_2": imgLH, "input_3": imgHL, "input_4": imgHH]
        let featureProvider = try self.featureProviderFromInput(multiArrays)
        let prediction = try self.predictionFromFeatureProvider(featureProvider)
        return prediction[0].floatValue
    }
    
    func predictionFromFeatureProvider(_ featureProvider: MLDictionaryFeatureProvider) throws -> MLMultiArray {
        guard let prediction = try self.model.prediction(from: featureProvider).featureValue(for: "Identity")?.multiArrayValue else {
            throw MoireDetectorError.predictionFailure
        }
        return prediction
    }
    
    func multiArrayFromTransform(_ transform: [[Float]], name: String) throws -> MLMultiArray {
        let shape = [1, 375, 500, 1] as [NSNumber]
        let strides = [187500, 500, 1, 1] as [NSNumber]
        var flattenedInput = transform.flatMap { $0 }
        return try MLMultiArray(dataPointer: &flattenedInput, shape: shape, dataType: .float32, strides: strides)
    }
    
    func multiArrayFromTransform(_ transform: inout [Float], name: String) throws -> MLMultiArray {
        let shape = [1, 375, 500, 1] as [NSNumber]
        let strides = [187500, 500, 1, 1] as [NSNumber]
        return try MLMultiArray(dataPointer: &transform, shape: shape, dataType: .float32, strides: strides)
    }
    
    func featureProviderFromInput(_ input: [String:[[Float]]]) throws -> MLDictionaryFeatureProvider {
        let multis = try input.map { k, v in
            (k, try self.multiArrayFromTransform(v, name: k))
        }
        let dict = multis.reduce(into: [String:MLFeatureValue](), { $0[$1.0] = MLFeatureValue(multiArray: $1.1) })
        return try MLDictionaryFeatureProvider(dictionary: dict)
    }
    
    func featureProviderFromInput(_ input: [String:[Float]]) throws -> MLDictionaryFeatureProvider {
        let multis = try input.map { k, v in
            var ar = v
            return (k, try self.multiArrayFromTransform(&ar, name: k))
        }
        let dict = multis.reduce(into: [String:MLFeatureValue](), { $0[$1.0] = MLFeatureValue(multiArray: $1.1) })
        return try MLDictionaryFeatureProvider(dictionary: dict)
    }
    
    func featureProviderFromMultiArrays(_ multiArrays: [String:MLMultiArray]) throws -> MLDictionaryFeatureProvider {
        let dict = multiArrays.mapValues({ MLFeatureValue(multiArray: $0) })
        return try MLDictionaryFeatureProvider(dictionary: dict)
    }
    
    func processImage(_ image: CGImage) throws -> Array2D<UInt8> {
        guard let resizedImage = self.resizeImage(image) else {
            throw ImageProcessingError.imageResizingError
        }
        let orientation: CGImagePropertyOrientation = resizedImage.width > resizedImage.height ? .up : .left
        let grayscale = try self.grayscaleFromCGImage(resizedImage, orientation: orientation)
        return grayscale
    }
    
    func grayscaleFromCGImage(_ cgImage: CGImage, orientation: CGImagePropertyOrientation) throws -> Array2D<UInt8> {
        var colourSpace: Unmanaged<CGColorSpace>
        if cgImage.colorSpace != nil {
            colourSpace = Unmanaged.passRetained(cgImage.colorSpace!)
        } else {
            colourSpace = Unmanaged.passRetained(CGColorSpaceCreateDeviceRGB())
        }
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
        if cgImage.bitsPerPixel == 8 {
            return try self.correctOrientationInImage(&originalBuffer, orientation: orientation)
        }
        let outLength = cgImage.width * cgImage.height
        let outPixels = UnsafeMutablePointer<UInt8>.allocate(capacity: outLength)
        var outputPlanar = vImage_Buffer(data: outPixels, height: vImagePixelCount(cgImage.height), width: vImagePixelCount(cgImage.width), rowBytes: cgImage.width)
        defer {
            outputPlanar.free()
        }
        let divisor: Float = 0x1000
        var matrix: [Int16] = [0,Int16(0.299*divisor),Int16(0.587*divisor),Int16(0.114*divisor)]
        error = vImageMatrixMultiply_ARGB8888ToPlanar8(&originalBuffer, &outputPlanar, &matrix, Int32(divisor), nil, 0, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else {
            throw ImageProcessingError.imageMatrixMultiplyError
        }
        return try self.correctOrientationInImage(&outputPlanar, orientation: orientation)
    }
    
    func correctOrientationInImage(_ image: inout vImage_Buffer, orientation: CGImagePropertyOrientation) throws -> Array2D<UInt8> {
        // Get the vImage rotation constant based on the UI orientation
        let rotation: UInt8
        switch orientation {
        case .right, .rightMirrored:
            rotation = 3
        case .up, .upMirrored:
            rotation = 0
        case .left, .leftMirrored:
            rotation = 1
        case .down, .downMirrored:
            rotation = 2
        }
        let outWidth: UInt
        let outHeight: UInt
        // Flip width and height if the image is rotated 90 or 270 degrees
        if rotation == 1 || rotation == 3 {
            outWidth = UInt(image.height)
            outHeight = UInt(image.width)
        } else {
            outWidth = UInt(image.width)
            outHeight = UInt(image.height)
        }
        // Set the bytes per row for the rotated image
        let outBytesPerRow: Int = Int(outWidth)
        // Calculate the size of the rotated image buffer
        let destSize = outBytesPerRow * Int(outHeight) * MemoryLayout<UInt8>.size
        let rotatedData = UnsafeMutablePointer<UInt8>.allocate(capacity: destSize)
        var outBuffer = vImage_Buffer(data: rotatedData, height: outHeight, width: outWidth, rowBytes: outBytesPerRow)
        defer {
            outBuffer.free()
        }
        guard vImageRotate90_Planar8(&image, &outBuffer, rotation, 0, numericCast(kvImageNoFlags)) == kvImageNoError else {
            throw ImageProcessingError.imageRotationError
        }
        let grayscaleData = Array(UnsafeBufferPointer(start: rotatedData, count: destSize))
        return try Array2D(data: grayscaleData, cols: Int(outWidth), rows: Int(outHeight))
    }
    
    func debugImageFromGrayscaleArray(_ grayscaleArray: Array2D<UInt8>) throws -> UIImage {
        let targetColourSpace = Unmanaged.passUnretained(CGColorSpaceCreateDeviceGray())
        var targetFormat = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 8, colorSpace: targetColourSpace, bitmapInfo: CGBitmapInfo(rawValue: 0), version: 0, decode: nil, renderingIntent: .defaultIntent)
        var input: [UInt8] = grayscaleArray.data
        let grayscalePixels = UnsafeMutablePointer<UInt8>.allocate(capacity: grayscaleArray.data.count)
        grayscalePixels.initialize(from: &input, count: input.count)
        var grayscaleBuffer = vImage_Buffer(data: grayscalePixels, height: vImagePixelCount(grayscaleArray.rows), width: vImagePixelCount(grayscaleArray.cols), rowBytes: grayscaleArray.cols)
        defer {
            grayscaleBuffer.free()
        }
        var error: Int = kvImageNoError
        guard let target = vImageCreateCGImageFromBuffer(&grayscaleBuffer, &targetFormat, nil, nil, numericCast(kvImageNoFlags), &error) else {
            throw ImageProcessingError.cgImageFromBufferError
        }
        return UIImage(cgImage: target.takeRetainedValue())
    }
    
    func resizeImage(_ image: CGImage) -> CGImage? {
        let size: CGSize
        if image.width > image.height {
            size = CGSize(width: self.imageLongerSideLength, height: self.imageShorterSideLength)
        } else {
            size = CGSize(width: self.imageShorterSideLength, height: self.imageLongerSideLength)
        }
        let uiImage = UIImage(cgImage: image)
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        uiImage.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    }
}

enum MoireDetectorError: Int, Error {
    case predictionFailure, failedToInferMultiArrayShape
}
